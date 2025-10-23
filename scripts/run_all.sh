#!/usr/bin/env bash
# One-click bootstrap for the XOSOL credit card demo on a 16GB Apple Silicon Mac.
# - Installs Homebrew (if missing)
# - Installs Podman, Minikube, kubectl, Helm
# - Initializes Podman VM and starts Minikube (driver=podman)
# - Builds OFBiz image (Apple Silicon-friendly)
# - Loads image into Minikube and deploys the Helm chart
# - Prints port-forward commands and demo data load step
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "==> 1/6 Installing Homebrew (if needed)"
./scripts/install_brew.sh || true

echo "==> 2/6 Installing Podman + K8s tools via brew"
./scripts/install_podman_k8s_brew.sh

echo "==> 3/6 Building OFBiz image (ofbiz-test:demo)"
./scripts/build_ofbiz_podman.sh

echo "==> 4/6 Loading image into Minikube and deploying Helm chart"
./scripts/deploy_helm.sh &

# Brief wait so we can give the user next steps
sleep 5

cat <<'EONEXT'

=== Next Steps ===
1) Watch the pods come up in another terminal:
   kubectl get pods -n ofbiz -w

2) When the OFBiz pod is Ready, load demo data to create the admin user:
   kubectl exec -n ofbiz deploy/ofbiz --      bash -lc "./gradlew --no-daemon 'ofbiz --load-data readers=seed,seed-initial,demo'"

3) Port-forward UIs:
   # OFBiz (login: admin / ofbiz)
   kubectl port-forward -n ofbiz svc/ofbiz 8443:8443

   # NiFi
   kubectl port-forward -n ofbiz svc/nifi 8080:8080

   # Superset
   kubectl port-forward -n ofbiz svc/superset 8088:8088

EONEXT

wait
