#!/bin/bash
# Start monitoring stack only (handles Docker permission fallback)
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MONITORING_DIR="$PROJECT_DIR/monitoring"

docker_cmd() {
  if docker info >/dev/null 2>&1; then
    docker "$@"
  elif sudo docker info >/dev/null 2>&1; then
    sudo docker "$@"
  else
    echo "ERROR: Cannot access Docker."
    echo "Run: bash scripts/fix-docker.sh"
    exit 1
  fi
}

compose_cmd() {
  if docker info >/dev/null 2>&1; then
    if docker compose version >/dev/null 2>&1; then
      docker compose "$@"
    else
      docker-compose "$@"
    fi
  elif sudo docker info >/dev/null 2>&1; then
    if sudo docker compose version >/dev/null 2>&1; then
      sudo docker compose "$@"
    else
      sudo docker-compose "$@"
    fi
  else
    echo "ERROR: Cannot access Docker. Run: bash scripts/fix-docker.sh"
    exit 1
  fi
}

echo "[1/4] Preparing environment..."
if [ ! -f "$MONITORING_DIR/.env" ]; then
  cp "$MONITORING_DIR/.env.example" "$MONITORING_DIR/.env"
fi

echo "[2/4] Pulling images and starting services..."
cd "$MONITORING_DIR"
compose_cmd up -d --build

echo "[3/4] Waiting for services to become healthy..."
for i in $(seq 1 30); do
  if curl -sf http://localhost:9090/-/ready >/dev/null 2>&1 && \
     curl -sf http://localhost:3000/api/health >/dev/null 2>&1; then
    echo "  Services ready after ${i}s"
    break
  fi
  sleep 2
done

echo "[4/4] Generating sample traffic..."
for i in $(seq 1 15); do
  curl -s http://localhost:8090/persons >/dev/null 2>&1 || true
  curl -s http://localhost:8090/actuator/prometheus >/dev/null 2>&1 || true
done

echo ""
echo "=== All services running ==="
compose_cmd ps
echo ""
echo "  Prometheus:    http://localhost:9090"
echo "  Alertmanager:  http://localhost:9093"
echo "  Grafana:       http://localhost:3000  (admin / yassen_hamdy)"
echo "  Demo1 App:     http://localhost:8090"
echo ""
echo "Take screenshots: bash scripts/capture-screenshots.sh"
