# Prometheus Query Examples — yassen hamdy

This document covers all Prometheus query types required for the project deliverables.

---

## 1. Instant Vector Examples (2)

An **instant vector** is a set of time series containing a single sample per series, all sharing the same timestamp (the query evaluation time). It represents the **current value** at a single point in time.

### Example 1: `up`

**Query:**
```promql
up
```

**Explanation:**
- `up` is a built-in metric that equals `1` if the target is healthy (scraped successfully) and `0` if it is down.
- Returns an **instant vector** — one value per target at the current moment.
- Each result has labels: `job`, `instance`.

**Expected output:**
```
up{instance="node-exporter:9100", job="node_exporter"} 1
up{instance="demo1-app:8090", job="demo1_app"} 1
up{instance="localhost:9090", job="prometheus"} 1
```

**Use case:** Quick health check — which scrape targets are currently reachable.

**How to test:**
1. Open Prometheus UI → http://localhost:9090
2. Go to **Graph** tab
3. Enter `up` and click **Execute**
4. Switch to **Table** view to see instant vector results

---

### Example 2: `node_memory_MemAvailable_bytes`

**Query:**
```promql
node_memory_MemAvailable_bytes
```

**Explanation:**
- Returns the amount of RAM (in bytes) currently available for new applications **right now**.
- This is a **counter-like gauge** scraped from node_exporter — returns current memory state as an instant vector.
- One series per `instance` label.

**Expected output:**
```
node_memory_MemAvailable_bytes{instance="node-exporter:9100", job="node_exporter"} 3.421e+09
```

**Use case:** Monitor current available memory on a server without any time-range function.

**How to test:**
1. Prometheus UI → Graph
2. Enter `node_memory_MemAvailable_bytes`
3. Click **Execute** → Table view shows current bytes available

---

## 2. Rate Example (1)

### `rate(http_server_requests_seconds_count[5m])`

**Query:**
```promql
rate(http_server_requests_seconds_count[5m])
```

**Explanation:**
- `rate()` calculates the **per-second average rate of increase** of a counter over a given time range (`[5m]` = last 5 minutes).
- It handles counter resets (e.g., pod restarts) automatically.
- Returns a range vector internally, but when used in a query it produces an instant vector of rates.
- **Smooths out spikes** — good for alerting and dashboards.

**Difference from raw counter:**
- Raw counter: `http_server_requests_seconds_count` → total requests since app start (always increasing)
- With rate: requests **per second** over the last 5 minutes

**Use case:** "How many HTTP requests per second is my app handling on average?"

**How to test:**
1. Generate traffic: `curl http://localhost:8090/persons` (repeat several times)
2. Prometheus UI → Graph → enter the query above
3. View as **Graph** to see the rate over time

---

## 3. Irate Example (1)

### `irate(http_server_requests_seconds_count[5m])`

**Query:**
```promql
irate(http_server_requests_seconds_count[5m])
```

**Explanation:**
- `irate()` calculates the **instantaneous rate** using only the **last two data points** within the range window.
- More sensitive to sudden spikes than `rate()`.
- Does NOT smooth — shows sharp changes immediately.
- Best for detecting **sudden bursts** of activity.

**rate() vs irate() comparison:**

| Feature          | `rate()`                    | `irate()`                   |
|------------------|-----------------------------|-----------------------------|
| Data points used | All points in range         | Last 2 points only          |
| Smoothing        | Yes (averaged)              | No (instant)                |
| Best for         | Alerts, dashboards          | Spike detection, debugging  |
| Sensitivity      | Low (stable)                | High (reactive)             |

**Use case:** "Did my app just get a sudden burst of requests in the last scrape interval?"

**How to test:**
1. Prometheus UI → Graph
2. Add both queries on the same graph:
   - `rate(http_server_requests_seconds_count[5m])`
   - `irate(http_server_requests_seconds_count[5m])`
3. Generate burst traffic and observe `irate` spikes higher than `rate`

---

## 4. Recording Rule (1)

**File:** `monitoring/prometheus/rules/recording_rules.yml`

```yaml
- record: job:http_requests:rate5m
  expr: sum(rate(http_server_requests_seconds_count[5m])) by (job)
```

**Explanation:**
- A **recording rule** pre-computes a query and stores the result as a new time series.
- Naming convention: `level:metric:operations` → `job:http_requests:rate5m`
- `sum(...) by (job)` aggregates request rate per job.
- Benefits:
  - Faster dashboard queries (pre-computed)
  - Reusable in alerts without repeating complex expressions
  - Reduces load on Prometheus for frequently-used queries

**How to verify:**
1. Prometheus UI → **Status → Rules**
2. Look for group `yassen_hamdy_recording_rules`
3. Query the recorded metric: `job:http_requests:rate5m`

---

## 5. Alert Rule (1)

**File:** `monitoring/prometheus/rules/alert_rules.yml`

```yaml
- alert: HighCPUUsage
  expr: instance:node_cpu_usage:percent > 80
  for: 2m
  labels:
    severity: warning
    owner: yassen_hamdy
  annotations:
    summary: "High CPU usage on {{ $labels.instance }}"
    description: "CPU usage is {{ $value | printf \"%.2f\" }}% on {{ $labels.instance }}."
```

**Explanation:**
- Fires when CPU usage (from recording rule) exceeds **80%** for **2 minutes** continuously.
- `for: 2m` prevents flapping — alert only fires if condition is true for 2 full minutes.
- Labels (`severity`, `owner`) are attached for routing in Alertmanager.
- Annotations provide human-readable messages sent in emails.

**Alert flow:**
```
Prometheus (evaluates rule every 15s)
    → Alert fires after 2m threshold
    → Sent to Alertmanager (port 9093)
    → Alertmanager routes to email receiver
    → Email sent to yassen.hamdy@gmail.com
```

**How to verify:**
1. Prometheus UI → **Alerts** tab → see `HighCPUUsage` state
2. Alertmanager UI → http://localhost:9093 → see active alerts
3. Check email inbox for alert notification

---

## Quick Reference — All Queries

| Type            | Query                                                      | Purpose                    |
|-----------------|------------------------------------------------------------|----------------------------|
| Instant Vector  | `up`                                                       | Target health check        |
| Instant Vector  | `node_memory_MemAvailable_bytes`                           | Current free memory        |
| Rate            | `rate(http_server_requests_seconds_count[5m])`             | Avg requests/sec (5m)      |
| Irate           | `irate(http_server_requests_seconds_count[5m])`            | Instant requests/sec       |
| Recording Rule  | `job:http_requests:rate5m`                                 | Pre-computed request rate  |
| Alert Rule      | `instance:node_cpu_usage:percent > 80`                     | High CPU alert             |
