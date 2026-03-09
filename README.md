# AI Team Hub

这目录用来集中存放本机多实例 OpenClaw 的文档、脚本和排查资料。

## 目录结构

- `multi-openclaw-mac-setup.md`
  - 本机多实例方案完整记录
  - 包含问题根因、修复过程、LaunchAgent 配置、排查命令

- `scripts/`
  - OpenClaw 实例启动脚本
  - 当前包含：
    - `OpenClaw_Visual.command`
    - `OpenClaw_Copy.command`

---

## 当前实例规划

- 主实例：`~/.openclaw`
  - 端口：`18789`

- Visual 实例：`~/.openclaw-visual`
  - 端口：`18790`

- Copy 实例：`~/.openclaw-copy`
  - 端口：`18800`

---

## 启动方式

### 手动启动脚本

```bash
/Users/yachen/ai-team-hub/scripts/OpenClaw_Visual.command
/Users/yachen/ai-team-hub/scripts/OpenClaw_Copy.command
```

### LaunchAgent（常驻）

- `~/Library/LaunchAgents/ai.openclaw.gateway.plist`
- `~/Library/LaunchAgents/ai.openclaw.gateway.visual.plist`
- `~/Library/LaunchAgents/ai.openclaw.gateway.copy.plist`

---

## 常用检查命令

### 1. 查看 OpenClaw 相关进程

```bash
launchctl list | grep -i openclaw
```

### 2. 检查三个 gateway 端口

```bash
python3 - <<'PY'
import urllib.request
for port in (18789, 18790, 18800):
    url=f'http://127.0.0.1:{port}/health'
    try:
        r=urllib.request.urlopen(url, timeout=3)
        print(url, '->', r.status)
    except Exception as e:
        print(url, '->', type(e).__name__, e)
PY
```

### 3. 查看 Visual / Copy 日志

```bash
tail -100 /Users/yachen/.openclaw-visual/logs/gateway.err.log
tail -100 /Users/yachen/.openclaw-copy/logs/gateway.err.log
```

---

## 重要经验

### 1. 多实例不是“多建几个目录”就完事
关键是每个实例都要有：

- 独立配置
- 独立端口
- 独立启动上下文
- 独立常驻进程

### 2. 桌面脚本如果会在 TUI 退出时 kill gateway，就不适合长期在线 bot
临时会话脚本 ≠ 常驻实例脚本。

### 3. 先验证端口监听，再相信 control-ui
如果 `18790 / 18800` 没监听，control-ui 里看着再像在线也可能是假的。

---

## 推荐阅读顺序

1. 先看本文件 `README.md`
2. 再看 `multi-openclaw-mac-setup.md`
3. 需要手动操作时再去 `scripts/`

---

## 一句话总结

这目录就是你这套多实例 OpenClaw 的“机房值班手册”。别靠脑子记，靠文件。