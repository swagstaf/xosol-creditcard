#!/usr/bin/env bash
# Stop background logs started by logs.sh fallback mode.
set -euo pipefail
for f in .logs_*.pid; do
  [[ -f "$f" ]] || continue
  pid="$(cat "$f")"
  echo "Killing $f (PID $pid)"
  kill "$pid" 2>/dev/null || true
  rm -f "$f"
done
echo "Done."
