#!/bin/bash
set -euo pipefail

echo "Applying yassen_hamdy Kubernetes manifests..."
kubectl apply -f yassen_hamdy/namespace.yaml
kubectl apply -f yassen_hamdy/deployment.yaml
kubectl apply -f yassen_hamdy/service.yaml

echo ""
echo "Applying ArgoCD project and application..."
kubectl apply -f argocd/project.yaml
kubectl apply -f argocd/application.yaml

echo ""
echo "ArgoCD Application status:"
kubectl get application yassen-hamdy-demo1 -n argocd 2>/dev/null || echo "ArgoCD not installed yet"

echo ""
echo "Kubernetes resources in yassen_hamdy namespace:"
kubectl get all -n yassen_hamdy
