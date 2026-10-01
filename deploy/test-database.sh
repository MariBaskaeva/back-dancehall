#!/usr/bin/env bash
# Shared disposable PostgreSQL fixture for Docker smoke tests.
start_test_database() {
  test_database="dancehall-test-postgres-$$"
  test_database_dir="$PWD/target/test-database-$$"
  mkdir -p "$test_database_dir"
  openssl rand -hex 32 > "$test_database_dir/app_password"
  openssl rand -hex 32 > "$test_database_dir/postgres_password"
  cp "$test_database_dir/app_password" "$test_database_dir/spring.datasource.password"
  chmod 0444 "$test_database_dir/"*
  local postgres_image
  postgres_image=$(awk '$1 == "image:" && $2 ~ /^postgres:/ {print $2}' deploy/compose.yaml)
  docker run -d --name "$test_database" --network "$network" --network-alias postgres \
    -e POSTGRES_DB=dancehall -e POSTGRES_USER=postgres \
    -e POSTGRES_PASSWORD_FILE=/run/secrets/postgres_password \
    -v "$test_database_dir:/run/secrets:ro" \
    -v "$PWD/deploy/init-db.sh:/docker-entrypoint-initdb.d/10-dancehall.sh:ro" \
    "$postgres_image" >/dev/null
  for ((attempt=0; attempt<60; attempt++)); do
    if docker exec "$test_database" pg_isready -h 127.0.0.1 -U postgres -d dancehall >/dev/null 2>&1; then
      return 0
    fi
    sleep 2
  done
  docker logs "$test_database" >&2
  return 1
}

stop_test_database() {
  docker rm -fv "${test_database:-dancehall-test-postgres-$$}" >/dev/null 2>&1 || true
  if [[ -n "${test_database_dir:-}" ]]; then
    rm -rf "$test_database_dir"
  fi
}
