#!/bin/bash
cd "$(dirname "$0")"

echo "Pulling latest config changes from GitHub..."
git pull

echo "Restarting BGPalerter..."
docker compose down
docker compose up -d

echo "Update complete."

chmod +x update-bgpalerter.sh
