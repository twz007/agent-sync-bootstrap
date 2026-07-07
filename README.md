# Agent Sync Bootstrap

一键同步 AI Agent 配置到新设备。

## 快速开始

在新设备上运行：

```bash
curl -sL https://raw.githubusercontent.com/twz007/agent-sync-bootstrap/main/bootstrap.sh | bash
```

## 这个脚本做什么

1. **检查必要依赖**
   - Git（必须）
   - Python3（必须）
   - Node.js（可选，部分agent需要）
   - GitHub CLI（自动安装）

2. **认证 GitHub**
   - 检查是否已登录
   - 未登录则引导设备码认证

3. **验证权限**
   - 检查是否有权限访问私有配置仓库

4. **拉取配置**
   - Clone 或更新私有配置仓库到 `~/workspace/agent-config-vault`

5. **安装同步能力**
   - 为本地已安装的 agent 安装同步 skill/instructions

## 支持的 Agent

- **Hermes Agent** - 安装 skill 到 `~/.hermes/skills/devops/agent-sync/`
- **Claude Code** - 写入同步指令到 `~/.claude/CLAUDE.md`
- **Claude Desktop (3p)** - 同步配置到 `~/Library/Application Support/Claude-3p/`
- **Codex** - 写入同步指令到 `~/.codex/AGENTS.md`
- **OpenCode** - 安装同步 agent 到 `~/.config/opencode/agents/sync.md`
- **OpenClaw** - 安装 skill 到 `~/.openclaw/skills/agent-sync/`

## 同步后使用

启动任意 agent，告诉它：

```
同步我的agent配置
```

Agent 会自动：
1. 检测本地已安装的 agent
2. 从配置仓库拉取最新配置
3. 遇到冲突时询问你
4. 遇到密钥时询问你
5. 完成同步

## 前提条件

- **macOS / Linux / Windows (WSL)**
- **网络连接**（能访问 GitHub）
- **GitHub 账号**（需要有私有仓库权限）

## 故障排除

### 无法访问 GitHub

如果在国内，可能需要配置代理：

```bash
export https_proxy=http://127.0.0.1:7897
export http_proxy=http://127.0.0.1:7897
curl -sL https://raw.githubusercontent.com/twz007/agent-sync-bootstrap/main/bootstrap.sh | bash
```

### 没有私有仓库权限

联系仓库管理员申请 `twz007/agent-config-vault` 的读取权限。

### Python/Node 未安装

脚本会提示安装命令，按提示安装后重新运行。

## 仓库结构

```
agent-sync-bootstrap/          # 本仓库（公开）
├── bootstrap.sh               # 引导脚本
└── README.md

agent-config-vault/            # 私有仓库
├── bootstrap.sh               # 实际安装脚本
├── skill/                     # Hermes/OpenClaw skill
├── instructions/              # Claude/Codex/OpenCode 指令
├── hermes/                    # Hermes 配置
├── openclaw/                  # OpenClaw 配置
├── claude-code/               # Claude Code 配置
├── claude-desktop/            # Claude Desktop 配置
├── codex/                     # Codex 配置
├── opencode/                  # OpenCode 配置
└── device-overlays/           # 设备特定配置
```

## 安全说明

- **密钥不会同步** - API key、token 等敏感信息只存在本地
- **私有仓库** - 配置内容通过私有 Git 仓库管理
- **权限控制** - 只有授权用户才能访问配置

## 相关仓库

- **公开引导仓库**: `twz007/agent-sync-bootstrap`（本仓库）
- **私有配置仓库**: `twz007/agent-config-vault`（需要权限）

## License

MIT
