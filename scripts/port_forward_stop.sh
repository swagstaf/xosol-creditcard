#!/usr/bin/env bash
# Stop port-forwards started by port_forward.sh by reading PID files in .pfwd
set -euo pipefail

PFDIR="${PFDIR:-.pfwd}"

stop_pf () {
  local name="$1"
  local pidf="$PFDIR/${name}.pid"
  if [[ -f "$pidf" ]]; then
    local pid="$(cat "$pidf")"
    if ps -p "$pid" >/dev/null 2>&1; then
      echo "Killing $name (PID $pid)"
      kill "$pid" || true
    fi
    rm -f "$pidf"
  else
    echo "No PID file for $name ($pidf)"
  fi
}

stop_pf "ofbiz"
stop_pf "nifi"
stop_pf "superset"
echo "Done."
