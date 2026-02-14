#!/bin/bash
set -euo pipefail

INTERVAL="${BACKUP_INTERVAL:-900}"
BACKUP_DIR="/backups"

log() { echo "$(date '+%F %T') [backup] $*"; }

mkdir -p /root/.ssh
chmod 700 /root/.ssh
echo "StrictHostKeyChecking accept-new" > /root/.ssh/config
chmod 600 /root/.ssh/config 2>/dev/null || true

log "Starting backup loop (interval: ${INTERVAL}s)"

while true; do
  TS=$(date '+%Y%m%d-%H%M%S')

  # Postgres dump
  log "pg_dump starting..."
  DUMP="${BACKUP_DIR}/pg-${TS}.sql.gz"
  pg_dump | gzip > "$DUMP"
  log "pg_dump done: $(du -h "$DUMP" | cut -f1)"

  # Prune old dumps (keep last 48)
  ls -1t "${BACKUP_DIR}"/pg-*.sql.gz 2>/dev/null | tail -n +49 | xargs -r rm -f

  # Rsync to peer if configured
  if [[ -n "${PEER_HOST:-}" ]] && [[ -f /root/.ssh/id_key ]] && [[ -s /root/.ssh/id_key ]]; then
    SSH="ssh -i /root/.ssh/id_key -o ConnectTimeout=15"

    log "Syncing forgejo data to ${PEER_HOST}..."
    rsync -az --delete -e "$SSH" /data/forgejo/ "root@${PEER_HOST}:/opt/vps-git/backups/forgejo/" 2>&1 \
      && log "Forgejo sync done." \
      || log "WARN: forgejo sync failed."

    log "Syncing pg dump to ${PEER_HOST}..."
    rsync -az -e "$SSH" "$DUMP" "root@${PEER_HOST}:/opt/vps-git/backups/pg-latest.sql.gz" 2>&1 \
      && log "PG dump sync done." \
      || log "WARN: pg dump sync failed."
  else
    log "No peer configured or no SSH key. Local backup only."
  fi

  sleep "$INTERVAL"
done
