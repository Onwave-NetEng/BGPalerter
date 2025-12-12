#!/bin/bash
# Manual update script for BGPalerter

set -e

echo "==> Pulling latest GitHub changes..."
git pull

echo "==> Restarting BGPalerter..."
docker compose down
docker compose up -d

echo "==> Update complete."
