#!/usr/bin/env bash
set -euo pipefail
psql --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" \
  --set=ON_ERROR_STOP=1 --set=app_password="$(cat /run/secrets/app_password)" <<'SQL'
CREATE ROLE dancehall LOGIN PASSWORD :'app_password' NOSUPERUSER NOCREATEDB NOCREATEROLE;
ALTER DATABASE dancehall OWNER TO dancehall;
ALTER SCHEMA public OWNER TO dancehall;
SQL
