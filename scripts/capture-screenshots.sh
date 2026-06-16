#!/bin/bash
# Screenshot capture script for yassen_hamdy deliverables
set -euo pipefail

SCREENSHOT_DIR="$(cd "$(dirname "$0")/.." && pwd)/screenshots"
mkdir -p "$SCREENSHOT_DIR"

capture() {
  local outfile="$1"
  local url="$2"
  echo "  -> $outfile"
  google-chrome --headless --disable-gpu --no-sandbox \
    --window-size=1920,1080 \
    --screenshot="$outfile" \
    --virtual-time-budget=5000 \
    "$url" 2>/dev/null || \
  chromium --headless --disable-gpu --no-sandbox \
    --window-size=1920,1080 \
    --screenshot="$outfile" \
    --virtual-time-budget=5000 \
    "$url" 2>/dev/null || \
  echo "    WARNING: failed to capture $outfile"
}

echo "Capturing full-screen screenshots to $SCREENSHOT_DIR ..."
sleep 3

# 1. Prometheus - Instant Vector: up
capture "$SCREENSHOT_DIR/01_prometheus_instant_vector_up.png" \
  "http://localhost:9090/graph?g0.expr=up&g0.tab=1"

# 2. Prometheus - Instant Vector: memory
capture "$SCREENSHOT_DIR/02_prometheus_instant_vector_memory.png" \
  "http://localhost:9090/graph?g0.expr=node_memory_MemAvailable_bytes&g0.tab=1"

# 3. Prometheus - rate
capture "$SCREENSHOT_DIR/03_prometheus_rate.png" \
  "http://localhost:9090/graph?g0.expr=rate(http_server_requests_seconds_count%5B5m%5D)&g0.tab=0"

# 4. Prometheus - irate
capture "$SCREENSHOT_DIR/04_prometheus_irate.png" \
  "http://localhost:9090/graph?g0.expr=irate(http_server_requests_seconds_count%5B5m%5D)&g0.tab=0"

# 5. Prometheus - Rules (recording rules)
capture "$SCREENSHOT_DIR/05_prometheus_recording_rules.png" \
  "http://localhost:9090/rules"

# 6. Prometheus - Alerts
capture "$SCREENSHOT_DIR/06_prometheus_alerts.png" \
  "http://localhost:9090/alerts"

# 7. Alertmanager
capture "$SCREENSHOT_DIR/07_alertmanager.png" \
  "http://localhost:9093"

# 8. Grafana - Metrics Dashboard
capture "$SCREENSHOT_DIR/08_grafana_metrics_dashboard.png" \
  "http://admin:yassen_hamdy@localhost:3000/d/yassen-hamdy-metrics/yassen-hamdy-metrics-dashboard?orgId=1&kiosk"

# 9. Grafana - Logs Dashboard
capture "$SCREENSHOT_DIR/09_grafana_logs_dashboard.png" \
  "http://admin:yassen_hamdy@localhost:3000/d/yassen-hamdy-logs/yassen-hamdy-logs-dashboard?orgId=1&kiosk"

# 10. Promtail logs (docker)
docker logs yassen_hamdy_promtail --tail 30 > "$SCREENSHOT_DIR/10_promtail_logs.txt" 2>&1 || \
  sudo docker logs yassen_hamdy_promtail --tail 30 > "$SCREENSHOT_DIR/10_promtail_logs.txt" 2>&1 || true

echo ""
echo "Screenshots saved:"
ls -la "$SCREENSHOT_DIR"
