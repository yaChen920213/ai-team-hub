# scripts/

这里放的是本机多实例 OpenClaw 的启动脚本。

## 当前脚本

- `OpenClaw_Radar.command`
  - 对应实例：`~/.openclaw-radar`
  - 对应端口：`18790`
  - 用途：启动或连接 Radar 实例（📡 感知信号，24/7 监控）

- `OpenClaw_Partner.command`
  - 对应实例：`~/.openclaw-partner`
  - 对应端口：`18800`
  - 用途：启动或连接 Partner 实例（🧠 思维对手，共创判断）

- `OpenClaw_Workshop.command`
  - 对应实例：`~/.openclaw-workshop`
  - 对应端口：`18810`
  - 用途：启动或连接 Workshop 实例（🔨 生产引擎，执行交付）

- `OpenClaw_Keeper.command`
  - 对应实例：`~/.openclaw-keeper`
  - 对应端口：`18820`
  - 用途：启动或连接 Keeper 实例（🛡️ 质量守门人，风险校验）

- `OpenClaw_Butler.command`
  - 对应实例：`~/.openclaw-butler`
  - 对应端口：`18830`
  - 用途：启动或连接 Butler 实例（🏠 生活管家）

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

这只适合临时本地使用，不适合长期在线 bot。

---

## 首次使用：Discord 配对

如果是新实例或重新安装，需要先完成 Discord 配对：

1. 运行脚本启动实例（见下方「方式 1」或「方式 2」）
2. 在 Discord 中找到对应的 bot（Radar / Partner / Workshop / Keeper / Butler）
3. 发送任意消息触发配对流程
4. bot 会回复一个**配对代码**（6位数字）
5. 在 TUI 中输入该代码完成配对
6. 配对成功后即可正常使用

**注意**：每个实例只需配对一次，配对信息会保存在本地。

---

## 使用方式

### 方式 1：双击运行

直接双击 `.command` 文件。

如果 macOS 拦截：
- 右键 → 打开

### 方式 2：终端运行

```bash
/Users/yachen/ai-team-hub/scripts/OpenClaw_Radar.command
/Users/yachen/ai-team-hub/scripts/OpenClaw_Partner.command
/Users/yachen/ai-team-hub/scripts/OpenClaw_Workshop.command
/Users/yachen/ai-team-hub/scripts/OpenClaw_Keeper.command
/Users/yachen/ai-team-hub/scripts/OpenClaw_Butler.command
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

- `~/Library/LaunchAgents/ai.openclaw.gateway.plist` (Ally)
- `~/Library/LaunchAgents/ai.openclaw.gateway.radar.plist`
- `~/Library/LaunchAgents/ai.openclaw.gateway.partner.plist`
- `~/Library/LaunchAgents/ai.openclaw.gateway.workshop.plist`
- `~/Library/LaunchAgents/ai.openclaw.gateway.keeper.plist`
- `~/Library/LaunchAgents/ai.openclaw.gateway.butler.plist`

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
for port in (18790, 18800, 18810, 18820, 18830):
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
tail -100 /Users/yachen/.openclaw-radar/logs/gateway.err.log
tail -100 /Users/yachen/.openclaw-partner/logs/gateway.err.log
tail -100 /Users/yachen/.openclaw-workshop/logs/gateway.err.log
tail -100 /Users/yachen/.openclaw-keeper/logs/gateway.err.log
tail -100 /Users/yachen/.openclaw-butler/logs/gateway.err.log
```

---

## 一句话总结

`scripts/` 里放的是"人工入口"，不是"系统级真相"。
真正决定实例是否长期在线的，是 LaunchAgent。
