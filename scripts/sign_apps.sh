#!/usr/bin/env bash
# Ad-hoc sign the included macOS apps locally to appease Gatekeeper.
# Note: This is NOT notarization. On first run, macOS may still prompt.
# Usage: ./scripts/sign_apps.sh

set -euo pipefail

APPS_DIR="$(cd "$(dirname "$0")/../Apps" && pwd)"

if ! command -v codesign >/dev/null 2>&1; then
  echo "codesign not found. Install Xcode command line tools first: xcode-select --install"
  exit 1
fi

apps=(
  "XOSOL Demo Start.app"
  "XOSOL Demo Stop.app"
  "XOSOL Demo Set Repo.app"
)

echo "Removing quarantine attributes (if any)..."
for app in "${apps[@]}"; do
  if [ -e "$APPS_DIR/$app" ]; then
    xattr -r -d com.apple.quarantine "$APPS_DIR/$app" 2>/dev/null || true
  fi
done

echo "Ad-hoc signing apps..."
for app in "${apps[@]}"; do
  if [ -e "$APPS_DIR/$app" ]; then
    echo " -> $app"
    /usr/bin/codesign --force --deep --sign - \
      --verbose=2 \
      "$APPS_DIR/$app"
    /usr/bin/codesign --verify --deep --strict --verbose=2 "$APPS_DIR/$app"
  else
    echo "Skipping missing app: $app"
  fi
done

echo "Gatekeeper assessment:"
for app in "${apps[@]}"; do
  if [ -e "$APPS_DIR/$app" ]; then
    spctl --assess --type execute -v "$APPS_DIR/$app" || true
  fi
done

echo "Done. If Launchpad still blocks the first run, right-click → Open once."
