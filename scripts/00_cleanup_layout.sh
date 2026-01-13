#!/usr/bin/env bash
set -euo pipefail

BASE="$HOME/BGPalerter"
CFG="$BASE/config"

echo "[*] Sanity check"
test -d "$BASE" || { echo "Missing $BASE"; exit 1; }
test -d "$CFG"  || { echo "Missing $CFG"; exit 1; }

echo "[*] Backup current config (timestamped)"
ts="$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BASE/backup/$ts"
cp -a "$CFG"/*.yml "$BASE/backup/$ts/" 2>/dev/null || true

echo "[*] Create standard runtime dirs"
mkdir -p "$BASE/var/log" "$BASE/var/alertdata" "$BASE/var/cache"

echo "[*] Fix permissions (ensure net-eng owns runtime dirs)"
chown -R "$(id -u)":"$(id -g)" "$BASE/var"

echo "[*] If repo-root logs/ is root-owned, stop using it (leave it in place but ensure it won't be written)"
if [ -d "$BASE/logs" ]; then
  echo "    Found $BASE/logs (owner: $(stat -c '%U:%G' "$BASE/logs"))"
  echo "    Leaving it as-is. We'll switch BGPalerter to use $BASE/var/log instead."
fi

echo "[*] Update config.yml paths to use var/"
CONFIG_YML="$CFG/config.yml"
if [ ! -f "$CONFIG_YML" ]; then
  echo "Missing $CONFIG_YML"
  exit 1
fi

# Replace reportFile alertDataDirectory
# Replace logging.directory
# These sed patterns assume the keys exist.
sed -i \
  -e 's|^\(\s*alertDataDirectory:\s*\).*|\1var/alertdata/|g' \
  -e 's|^\(\s*directory:\s*\).*|\1var/log|g' \
  "$CONFIG_YML"

echo "[*] Show resulting key lines"
grep -nE 'alertDataDirectory:|logging:|directory:' "$CONFIG_YML" || true

echo "[*] Done."
echo "    Config backup: $BASE/backup/$ts/"
