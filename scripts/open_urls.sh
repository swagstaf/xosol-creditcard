#!/usr/bin/env bash
# Open local URLs for OFBiz, NiFi, and Superset if their ports are reachable.
set -euo pipefail

GREEN="\033[1;32m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

check_port () {
  local host="$1" port="$2" label="$3"
  # Use bash's /dev/tcp if available
  if (exec 3<>/dev/tcp/$host/$port) >/dev/null 2>&1; then
    exec 3<&-
    exec 3>&-
    echo -e "${GREEN}✅ ${label}:${NC} $host:$port reachable"
    return 0
  else
    echo -e "${YELLOW}⚠️  ${label}:${NC} $host:$port not reachable. Is port-forward running?"
    return 1
  fi
}

open_url () {
  if command -v open >/dev/null 2>&1; then
    open "$1"
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$1"
  else
    echo "Open this in your browser: $1"
  fi
}

ok=0
check_port localhost 8443 "OFBiz" || ok=1
check_port localhost 8080 "NiFi" || ok=1
check_port localhost 8088 "Superset" || ok=1

if [[ $ok -ne 0 ]]; then
  echo -e "${RED}Some ports are not reachable. Run: make port-forward${NC}"
fi

open_url "https://localhost:8443/partymgr"
open_url "http://localhost:8080/nifi"
open_url "http://localhost:8088"
