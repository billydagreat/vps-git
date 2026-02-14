#!/usr/bin/env python3
"""
Watchdog that monitors the primary Forgejo instance and triggers
automatic failover via Ansible when it detects sustained downtime.
"""

import os
import subprocess
import time
import logging

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [watchdog] %(levelname)s %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
log = logging.getLogger(__name__)

HEALTH_URL = os.environ["PRIMARY_HEALTH_URL"]
CHECK_INTERVAL = int(os.environ.get("CHECK_INTERVAL", 30))
FAIL_THRESHOLD = int(os.environ.get("FAIL_THRESHOLD", 3))
PLAYBOOK = os.environ.get("ANSIBLE_PLAYBOOK", "/ansible/promote.yml")
INVENTORY = os.environ.get("ANSIBLE_INVENTORY", "/ansible/inventory.yml")
COOLDOWN_SEC = int(os.environ.get("COOLDOWN_SEC", 3600))

consecutive_failures = 0
last_failover: float = 0


def check_health() -> bool:
    try:
        import requests
        r = requests.get(HEALTH_URL, timeout=10)
        return r.status_code == 200
    except Exception as e:
        log.warning("Health check failed: %s", e)
        return False


def trigger_failover():
    global last_failover

    elapsed = time.time() - last_failover
    if last_failover > 0 and elapsed < COOLDOWN_SEC:
        log.warning("Cooldown active (%ds left). Skipping.", int(COOLDOWN_SEC - elapsed))
        return

    log.critical("*** TRIGGERING FAILOVER ***")
    log.info("Running ansible-playbook -i %s %s", INVENTORY, PLAYBOOK)

    try:
        result = subprocess.run(
            [
                "ansible-playbook",
                "-i", INVENTORY,
                PLAYBOOK,
            ],
            capture_output=True,
            text=True,
            timeout=300,
        )
        log.info("stdout:\n%s", result.stdout)
        if result.returncode != 0:
            log.error("stderr:\n%s", result.stderr)
            log.error("Playbook failed (exit %d).", result.returncode)
        else:
            log.info("Failover completed successfully.")
            last_failover = time.time()
    except subprocess.TimeoutExpired:
        log.error("Playbook timed out (300s).")
    except Exception as e:
        log.error("Ansible error: %s", e)


def main():
    global consecutive_failures

    log.info("Watchdog starting")
    log.info("  target:    %s", HEALTH_URL)
    log.info("  interval:  %ds", CHECK_INTERVAL)
    log.info("  threshold: %d failures", FAIL_THRESHOLD)
    log.info("  cooldown:  %ds", COOLDOWN_SEC)

    while True:
        if check_health():
            if consecutive_failures > 0:
                log.info("Primary recovered after %d failure(s).", consecutive_failures)
            consecutive_failures = 0
        else:
            consecutive_failures += 1
            log.warning("FAIL %d/%d", consecutive_failures, FAIL_THRESHOLD)
            if consecutive_failures >= FAIL_THRESHOLD:
                trigger_failover()
                consecutive_failures = 0

        time.sleep(CHECK_INTERVAL)


if __name__ == "__main__":
    main()
