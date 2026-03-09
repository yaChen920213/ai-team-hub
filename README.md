# AI Team Hub

这目录用来集中存放本机多实例 OpenClaw 的文档、脚本和排查资料。

## 目录结构

- `README.md`
  - 总索引
  - 先看这个，再决定往下读哪份文档

- `docs/`
  - 文档目录
  - 包含：
    - `multi-openclaw-mac-setup.md`
    - `ai-team-roles-and-routing.md`
    - `team-topology.md`

- `scripts/`
  - 实例启动脚本目录
  - 当前包含：
    - `OpenClaw_Form.command`
    - `OpenClaw_Wit.command`
    - `OpenClaw_Lens.command`
    - `README.md`
  - **Ally 是主实例，不通过这里的 .command 管理**

- `ops/`
  - 运维脚本目录
  - 包含：
    - `healthcheck-all.sh`
    - `start-all.sh`
    - `stop-all.sh`
    - `restart-all.sh`
    - `status-all.sh`

- `archive/`
  - 预留给历史文件、旧版本和归档资料

---

## 当前实例总览

- 主实例：`~/.openclaw`
  - 端口：`18789`
  - 定位：主控 / 通用 / 总协调

- Form 实例：`~/.openclaw-visual`
  - 端口：`18790`
  - 定位：品牌 / 包装 / 电商设计

- Wit 实例：`~/.openclaw-copy`
  - 端口：`18800`
  - 定位：品牌 / 包装 / 电商文案 / 新媒体文案

- Lens 实例：`~/.openclaw-lens`
  - 端口：`18810`
  - 定位：平面 / 摄影 / 视频 / 音频
  - 状态：已正式上线，Discord 已连通

---

## 启动方式

### 手动启动脚本

```bash
/Users/yachen/ai-team-hub/scripts/OpenClaw_Form.command
/Users/yachen/ai-team-hub/scripts/OpenClaw_Wit.command
/Users/yachen/ai-team-hub/scripts/OpenClaw_Lens.command
```

说明：
- 这里的 `.command` 只负责 Form / Wit / Lens
- **Ally 是主实例，主要通过现有 LaunchAgent 常驻，不走这里的脚本入口**

### LaunchAgent（常驻）

- `~/Library/LaunchAgents/ai.openclaw.gateway.plist`
- `~/Library/LaunchAgents/ai.openclaw.gateway.visual.plist`
- `~/Library/LaunchAgents/ai.openclaw.gateway.copy.plist`
- `~/Library/LaunchAgents/ai.openclaw.gateway.lens.plist`

---

## 常用检查命令

### 1. 查看 OpenClaw 相关进程

这条命令主要用来确认 4 个 gateway 标签是否都在：

```bash
launchctl list | grep -i openclaw
```

### 2. 检查四个 gateway 端口

```bash
python3 - <<'PY'
import urllib.request
for port in (18789, 18790, 18800, 18810):
    url=f'http://127.0.0.1:{port}/health'
    try:
        r=urllib.request.urlopen(url, timeout=3)
        print(url, '->', r.status)
    except Exception as e:
        print(url, '->', type(e).__name__, e)
PY
```

### 3. 查看 Form / Wit / Lens 日志

```bash
tail -100 /Users/yachen/.openclaw-visual/logs/gateway.err.log
tail -100 /Users/yachen/.openclaw-copy/logs/gateway.err.log
tail -100 /Users/yachen/.openclaw-lens/logs/gateway.err.log
```

---

## 重要经验

### 1. 多实例不是“多建几个目录”就完事
关键是每个实例都要有：

- 独立配置
- 独立端口
- 独立启动上下文
- 独立常驻进程

### 2. 旧版临时脚本如果会在 TUI 退出时 kill gateway，就不适合长期在线 bot
临时会话脚本 ≠ 常驻实例脚本。

### 3. 先验证端口监听，再相信 control-ui
如果 `18790 / 18800` 没监听，control-ui 里看着再像在线也可能是假的。

---

## 推荐阅读顺序

1. 先看本文件 `README.md`
2. 再看 `docs/multi-openclaw-mac-setup.md`
3. 看角色分工时读 `docs/ai-team-roles-and-routing.md`
4. 需要手动操作时再去 `scripts/`
5. 需要运维时再去 `ops/`

---

## 一句话总结

这目录就是你这套多实例 OpenClaw 的“机房值班手册”。别靠脑子记，靠文件。