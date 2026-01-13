#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/BGPalerter"

echo "=== [1] docker compose ps ==="
docker compose ps || true
echo

echo "=== [2] docker compose logs (tail 120) ==="
docker compose logs --tail=120 || true
echo

echo "=== [3] port mapping for 8011 ==="
docker compose port bgpalerter 8011 || true
echo

# Try common cases for status endpoint:
#  - host port 8011
#  - if docker compose port returns something else, try that too
echo "=== [4] REST status checks ==="
set +e
echo "--- curl http://127.0.0.1:8011/status"
curl -sS -m 3 -w "\nHTTP %{http_code}\n" http://127.0.0.1:8011/status | head -c 2000
echo
set -e

# If bgpalerter container exists, try status from inside container too
echo "=== [5] status from inside container (if possible) ==="
set +e
docker compose exec bgpalerter sh -lc 'wget -qO- -T 3 http://127.0.0.1:8011/status || true'
echo
set -e

echo "=== [6] config files visible inside container (if possible) ==="
set +e
docker compose exec bgpalerter sh -lc 'ls -la /app/config 2>/dev/null || ls -la /config 2>/dev/null || true'
echo
set -e

echo "=== [7] host-side runtime dirs ==="
ls -la "$HOME/BGPalerter/var" || true
echo "--- var/log:"
ls -la "$HOME/BGPalerter/var/log" || true
echo
