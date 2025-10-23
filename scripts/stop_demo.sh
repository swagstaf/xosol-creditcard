#!/usr/bin/env bash
# Stop the XOSOL demo stack WITHOUT deleting the Helm release (so you can start again quickly).
# - Scales deployments to zero to free resources
# - Stops Minikube and Podman VM (optional flags)
set -euo pipefail

NS="${1:-ofbiz}"
STOP_MINIKUBE="${STOP_MINIKUBE:-true}"
STOP_PODMAN="${STOP_PODMAN:-false}"

if command -v kubectl >/dev/null 2>&1; then
  echo "Scaling deployments in namespace ${NS} to 0..."
  kubectl -n "${NS}" get deploy -o name 2>/dev/null | xargs -I{} kubectl -n "${NS}" scale {} --replicas=0 || true
fi

if [ "${STOP_MINIKUBE}" = "true" ] && command -v minikube >/dev/null 2>&1; then
  echo "Stopping Minikube..."
  minikube stop || true
fi

if [ "${STOP_PODMAN}" = "true" ] && command -v podman >/dev/null 2>&1; then
  echo "Stopping Podman machine..."
  podman machine stop || true
fi

echo "Done. To fully remove resources, run: ./scripts/destroy_all.sh"
