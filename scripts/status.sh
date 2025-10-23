#!/usr/bin/env bash
# Status dashboard for the XOSOL credit card demo.
# - Shows Podman VM, Minikube, K8s nodes/pods/svcs, and helpful port-forward hints.
set -euo pipefail

NS="${1:-ofbiz}"

echo "=== Podman machine ==="
podman machine list || true
echo

echo "=== Minikube status ==="
minikube status || true
echo

echo "=== kubectl context ==="
kubectl config current-context || true
echo

echo "=== K8s nodes ==="
kubectl get nodes -o wide || true
echo

echo "=== Namespace: ${NS} (pods) ==="
kubectl get pods -n "${NS}" -o wide || true
echo

echo "=== Namespace: ${NS} (services) ==="
kubectl get svc -n "${NS}" || true
echo

cat <<'EOT'

Helpful port-forward commands:
  # OFBiz (login: admin / ofbiz)
  kubectl port-forward -n ofbiz svc/ofbiz 8443:8443

  # NiFi
  kubectl port-forward -n ofbiz svc/nifi 8080:8080

  # Superset
  kubectl port-forward -n ofbiz svc/superset 8088:8088

EOT
