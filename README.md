# XOSOL Credit Card Reconciliation Demo

This repository contains a deployable demo for international credit-card reconciliation using an all–open-source stack:
- Apache **OFBiz** (ERP + GL)
- Apache **NiFi** (ingest & flows)
- Apache **Spark** (reconciliation + classification)
- **PostgreSQL** (staging & recon tables)
- Apache **Superset** (dashboards)
- **Helm** chart to deploy on Kubernetes (Minikube with Podman on Apple Silicon).

## Quick start
```bash
# 1) Build OFBiz image with Podman (Apple Silicon)
./scripts/build_ofbiz_podman.sh

# 2) Start Minikube on Podman and enable ingress (optional)
./scripts/setup_podman_minikube.sh

# 3) Load the image into Minikube and deploy the stack
./scripts/deploy_helm.sh
```

## Layout
- `ofbiz-recon-demo/` — Helm chart (OFBiz, Postgres, NiFi, Spark, Superset)
- `scripts/` — helper scripts to build, start Minikube, and deploy
- `values-local.yaml` — resource-tuned values for a 16‑GB MacBook Pro
