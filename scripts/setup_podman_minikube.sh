#!/usr/bin/env bash
set -euo pipefail
podman machine init --cpus 4 --memory 8192 || true
podman machine start
minikube start --driver=podman --cpus=4 --memory=11264
# Optional ingress:
# minikube addons enable ingress
