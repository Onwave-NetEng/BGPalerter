#!/usr/bin/env bash
set -euo pipefail
CFG="$HOME/BGPalerter/config/config.yml"
cp -a "$CFG" "$CFG.bak.$(date +%Y%m%d-%H%M%S)"

# Remove any existing reportSyslog block (best-effort, based on indentation)
perl -0777 -i -pe '
  s/\n\s*-\s*file:\s*reportSyslog\b.*?\n(?=\s*-\s*file:|\s*[A-Za-z_]+\s*:|\z)//s
' "$CFG"

# Insert a clean syslog block immediately after "reports:" line
perl -0777 -i -pe '
  s/(reports:\n)/$1  - file: reportSyslog\n    channels:\n      - hijack\n      - newprefix\n      - visibility\n      - path\n      - misconfiguration\n      - rpki\n      - roa\n    params:\n      host: 172.30.250.34\n      port: 514\n      transport: udp\n      templates:\n        default: '\''++BGPalerter-3-${type}: ${summary}|${earliest}|${latest}'\''\n        hijack: '\''++BGPalerter-5-${type}: ${summary}|${prefix}|${description}|${asn}|${newprefix}|${neworigin}|${earliest}|${latest}|${peers}'\''\n        newprefix: '\''++BGPalerter-4-${type}: ${summary}|${prefix}|${description}|${asn}|${newprefix}|${neworigin}|${earliest}|${latest}|${peers}'\''\n        visibility: '\''++BGPalerter-5-${type}: ${summary}|${prefix}|${description}|${asn}|${earliest}|${latest}|${peers}'\''\n        misconfiguration: '\''++BGPalerter-3-${type}: ${summary}|${asn}|${prefix}|${earliest}|${latest}'\''\n        rpki: '\''++BGPalerter-3-${type}: ${summary}|${prefix}|${description}|${asn}|${earliest}|${latest}'\''\n        roa: '\''++BGPalerter-3-${type}: ${summary}|${prefix}|${description}|${asn}|${earliest}|${latest}'\''\n\n/s
' "$CFG"

echo "[*] Done. Validate YAML..."
cd "$HOME/BGPalerter"
yamllint -d .yamllint config/config.yml
