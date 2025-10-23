#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$HERE/.." && pwd)"
ICON_DIR="$ROOT_DIR/icons"
APPS_DIR="$ROOT_DIR/Apps"

make_icns () { # $1: png base name (without extension), $2: app bundle name
  base="$1"
  app="$2"
  work="/tmp/${base}.iconset"
  rm -rf "$work"; mkdir -p "$work"
  sips -s format png "$ICON_DIR/${base}.png" --out "$work/icon_1024x1024.png" >/dev/null
  sips -Z 512 "$work/icon_1024x1024.png" --out "$work/icon_512x512.png" >/dev/null
  sips -Z 256 "$work/icon_1024x1024.png" --out "$work/icon_256x256.png" >/dev/null
  sips -Z 128 "$work/icon_1024x1024.png" --out "$work/icon_128x128.png" >/dev/null
  sips -Z 64  "$work/icon_1024x1024.png" --out "$work/icon_64x64.png" >/dev/null
  sips -Z 32  "$work/icon_1024x1024.png" --out "$work/icon_32x32.png" >/dev/null
  iconutil -c icns "$work" -o "$ICON_DIR/${base}.icns"
  # Copy into app bundle
  cp "$ICON_DIR/${base}.icns" "$APPS_DIR/${app}/Contents/Resources/${base}.icns"
  # Touch the app to refresh Finder
  touch "$APPS_DIR/${app}"
}

echo "Building ICNS and injecting into app bundles..."
make_icns "xosol-start" "XOSOL Demo Start.app"
make_icns "xosol-stop"  "XOSOL Demo Stop.app"

echo "Done. If icons don't update in Launchpad immediately, try: killall Dock"
