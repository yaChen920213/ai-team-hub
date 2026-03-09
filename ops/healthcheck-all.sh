#!/bin/zsh
set -euo pipefail

echo "== OpenClaw Team Health Check =="
echo "time: $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo

echo "[1/4] LaunchAgents"
launchctl list | grep -E 'ai\.openclaw\.gateway(\.visual|\.copy|\.lens)?' || true

echo

echo "[2/4] Gateway health"
python3 - <<'PY'
import urllib.request
items = [
    ('Ally', 18789),
    ('Form', 18790),
    ('Wit', 18800),
    ('Lens', 18810),
]
for name, port in items:
    url = f'http://127.0.0.1:{port}/health'
    try:
        r = urllib.request.urlopen(url, timeout=3)
        print(f'{name:<6} {port}: OK {r.status}')
    except Exception as e:
        print(f'{name:<6} {port}: FAIL {type(e).__name__}: {e}')
PY

echo

echo "[3/4] Recent gateway errors"
for f in \
  /Users/yachen/.openclaw/logs/gateway.err.log \
  /Users/yachen/.openclaw-visual/logs/gateway.err.log \
  /Users/yachen/.openclaw-copy/logs/gateway.err.log \
  /Users/yachen/.openclaw-lens/logs/gateway.err.log; do
  echo "--- $f ---"
  if [ -f "$f" ]; then
    tail -5 "$f"
  else
    echo "(missing)"
  fi
  echo
 done

echo "[4/4] Summary"
echo "- Ally: 主控 / 协调"
echo "- Form: 设计"
echo "- Wit: 文案"
echo "- Lens: 已正式上线"
