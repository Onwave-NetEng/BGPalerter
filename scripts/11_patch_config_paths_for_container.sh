#!/usr/bin/env bash
set -euo pipefail

CFG="$HOME/BGPalerter/config/config.yml"

# Backup
cp -a "$CFG" "$CFG.bak.$(date +%Y%m%d-%H%M%S)"

# Use explicit container paths
perl -i -pe '
  s|^\s*-\s*prefixes\.yml\s*$|  - /opt/bgpalerter/prefixes.yml|m;
  s|^\s*groupsFile:\s*groups\.yml\s*$|groupsFile: /opt/bgpalerter/groups.yml|m;
  s|^\s*directory:\s*var/log\s*$|  directory: /opt/bgpalerter/logs|m;
  s|^\s*alertDataDirectory:\s*var/alertdata/\s*$|      alertDataDirectory: /opt/bgpalerter/alertdata/|m;
' "$CFG"

echo "[*] Key lines now:"
grep -nE 'monitoredPrefixesFiles:|/opt/bgpalerter/prefixes.yml|groupsFile:|logging:|directory:|alertDataDirectory:' "$CFG" || true
