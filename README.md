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
    - `OpenClaw_Radar.command`
    - `OpenClaw_Partner.command`
    - `OpenClaw_Workshop.command`
    - `OpenClaw_Keeper.command`
    - `OpenClaw_Butler.command`
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

| 实例 | 目录 | 端口 | 定位 | Emoji |
|------|------|------|------|-------|
| **Ally** | `~/.openclaw` | `18789` | 总控 / 通用 / 总协调 | 🤝 |
| **Radar** | `~/.openclaw-radar` | `18790` | 感知信号，24/7 监控世界 | 📡 |
| **Partner** | `~/.openclaw-partner` | `18800` | 思维对手，共创判断 | 🧠 |
| **Workshop** | `~/.openclaw-workshop` | `18810` | 生产引擎，执行交付 | 🔨 |
| **Keeper** | `~/.openclaw-keeper` | `18820` | 质量守门人，风险校验 | 🛡️ |
| **Butler** | `~/.openclaw-butler` | `18830` | 生活管家 | 🏠 |

### 角色分工

- **Radar** 📡 — 信息触角，24/7 感知世界
  - 监控竞品动态、行业资讯、社交信号
  - 每日简报，异常信号立即推送
  - 高自主权，按既定信息源持续运转

- **Partner** 🧠 — 思维对手，共创判断
  - 品牌战略推演、设计方向探讨
  - 复杂问题拆解、Brief 输出
  - 低自主权，给建议但不替决策

- **Workshop** 🔨 — 生产引擎，执行交付
  - 文案撰写、数据分析、报告生成
  - 在 Brief 范围内高度自主执行
  - 关键节点强制暂停，等亚臣确认

- **Keeper** 🛡️ — 质量守门人，风险校验
  - 法规合规审核、品牌一致性检查
  - 事实核查、交付完整性验证
  - 有否决权，致命问题直接打回

- **Butler** 🏠 — 生活管家
  - 日程管理、健康追踪、财务提醒
  - 家庭事务、重要日期提醒
  - 高自主权，按规则静默执行

---

## 架构关系

```
Radar → Partner → Workshop → Keeper
  │        │         │          │
感知信号  共创判断   生产交付   风险校验
  │        │         │          │
  └──→ 你 ────→ 你可中途介入 ──→ 你最终拍板
```

---

## 启动方式

### 手动启动脚本

```bash
/Users/yachen/ai-team-hub/scripts/OpenClaw_Radar.command
/Users/yachen/ai-team-hub/scripts/OpenClaw_Partner.command
/Users/yachen/ai-team-hub/scripts/OpenClaw_Workshop.command
/Users/yachen/ai-team-hub/scripts/OpenClaw_Keeper.command
/Users/yachen/ai-team-hub/scripts/OpenClaw_Butler.command
```

说明：
- 这里的 `.command` 只负责 Radar / Partner / Workshop / Keeper / Butler
- **Ally 是主实例，主要通过现有 LaunchAgent 常驻，不走这里的脚本入口**

### LaunchAgent（常驻）

- `~/Library/LaunchAgents/ai.openclaw.gateway.plist` (Ally)
- `~/Library/LaunchAgents/ai.openclaw.gateway.radar.plist`
- `~/Library/LaunchAgents/ai.openclaw.gateway.partner.plist`
- `~/Library/LaunchAgents/ai.openclaw.gateway.workshop.plist`
- `~/Library/LaunchAgents/ai.openclaw.gateway.keeper.plist`
- `~/Library/LaunchAgents/ai.openclaw.gateway.butler.plist`

---

## 常用检查命令

### 1. 查看 OpenClaw 相关进程

这条命令主要用来确认 6 个 gateway 标签是否都在：

```bash
launchctl list | grep -i openclaw
```

### 2. 检查六个 gateway 端口

```bash
python3 - <<'PY'
import urllib.request
for port in (18789, 18790, 18800, 18810, 18820, 18830):
    url=f'http://127.0.0.1:{port}/health'
    try:
        r=urllib.request.urlopen(url, timeout=3)
        print(url, '->', r.status)
    except Exception as e:
        print(url, '->', type(e).__name__, e)
PY
```

### 3. 查看各实例日志

```bash
tail -100 /Users/yachen/.openclaw-radar/logs/gateway.err.log
tail -100 /Users/yachen/.openclaw-partner/logs/gateway.err.log
tail -100 /Users/yachen/.openclaw-workshop/logs/gateway.err.log
tail -100 /Users/yachen/.openclaw-keeper/logs/gateway.err.log
tail -100 /Users/yachen/.openclaw-butler/logs/gateway.err.log
```

---

## 重要经验

### 1. 多实例不是"多建几个目录"就完事
关键是每个实例都要有：

- 独立配置
- 独立端口
- 独立启动上下文
- 独立常驻进程

### 2. 旧版临时脚本如果会在 TUI 退出时 kill gateway，就不适合长期在线 bot
临时会话脚本 ≠ 常驻实例脚本。

### 3. 先验证端口监听，再相信 control-ui
如果端口没监听，control-ui 里看着再像在线也可能是假的。

---

## 推荐阅读顺序

1. 先看本文件 `README.md`
2. 再看 `docs/multi-openclaw-mac-setup.md`
3. 看角色分工时读 `docs/ai-team-roles-and-routing.md`
4. 需要手动操作时再去 `scripts/`
5. 需要运维时再去 `ops/`
6. 灵魂配置在 `~/ai-team-souls/`

---

## 相关仓库

- [ai-team-souls](https://github.com/yaChen920213/ai-team-souls) — AI 团队灵魂配置（SOUL.md / IDENTITY.md / 分工规则）

---

## 一句话总结

这目录就是你这套多实例 OpenClaw 的"机房值班手册"。别靠脑子记，靠文件。
