# scripts/

这里放的是本机多实例 OpenClaw 的启动脚本。

## 当前脚本

- `OpenClaw_Form.command`
  - 对应实例：`~/.openclaw-visual`
  - 对应端口：`18790`
  - 用途：启动或连接 Form 实例（品牌 / 包装 / 电商设计）

- `OpenClaw_Wit.command`
  - 对应实例：`~/.openclaw-copy`
  - 对应端口：`18800`
  - 用途：启动或连接 Wit 实例（品牌 / 包装 / 电商文案 / 新媒体文案）

- `OpenClaw_Lens.command`
  - 对应实例：`~/.openclaw-lens`
  - 对应端口：`18810`
  - 用途：启动或连接 Lens 实例（平面 / 摄影 / 视频 / 音频）

---

## 当前脚本逻辑

脚本现在是**常驻友好版本**：

1. 先检查目标端口是否已经监听
2. 如果没监听，就启动该实例的 gateway
3. 然后打开 TUI
4. **不会**因为 TUI 关闭就自动 kill gateway

这点很关键。

旧版脚本的问题是：
- 打开 TUI 时顺手启动 gateway
- 关闭 TUI 时又把 gateway 一起杀掉

这只适合临时本地会话，不适合长期在线 bot。

---

## 使用方式

### 方式 1：双击运行

直接双击 `.command` 文件。

如果 macOS 拦截：
- 右键 → 打开

### 方式 2：终端运行

```bash
/Users/yachen/ai-team-hub/scripts/OpenClaw_Form.command
/Users/yachen/ai-team-hub/scripts/OpenClaw_Wit.command
/Users/yachen/ai-team-hub/scripts/OpenClaw_Lens.command
```

---

## 什么时候用这些脚本

适合：
- 手动拉起某个实例
- 手动进入某个实例的 TUI
- 临时检查实例当前状态

不适合把它们当作唯一常驻方式。

长期在线仍应以 LaunchAgent 为主。

---

## 对应的 LaunchAgent

- `~/Library/LaunchAgents/ai.openclaw.gateway.visual.plist`
- `~/Library/LaunchAgents/ai.openclaw.gateway.copy.plist`
- `~/Library/LaunchAgents/ai.openclaw.gateway.lens.plist`

LaunchAgent 负责：
- 开机自启
- 后台常驻
- 崩了自动拉起

脚本负责：
- 人手动进入 / 连接 / 观察

两者分工别搞混。

---

## 排查建议

如果双击脚本后实例还是不正常，先查：

```bash
launchctl list | grep -i openclaw
```

再查端口：

```bash
python3 - <<'PY'
import urllib.request
for port in (18790, 18800, 18810):
    url=f'http://127.0.0.1:{port}/health'
    try:
        r=urllib.request.urlopen(url, timeout=3)
        print(url, '->', r.status)
    except Exception as e:
        print(url, '->', type(e).__name__, e)
PY
```

再查日志：

```bash
tail -100 /Users/yachen/.openclaw-visual/logs/gateway.err.log
tail -100 /Users/yachen/.openclaw-copy/logs/gateway.err.log
tail -100 /Users/yachen/.openclaw-lens/logs/gateway.err.log
```

---

## 一句话总结

`scripts/` 里放的是“人工入口”，不是“系统级真相”。
真正决定实例是否长期在线的，是 LaunchAgent。