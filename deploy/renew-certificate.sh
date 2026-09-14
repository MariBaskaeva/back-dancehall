#!/usr/bin/env bash
set -euo pipefail
cd /opt/dancehall
exec 9>/opt/dancehall/certificate.lock
flock -n 9 || exit 0
docker compose -p dancehall run --rm --no-deps certbot renew --quiet
docker compose -p dancehall exec -T nginx nginx -t
docker compose -p dancehall exec -T nginx nginx -s reload
