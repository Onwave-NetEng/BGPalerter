#!/usr/bin/env bash
set -euo pipefail

CFG="$HOME/BGPalerter/config/config.yml"
cp -a "$CFG" "$CFG.bak.$(date +%Y%m%d-%H%M%S)"

perl -0777 -i -pe '
  # Replace the whole reports section (from "reports:" up to just before "monitoredPrefixesFiles:")
  s/reports:\n.*?\n(?=monitoredPrefixesFiles:)/reports:\n  - file: reportFile\n    channels:\n      - hijack\n      - newprefix\n      - visibility\n      - path\n      - misconfiguration\n      - rpki\n    params:\n      persistAlertData: false\n      alertDataDirectory: \/opt\/bgpalerter\/alertdata\/\n\n  - file: reportEmail\n    channels:\n      - hijack\n      - newprefix\n      - visibility\n      - path\n      - misconfiguration\n      - rpki\n    params:\n      senderEmail: bgpalerter@onwave.com\n      smtp:\n        host: onwave-com.mail.protection.outlook.com\n        port: 25\n        secure: false\n      notifiedEmails:\n        default:\n          - iain.murdoch@onwave.com\n\n  - file: reportSyslog\n    channels:\n      - hijack\n      - newprefix\n      - visibility\n      - path\n      - misconfiguration\n      - rpki\n    params:\n      host: 172.30.250.34\n      port: 514\n      transport: udp\n      templates:\n        default: '\''++BGPalerter-3-${type}: ${summary}|${earliest}|${latest}'\''\n        hijack: '\''++BGPalerter-5-${type}: ${summary}|${prefix}|${description}|${asn}|${newprefix}|${neworigin}|${earliest}|${latest}|${peers}'\''\n        newprefix: '\''++BGPalerter-4-${type}: ${summary}|${prefix}|${description}|${asn}|${newprefix}|${neworigin}|${earliest}|${latest}|${peers}'\''\n        visibility: '\''++BGPalerter-5-${type}: ${summary}|${prefix}|${description}|${asn}|${earliest}|${latest}|${peers}'\''\n        misconfiguration: '\''++BGPalerter-3-${type}: ${summary}|${asn}|${prefix}|${earliest}|${latest}'\''\n        rpki: '\''++BGPalerter-3-${type}: ${summary}|${prefix}|${description}|${asn}|${earliest}|${latest}'\''\n\n/s
' "$CFG"

echo "[*] Validate YAML..."
cd "$HOME/BGPalerter"
yamllint -d .yamllint config/config.yml
echo "[*] OK"
