#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MONITORING_DIR="$PROJECT_DIR/monitoring"

docker_cmd() {
  if docker info >/dev/null 2>&1; then
    docker "$@"
  elif sudo docker info >/dev/null 2>&1; then
    sudo docker "$@"
  else
    echo ""
    echo "ERROR: Docker permission denied."
    echo "Run this first:  bash scripts/fix-docker.sh"
    echo "Then run:        bash scripts/setup.sh"
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

echo "========================================="
echo "  yassen hamdy - Project Setup"
echo "========================================="

# Step 1: Build Java application
echo "[1/6] Building Java Maven application..."
cd "$PROJECT_DIR"
mvn clean package -DskipTests -B
echo "  JAR built: target/demo1-0.0.1-SNAPSHOT.jar"

# Step 2: Setup monitoring environment
echo "[2/6] Setting up monitoring environment..."
if [ ! -f "$MONITORING_DIR/.env" ]; then
  cp "$MONITORING_DIR/.env.example" "$MONITORING_DIR/.env"
  echo "  Created monitoring/.env - UPDATE SMTP_PASSWORD before starting!"
fi

# Step 3: Check Docker access
echo "[3/6] Checking Docker access..."
if ! docker_cmd info >/dev/null 2>&1; then
  exit 1
fi
echo "  Docker OK"

# Step 4: Start monitoring stack
echo "[4/6] Starting monitoring stack (Docker Compose)..."
cd "$MONITORING_DIR"
compose_cmd up -d --build
echo "  Waiting for services to be ready..."
for i in $(seq 1 30); do
  if curl -sf http://localhost:9090/-/ready >/dev/null 2>&1; then
    echo "  Prometheus ready after ${i}x2s"
    break
  fi
  sleep 2
done
sleep 5

# Step 5: Generate traffic for metrics
echo "[5/6] Generating sample traffic..."
for i in $(seq 1 15); do
  curl -s http://localhost:8090/persons > /dev/null 2>&1 || true
  curl -s http://localhost:8090/actuator/prometheus > /dev/null 2>&1 || true
done

# Step 6: Capture screenshots
echo "[6/6] Capturing screenshots..."
bash "$PROJECT_DIR/scripts/capture-screenshots.sh" || echo "  Screenshot capture skipped (Chrome may not be available)"

echo ""
echo "========================================="
echo "  Setup Complete - yassen hamdy"
echo "========================================="
echo ""
compose_cmd ps
echo ""
echo "Services:"
echo "  Prometheus:    http://localhost:9090"
echo "  Alertmanager:  http://localhost:9093"
echo "  Grafana:       http://localhost:3000  (admin / yassen_hamdy)"
echo "  Demo1 App:     http://localhost:8090"
echo ""
echo "Screenshots:     $PROJECT_DIR/screenshots/"
