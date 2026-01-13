#!/usr/bin/env bash
set -euo pipefail
CFG="$HOME/BGPalerter/config/config.yml"
cp -a "$CFG" "$CFG.bak.$(date +%Y%m%d-%H%M%S)"

# Remove mistaken "-     params:" list items
perl -i -pe 's/^\s*-\s+params:\s*$/    params:/;' "$CFG"

# Indent keys that must be children of params:
perl -i -pe '
  s/^(\s*)persistAlertData:/$1  persistAlertData:/;
  s/^(\s*)alertDataDirectory:/$1  alertDataDirectory:/;
  s/^(\s*)senderEmail:/$1  senderEmail:/;
' "$CFG"

echo "[*] Validate YAML..."
cd "$HOME/BGPalerter"
yamllint -d .yamllint config/config.yml
echo "[*] OK"
