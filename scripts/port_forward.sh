#!/usr/bin/env bash
# Start port-forwards for OFBiz, NiFi, and Superset, then open them in the default browser.
# Creates a .pfwd directory with PID files so we can stop them later.
set -euo pipefail

NS="${1:-ofbiz}"
PFDIR="${PFDIR:-.pfwd}"
mkdir -p "$PFDIR"

echo "Starting port-forwards in background (namespace: $NS)..."

start_pf () {
  local name="$1" svc="$2" lport="$3" rport="$4"
  local log="$PFDIR/${name}.log"
  local pidf="$PFDIR/${name}.pid"
  if [[ -f "$pidf" ]] && ps -p "$(cat "$pidf")" >/dev/null 2>&1; then
    echo "  - $name already running (PID $(cat "$pidf"))"
    return 0
  fi
  echo "  - $name: $lport -> $svc:$rport"
  (kubectl port-forward -n "$NS" "svc/${svc}" "${lport}:${rport}" >"$log" 2>&1 & echo $! > "$pidf") || true
  # small wait for port-forward to initialize
  sleep 2
}

start_pf "ofbiz" "ofbiz" "8443" "8443"
start_pf "nifi" "nifi" "8080" "8080"
start_pf "superset" "superset" "8088" "8088"

# Open URLs (macOS 'open', else xdg-open if present)
open_url () {
  if command -v open >/dev/null 2>&1; then
    open "$1"
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$1"
  else
    echo "Open: $1"
  fi
}

echo "Opening browser tabs..."
open_url "https://localhost:8443/partymgr"
open_url "http://localhost:8080/nifi"
open_url "http://localhost:8088"

echo "Port-forwards running. Logs in $PFDIR/*.log, PIDs in $PFDIR/*.pid"

# Run health check automatically
"$(dirname "$0")/health_check.sh"
