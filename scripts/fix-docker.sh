#!/bin/bash
# Fix Docker permission denied error for user pc
set -euo pipefail

echo "=== Fixing Docker permissions for yassen_hamdy ==="

if docker info >/dev/null 2>&1; then
  echo "Docker already works. No fix needed."
  exit 0
fi

echo "Adding user '$USER' to docker group..."
sudo usermod -aG docker "$USER"

echo "Ensuring Docker service is running..."
sudo systemctl enable docker
sudo systemctl start docker

echo ""
echo "Docker group updated. Apply it now with ONE of these options:"
echo ""
echo "  Option A (recommended): run this, then re-run setup"
echo "    newgrp docker"
echo "    bash scripts/setup.sh"
echo ""
echo "  Option B: log out and log back in, then run:"
echo "    bash scripts/setup.sh"
echo ""
echo "  Option C: use sudo directly (no logout needed):"
echo "    bash scripts/start-monitoring.sh"
