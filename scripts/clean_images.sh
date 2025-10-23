#!/usr/bin/env bash
# Remove local demo images from Podman and Minikube cache.
set -euo pipefail

IMAGE="${1:-ofbiz-test:demo}"

echo "Target image: $IMAGE"

# Remove from Podman (host)
if command -v podman >/dev/null 2>&1; then
  echo "Removing from Podman (if present)..."
  podman images --format "{{.Repository}}:{{.Tag}}" | grep -q "^${IMAGE}$" && podman rmi -f "${IMAGE}" || echo "Podman: image not found."
  echo "Podman dangling prune (optional)..."
  podman image prune -f || true
else:
  echo "Podman not found, skipping host removal."
fi

# Remove from Minikube’s container runtime cache
if command -v minikube >/dev/null 2>&1; then
  echo "Removing from Minikube cache (if present)..."
  # Try both docker and containerd image registries used by Minikube
  minikube image rm "${IMAGE}" || true
  # For older versions or alternative runtimes, try cache delete
  minikube cache delete "${IMAGE}" 2>/dev/null || true
else
  echo "Minikube not found, skipping cluster cache removal."
fi

echo "Done."
