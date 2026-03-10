#!/bin/zsh
source ~/.zshrc 2>/dev/null
cd ~

echo "🔨 Starting OpenClaw Workshop (AI Team)..."
echo "Gateway on port 18801"

export OPENCLAW_STATE_DIR="$HOME/.openclaw-workshop"
export OPENCLAW_CONFIG_PATH="$HOME/.openclaw-workshop/openclaw.json"
export OPENCLAW_GATEWAY_PORT=18801

# Start persistent gateway if needed, then attach TUI.
if lsof -i :${OPENCLAW_GATEWAY_PORT} -sTCP:LISTEN -P >/dev/null 2>&1; then
  echo "✅ Gateway already running on port ${OPENCLAW_GATEWAY_PORT}, connecting TUI..."
else
  echo "🚀 Starting persistent gateway on port ${OPENCLAW_GATEWAY_PORT}..."
  nohup openclaw gateway run > "$HOME/.openclaw-workshop/logs/manual-gateway.log" 2>&1 &
  sleep 5
fi

openclaw tui
