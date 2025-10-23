#!/usr/bin/env bash
# Load OFBiz demo data (creates admin/ofbiz) into the running pod.
set -euo pipefail

NS="${1:-ofbiz}"

echo "Looking for OFBiz deployment in namespace: $NS"
if ! kubectl -n "$NS" get deploy ofbiz >/dev/null 2>&1; then
  echo "OFBiz deployment not found in namespace '$NS'. Ensure the chart is deployed."
  exit 1
fi

echo "Loading demo data..."
kubectl exec -n "$NS" deploy/ofbiz -- \
  bash -lc "./gradlew --no-daemon 'ofbiz --load-data readers=seed,seed-initial,demo'"

echo "Done. Admin user: admin / ofbiz"
