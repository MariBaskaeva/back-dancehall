#!/usr/bin/env bash
set -euo pipefail
umask 077
cd /opt/dancehall
exec 9>/opt/dancehall/backup.lock
flock -n 9 || exit 0
backup="/opt/dancehall/backups/dancehall-$(date -u +%Y%m%dT%H%M%SZ).dump"
trap 'rm -f "$backup.tmp"' EXIT
docker compose -p dancehall exec -T postgres pg_dump -U postgres -d dancehall -Fc > "$backup.tmp"
[[ -s "$backup.tmp" ]]
mv "$backup.tmp" "$backup"
find /opt/dancehall/backups -maxdepth 1 -type f -name 'dancehall-*.dump' -mtime +6 -delete
printf 'Backup created: %s\n' "$backup"
