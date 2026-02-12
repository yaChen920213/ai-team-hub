# Mac 端多 OpenClaw 实例配置指南

本指南介绍如何在一台 Mac 上运行多个独立的 OpenClaw 实例，每个实例由不同的 AI 模型驱动，通过共享资源进行协作。

---

## 简介

OpenClaw 支持在一台机器上运行多个独立实例。每个实例连接到不同的消息机器人（例如 Telegram），并使用不同的 AI 模型后端。这实现了"机器人团队"架构，专门的代理在单一操作员的指挥下协作。

**使用场景：**
- 同时运行 Claude、DeepSeek 和 Gemini，发挥各自优势
- 实时 A/B 测试模型响应
- 将不同任务分配给不同模型
- 构建具有共享知识库的协作式多代理系统

---

## 前置要求

- **macOS**（Apple Silicon 或 Intel）
- 已安装 **Node.js** v20+
- 已全局安装 **OpenClaw**（`npm install -g openclaw`）
- **Telegram Bot 令牌** — 每个实例一个（通过 [@BotFather](https://t.me/BotFather) 创建）
- 每个模型提供商的 **API 密钥**（安全存储，切勿放在共享文件中）

## 版本兼容性

本指南已通过以下 OpenClaw 版本测试：

| OpenClaw 版本 | 测试日期 | 状态 |
|----------------|-------------|--------|
| 0.9.x 系列 | 2026-02 | ✅ 完全兼容 |
| 0.8.x 系列 | 2026-01 | ✅ 兼容（配置略有差异） |
| 0.7.x 及以下 | 未测试 | ⚠️ 可能需要调整 |

**注意：** OpenClaw 快速迭代。请务必查阅[官方文档](https://docs.openclaw.ai)以获取最新功能和重大变更。如果在使用较新版本时遇到问题，请查看发行说明了解迁移指南。

### 关键版本特性
- **v0.9.x**：增强的多机器人支持，改进的 cron 调度
- **v0.8.x**：基础多实例支持（本文档所述）
- **v0.7.x 及更早版本**：多机器人功能有限（不推荐）

---

## 架构概览

```
┌─────────────────────────────────────────────┐
│                  macOS 主机                │
│                                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │ 实例      │  │ 实例     │  │ 实例     │  │
│  │   "C"    │  │   "D"    │  │   "G"   │  │
│  │  Claude  │  │ DeepSeek │  │ Gemini  │  │
│  │          │  │          │  │          │  │
│  │ ~/.oc-c/ │  │ ~/.oc-d/ │  │ ~/.oc-g/ │  │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  │
│       │              │              │        │
│       └──────────┬───┴──────────────┘        │
│                  │                           │
│         ┌───────┴────────┐                   │
│         │ ~/shared/      │                   │
│         │  ├── setting/  │                   │
│         │  ├── github/   │                   │
│         │  └── program/  │                   │
│         └────────────────┘                   │
│                                             │
│              Telegram API                     │
└─────────────────────────────────────────────┘
```

每个实例作为独立的进程运行，拥有自己的：
- 配置目录
- 工作区（memory、soul、identity 文件）
- Cron 调度器
- Telegram 机器人连接

所有实例共享一个公共文件夹用于协作。

---

## 快速启动清单

使用此清单验证你的设置是否准备好启动实例：

- [ ] **验证 macOS 环境**：`node --version` 显示 v20+，`which openclaw` 返回路径
- [ ] **创建目录**：所有实例文件夹存在（`~/.openclaw`、`~/.openclaw-deepseek`、`~/.openclaw-gemini`）和共享文件夹（`~/shared/`）
- [ ] **配置 Telegram 机器人**：从 @BotFather 获取唯一的机器人令牌（3 个实例需要 3 个令牌）
- [ ] **设置 API 密钥**：在每个启动脚本中定义环境变量（每个模型提供商一个）
- [ ] **初始化工作区文件**：在每个实例的 `workspace/` 目录中创建 `SOUL.md`、`MEMORY.md` 和 `USER.md`
- [ ] **创建启动脚本**：`.command` 文件使用正确的 `OPENCLAW_HOME` 路径写入并设置为可执行（`chmod +x`）
- [ ] **测试单个实例**：使用 `OPENCLAW_HOME=~/.openclaw openclaw gateway` 启动一个实例，验证它能连接到 Telegram
- [ ] **验证共享文件夹访问**：所有实例都可以读/写 `~/shared/`
- [ ] **将机器人添加到群组**：所有机器人以管理员权限添加到你的 Telegram 群组

**如果所有检查通过**，你就可以启动所有三个实例了！

---

## 配置步骤

### 步骤 1：创建实例目录

每个实例都需要自己的 `OPENCLAW_HOME`：

```bash
# 实例 C (Claude)
mkdir -p ~/.openclaw/workspace

# 实例 D (DeepSeek)
mkdir -p ~/.openclaw-deepseek/workspace

# 实例 G (Gemini)
mkdir -p ~/.openclaw-gemini/workspace

# 共享协作文件夹
mkdir -p ~/shared/setting
mkdir -p ~/shared/github
mkdir -p ~/shared/program
```

### 步骤 2：配置每个实例

在每个实例的根目录中创建 `config.yaml`。

**示例结构**（`~/.openclaw-<name>/config.yaml`）：

```yaml
# 模型配置
model: <provider>/<model-name>

# 频道配置
channels:
  telegram:
    enabled: true
    token: "<your-bot-token>"
    dmPolicy: open
    allowFrom:
      - "*"

# 可选：代理设置（如果在使用代理）
# proxy: http://proxy-host:port
```

> ⚠️ **切勿在配置文件中硬编码 API 密钥。** 请改用环境变量。

### 步骤 3：创建启动脚本

为每个实例创建一个 `.command` 文件：

**`OpenClaw_Claude.command`**：
```bash
#!/bin/bash
cd ~

# 通过环境变量设置 API 密钥
export ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY"

# 可选：代理配置
# export HTTP_PROXY="http://your-proxy:port"
# export HTTPS_PROXY="http://your-proxy:port"
# export NO_PROXY="localhost,127.0.0.1"

# 使用指定主目录启动
OPENCLAW_HOME=~/.openclaw openclaw gateway
```

**`OpenClaw_DeepSeek.command`**：
```bash
#!/bin/bash
cd ~

export DEEPSEEK_API_KEY="$DEEPSEEK_API_KEY"

OPENCLAW_HOME=~/.openclaw-deepseek openclaw gateway
```

**`OpenClaw_Gemini.command`**：
```bash
#!/bin/bash
cd ~

export GOOGLE_API_KEY="$GOOGLE_API_KEY"

OPENCLAW_HOME=~/.openclaw-gemini openclaw gateway
```

设置可执行权限：
```bash
chmod +x OpenClaw_*.command
```

### 步骤 4：初始化工作区文件

每个实例都需要自己的个性和记忆：

```bash
# 为每个实例目录执行
for dir in ~/.openclaw ~/.openclaw-deepseek ~/.openclaw-gemini; do
  cat > "$dir/workspace/SOUL.md" << 'EOF'
# SOUL.md
# 自定义此实例的个性
EOF

  cat > "$dir/workspace/MEMORY.md" << 'EOF'
# MEMORY.md - 长期记忆
EOF

  cat > "$dir/workspace/USER.md" << 'EOF'
# USER.md - 关于你的人类
EOF
done
```

### 步骤 5：启动所有实例

双击每个 `.command` 文件，或在单独的终端标签页中运行：

```bash
# 终端 1
OPENCLAW_HOME=~/.openclaw openclaw gateway

# 终端 2
OPENCLAW_HOME=~/.openclaw-deepseek openclaw gateway

# 终端 3
OPENCLAW_HOME=~/.openclaw-gemini openclaw gateway
```

---

## 隔离技术

### 进程级隔离

每个实例作为完全独立的操作系统进程运行：

| 方面 | 隔离方法 |
|--------|-----------------|
| **配置** | 独立的 `OPENCLAW_HOME` 目录 |
| **记忆** | 独立的 `MEMORY.md` 和 `workspace/` |
| **Cron** | 每个实例独立的 `cron/jobs.json` |
| **Telegram** | 每个实例唯一的机器人令牌 |
| **API 密钥** | 环境变量，不共享 |
| **日志** | 独立的日志目录 |

### 共享与隔离的内容

```
隔离（每个实例）：              共享（所有实例）：
├── config.yaml                   ~/shared/
├── workspace/                      ├── setting/     # 规则和配置文档
│   ├── MEMORY.md                   ├── github/      # 代码和文档
│   ├── SOUL.md                     └── program/     # 项目
│   └── AGENTS.md
├── cron/
└── logs/
```

### 环境变量隔离

绝不让 API 密钥在实例之间泄漏：

```bash
# 错误：所有实例都能看到的全局导出
export ANTHROPIC_API_KEY="sk-..."

# 正确：仅在特定的启动脚本中设置
# 只有 Claude 实例能看到这个密钥
```

---

## 控制与协作机制

### 共享文件夹结构

所有实例都读写 `~/shared/`：

```
~/shared/
├── setting/
│   ├── 群聊天规则.md          # 群组聊天行为规则
│   ├── 机器人简称对照表.md      # 机器人名单和角色
│   ├── cron-config-guide.md   # 定时器/提醒配置
│   └── api-tokens.md          # 令牌注册表（访问控制）
├── github/
│   └── (协作文档)
└── program/
    └── (项目文件夹)
```

### 群组聊天协调

将所有机器人添加到一个 Telegram 群组。在共享设置中定义规则：

1. **单一指挥官**：只有指定的人类操作员可以发布命令
2. **选择性响应**：机器人仅在操作员 @ 提及时才响应
3. **上下文感知**：每个机器人读取最近的群组历史记录以理解上下文
4. **角色层级**：指定一个"主导"机器人用于冲突解决

### 通过文件进行机器人间通信

机器人可以在共享文件夹中为彼此留言：

```bash
# 机器人 D 写入状态更新
echo "Task completed at $(date)" > ~/shared/status/d-last-update.txt

# 机器人 C 在下次检查时读取它
cat ~/shared/status/d-last-update.txt
```

### 基于 Cron 的监控

一个机器人可以监控另一个机器人的活动：

```json
{
  "name": "Check bot D status",
  "schedule": { "kind": "cron", "expr": "*/30 * * * *" },
  "sessionTarget": "isolated",
  "payload": {
    "kind": "agentTurn",
    "message": "Check if Bot D has posted any updates in the last 30 minutes."
  },
  "delivery": {
    "mode": "announce",
    "channel": "telegram",
    "to": "<group-chat-id>"
  }
}
```

---

## 不同模型的配置

### 模型选择

每个实例在 `config.yaml` 中指定其模型：

```yaml
# Claude 实例
model: anthropic/claude-opus-4-6

# DeepSeek 实例
model: deepseek/deepseek-chat

# Gemini 实例
model: google/gemini-2.5-pro
```

### 模型特定的环境变量

| 提供商 | 环境变量 | 说明 |
|----------|---------------------|-------|
| Anthropic | `ANTHROPIC_API_KEY` | Claude 模型 |
| DeepSeek | `DEEPSEEK_API_KEY` | DeepSeek 模型 |
| Google | `GOOGLE_API_KEY` | Gemini 模型 |
| OpenAI | `OPENAI_API_KEY` | GPT 模型 |

### 为每个实例自定义行为

**系统提示词** — 编辑每个实例的 `SOUL.md`：
```markdown
# 对于专注于代码的机器人
You specialize in code review and programming tasks.

# 对于专注于研究的机器人
You specialize in web research and summarization.
```

**模型参数** — 在 `config.yaml` 中调整：
```yaml
# 用于创意任务（更高的温度）
modelParams:
  temperature: 0.8

# 用于精确任务（更低的温度）
modelParams:
  temperature: 0.2
```

### 为每个角色选择合适的模型

| 角色 | 推荐模型 | 优势 |
|------|------------------|----------|
| 主导 / 复杂推理 | Claude | 细致的分析，安全性 |
| 高性价比批量任务 | DeepSeek | 速度，效率 |
| 多模态 / 搜索 | Gemini | 视觉，网络连接 |
| 代码生成 | GPT-4o / Claude | 强大的编码能力 |

---

## 最佳实践

### 1. 安全性
- **切勿在共享文件夹中存储 API 密钥**
- 仅使用环境变量存储机密
- 将 `api-tokens.md` 作为参考（仅包含令牌名称，不包含值）
- 限制共享文件夹的写权限，仅允许操作员命令

### 2. 资源管理
- 每个实例消耗内存约 300-500MB
- 使用 `ps aux | grep openclaw` 监控
- 考虑关闭未使用的实例以节省资源

### 3. 命名约定
- 在所有文档中使用一致的短名称（C、D、G）
- 在相关时用创建机器人的标识符作为共享文件的前缀
- 将共享设置保存在单个 `setting/` 目录中

### 4. 通信协议
- 明确定义机器人何时响应与保持静默的规则
- 使用指定的领导者进行冲突解决
- 批量定期检查以降低 API 成本

### 5. 维护
- 定期审查和清理共享文件夹
- 保持实例配置与共享规则同步
- 升级 OpenClaw 时同时更新所有实例：
  ```bash
  npm update -g openclaw
  # 然后重启所有实例
  ```

### 6. 监控和日志
- **进程监控**：使用 `ps aux | grep openclaw` 检查所有运行中的实例
- **内存使用**：使用 `top` 或 `htop` 监控；每个实例使用约 300-500MB
- **日志文件**：每个实例记录到自己的目录：
  ```bash
  # 查看特定实例的日志
  tail -f ~/.openclaw-<name>/logs/gateway.log

  # 检查错误
  grep -i error ~/.openclaw-<name>/logs/gateway.log | tail -20

  # 一次监控所有实例
  for dir in ~/.openclaw ~/.openclaw-deepseek ~/.openclaw-gemini; do
    echo "=== $(basename $dir) ==="
    tail -5 "$dir/logs/gateway.log" 2>/dev/null || echo "No logs found"
  done
  ```
- **健康检查**：创建一个 cron 任务定期检查实例健康状态：
  ```bash
  # 健康检查脚本
  for name in openclaw openclaw-deepseek openclaw-gemini; do
    if ps aux | grep -v grep | grep -q "$name"; then
      echo "✅ $name is running"
    else
      echo "❌ $name is NOT running"
    fi
  done
  ```

### 7. 备份和恢复
- **配置备份**：定期备份实例配置：
  ```bash
  # 备份所有实例配置
  backup_dir="~/openclaw-backup/$(date +%Y%m%d)"
  mkdir -p "$backup_dir"

  for dir in ~/.openclaw ~/.openclaw-deepseek ~/.openclaw-gemini; do
    if [ -d "$dir" ]; then
      cp -r "$dir/config.yaml" "$backup_dir/$(basename $dir)-config.yaml"
      echo "Backed up $(basename $dir)"
    fi
  done

  # 备份共享文件夹
  tar -czf "$backup_dir/shared.tar.gz" ~/shared/
  ```
- **工作区备份**：备份记忆和灵魂文件：
  ```bash
  # 备份工作区文件
  for dir in ~/.openclaw ~/.openclaw-deepseek ~/.openclaw-gemini; do
    if [ -d "$dir/workspace" ]; then
      tar -czf "$backup_dir/$(basename $dir)-workspace.tar.gz" -C "$dir" workspace/
    fi
  done
  ```
- **恢复过程**：
  1. 停止所有实例：`pkill -f openclaw-gateway`
  2. 恢复配置：`cp backup/config.yaml ~/.openclaw-<name>/`
  3. 恢复工作区：`tar -xzf backup/workspace.tar.gz -C ~/.openclaw-<name>/`
  4. 恢复共享文件夹：`tar -xzf backup/shared.tar.gz -C ~/`
  5. 重启实例
- **自动备份**：创建一个 cron 任务进行每周备份：
  ```bash
  # 添加到 crontab（每周日凌晨 2 点运行）
  0 2 * * 0 /path/to/backup-script.sh
  ```

---

## 故障排查

### 实例无法启动

```bash
# 检查是否有另一个实例正在使用相同的机器人令牌
ps aux | grep openclaw

# 验证配置
OPENCLAW_HOME=~/.openclaw-<name> openclaw doctor
```

### 机器人在群组中无响应

1. 验证机器人已以管理员权限添加到群组
2. 检查 `allowFrom` 包含 `"*"` 或特定用户 ID
3. 确保设置了 `dmPolicy: open`
4. 检查日志：`tail -f ~/.openclaw-<name>/logs/gateway.log`

### Telegram 令牌冲突

**症状**：当另一个实例启动时，一个机器人离线。

**原因**：两个实例使用相同的机器人令牌。

**解决方法**：每个实例必须有唯一的 Telegram 机器人令牌。通过 @BotFather 创建单独的机器人。

### 共享文件夹权限问题

```bash
# 确保所有实例都可以读/写
chmod -R 755 ~/shared/

# 检查所有权
ls -la ~/shared/
```

### Cron 任务未触发

- 使用 `isolated` + `agentTurn` + `delivery` 进行群组聊天提醒
- 在多机器人群组场景中避免使用 `main` + `systemEvent`
- 验证时区计算（北京时间 = UTC + 8）
- 详见 `~/shared/setting/cron-config-guide.md`

### 内存占用过高

```bash
# 检查每个实例的内存
ps aux | grep openclaw-gateway | awk '{print $11, $6/1024 "MB"}'

# 重启特定实例
# 查找并终止进程，然后重新启动
kill <PID>
```

---

## 快速参考

| 命令 | 用途 |
|---------|---------|
| `OPENCLAW_HOME=~/.openclaw-<name> openclaw gateway` | 启动实例 |
| `OPENCLAW_HOME=~/.openclaw-<name> openclaw gateway status` | 检查状态 |
| `ps aux \| grep openclaw` | 列出所有运行中的实例 |
| `ls ~/shared/setting/` | 查看共享配置 |
| `cat ~/shared/setting/机器人简称对照表.md` | 查看机器人名单 |

---

> **来源**：[CryptoMiaobug/4AI](https://github.com/CryptoMiaobug/4AI)
