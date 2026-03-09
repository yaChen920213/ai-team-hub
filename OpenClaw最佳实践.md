# OpenClaw 最佳实践

## 核心配置要点

### 1. 环境变量清理
**关键问题：** 环境变量会覆盖 `openclaw.json` 配置，导致 HTTP 401 错误。

**解决方案：**
```bash
unset ANTHROPIC_AUTH_TOKEN
unset ANTHROPIC_BASE_URL
```

### 2. Discord 配置

#### Bot 权限
- **Message Content Intent**：必须启用
- **Server Members Intent**：建议启用

#### 授权配置
```json
"channels": {
  "discord": {
    "enabled": true,
    "token": "YOUR_BOT_TOKEN",
    "groupPolicy": "open",
    "guilds": {
      "YOUR_GUILD_ID": {
        "requireMention": false,
        "users": ["*"],  // 关键：允许所有用户使用命令
        "channels": {
          "*": { "allow": true }
        }
      }
    }
  }
}
```

### 3. 模型配置

#### 推理模型配置
**问题：** Kimi K2.5 等推理模型需要特殊处理。

**正确配置：**
```json
{
  "id": "kimi-k2.5",
  "reasoning": false,  // 必须设为 false
  "input": ["text", "image"],
  "cost": {
    "input": 0.00001,
    "output": 0.00001,
    "cacheRead": 0,
    "cacheWrite": 0
  },
  "contextWindow": 256000,
  "maxTokens": 8192
}
```

#### 常用模型配置
- **Zhipu AI**: `https://api.z.ai/api/anthropic` (Anthropic Messages API)
- **Moonshot/Kimi**: `https://api.moonshot.cn/v1` (OpenAI Completions API)
- **Cursor AI**: `https://api.cursorai.art` (OpenAI Completions API)

## 常见问题排查

### HTTP 401 错误
1. 检查环境变量是否已清除
2. 验证 API Key 是否正确
3. 确认 baseUrl 配置正确

### "You are not authorized to use this command"
- 在 guild 配置中添加 `"users": ["*"]`

### "Message ordering conflict"
1. 检查模型 `reasoning` 字段是否为 false
2. 清除会话缓存：删除 `~/.openclaw/agents/main/sessions/*`
3. 清除记忆缓存：删除 `~/.openclaw/workspace/memory/*`

### 网关连接失败
```bash
# 重启网关
cd /Users/yachen/openclaw
unset ANTHROPIC_AUTH_TOKEN
unset ANTHROPIC_BASE_URL
npx openclaw gateway &
```

## 启动流程

1. **清除环境变量**
   ```bash
   unset ANTHROPIC_AUTH_TOKEN ANTHROPIC_BASE_URL
   ```

2. **启动网关**
   ```bash
   npx openclaw gateway
   ```

3. **验证运行状态**
   ```bash
   lsof -i :18789  # 检查网关端口
   ```

## 目录结构
- 配置文件：`~/.openclaw/openclaw.json`
- 会话缓存：`~/.openclaw/agents/main/sessions/`
- 记忆文件：`~/.openclaw/workspace/memory/`
- 日志文件：`/tmp/openclaw/openclaw-YYYY-MM-DD.log`

## 版本信息
- 当前版本：2026.1.30
- 网关端口：18789
- Discord Bot ID：1470392312445276357
