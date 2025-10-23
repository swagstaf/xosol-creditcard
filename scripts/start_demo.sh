#!/usr/bin/env bash
# Start the XOSOL demo stack without reinstalling.
# - Starts Podman VM if needed
# - Starts Minikube (driver=podman)
# - Installs (or upgrades) Helm release
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

RELEASE="ofbiz-recon-demo"
NS="ofbiz"

# Ensure brew tools exist
for cmd in podman minikube kubectl helm; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing $cmd. Run ./scripts/install_podman_k8s_brew.sh first."
    exit 1
  fi
done

# Start Podman VM
podman machine start >/dev/null 2>&1 || true

# Start Minikube with resource profile (idempotent)
minikube status >/dev/null 2>&1 || minikube start --driver=podman --cpus=4 --memory=11264

# Namespace
kubectl get ns "$NS" >/dev/null 2>&1 || kubectl create ns "$NS"

# If release exists, upgrade; else install
if helm status "$RELEASE" -n "$NS" >/dev/null 2>&1; then
  echo "Upgrading Helm release $RELEASE in namespace $NS..."
  helm upgrade "$RELEASE" ./ofbiz-recon-demo -n "$NS" -f values-local.yaml
else
  echo "Installing Helm release $RELEASE in namespace $NS..."
  helm install "$RELEASE" ./ofbiz-recon-demo -n "$NS" -f values-local.yaml
fi

echo "Waiting for pods..."
kubectl get pods -n "$NS"
echo
echo "If first run, load demo users with:"
echo "kubectl exec -n $NS deploy/ofbiz -- bash -lc "./gradlew --no-daemon 'ofbiz --load-data readers=seed,seed-initial,demo'""
echo
echo "Port-forwarding tips:"
echo "kubectl port-forward -n $NS svc/ofbiz 8443:8443"
echo "kubectl port-forward -n $NS svc/nifi 8080:8080"
echo "kubectl port-forward -n $NS svc/superset 8088:8088"
