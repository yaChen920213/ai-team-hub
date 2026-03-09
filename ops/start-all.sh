#!/bin/zsh
set -euo pipefail

echo "== Start OpenClaw Team =="
launchctl load ~/Library/LaunchAgents/ai.openclaw.gateway.plist 2>/dev/null || true
launchctl load ~/Library/LaunchAgents/ai.openclaw.gateway.visual.plist 2>/dev/null || true
launchctl load ~/Library/LaunchAgents/ai.openclaw.gateway.copy.plist 2>/dev/null || true
launchctl load ~/Library/LaunchAgents/ai.openclaw.gateway.lens.plist 2>/dev/null || true
sleep 3
/Users/yachen/ai-team-hub/healthcheck-all.sh
