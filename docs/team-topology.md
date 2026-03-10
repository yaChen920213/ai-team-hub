# AI Team Topology

更新时间：2026-03-10

## 总控关系

- **Ally（主实例）** = 总控 / 分流 / 协调
- **Radar** = 感知信号，24/7 监控世界 📡
- **Partner** = 思维对手，共创判断 🧠
- **Workshop** = 生产引擎，执行交付 🔨
- **Keeper** = 质量守门人，风险校验 🛡️
- **Butler** = 生活管家 🏠

---

## 实例总表

| 实例名 | 目录 | 端口 | LaunchAgent | 启动脚本 | 当前状态 | 定位 | Emoji |
|---|---|---:|---|---|---|---|---|
| Ally | `~/.openclaw` | 18789 | `ai.openclaw.gateway` | 主实例常驻 | 在线 | 总控 / 通用 / 协调 | 🤝 |
| Radar | `~/.openclaw-radar` | 18790 | `ai.openclaw.gateway.radar` | `scripts/OpenClaw_Radar.command` | 在线 | 感知信号 / 信息监控 | 📡 |
| Partner | `~/.openclaw-partner` | 18800 | `ai.openclaw.gateway.partner` | `scripts/OpenClaw_Partner.command` | 在线 | 共创判断 / 策略制定 | 🧠 |
| Workshop | `~/.openclaw-workshop` | 18810 | `ai.openclaw.gateway.workshop` | `scripts/OpenClaw_Workshop.command` | 在线 | 生产交付 / 执行 | 🔨 |
| Keeper | `~/.openclaw-keeper` | 18820 | `ai.openclaw.gateway.keeper` | `scripts/OpenClaw_Keeper.command` | 在线 | 质量校验 / 合规审核 | 🛡️ |
| Butler | `~/.openclaw-butler` | 18830 | `ai.openclaw.gateway.butler` | `scripts/OpenClaw_Butler.command` | 在线 | 生活管家 / 日程管理 | 🏠 |

---

## 架构流程

```
Radar → Partner → Workshop → Keeper
  │        │         │          │
感知信号  共创判断   生产交付   风险校验
  │        │         │          │
  └──→ 你 ────→ 你可中途介入 ──→ 你最终拍板
          ↑
       Butler（独立系统，生活管理）
```

---

## 当前分工原则

### Ally 负责
- 接住混合任务
- 判断该路由给谁
- 拆解复杂任务
- 做多实例协调
- 处理系统与配置问题

### Ally 不应长期替代专业实例
- 信息监控 → Radar
- 策略制定 → Partner
- 生产执行 → Workshop
- 质量审核 → Keeper
- 生活管理 → Butler

---

## 各实例详细定位

### Radar 📡
**本质：** 信息触角，24/7 感知世界
**自主权：** 高
**核心工作：**
- 监控竞品动态
- 扫描行业资讯
- 追踪社交信号
- 每日简报推送

### Partner 🧠
**本质：** 思维对手，共创判断
**自主权：** 低
**核心工作：**
- 品牌战略推演
- 设计方向探讨
- 复杂问题拆解
- Brief 输出

### Workshop 🔨
**本质：** 生产引擎，执行交付
**自主权：** Brief 内高
**核心工作：**
- 文案撰写
- 数据分析
- 报告生成
- 生产执行

### Keeper 🛡️
**本质：** 质量守门人，风险校验
**自主权：** 审核自主
**核心工作：**
- 法规合规审核
- 品牌一致性检查
- 事实核查
- 交付完整性验证

### Butler 🏠
**本质：** 生活管家（独立系统）
**自主权：** 高
**核心工作：**
- 日程管理
- 健康追踪
- 财务提醒
- 家庭事务

---

## 相关文档

- `ai-team-roles-and-routing.md` — 详细角色分工和路由规则
- `multi-openclaw-mac-setup.md` — 技术配置和运维指南
- `~/ai-team-souls/` — 灵魂配置（SOUL.md / IDENTITY.md）

---

## Discord 频道对应

- `#radar` — Radar 推送信息
- `#partner` — Partner 策略讨论
- `#workshop` — Workshop 生产交付
- `#keeper` — Keeper 审核报告
- `#butler` — Butler 生活管理
- `#general` — 通用讨论 / Ally 协调

---

## 一句话总结

六实例按流程协作：Radar 感知 → Partner 判断 → Workshop 交付 → Keeper 校验，Butler 独立管理生活，Ally 总控协调。
