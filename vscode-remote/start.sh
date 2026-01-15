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

# 创建持久化目录
echo "创建持久化目录..."
mkdir -p "$DATA_DIR/pip"
mkdir -p "$DATA_DIR/pip-cache"
mkdir -p "$DATA_DIR/npm"
mkdir -p "$DATA_DIR/go"
mkdir -p "$DATA_DIR/workspace"
mkdir -p "$DATA_DIR/project"
mkdir -p "$DATA_DIR/vscode-server"
mkdir -p "$DATA_DIR/claude"

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
    -v $DATA_DIR/workspace:/root/workspace \
    -v $DATA_DIR/project:/root/project \
    -v $DATA_DIR/vscode-server:/root/.vscode-server \
    -v $DATA_DIR/claude:/root/.claude \
    -e ANTHROPIC_BASE_URL=${ANTHROPIC_BASE_URL:-} \
    -e ANTHROPIC_AUTH_TOKEN=${ANTHROPIC_AUTH_TOKEN:-} \
    -e ANTHROPIC_DEFAULT_SONNET_MODEL=${ANTHROPIC_DEFAULT_SONNET_MODEL:-} \
    -e ANTHROPIC_DEFAULT_OPUS_MODEL=${ANTHROPIC_DEFAULT_OPUS_MODEL:-} \
    -e ANTHROPIC_DEFAULT_HAIKU_MODEL=${ANTHROPIC_DEFAULT_HAIKU_MODEL:-} \
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
echo "  - workspace: $DATA_DIR/workspace"
echo "  - vscode-server: $DATA_DIR/vscode-server"
echo "  - claude: $DATA_DIR/claude"
echo "  - 项目目录: $DATA_DIR/project"
echo ""
echo "VSCode SSH 连接配置 (~/.ssh/config):"
echo ""
echo "Host vscode-remote"
echo "    HostName localhost"
echo "    Port $SSH_PORT"
echo "    User $SSH_USER"
echo "==================================="
