#!/usr/bin/env bash
# Health check for local port-forwarded services with color output.
set -euo pipefail

GREEN="\033[1;32m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
NC="\033[0m"

echo -e "${BLUE}🌐 Checking service readiness...${NC}"

# url, label, insecure?
check_url () {
  local url="$1"
  local label="$2"
  local insecure="${3:-false}"
  local tries=10
  local delay=2
  local ok=1

  for i in $(seq 1 $tries); do
    if [[ "$insecure" == "true" ]]; then
      if curl -sk --max-time 3 "$url" >/dev/null 2>&1; then ok=0; break; fi
    else
      if curl -s --max-time 3 "$url" >/dev/null 2>&1; then ok=0; break; fi
    fi
    sleep "$delay"
  done

  if [[ $ok -eq 0 ]]; then
    echo -e "${GREEN}✅ ${label}:${NC} ${url} is ready"
    return 0
  else
    echo -e "${RED}❌ ${label}:${NC} ${url} did not respond after $((tries*delay))s"
    return 1
  fi
}

fail=0
check_url "https://localhost:8443/partymgr" "OFBiz" true || fail=1
check_url "http://localhost:8080/nifi" "NiFi" false || fail=1
check_url "http://localhost:8088" "Superset" false || fail=1

if [[ $fail -eq 0 ]]; then
  echo -e "${GREEN}All services are ready! 🚀${NC}"
else
  echo -e "${YELLOW}Some services failed readiness. Tips:${NC}"
  echo " - Ensure pods are Ready: kubectl get pods -n ofbiz"
  echo " - View logs: kubectl logs -n ofbiz deploy/ofbiz --tail=200"
  echo " - Port-forward logs are in .pfwd/*.log"
  exit 1
fi
