#!/bin/zsh
set -euo pipefail

echo "== Restart OpenClaw Team =="
/Users/yachen/ai-team-hub/stop-all.sh || true
sleep 2
/Users/yachen/ai-team-hub/start-all.sh
