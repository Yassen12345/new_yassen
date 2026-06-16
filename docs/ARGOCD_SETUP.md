# ArgoCD Setup — yassen hamdy

## Prerequisites

- Kubernetes cluster running
- ArgoCD installed in `argocd` namespace
- Docker image pushed to Docker Hub

## 1. Create ArgoCD Project

The project `yassen-hamdy-project` allows deploying all resources to the `yassen_hamdy` namespace.

```bash
kubectl apply -f argocd/project.yaml
```

**Project configuration:**
- **Name:** `yassen-hamdy-project`
- **Allowed destination:** namespace `yassen_hamdy` on in-cluster server
- **Source repos:** all (`*`)
- **Resources:** all kinds allowed in namespace

## 2. Create ArgoCD Application

Before applying, update `argocd/application.yaml`:
- Replace `YOUR_GITHUB_USERNAME` with your actual GitHub username

```bash
kubectl apply -f argocd/application.yaml
```

**Application configuration:**
- **Name:** `yassen-hamdy-demo1`
- **Project:** `yassen-hamdy-project`
- **Source path:** `yassen_hamdy/` in your GitHub repo
- **Destination namespace:** `yassen_hamdy`
- **Auto-sync:** enabled
- **Self-heal:** enabled
- **Prune:** enabled

## 3. Kubernetes Manifests (yassen_hamdy folder)

| File              | Description                                    |
|-------------------|------------------------------------------------|
| `namespace.yaml`  | Creates `yassen_hamdy` namespace               |
| `deployment.yaml` | 2 replicas, image from Docker Hub, health probes |
| `service.yaml`    | NodePort service on port **30090**             |

## 4. Verify Deployment

```bash
# Check ArgoCD app status
argocd app get yassen-hamdy-demo1

# Or via kubectl
kubectl get application yassen-hamdy-demo1 -n argocd

# Check deployed resources
kubectl get all -n yassen_hamdy

# Access app via NodePort
curl http://<node-ip>:30090/persons
```

## 5. ArgoCD UI Screenshot Checklist

Take full-screen screenshots of:
1. **Projects** → `yassen-hamdy-project` showing namespace restriction
2. **Applications** → `yassen-hamdy-demo1` showing **Synced** status
3. **Application details** → Sync Policy showing **Auto-Sync** and **Self Heal** enabled
4. **Resource tree** showing Deployment + Service

## Sync Policy Details

```yaml
syncPolicy:
  automated:
    prune: true        # Remove resources not in Git
    selfHeal: true     # Revert manual changes
    allowEmpty: false
  syncOptions:
    - CreateNamespace=true
```

- **Auto-sync:** ArgoCD automatically syncs when Git changes
- **Self-heal:** If someone manually changes K8s resources, ArgoCD reverts to Git state
- **Prune:** Resources deleted from Git are removed from cluster
