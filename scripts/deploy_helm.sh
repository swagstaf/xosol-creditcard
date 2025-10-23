#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
# Load image into Minikube CRI
minikube image load ofbiz-test:demo
kubectl create ns ofbiz || true
helm install ofbiz-recon-demo ./ofbiz-recon-demo -n ofbiz -f values-local.yaml
echo "Waiting for pods..."
kubectl get pods -n ofbiz -w
echo "Load demo data (admin/ofbiz login) when OFBiz is running:"
echo "kubectl exec -n ofbiz deploy/ofbiz -- bash -lc "./gradlew --no-daemon 'ofbiz --load-data readers=seed,seed-initial,demo'""
