#!/bin/bash
# Runs only on first Postgres init (primary).
# Creates the replication user and opens pg_hba for streaming replication.
set -e

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" <<-SQL
  DO \$\$
  BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '${REPL_USER}') THEN
      CREATE ROLE ${REPL_USER} LOGIN REPLICATION PASSWORD '${REPL_PASSWORD}';
    END IF;
  END \$\$;
SQL

echo "host replication ${REPL_USER} 0.0.0.0/0 scram-sha-256" >> "$PGDATA/pg_hba.conf"
pg_ctl reload -D "$PGDATA"
