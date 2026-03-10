# Multi OpenClaw on Mac：本机第三方多实例方案落地记录

更新时间：2026-03-09

## 背景

这台 Mac 上已经存在主 OpenClaw 实例，后来又逐步新增了三个专业分身：

- `~/.openclaw-form` → **Form**
- `~/.openclaw-wit` → **Wit**
- `~/.openclaw-lens` → **Lens**

目标是让四个实例长期共存、互不串线、各自独立在线。

---

## 当前正式实例拓扑

- 主实例：主控 / 通用 / 总协调
- **Form**：品牌 / 包装 / 电商设计
- **Wit**：品牌 / 包装 / 电商文案 / 新媒体文案
- **Lens**：平面 / 摄影 / 视频 / 音频

---

## 这次问题的根因

一开始以为是 Discord token 或模型 token 的问题，但后来确认：

### 1. 模型问题确实存在
两个新实例最初默认模型是：

- `zhipu/glm-5`

而该 provider 的 key 当时失效，所以日志里出现：

- `provider: zhipu`
- `model: glm-5`
- `401: token expired or incorrect`

### 2. 但更深层的问题是：多实例“配置分开了，启动没分开”
两个新实例虽然各自有：

- 独立目录
- 独立 `openclaw.json`
- 独立端口（18790 / 18800）

但最开始并没有形成**真正独立的常驻 gateway**。结果是：

- CLI/status 容易回落到主 gateway（18789）
- control-ui 看起来像两个实例随机掉线
- 新实例端口无人监听

---

## 参考方案来源

参考文章：

- <https://github.com/CryptoMiaobug/4AI/blob/main/Multi-OpenClaw-Setup-on-Mac.md>

这篇文章真正有用的核心不是“多开目录”，而是：

> 多实例要隔离的不只是目录，更是启动上下文。

也就是每个实例都要明确隔离：

- `OPENCLAW_STATE_DIR`
- `OPENCLAW_CONFIG_PATH`
- `OPENCLAW_GATEWAY_PORT`
- 独立启动入口 / 独立守护进程

---

## 最终采用的方案

### 一、实例目录

- 主实例：`~/.openclaw`
- Form 实例（目录仍为 `~/.openclaw-form`）
- Wit 实例（目录仍为 `~/.openclaw-wit`）
- Lens 实例：`~/.openclaw-lens`

### 二、端口规划

- 主实例：`18789`
- Form（目录仍为 `~/.openclaw-form`）：`18790`
- Wit（目录仍为 `~/.openclaw-wit`）：`18800`
- Lens：`18810`

### 三、先把两个新实例默认模型切走

为了先恢复可用性，把两个新实例默认模型从：

- `zhipu/glm-5`

改成了：

- `bailian/kimi-k2.5`

并把 `zhipu/glm-5` 放到 fallback。

### 四、修正桌面启动脚本

原来的桌面脚本是“临时会话模式”：

- 启动 gateway
- 打开 TUI
- TUI 退出后把 gateway 一起 kill

这只适合临时本地使用，不适合 Discord 长期在线 bot。

所以改成了：

- 没有监听时，`nohup openclaw gateway run` 启动常驻 gateway
- 已监听时，直接连接 TUI
- **不再因为 TUI 关闭就杀掉 gateway**

当前脚本：

- `/Users/yachen/ai-team-hub/scripts/OpenClaw_Form.command`
- `/Users/yachen/ai-team-hub/scripts/OpenClaw_Wit.command`
- `/Users/yachen/ai-team-hub/scripts/OpenClaw_Lens.command`

运维脚本：

- `/Users/yachen/ai-team-hub/ops/healthcheck-all.sh`
- `/Users/yachen/ai-team-hub/ops/start-all.sh`
- `/Users/yachen/ai-team-hub/ops/stop-all.sh`
- `/Users/yachen/ai-team-hub/ops/restart-all.sh`
- `/Users/yachen/ai-team-hub/ops/status-all.sh`

### 五、真正稳定的做法：为三个专业实例创建独立 LaunchAgent

新增三个 LaunchAgent：

- `~/Library/LaunchAgents/ai.openclaw.gateway.visual.plist`
- `~/Library/LaunchAgents/ai.openclaw.gateway.copy.plist`
- `~/Library/LaunchAgents/ai.openclaw.gateway.lens.plist`

#### Form LaunchAgent

- Label: `ai.openclaw.gateway.visual`
- `OPENCLAW_STATE_DIR=/Users/yachen/.openclaw-form`
- `OPENCLAW_CONFIG_PATH=/Users/yachen/.openclaw-form/openclaw.json`
- `OPENCLAW_GATEWAY_PORT=18790`

#### Wit LaunchAgent

- Label: `ai.openclaw.gateway.copy`
- `OPENCLAW_STATE_DIR=/Users/yachen/.openclaw-wit`
- `OPENCLAW_CONFIG_PATH=/Users/yachen/.openclaw-wit/openclaw.json`
- `OPENCLAW_GATEWAY_PORT=18800`

#### Lens LaunchAgent

- Label: `ai.openclaw.gateway.lens`
- `OPENCLAW_STATE_DIR=/Users/yachen/.openclaw-lens`
- `OPENCLAW_CONFIG_PATH=/Users/yachen/.openclaw-lens/openclaw.json`
- `OPENCLAW_GATEWAY_PORT=18810`

加载后验证成功。

---

## 当前验证结果

已确认：

- `http://127.0.0.1:18790/health` → `200`
- `http://127.0.0.1:18800/health` → `200`
- `http://127.0.0.1:18810/health` → `200`

说明：

- Form gateway 正在监听
- Wit gateway 正在监听
- Lens gateway 正在监听

LaunchAgent 状态：

- `ai.openclaw.gateway`（主实例）
- `ai.openclaw.gateway.visual`
- `ai.openclaw.gateway.copy`
- `ai.openclaw.gateway.lens`

四套已能并存。

---

## 相关文件清单

### 实例配置
- `/Users/yachen/.openclaw/openclaw.json`
- `/Users/yachen/.openclaw-form/openclaw.json`
- `/Users/yachen/.openclaw-wit/openclaw.json`
- `/Users/yachen/.openclaw-lens/openclaw.json`

### 启动脚本
- `/Users/yachen/ai-team-hub/scripts/OpenClaw_Form.command`
- `/Users/yachen/ai-team-hub/scripts/OpenClaw_Wit.command`
- `/Users/yachen/ai-team-hub/scripts/OpenClaw_Lens.command`

### 运维脚本
- `/Users/yachen/ai-team-hub/ops/healthcheck-all.sh`
- `/Users/yachen/ai-team-hub/ops/start-all.sh`
- `/Users/yachen/ai-team-hub/ops/stop-all.sh`
- `/Users/yachen/ai-team-hub/ops/restart-all.sh`
- `/Users/yachen/ai-team-hub/ops/status-all.sh`

### LaunchAgents
- `/Users/yachen/Library/LaunchAgents/ai.openclaw.gateway.plist`
- `/Users/yachen/Library/LaunchAgents/ai.openclaw.gateway.visual.plist`
- `/Users/yachen/Library/LaunchAgents/ai.openclaw.gateway.copy.plist`
- `/Users/yachen/Library/LaunchAgents/ai.openclaw.gateway.lens.plist`

### 日志目录
- `/Users/yachen/.openclaw/logs/`
- `/Users/yachen/.openclaw-form/logs/`
- `/Users/yachen/.openclaw-wit/logs/`
- `/Users/yachen/.openclaw-lens/logs/`

---

## 常用排查命令

### 1. 看四个 gateway 是否都在

```bash
launchctl list | grep -i openclaw
```

### 2. 看端口是否监听

```bash
python3 - <<'PY'
import urllib.request
for port in (18789, 18790, 18800, 18810):
    for path in ('/health',):
        url=f'http://127.0.0.1:{port}{path}'
        try:
            r=urllib.request.urlopen(url, timeout=3)
            print(url, '->', r.status)
        except Exception as e:
            print(url, '->', type(e).__name__, e)
PY
```

### 3. 看 Form / Wit / Lens 日志

```bash
tail -100 /Users/yachen/.openclaw-form/logs/gateway.err.log
tail -100 /Users/yachen/.openclaw-wit/logs/gateway.err.log
tail -100 /Users/yachen/.openclaw-lens/logs/gateway.err.log
```

### 4. 手动重载 LaunchAgent

```bash
launchctl unload ~/Library/LaunchAgents/ai.openclaw.gateway.visual.plist
launchctl load ~/Library/LaunchAgents/ai.openclaw.gateway.visual.plist

launchctl unload ~/Library/LaunchAgents/ai.openclaw.gateway.copy.plist
launchctl load ~/Library/LaunchAgents/ai.openclaw.gateway.copy.plist

launchctl unload ~/Library/LaunchAgents/ai.openclaw.gateway.lens.plist
launchctl load ~/Library/LaunchAgents/ai.openclaw.gateway.lens.plist
```

---

## 后续建议

### 建议 1：把失效的智谱 key 全量轮换
这次排查过程中，旧 key 已经暴露在本地输出里。应视为泄露。

建议：

- 重置智谱 key
- 重置相关 Discord / 其他 provider secrets（如果也出现在输出中）
- 再统一更新到配置里

### 建议 2：三个实例最好明确角色
例如：

- 主实例：总控 / 通用助手
- Visual：视觉、设计、图像、品牌方向
- Copy：文案、内容、表达、营销方向

### 建议 3：以后新增实例，先做“独立启动”再做“独立配置”
正确顺序应该是：

1. 建目录
2. 配 openclaw.json
3. 设定专属端口
4. 建专属启动脚本 / LaunchAgent
5. 验证端口监听
6. 最后再接入 Discord / 其他渠道

别再只建目录就以为实例已经独立了。

---

## 一句话总结

这次真正学到的不是“怎么多开 OpenClaw”，而是：

> 多实例是否成立，不取决于你建了几个目录，而取决于你是否给每个实例建立了独立、稳定、可验证的运行态。
