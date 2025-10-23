#!/usr/bin/env bash
# Teardown for the XOSOL credit card demo.
# - Uninstalls the Helm release
# - Deletes the namespace
# - Stops Minikube
# - Stops Podman machine
set -euo pipefail

RELEASE="ofbiz-recon-demo"
NAMESPACE="ofbiz"

echo "==> Uninstalling Helm release: ${RELEASE} (namespace: ${NAMESPACE})"
helm uninstall "${RELEASE}" -n "${NAMESPACE}" || echo "Helm release not found or already removed."

echo "==> Deleting namespace: ${NAMESPACE}"
kubectl delete ns "${NAMESPACE}" --ignore-not-found

echo "==> Stopping Minikube"
minikube stop || true

echo "==> Stopping Podman machine"
podman machine stop || true

echo "Teardown complete."
