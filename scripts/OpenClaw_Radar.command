#!/bin/zsh
source ~/.zshrc 2>/dev/null
cd ~

echo "📡 Starting OpenClaw Radar (AI Team)..."
echo "Gateway on port 18810"

export OPENCLAW_STATE_DIR="$HOME/.openclaw-radar"
export OPENCLAW_CONFIG_PATH="$HOME/.openclaw-radar/openclaw.json"
export OPENCLAW_GATEWAY_PORT=18810

if lsof -i :${OPENCLAW_GATEWAY_PORT} -sTCP:LISTEN -P >/dev/null 2>&1; then
  echo "✅ Gateway already running on port ${OPENCLAW_GATEWAY_PORT}, connecting TUI..."
else
  echo "🚀 Starting persistent gateway on port ${OPENCLAW_GATEWAY_PORT}..."
  nohup openclaw gateway run > "$HOME/.openclaw-radar/logs/manual-gateway.log" 2>&1 &
  sleep 5
fi

openclaw tui
