#!/usr/bin/env bash
set -euo pipefail
NS="${NS:-ofbiz}"
DEP="${DEPLOYMENT:-ofbiz}"
PASS="${DEFAULT_PASS:-password.1}"
OUT="${OUT:-/tmp/xosol_users.groovy}"

echo "Generating Groovy from XOSOL pages..."
pip3 show beautifulsoup4 requests lxml >/dev/null 2>&1 || \
  (echo "Installing Python dependencies (user env)..." && pip3 install --user beautifulsoup4 requests lxml)
scripts/generate_xosol_users.py > "$OUT"

echo "Copying Groovy to the OFBiz pod..."
kubectl -n "$NS" cp "$OUT" "deploy/${DEP}:/tmp/xosol_users.groovy"

echo "Executing Groovy inside OFBiz (password=${PASS})..."
kubectl -n "$NS" exec "deploy/${DEP}" -- \
  bash -lc 'XOSOL_DEFAULT_PASSWORD="'"${PASS}"'" ./gradlew --no-daemon "ofbiz --script=/tmp/xosol_users.groovy"'

echo "✅ Users created/updated. Group: XOSOL_EMPLOYEE. Default password: ${PASS}"
