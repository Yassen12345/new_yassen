# yassen hamdy - Project Setup & Deliverables

**Author:** yassen hamdy  
**Namespace:** `yassen_hamdy`  
**Environment:** `yassen_hamdy`

---

## Project Structure

```
new_app_yassen/
├── .github/workflows/
│   └── production-cicd.yml      # GitHub Actions CI/CD pipeline
├── argocd/
│   ├── project.yaml               # ArgoCD project
│   └── application.yaml           # ArgoCD application (auto-sync + self-heal)
├── monitoring/
│   ├── docker-compose.yml         # Full monitoring stack
│   ├── prometheus/
│   │   ├── prometheus.yml
│   │   └── rules/
│   │       ├── recording_rules.yml
│   │       └── alert_rules.yml
│   ├── alertmanager/
│   │   └── alertmanager.yml
│   ├── grafana/
│   │   ├── dashboards/
│   │   │   ├── metrics-dashboard.json
│   │   │   └── logs-dashboard.json
│   │   └── provisioning/
│   ├── loki/loki.yml
│   ├── promtail/promtail.yml
│   └── logs/                      # 3 log paths for Promtail
│       ├── app/
│       ├── access/
│       └── error/
├── yassen_hamdy/
│   ├── namespace.yaml
│   ├── deployment.yaml
│   └── service.yaml               # NodePort 30090
├── docs/
│   └── PROMETHEUS_EXAMPLES.md
├── Dockerfile
├── pom.xml
└── src/
```

---

## Quick Start

### Fix Docker Permission (run once if you see "permission denied")

```bash
bash scripts/fix-docker.sh    # enter your sudo password
newgrp docker                 # activate docker group (no logout needed)
```

### Start Everything + Screenshots

```bash
bash scripts/setup.sh
```

**Or** if you prefer sudo without changing groups:

```bash
bash scripts/start-monitoring.sh   # uses sudo automatically
bash scripts/capture-screenshots.sh
```

### Manual start (alternative)

```bash
cd monitoring
sudo docker-compose up -d --build
bash ../scripts/capture-screenshots.sh
```

| Service       | URL                          | Credentials        |
|---------------|------------------------------|--------------------|
| Prometheus    | http://localhost:9090        | -                  |
| Alertmanager  | http://localhost:9093        | -                  |
| Grafana       | http://localhost:3000        | admin / yassen_hamdy |
| Loki          | http://localhost:3100        | -                  |
| Demo1 App     | http://localhost:8090        | -                  |

### 2. Build Java Application

```bash
mvn clean package -DskipTests
docker build -t yassenhamdy/demo1:latest .
```

### 3. Deploy to Kubernetes via ArgoCD

```bash
kubectl apply -f yassen_hamdy/namespace.yaml
kubectl apply -f argocd/project.yaml
kubectl apply -f argocd/application.yaml
```

### 4. GitHub Actions Setup

1. Create environment `yassen_hamdy` in GitHub repo settings
2. Add secrets to the environment:
   - `DOCKER_USERNAME` — your Docker Hub username
   - `DOCKER_PASSWORD` — your Docker Hub password/token
   - `CD_REPO_TOKEN` — GitHub PAT with repo write access to CD repo
3. Run workflow manually: **Actions → Production CI/CD - yassen_hamdy → Run workflow**

---

## Deliverables Checklist

| # | Deliverable                              | Location                                      | Status |
|---|------------------------------------------|-----------------------------------------------|--------|
| 1 | 2 Instant Vector examples + explanation  | `docs/PROMETHEUS_EXAMPLES.md`                 | ✅     |
| 2 | 1 rate + 1 irate example + explanation   | `docs/PROMETHEUS_EXAMPLES.md`                 | ✅     |
| 3 | 1 Recording Rule                         | `monitoring/prometheus/rules/recording_rules.yml` | ✅ |
| 4 | 1 Alert Rule                             | `monitoring/prometheus/rules/alert_rules.yml` | ✅     |
| 5 | Email alert via Alertmanager             | `monitoring/alertmanager/alertmanager.yml`  | ✅     |
| 6 | Grafana Metrics Dashboard                | `monitoring/grafana/dashboards/metrics-dashboard.json` | ✅ |
| 6 | Grafana Logs Dashboard                   | `monitoring/grafana/dashboards/logs-dashboard.json` | ✅ |
| 7 | Promtail with 3 log paths                | `monitoring/promtail/promtail.yml`            | ✅     |
| 8 | GitHub Actions CI/CD pipeline            | `.github/workflows/production-cicd.yml`     | ✅     |
| 9 | ArgoCD Project + Application             | `argocd/project.yaml`, `argocd/application.yaml` | ✅ |

---

## Screenshot Guide

Take **full-screen screenshots** of each item below for submission:

1. **Prometheus → Graph** — run instant vector queries `up` and `node_memory_MemAvailable_bytes`
2. **Prometheus → Graph** — run `rate(...)` and `irate(...)` queries
3. **Prometheus → Status → Rules** — show recording rules loaded
4. **Prometheus → Alerts** — show firing/pending alerts
5. **Alertmanager → Alerts** — show alert routed to email receiver
6. **Email inbox** — show received alert email
7. **Grafana → yassen_hamdy - Metrics Dashboard** — full dashboard
8. **Grafana → yassen_hamdy - Logs Dashboard** — full dashboard
9. **Promtail** — `docker logs yassen_hamdy_promtail` showing 3 paths
10. **GitHub Actions** — workflow run summary
11. **ArgoCD UI** — project + app synced with auto-sync enabled

---

## Configuration Notes

### Alertmanager Email

Edit `monitoring/alertmanager/alertmanager.yml`:
- Replace `yassen.hamdy.alert@gmail.com` with your sender Gmail
- Replace `yassen.hamdy@gmail.com` with your recipient email
- Set `SMTP_PASSWORD` env var (Gmail App Password)

### ArgoCD Application

Update `argocd/application.yaml`:
- Replace `YOUR_GITHUB_USERNAME` with your actual GitHub username

### Docker Hub Image

Default image: `yassenhamdy/demo1:latest`  
Update in `yassen_hamdy/deployment.yaml` to match your Docker Hub username.
