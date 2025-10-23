# XOSOL Credit Card Reconciliation Demo

An open-source demonstration showing international credit-card reconciliation using:
- Apache **OFBiz** (ERP)
- Apache **NiFi** (ETL/flows)
- Apache **Spark** (reconciliation/classification)
- **PostgreSQL** (staging & recon tables)
- Apache **Superset** (dashboards)
- **Helm** (Kubernetes deployment)
- **Podman + Minikube** (local Kubernetes on Apple Silicon)

---

## 🔧 Install Homebrew (macOS)

If you don't have Homebrew yet, install it with:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Then add brew to your PATH (Apple Silicon):
```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
brew --version
```

> On Intel macOS, Homebrew's prefix is usually `/usr/local` instead of `/opt/homebrew`.

---

## 📦 Install Podman & Kubernetes tools (via Homebrew)

```bash
brew install podman minikube kubectl helm
```

Initialize the Podman VM and start a Minikube cluster that uses Podman as its driver (resource sizes are tuned for a 16‑GB MacBook Pro):

```bash
podman machine init --cpus 4 --memory 8192 || true
podman machine start

minikube start --driver=podman --cpus=4 --memory=11264
kubectl get nodes
```

(Optional) enable Ingress:
```bash
minikube addons enable ingress
```

---

## 🚢 Build the OFBiz image (Apple Silicon, Podman)

```bash
./scripts/build_ofbiz_podman.sh
```

This builds an image `ofbiz-test:demo` suitable for local use.

---

## ☸️ Deploy the stack to Kubernetes

```bash
# Load the image into Minikube’s container runtime
minikube image load ofbiz-test:demo

# Install the Helm chart with local-friendly values
kubectl create namespace ofbiz || true
helm install ofbiz-recon-demo ./ofbiz-recon-demo -n ofbiz -f values-local.yaml

# Watch pods
kubectl get pods -n ofbiz -w
```

Load demo data (creates `admin/ofbiz`):
```bash
kubectl exec -n ofbiz deploy/ofbiz --   bash -lc "./gradlew --no-daemon 'ofbiz --load-data readers=seed,seed-initial,demo'"
```

Port-forward UIs:
```bash
kubectl port-forward -n ofbiz svc/ofbiz 8443:8443    # https://localhost:8443/partymgr
kubectl port-forward -n ofbiz svc/nifi 8080:8080     # http://localhost:8080/nifi
kubectl port-forward -n ofbiz svc/superset 8088:8088 # http://localhost:8088
```

---

## 🧰 Helper scripts

- `scripts/install_brew.sh` — installs Homebrew (if missing) and configures your shell.
- `scripts/install_podman_k8s_brew.sh` — installs Podman/Minikube/kubectl/Helm using brew; initializes Podman VM and starts Minikube.
- `scripts/build_ofbiz_podman.sh` — clones and builds an Apple‑Silicon friendly OFBiz image (skips tests for speed).
- `scripts/setup_podman_minikube.sh` — starts/initializes Podman VM and Minikube (driver=podman).
- `scripts/deploy_helm.sh` — loads the local image into Minikube and installs the Helm chart.

End-to-end bootstrap:
```bash
./scripts/install_brew.sh           # if you don't have Homebrew yet
./scripts/install_podman_k8s_brew.sh
./scripts/build_ofbiz_podman.sh
./scripts/deploy_helm.sh
```

---

## 📁 Repo layout

- `ofbiz-recon-demo/` — Helm chart (OFBiz, Postgres, NiFi, Spark, Superset)
- `values-local.yaml` — resource tuning for a 16‑GB MacBook Pro
- `scripts/` — helper scripts
