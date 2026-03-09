#!/bin/zsh
source ~/.zshrc 2>/dev/null
cd ~

echo "📷 Starting OpenClaw Lens (Instance L)..."
echo "Gateway on port 18810"

export OPENCLAW_STATE_DIR="$HOME/.openclaw-lens"
export OPENCLAW_CONFIG_PATH="$HOME/.openclaw-lens/openclaw.json"
export OPENCLAW_GATEWAY_PORT=18810

if lsof -i :${OPENCLAW_GATEWAY_PORT} -sTCP:LISTEN -P >/dev/null 2>&1; then
  echo "✅ Gateway already running on port ${OPENCLAW_GATEWAY_PORT}, connecting TUI..."
else
  echo "🚀 Starting persistent gateway on port ${OPENCLAW_GATEWAY_PORT}..."
  nohup openclaw gateway run > "$HOME/.openclaw-lens/logs/manual-gateway.log" 2>&1 &
  sleep 5
fi

openclaw tui
