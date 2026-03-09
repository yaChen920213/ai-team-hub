# AI Team Topology

更新时间：2026-03-09

## 总控关系

- **Ally（主实例）** = 总控 / 分流 / 协调
- **Form** = 品牌 / 包装 / 电商设计
- **Wit** = 品牌 / 包装 / 电商文案 / 新媒体文案
- **Lens** = 平面 / 摄影 / 视频 / 音频（已正式上线，Discord 已连通）

---

## 实例总表

| 实例名 | 目录 | 端口 | LaunchAgent | 启动脚本 | 当前状态 | 定位 |
|---|---|---:|---|---|---|---|
| Ally | `~/.openclaw` | 18789 | `ai.openclaw.gateway` | 主实例常驻 | 在线 | 总控 / 通用 / 协调 |
| Form | `~/.openclaw-visual` | 18790 | `ai.openclaw.gateway.visual` | `scripts/OpenClaw_Form.command` | 在线 | 品牌 / 包装 / 电商设计 |
| Wit | `~/.openclaw-copy` | 18800 | `ai.openclaw.gateway.copy` | `scripts/OpenClaw_Wit.command` | 在线 | 品牌 / 包装 / 电商文案 / 新媒体文案 |
| Lens | `~/.openclaw-lens` | 18810 | `ai.openclaw.gateway.lens` | `scripts/OpenClaw_Lens.command` | 在线（Discord 已连通） | 平面 / 摄影 / 视频 / 音频 |

---

## 当前分工原则

### Ally 负责
- 接住混合任务
- 判断该路由给谁
- 拆解复杂任务
- 做多实例协调
- 处理系统与配置问题

### Ally 不应长期替代专业实例
- 设计主判断 → Form
- 文案主输出 → Wit
- 视听主判断 → Lens

---

## Lens 备注

Lens 目前：
- 已创建实例
- 已有 LaunchAgent
- 已邀请进 Discord
- **现已正式纳入稳定工作流**
- **Discord 已连通，可直接参与正式任务**

当前建议：
- Ally / Form / Wit / Lens 四者按分工协作
- 涉及平面、摄影、视频、音频的任务优先考虑交给 Lens
