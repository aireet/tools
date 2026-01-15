#!/bin/bash

# 镜像名称
IMAGE_NAME="vscode-remote"
# 容器名称
CONTAINER_NAME="vscode-dev"
# SSH 端口映射 (本地端口:容器端口)
SSH_PORT=2222
# 用户名
SSH_USER="root"
# root 密码 (默认: root)
ROOT_PASSWORD=${1:-root}

# 持久化目录
DATA_DIR="$HOME/.vscode-remote"

# Claude Code
ANTHROPIC_BASE_URL=""
ANTHROPIC_AUTH_TOKEN=""


# 创建持久化目录
echo "创建持久化目录..."
mkdir -p "$DATA_DIR/pip"
mkdir -p "$DATA_DIR/pip-cache"
mkdir -p "$DATA_DIR/npm"
mkdir -p "$DATA_DIR/go"
mkdir -p "$DATA_DIR/go-env"
mkdir -p "$DATA_DIR/workspace"
mkdir -p "$DATA_DIR/project"
mkdir -p "$DATA_DIR/vscode-server"
mkdir -p "$DATA_DIR/claude"
mkdir -p "$DATA_DIR/ssh-keys"
mkdir -p "$DATA_DIR/py-venvs"

# 复制 Claude Code settings
if [ ! -f "$DATA_DIR/claude/settings.json" ]; then
    cp ~/.claude/settings.json "$DATA_DIR/claude/settings.json"
fi

# 停止并删除已存在的容器
if docker ps -a | grep -q $CONTAINER_NAME; then
    echo "停止并删除现有容器..."
    docker stop $CONTAINER_NAME 2>/dev/null
    docker rm $CONTAINER_NAME 2>/dev/null
fi

# 启动容器
echo "启动容器..."
docker run -d \
    --name $CONTAINER_NAME \
    --restart unless-stopped \
    -p $SSH_PORT:22 \
    -v $DATA_DIR/pip:/root/.local/lib/python3.12/site-packages \
    -v $DATA_DIR/pip-cache:/root/.cache/pip \
    -v $DATA_DIR/npm:/root/.npm \
    -v $DATA_DIR/go:/root/go \
    -v $DATA_DIR/go-env:/root/.config/go \
    -v $DATA_DIR/workspace:/root/workspace \
    -v $DATA_DIR/project:/root/project \
    -v $DATA_DIR/vscode-server:/root/.vscode-server \
    -v $DATA_DIR/py-venvs:/root/py-venvs \
    -v $DATA_DIR/claude:/root/.claude \
    -v $DATA_DIR/ssh-keys:/root/.ssh/authorized_keys.d:ro \
    -e ANTHROPIC_BASE_URL=${ANTHROPIC_BASE_URL} \
    -e ANTHROPIC_AUTH_TOKEN=${ANTHROPIC_AUTH_TOKEN} \

    --hostname vscode-remote \
    $IMAGE_NAME

# 设置 root 密码 (如果与默认密码不同)
if [ "$ROOT_PASSWORD" != "root" ]; then
    docker exec $CONTAINER_NAME bash -c "echo root:$ROOT_PASSWORD | chpasswd"
fi

echo ""
echo "==================================="
echo "容器启动成功！"
echo "==================================="
echo "容器名称: $CONTAINER_NAME"
echo "SSH 端口: $SSH_PORT"
echo "用户名: $SSH_USER"
echo "密码: $ROOT_PASSWORD"
echo "重启策略: unless-stopped (自动重启)"
echo ""
echo "持久化目录:"
echo "  - pip 包: $DATA_DIR/pip"
echo "  - pip 缓存: $DATA_DIR/pip-cache"
echo "  - npm 包: $DATA_DIR/npm"
echo "  - go 包: $DATA_DIR/go"
echo "  - go env: $DATA_DIR/go-env"
echo "  - workspace: $DATA_DIR/workspace"
echo "  - vscode-server: $DATA_DIR/vscode-server"
echo "  - claude: $DATA_DIR/claude"
echo "  - ssh-keys: $DATA_DIR/ssh-keys (添加公钥到此目录可免密登录)"
echo "  - 项目目录: $DATA_DIR/project"
echo ""
echo "VSCode SSH 连接配置 (~/.ssh/config):"
echo ""
echo "Host vscode-remote"
echo "    HostName localhost"
echo "    Port $SSH_PORT"
echo "    User $SSH_USER"
echo "==================================="
