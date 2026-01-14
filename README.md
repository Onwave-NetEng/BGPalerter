# Onwave BGPalerter (AS58173)

This repository contains the minimal configuration and Docker Compose deployment to run **BGPalerter**
for **AS58173 (Onwave UK Ltd)**, with optional forwarding to a central ELK stack.

## What it monitors

Channels:
- hijack
- newprefix
- visibility
- path
- misconfiguration (ASN monitor)
- rpki
- roa

Prefixes are defined in `config/prefixes.yml`. Groups/ASNs are defined in `config/groups.yml`.

## Repository structure

.
+-- docker-compose.yml
+-- config/
¦   +-- config.yml
¦   +-- prefixes.yml
¦   +-- groups.yml
¦   +-- irr.yml
¦   +-- rpki.yml
¦   +-- subs.yml
+-- scripts/
¦   +-- 00_cleanup_layout.sh
¦   +-- 01_fix_yamllint_style.sh
¦   +-- 10_bgpalerter_diagnostics.sh
¦   +-- 11_patch_config_paths_for_container.sh
¦   +-- 12_fix_reportSyslog_block.sh
¦   +-- 13_fix_params_indentation.sh
¦   +-- 14_repair_reports_section.sh
¦   +-- 30_pin_bgpalerter_image.sh
¦   +-- 31_enable_monitorROAS.sh
+-- validate.sh
+-- .yamllint
+-- .gitignore

## Server prerequisites (target host)

Required:
- Ubuntu 20.04+ recommended
- Docker Engine
- Docker Compose plugin (`docker compose`)
- git
- (optional) jq

Optional (for central logging / dashboards):
- Filebeat on the BGPalerter host

Network:
- Outbound to RIPE RIS Live: `ris-live.ripe.net` (ws/wss)
- If using Syslog report: outbound to syslog receiver (default UDP/514)
- If using Filebeat to Logstash: outbound TCP/5044 to Logstash

## Deployment from private GitHub repo

1) Clone:
```bash
git clone git@github.com:Onwave-NetEng/BGPalerter.git
cd BGPalerter

