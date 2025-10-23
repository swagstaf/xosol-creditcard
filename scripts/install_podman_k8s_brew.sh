#!/usr/bin/env bash
set -euo pipefail

# Ensure Homebrew exists
if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew not found. Run ./scripts/install_brew.sh first."
  exit 1
fi

echo "Installing Podman, Minikube, kubectl, Helm..."
brew install podman minikube kubectl helm

echo "Initializing Podman VM (arm64)"
podman machine init --cpus 4 --memory 8192 || true
podman machine start

echo "Starting Minikube with Podman driver"
minikube start --driver=podman --cpus=4 --memory=11264

echo "Cluster info:"
kubectl get nodes -o wide
