#!/usr/bin/env bash
# Tail logs for OFBiz, NiFi, and Superset. Uses tmux if available.
set -euo pipefail

NS="${1:-ofbiz}"
SESSION="${TMUX_SESSION_NAME:-xosol-logs}"

# Resolve pod names for each app (pick first match)
get_pod () {
  local app="$1"
  kubectl get pods -n "$NS" -l "app.kubernetes.io/name=${app}" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true
}

OFBIZ_POD="$(get_pod ofbiz)"
NIFI_POD="$(get_pod nifi)"
SUPERSET_POD="$(get_pod superset)"

if [[ -z "$OFBIZ_POD" && -z "$NIFI_POD" && -z "$SUPERSET_POD" ]]; then
  echo "No pods found in namespace '$NS'. Is the chart deployed?"
  exit 1
fi

echo "Pods:"
echo "  OFBiz:    ${OFBIZ_POD:-<none>}"
echo "  NiFi:     ${NIFI_POD:-<none>}"
echo "  Superset: ${SUPERSET_POD:-<none>}"
echo

if command -v tmux >/dev/null 2>&1; then
  echo "Launching tmux session: $SESSION"
  tmux new-session -d -s "$SESSION" "kubectl -n '$NS' logs -f '$OFBIZ_POD' || read -p 'Press Enter to exit'"
  tmux split-window -h "kubectl -n '$NS' logs -f '$NIFI_POD' || read -p 'Press Enter to exit'"
  tmux split-window -v "kubectl -n '$NS' logs -f '$SUPERSET_POD' || read -p 'Press Enter to exit'"
  tmux select-layout tiled >/dev/null 2>&1 || true
  tmux set-option -g mouse on >/dev/null 2>&1 || true
  tmux attach -t "$SESSION"
  exit 0
fi

echo "tmux not found. Fallback: multiplexed logs in one terminal with prefixes."
echo "Tip: brew install tmux   # for a nicer experience"
echo

# Fallback: run logs with prefixes in the same terminal
prefix_log () {
  local label="$1" pod="$2"
  if [[ -n "$pod" ]]; then
    (kubectl -n "$NS" logs -f "$pod" 2>&1 | sed -e "s/^/[$label] /") &
    echo $! > ".logs_${label}.pid"
  fi
}

prefix_log OFBIZ "$OFBIZ_POD"
prefix_log NIFI "$NIFI_POD"
prefix_log SUPERSET "$SUPERSET_POD"

echo "Press Ctrl+C to stop. PIDs saved as .logs_*.pid"
wait
