#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
minikube image load ofbiz-test:demo
kubectl create ns ofbiz || true
helm install ofbiz-recon-demo ./ofbiz-recon-demo -n ofbiz -f values-local.yaml
echo "Waiting for pods in namespace 'ofbiz'..."
kubectl get pods -n ofbiz -w
echo
echo "When OFBiz is running, load demo data:"
echo "kubectl exec -n ofbiz deploy/ofbiz -- bash -lc "./gradlew --no-daemon 'ofbiz --load-data readers=seed,seed-initial,demo'""
