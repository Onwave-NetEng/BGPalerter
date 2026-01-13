#!/usr/bin/env bash
set -euo pipefail

FILES=(
  "$HOME/BGPalerter/config/groups.yml"
  "$HOME/BGPalerter/config/config.yml"
  "$HOME/BGPalerter/config/prefixes.yml"
)

echo "[*] Removing trailing whitespace..."
for f in "${FILES[@]}"; do
  [ -f "$f" ] || continue
  sed -i 's/[[:space:]]\+$//' "$f"
done

echo "[*] Removing extra blank lines at end of groups.yml..."
# Remove trailing blank lines at EOF (groups.yml specifically)
perl -0777 -i -pe 's/\n+\z/\n/s' "$HOME/BGPalerter/config/groups.yml"

echo "[*] Done. Re-running yamllint..."
cd "$HOME/BGPalerter"
./validate.sh || true
yamllint -d .yamllint config/config.yml config/prefixes.yml config/groups.yml
