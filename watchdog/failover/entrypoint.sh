#!/bin/bash
set -euo pipefail

# Build SSH config so Ansible can reach both VPS nodes from inside the container.
# Keys are mounted by docker compose at /root/.ssh/{primary,standby}_key.
cat > /root/.ssh/config <<'EOF'
Host *
  StrictHostKeyChecking accept-new
  UserKnownHostsFile /root/.ssh/known_hosts
  IdentityFile /root/.ssh/primary_key
  IdentityFile /root/.ssh/standby_key
EOF

chmod 600 /root/.ssh/config

exec python -u /failover.py
