#!/usr/bin/env bash
set -euo pipefail

backup=${1:?Provide a PostgreSQL custom-format dump}
[[ -s "$backup" ]] || { echo "Backup does not exist or is empty: $backup" >&2; exit 2; }
cd /opt/dancehall
database="dancehall_restore_check_$(date -u +%s)"
cleanup() {
  docker compose -p dancehall exec -T postgres \
    dropdb --if-exists --force -U postgres "$database" >/dev/null 2>&1 || true
}
trap cleanup EXIT
docker compose -p dancehall exec -T postgres createdb -U postgres "$database"
docker compose -p dancehall exec -T postgres \
  pg_restore -U postgres --dbname "$database" --clean --if-exists < "$backup"
docker compose -p dancehall exec -T postgres \
  psql -U postgres --dbname "$database" --tuples-only --command 'SELECT 1' | grep -q 1
echo "Restore check passed: $backup"
