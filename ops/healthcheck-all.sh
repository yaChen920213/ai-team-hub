#!/bin/zsh
set -euo pipefail

echo "== OpenClaw AI Team Health Check =="
echo "time: $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo

echo "[1/3] Running gateway processes"
ps aux | grep 'openclaw-gateway' | grep -v grep | awk '{print $11, $2}' || echo "No processes running"

echo

echo "[2/3] Gateway health"
python3 - <<'PY'
import urllib.request
items = [
    ('Ally', 18789),
    ('Partner', 18800),
    ('Radar', 18810),
    ('Workshop', 18801),
]
for name, port in items:
    url = f'http://127.0.0.1:{port}/health'
    try:
        r = urllib.request.urlopen(url, timeout=3)
        print(f'{name:<10} {port}: OK {r.status}')
    except Exception as e:
        print(f'{name:<10} {port}: FAIL {type(e).__name__}')
PY

echo

echo "[3/3] Recent gateway errors"
for f in \
  /Users/yachen/.openclaw/logs/gateway.err.log \
  /Users/yachen/.openclaw-partner/logs/gateway.err.log \
  /Users/yachen/.openclaw-radar/logs/gateway.err.log \
  /Users/yachen/.openclaw-workshop/logs/gateway.err.log; do
  echo "--- $f ---"
  if [ -f "$f" ]; then
    tail -3 "$f"
  else
    echo "(missing)"
  fi
  echo
 done

echo "[4/4] Summary"
echo "- Ally:     主控 / 协调"
echo "- Partner:  思维对手 / 共创判断"
echo "- Radar:    信息触角 / 24/7 感知"
echo "- Workshop: 生产引擎 / 执行交付"
