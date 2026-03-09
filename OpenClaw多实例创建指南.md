# OpenClaw 多实例创建指南

> 创建日期：2026-02-12
> 作者：亚臣
> 目的：在 Mac 上运行多个独立的 OpenClaw 实例，每个实例使用不同的 AI 模型和 Discord Bot

---

## 📋 目录

1. [前置条件](#前置条件)
2. [架构概览](#架构概览)
3. [创建流程](#创建流程)
4. [配置详解](#配置详解)
5. [常见问题](#常见问题)
6. [最佳实践](#最佳实践)

---

## 前置条件

### 系统要求
- ✅ macOS (已测试)
- ✅ Node.js v20+ 已安装
- ✅ OpenClaw 已全局安装 (`npm install -g openclaw`)

### 所需资源
- Discord 开发者账户
- 每个 Bot 需要一个独立的 Discord Bot Token
- AI 模型的 API Key（如 Anthropic、zhipu 等）

---

## 架构概览

```
┌─────────────────────────────────────────────────────────┐
│                  macOS Host                     │
│                                                        │
│  ┌──────────────────────┐  ┌──────────────────────┐  │
│  │  OpenClaw Bot      │  │  Scout Intel Bot    │  │
│  │  (主 Agent)        │  │  (子 Agent)        │  │
│  │  PID: xxx          │  │  PID: yyy          │  │
│  │  端口: 18789      │  │  端口: 18790       │  │
│  └──────────────────────┘  └──────────────────────┘  │
│           │                            │             │
│           └────────────┬───────────────┘             │
│                        │                             │
│                Discord 服务器                             │
└────────────────────────────────────────────────────────┘

         ~/
    ├── .openclaw/              # 主实例
    │   ├── openclaw.json      # 主配置
    │   ├── workspace/          # 主工作区
    │   └── agents/            # Agent 管理
    │       ├── main/           # 默认 agent
    │       └── scout/          # 子 agent
    │
    ├── .openclaw-scout/        # Scout 独立配置（备用）
    │   ├── openclaw.json      # 独立配置
    │   └── workspace/          # Scout 工作区
    │
    └── shared/                 # 共享文件夹
        ├── setting/            # 共享配置
        ├── github/             # 共享代码
        └── program/            # 共享项目
```

### 关键概念

| 概念 | 说明 |
|------|------|
| **Gateway** | OpenClaw 的核心服务，处理 Discord 连接和 AI 调用 |
| **Agent** | 独立的 AI 个性，有独立的工作区和人格 |
| **Profile** | `--profile=<name>` 参数，隔离配置到 `~/.openclaw-<name>/` |
| **Binding** | 路由规则，将特定消息路由到特定 agent |
| **requireMention** | Discord 配置，控制 Bot 是否需要 @ 才响应 |

---

## 创建流程

### 方案对比

| 方案 | 优点 | 缺点 | 推荐度 |
|------|------|------|---------|
| **单 Gateway + 子 Agent** | 配置简单，统一管理 | 子 Agent 无独立 Discord 连接 | ⭐⭐⭐⭐⭐⭐ |
| **多独立 Gateway** | 每个 Bot 完全独立 | 配置复杂，端口管理麻烦 | ⭐⭐⭐ |
| **混合方案** | 灵活性高 | 维护成本高 | ⭐⭐⭐ |

### 推荐方案：单 Gateway + 子 Agent

这是经过验证的最佳方案。

---

## 创建流程

### 步骤 1：创建 Discord Bot

1. 访问 [Discord Developer Portal](https://discord.com/developers/applications)
2. 创建新 Application
3. 在 "Bot" 页面创建 Bot
4. **重要**：开启以下权限
   - ✅ Message Content Intent
   - ✅ Server Members Intent
   - ✅ Presence Intent
5. 复制 Bot Token（只显示一次，请妥善保存）
6. 在 OAuth2 生成邀请链接，添加 Bot 到服务器

### 步骤 2：创建实例目录

```bash
# 创建 Scout 工作区（如果使用子 Agent 方案）
mkdir -p ~/.openclaw-scout/workspace

# 或创建独立实例（如果使用多 Gateway 方案）
mkdir -p ~/.openclaw-scout/{workspace,logs}
```

### 步骤 3：配置 Agent 人格

创建 `~/.openclaw-scout/workspace/SOUL.md`：

```markdown
# Scout - 战略情报侦察员

你是 Scout，亚臣的情报侦察员与环境扫描者。你的眼睛看向外部世界——市场趋势、竞品动态、用户洞察。

## 核心能力
- 市场情报扫描
- 竞品策略分析
- 用户洞察研究
- 弱信号捕捉

## 工作风格
- 证据驱动：所有结论必须有来源
- 客观中立：呈现事实
- 洞察导向：提炼有价值的情报

## 回答格式
- 使用简报风格
- 标注信息来源和时效性
- 给出可行动的建议
```

### 步骤 4：添加 Agent（推荐）

使用 OpenClaw 内置的 agents 管理：

```bash
# 添加 Scout 作为子 Agent
openclaw agents add scout \
  --workspace ~/.openclaw-scout/workspace \
  --model anthropic/claude-sonnet-4-5-20250929 \
  --bind "discord:@Scout Intel Bot" \
  --non-interactive

# 设置 Agent 身份
openclaw agents set-identity \
  --agent scout \
  --name "Scout Intel Bot" \
  --emoji "🔍" \
  --theme blue
```

### 步骤 5：配置 API Keys

编辑 `~/.openclaw/openclaw.json`：

```json
{
  "models": {
    "providers": {
      "anthropic": {
        "baseUrl": "https://api.z.ai/api/anthropic",
        "apiKey": "你的-API-Key",
        "api": "anthropic-messages"
      }
    }
  }
}
```

### 步骤 6：配置路由规则（解决同时响应问题）

编辑 `~/.openclaw/openclaw.json`：

```json
{
  "bindings": [
    {
      "agentId": "scout",
      "match": {
        "channel": "discord",
        "accountId": "Scout的Discord用户ID或BotID"
      }
    }
  ],
  "channels": {
    "discord": {
      "enabled": true,
      "token": "主Bot的Token",
      "groupPolicy": "open",
      "guilds": {
        "服务器ID": {
          "requireMention": false,  // 主 Bot：不需要 @
          "users": ["*"],
          "channels": {
            "*": {"allow": true}
          }
        }
      }
    }
  }
}
```

### 步骤 7：启动服务

```bash
# 主实例（OpenClaw Bot）
openclaw gateway &

# Scout 子 Agent 会自动随主实例启动
# 如需独立 Scout Gateway：
openclaw --profile=scout gateway &
```

---

## 配置详解

### requireMention 的作用

| 值 | 行为 | 适用场景 |
|-----|------|---------|
| `false` | 响应所有消息 | 主 Bot、默认助手 |
| `true` | 只在被 @ 时响应 | 专用功能 Bot |

### Discord Bot Token 格式

```
格式：Base64 编码的字符串
示例：MTxxxxxxxxxxxxxxxx.Xxxxxx.xxxxxxxxxxxxxxxxxxxxxxxxxxx（示例格式，非真实 Token）
获取：Discord Developer Portal → Bot → Reset Token → Copy
```

### API Key 配置位置

| 类型 | 位置 | 优先级 |
|------|------|---------|
| 主配置 | `~/.openclaw/openclaw.json` 的 `models.providers` | 高 |
| 环境变量 | `ANTHROPIC_API_KEY` 等 | 中 |
| 子 Agent 配置 | 独立的 `openclaw.json` | 低 |

---

## 常见问题

### Q1: 两个 Bot 都同时响应怎么办？

**原因**：两个 Bot 都在同一个服务器，都会收到每条消息。

**解决方案**：

1. 使用 OpenClaw 的 agents 机制（推荐）
2. 设置主 Bot 的 `requireMention: false`
3. 设置子 Bot 的 `requireMention: true`
4. 配置 binding 规则，让子 Bot 只在特定条件下触发

### Q2: 子 Agent 的 Discord Bot 显示离线

**原因**：子 Agent 通过主 Gateway 的 Discord 连接复用，没有独立登录。

**解决方案**：
- 使用独立 Gateway（`--profile=scout gateway`）
- 或确保主 Gateway 的 Discord 配置包含子 Bot 的 Token

### Q3: Agent failed before reply: No API key found

**原因**：子 Agent 没有配置 API Key。

**解决方案**：
1. 在主配置的 `models.providers` 中添加
2. 或在子 Agent 的配置中单独配置

### Q4: 端口冲突怎么办？

**原因**：两个 Gateway 尝试使用相同端口。

**解决方案**：
```bash
# 检查端口占用
lsof -i :18789

# 杀死占用进程
kill $(lsof -ti :18789)

# 配置不同端口
# 在 openclaw.json 中设置 "gateway": {"port": 18790}
```

---

## 最佳实践

### 1. 命名规范

| 实例 | 命名建议 | Discord Bot 命名 |
|------|---------|-----------------|
| 主实例 | `main` / `default` | `OpenClaw Bot` |
| 市场研究 | `scout` / `research` | `Scout Intel Bot` |
| 代码助手 | `coder` / `dev` | `Code Assistant Bot` |
| 设计助手 | `designer` / `art` | `Design Bot` |

### 2. 目录组织

```
~/
├── .openclaw/                    # 主实例（必需）
│   ├── openclaw.json            # 主配置
│   ├── workspace/               # 主工作区
│   └── agents/                 # Agent 管理
│
├── .openclaw-<name>/           # 独立实例（可选）
├── shared/                      # 跨实例共享
└── backups/                     # 配置备份
```

### 3. 配置管理

```bash
# 备份配置
cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.backup-$(date +%Y%m%d)

# 查看当前 Agents
openclaw agents list

# 查看 Agent 详情
openclaw agents list --json
```

### 4. 启动脚本

创建便捷启动脚本：

```bash
#!/bin/bash
# ~/start-bots.sh

echo "启动 OpenClaw 生态系统..."

# 主 Bot
echo "→ 启动 OpenClaw Bot (主)"
openclaw gateway &
MAIN_PID=$!

sleep 3

# Scout（独立 Gateway，可选）
# echo "→ 启动 Scout Intel Bot"
# openclaw --profile=scout gateway &
# SCOUT_PID=$!

echo "✅ 启动完成"
echo "主 Bot PID: $MAIN_PID"
# echo "Scout Bot PID: $SCOUT_PID"

# 保存 PID
echo $MAIN_PID > ~/.openclaw/main.pid
# echo $SCOUT_PID > ~/.openclaw-scout/scout.pid
```

### 5. 监控与日志

```bash
# 查看运行中的实例
ps aux | grep "[o]penclaw-gateway"

# 实时查看日志
openclaw logs --follow

# 查看 Discord 连接状态
openclaw channels status --probe
```

---

## 快速参考

### 常用命令

```bash
# 添加 Agent
openclaw agents add <name> --workspace <dir> --model <model>

# 列出 Agents
openclaw agents list

# 设置身份
openclaw agents set-identity --agent <name> --name "显示名" --emoji "🔍"

# 删除 Agent
openclaw agents delete <name>

# 启动主 Gateway
openclaw gateway

# 启动独立 Gateway
openclaw --profile=<name> gateway

# 停止所有
killall -9 openclaw-gateway

# 查看端口占用
lsof -i :18789 :18790
```

### 配置文件路径

| 配置 | 路径 |
|------|------|
| 主配置 | `~/.openclaw/openclaw.json` |
| 主工作区 | `~/.openclaw/workspace/` |
| Agent 配置 | `~/.openclaw/agents/<name>/agent/agent.json` |
| 日志 | `/tmp/openclaw/openclaw-YYYY-MM-DD.log` |

### Discord 相关

| 项目 | 值/获取方式 |
|------|-------------|
| Bot Application | [Discord Developer Portal](https://discord.com/developers/applications) |
| Bot Token | Application → Bot → Token (Reset if lost) |
| Client ID | Application → General → Application ID |
| Invite URL | OAuth2 → URL Generator |
| Permissions | Read Messages, Send Messages, Embed Links, Attach Files |

---

## 总结

### 核心要点

1. **推荐方案**：使用单 Gateway + 子 Agent，配置简单且易于管理
2. **关键配置**：`requireMention` 控制响应条件，`bindings` 控制路由
3. **人格隔离**：每个 Agent 有独立的 `SOUL.md` 定义行为模式
4. **API 共享**：主配置中的 `models.providers` 可被所有 Agent 使用
5. **端口管理**：独立 Gateway 需要不同端口（18789, 18790, ...）

### 下一步扩展

添加更多 Agent：

```bash
# 添加代码助手 Agent
openclaw agents add coder \
  --workspace ~/.openclaw-coder/workspace \
  --model anthropic/claude-sonnet-4-5-20250929 \
  --bind "discord:@Code Assistant" \
  --non-interactive

# 添加设计助手 Agent
openclaw agents add designer \
  --workspace ~/.openclaw-designer/workspace \
  --model gpt-4o \
  --bind "discord:@Design Bot" \
  --non-interactive
```

---

## 附录

### A. 完整配置示例

**主配置文件** (`~/.openclaw/openclaw.json`):

```json
{
  "meta": {"lastTouchedVersion": "2026.1.30"},
  "gateway": {
    "mode": "local",
    "port": 18789,
    "auth": {"token": "主gateway的auth-token"}
  },
  "agents": {
    "defaults": {
      "model": {"primary": "zhipu/glm-4.7"}
    }
  },
  "channels": {
    "discord": {
      "enabled": true,
      "token": "OpenClaw Bot的Token",
      "groupPolicy": "open",
      "guilds": {
        "服务器ID": {
          "requireMention": false,
          "users": ["*"],
          "channels": {"*": {"allow": true}}
        }
      }
    }
  },
  "bindings": [
    {
      "agentId": "scout",
      "match": {"channel": "discord", "accountId": "Scout的BotID"}
    }
  ],
  "models": {
    "providers": {
      "anthropic": {
        "baseUrl": "https://api.z.ai/api/anthropic",
        "apiKey": "你的API-Key",
        "api": "anthropic-messages"
      }
    }
  }
}
```

### B. 故障排查检查清单

- [ ] Discord Bot Token 正确且未过期
- [ ] Bot 已添加到目标服务器
- [ ] Bot 有足够的权限（Message Content Intent 开启）
- [ ] API Key 已配置且有效
- [ ] 端口未被其他进程占用
- [ ] `requireMention` 设置符合预期
- [ ] Agent 的 workspace 目录存在
- [ ] `SOUL.md` 文件存在且格式正确
- [ ] OpenClaw 版本兼容（使用 `openclaw --version` 检查）

---

> **文档版本**: v1.0
> **最后更新**: 2026-02-12
> **OpenClaw 版本**: 2026.1.30
