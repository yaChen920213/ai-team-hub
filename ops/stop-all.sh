#!/bin/zsh
set -euo pipefail

echo "== Stop OpenClaw Team =="
launchctl unload ~/Library/LaunchAgents/ai.openclaw.gateway.lens.plist 2>/dev/null || true
launchctl unload ~/Library/LaunchAgents/ai.openclaw.gateway.copy.plist 2>/dev/null || true
launchctl unload ~/Library/LaunchAgents/ai.openclaw.gateway.visual.plist 2>/dev/null || true
launchctl unload ~/Library/LaunchAgents/ai.openclaw.gateway.plist 2>/dev/null || true
sleep 2
launchctl list | grep -E 'ai\.openclaw\.gateway(\.visual|\.copy|\.lens)?' || echo 'All OpenClaw LaunchAgents unloaded.'
