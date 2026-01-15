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

# 创建持久化目录
echo "创建持久化目录..."
mkdir -p $HOME/.vscode-remote/pip
mkdir -p $HOME/.vscode-remote/npm
mkdir -p $HOME/.vscode-remote/go
mkdir -p $HOME/.vscode-remote/workspace
mkdir -p $HOME/.vscode-remote/project
mkdir -p $HOME/.vscode-remote/vscode-server

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
    -v $HOME/.vscode-remote/pip:/root/.local/lib/python3.12/site-packages \
    -v $HOME/.vscode-remote/pip-cache:/root/.cache/pip \
    -v $HOME/.vscode-remote/npm:/root/.npm \
    -v $HOME/.vscode-remote/go:/root/go \
    -v $HOME/.vscode-remote/workspace:/root/workspace \
    -v $HOME/.vscode-remote/project:/root/project \
    -v $HOME/.vscode-remote/vscode-server:/root/.vscode-server \
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
echo "  - pip 包: $HOME/.vscode-remote/pip"
echo "  - pip 缓存: $HOME/.vscode-remote/pip-cache"
echo "  - npm 包: $HOME/.vscode-remote/npm"
echo "  - go 包: $HOME/.vscode-remote/go"
echo "  - workspace: $HOME/.vscode-remote/workspace"
echo "  - vscode-server: $HOME/.vscode-remote/vscode-server"
echo "  - 项目目录: $HOME/.vscode-remote/project"
echo ""
echo "VSCode SSH 连接配置 (~/.ssh/config):"
echo ""
echo "Host vscode-remote"
echo "    HostName localhost"
echo "    Port $SSH_PORT"
echo "    User $SSH_USER"
echo "==================================="
