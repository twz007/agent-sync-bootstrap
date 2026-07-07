#!/bin/bash
# Agent Sync Bootstrap - Public Entry Point
# 新设备引导脚本：检查依赖、认证GitHub、拉取私有配置仓库

set -e

echo "🚀 Agent Sync Bootstrap"
echo "======================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查函数
check_command() {
    if command -v "$1" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 已安装: $(command -v $1)"
        return 0
    else
        echo -e "${RED}✗${NC} $1 未安装"
        return 1
    fi
}

# 1. 检查 Git
echo "📦 检查必要依赖..."
echo ""

if ! check_command git; then
    echo ""
    echo "请先安装 Git:"
    echo "  macOS:   brew install git"
    echo "  Windows: winget install Git.Git"
    echo "  Linux:   sudo apt install git"
    exit 1
fi

# 2. 检查 Python3
if ! check_command python3; then
    echo ""
    echo "请先安装 Python3:"
    echo "  macOS:   brew install python3"
    echo "  Windows: winget install Python.Python.3.11"
    echo "  Linux:   sudo apt install python3"
    exit 1
fi

# 检查 Python 版本
PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
echo "  Python 版本: $PYTHON_VERSION"

# 3. 检查 Node.js（可选，某些agent需要）
if ! check_command node; then
    echo -e "${YELLOW}⚠${NC} Node.js 未安装（部分agent可能需要）"
    echo "  安装命令:"
    echo "    macOS:   brew install node"
    echo "    Windows: winget install OpenJS.NodeJS"
    echo "    Linux:   sudo apt install nodejs npm"
    echo ""
    read -p "是否继续? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    NODE_VERSION=$(node --version 2>&1)
    echo "  Node 版本: $NODE_VERSION"
fi

echo ""

# 4. 检查 GitHub CLI
if ! check_command gh; then
    echo ""
    echo "📦 安装 GitHub CLI..."
    echo ""
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            brew install gh
        else
            echo "请先安装 Homebrew: https://brew.sh"
            exit 1
        fi
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        # Windows
        winget install GitHub.cli
    else
        # Linux
        if command -v apt &> /dev/null; then
            sudo apt update && sudo apt install gh
        else
            echo "请手动安装 GitHub CLI: https://cli.github.com"
            exit 1
        fi
    fi
    
    echo -e "${GREEN}✓${NC} GitHub CLI 安装完成"
fi

# 5. 检查 GitHub 认证
echo ""
echo "🔐 检查 GitHub 认证..."
echo ""

if ! gh auth status &> /dev/null; then
    echo "需要登录 GitHub..."
    echo ""
    echo "将打开浏览器进行设备码认证，请在任意设备上确认。"
    echo ""
    gh auth login --web
else
    echo -e "${GREEN}✓${NC} GitHub 已认证"
    gh auth status --show-token 2>&1 | grep -E "Logged in to|account" || true
fi

echo ""

# 6. 验证私有仓库权限
echo "🔍 验证私有仓库权限..."
echo ""

PRIVATE_REPO="twz007/agent-config-vault"

if ! gh repo view "$PRIVATE_REPO" &> /dev/null; then
    echo -e "${RED}✗${NC} 没有权限访问私有仓库: $PRIVATE_REPO"
    echo ""
    echo "请联系仓库管理员申请权限，或检查仓库地址是否正确。"
    exit 1
fi

echo -e "${GREEN}✓${NC} 有权限访问私有仓库: $PRIVATE_REPO"
echo ""

# 7. Clone 或更新私有仓库
REPO_DIR="$HOME/workspace/agent-config-vault"

if [ -d "$REPO_DIR" ]; then
    echo "📦 更新配置仓库..."
    cd "$REPO_DIR"
    git pull origin main
else
    echo "📦 克隆配置仓库..."
    mkdir -p "$HOME/workspace"
    gh repo clone "$PRIVATE_REPO" "$REPO_DIR"
fi

echo ""

# 8. 执行私有仓库的 bootstrap.sh
echo "🔧 执行配置同步..."
echo ""

bash "$REPO_DIR/bootstrap.sh"

echo ""
echo "✅ 完成！"
echo ""
echo "现在你可以："
echo "1. 启动任意 agent（Hermes/Claude/Codex/OpenCode/OpenClaw）"
echo "2. 告诉它: '同步我的agent配置'"
echo "3. Agent 会自动执行同步流程"
