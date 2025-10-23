# XOSOL Credit Card Demo - Makefile convenience targets

SHELL := /bin/bash
REPO_ROOT := $(shell pwd)

.PHONY: help up start stop down status brew-install k8s-install build deploy icons sign apps-install apps-open-setrepo

help:
	@echo "Common targets:"
	@echo "  make up              - One-click bootstrap (brew + podman/k8s + build + deploy)"
	@echo "  make start           - Start/upgrade the Helm release (idempotent)"
	@echo "  make stop            - Stop workloads (scale to 0) [keeps release]"
	@echo "  make down            - Full teardown (Helm uninstall + ns delete + stop minikube/podman)"
	@echo "  make status          - Show cluster/nodes/pods/services and port-forward hints"
	@echo "  make brew-install    - Install Homebrew (if missing)"
	@echo "  make k8s-install     - Install Podman/Minikube/kubectl/Helm and start cluster"
	@echo "  make build           - Build OFBiz image with Podman (Apple Silicon)"
	@echo "  make deploy          - Load image into Minikube and install Helm chart"
	@echo "  make icons           - Build .icns and inject into macOS apps"
	@echo "  make sign            - Ad-hoc sign macOS apps (codesign)"
	@echo "  make apps-install    - Copy app bundles to ~/Applications"
	@echo "  make apps-open-setrepo - Launch 'Set Repo' helper app"

up:
	./scripts/run_all.sh

start:
	./scripts/start_demo.sh

stop:
	./scripts/stop_demo.sh

down:
	./scripts/destroy_all.sh

status:
	./scripts/status.sh

brew-install:
	./scripts/install_brew.sh

k8s-install:
	./scripts/install_podman_k8s_brew.sh

build:
	./scripts/build_ofbiz_podman.sh

deploy:
	./scripts/deploy_helm.sh

icons:
	./scripts/make_icons.sh

sign:
	./scripts/sign_apps.sh

apps-install:
	mkdir -p $$HOME/Applications
	cp -R Apps/XOSOL\ Demo\ Start.app $$HOME/Applications/ || true
	cp -R Apps/XOSOL\ Demo\ Stop.app $$HOME/Applications/ || true
	cp -R Apps/XOSOL\ Demo\ Set\ Repo.app $$HOME/Applications/ || true
	@echo "Apps copied to $$HOME/Applications. They should appear in Launchpad."

apps-open-setrepo:
	open Apps/XOSOL\ Demo\ Set\ Repo.app

port-forward:
	./scripts/port_forward.sh

port-forward-stop:
	./scripts/port_forward_stop.sh

health:
	./scripts/health_check.sh

demo-data:
	./scripts/load_demo_data.sh

ofbiz-admin:
	./scripts/ofbiz_admin_creds.sh

open:
	./scripts/open_urls.sh

logs:
	./scripts/logs.sh

logs-stop:
	./scripts/logs_stop.sh

clean-images:
	./scripts/clean_images.sh
