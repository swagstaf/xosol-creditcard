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


---

## 🚀 One-click bootstrap

Run everything end-to-end with a single command:
```bash
./scripts/run_all.sh
```
This will install Homebrew (if needed), install Podman/Minikube/kubectl/Helm, build the OFBiz image, start the cluster, deploy the Helm chart, and print the final next steps (demo data load + port-forwards).


---

## 🧹 Teardown
Clean up everything (Helm release, namespace, Minikube, Podman VM):
```bash
./scripts/destroy_all.sh
```


---

## 📊 Status
Check cluster, nodes, pods, and services at a glance (default namespace `ofbiz`, or pass another namespace):
```bash
./scripts/status.sh [namespace]
```


---

## 🖱️ Mac Launchpad Apps (Start/Stop)
You can create macOS apps that appear in Launchpad and run the demo start/stop scripts.

### Option A — Automator Applications (no extra tools)
1. Open **Automator** → **New Document** → choose **Application**.
2. Add **"Run Shell Script"**.
3. Set **Shell** to `/bin/zsh` and **Pass input** to `to stdin`.
4. Paste this for **Start**:
   ```bash
   cd "$HOME/Projects/xosol-creditcard"
   ./scripts/start_demo.sh
   ```
   Save as **`XOSOL Demo Start.app`** in `~/Applications` (create the folder if it doesn't exist).

5. Repeat for **Stop**:
   ```bash
   cd "$HOME/Projects/xosol-creditcard"
   STOP_MINIKUBE=true STOP_PODMAN=false ./scripts/stop_demo.sh
   ```
   Save as **`XOSOL Demo Stop.app`** in `~/Applications`.

6. Launchpad will show both apps. You can also drag them to the Dock.

### Option B — AppleScript Applications (Script Editor)
Open **Script Editor**, create a new document, set **Language: AppleScript**, paste:

**Start app:**
```applescript
tell application "Terminal"
  activate
  do script "cd ~/Projects/xosol-creditcard && ./scripts/start_demo.sh"
end tell
```
Save as **Application** named `XOSOL Demo Start.app` into `~/Applications`.

**Stop app:**
```applescript
tell application "Terminal"
  activate
  do script "cd ~/Projects/xosol-creditcard && STOP_MINIKUBE=true STOP_PODMAN=false ./scripts/stop_demo.sh"
end tell
```
Save as **Application** named `XOSOL Demo Stop.app` into `~/Applications`.

> Tip: If macOS Gatekeeper blocks the app, right-click → **Open** the first time.

### Which should I use?
- **Automator** runs the shell directly (no Terminal window).
- **AppleScript** opens a Terminal window so you can see logs.

---

## ▶️ Quick commands
```bash
./scripts/start_demo.sh   # fast start (idempotent)
./scripts/stop_demo.sh    # stop (keeps Helm release)
./scripts/destroy_all.sh  # full teardown
```


---

## 🎨 App Icons (Launchpad)
Icon PNGs are included in `icons/`:
- `xosol-start.png`
- `xosol-stop.png`

### Convert PNG → ICNS (macOS)
On macOS you can convert to `.icns` using built‑in tools:
```bash
mkdir -p /tmp/XOSOLStart.iconset /tmp/XOSOLStop.iconset
sips -s format png icons/xosol-start.png --out /tmp/XOSOLStart.iconset/icon_1024x1024.png
sips -Z 512 /tmp/XOSOLStart.iconset/icon_1024x1024.png --out /tmp/XOSOLStart.iconset/icon_512x512.png
sips -Z 256 /tmp/XOSOLStart.iconset/icon_1024x1024.png --out /tmp/XOSOLStart.iconset/icon_256x256.png
sips -Z 128 /tmp/XOSOLStart.iconset/icon_1024x1024.png --out /tmp/XOSOLStart.iconset/icon_128x128.png
sips -Z 32  /tmp/XOSOLStart.iconset/icon_1024x1024.png --out /tmp/XOSOLStart.iconset/icon_32x32.png
iconutil -c icns /tmp/XOSOLStart.iconset -o icons/xosol-start.icns

sips -s format png icons/xosol-stop.png --out /tmp/XOSOLStop.iconset/icon_1024x1024.png
sips -Z 512 /tmp/XOSOLStop.iconset/icon_1024x1024.png --out /tmp/XOSOLStop.iconset/icon_512x512.png
sips -Z 256 /tmp/XOSOLStop.iconset/icon_1024x1024.png --out /tmp/XOSOLStop.iconset/icon_256x256.png
sips -Z 128 /tmp/XOSOLStop.iconset/icon_1024x1024.png --out /tmp/XOSOLStop.iconset/icon_128x128.png
sips -Z 32  /tmp/XOSOLStop.iconset/icon_1024x1024.png --out /tmp/XOSOLStop.iconset/icon_32x32.png
iconutil -c icns /tmp/XOSOLStop.iconset -o icons/xosol-stop.icns
```

### Apply a custom icon to your app
1. Open Finder → `~/Applications`
2. Select `XOSOL Demo Start.app` (or Stop) → **Cmd+I** (Get Info)
3. Drag `icons/xosol-start.icns` (or `xosol-stop.icns`) onto the small icon in the Get Info window’s top-left corner.
   If it doesn’t stick, open the `.icns` in Preview, `Cmd+A` → `Cmd+C`, click the small icon, `Cmd+V`.

> Note: On first run, macOS Gatekeeper may prompt. Right‑click → **Open** to approve.


---

## 🧰 macOS App Bundles (Launchpad-ready)
We ship two app bundles ready to drop into Launchpad:
- `Apps/XOSOL Demo Start.app`
- `Apps/XOSOL Demo Stop.app`

These open Terminal and run the repo scripts. By default they expect the repo at `~/Projects/xosol-creditcard`.
If your path is different, edit the launcher inside the app:
- `Apps/XOSOL Demo Start.app/Contents/MacOS/start-demo`
- `Apps/XOSOL Demo Stop.app/Contents/MacOS/stop-demo`

### Icons
We include PNG icons and a helper to generate proper `.icns` and inject them into the apps:
```bash
./scripts/make_icons.sh
```
After running, you’ll have:
- `icons/xosol-start.icns` and `icons/xosol-stop.icns` copied into each app bundle.
If Launchpad doesn’t refresh, run `killall Dock`.

### Install apps
Drag both apps from `Apps/` into `~/Applications` (create it if missing). They’ll appear in Launchpad automatically.


---

## 🧭 Auto-detect Repo Path (First Run)
The included macOS apps now prompt you with a **folder picker** on first run if the repository path is unknown.
Your selection is saved to `~/.xosol_repo_path` and reused automatically thereafter.
To change it later, delete that file or edit its contents.


---

## 🧭 Set/Change Repo Path App
We include a helper app to set or change the repository path used by the Start/Stop apps:

- `Apps/XOSOL Demo Set Repo.app`

Use it if you move the project or keep it somewhere other than `~/Projects/xosol-creditcard`.
It will write your selection to `~/.xosol_repo_path`.


---

## 🔏 Local ad‑hoc signing (macOS)
To reduce Gatekeeper warnings, you can **ad‑hoc sign** the included apps locally (this is not notarization).
Requirements: **Xcode Command Line Tools** → `xcode-select --install`

```bash
# from the repo root
./scripts/sign_apps.sh
```

The script will:
- remove the quarantine flag from the app bundles,
- run `codesign --deep --sign -` on each app,
- verify signatures and print a Gatekeeper assessment.

On first launch you may still need to right‑click → **Open** to approve.
