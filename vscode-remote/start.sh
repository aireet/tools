#!/bin/bash

# 镜像名称
IMAGE_NAME="vscode-remote"
# 容器名称
CONTAINER_NAME="vscode-dev"
# SSH 端口映射 (本地端口:容器端口)
SSH_PORT=2222
# 用户密码 (默认: vscode)
USER_PASSWORD=${1:-vscode}

# 创建持久化目录
echo "创建持久化目录..."
mkdir -p $HOME/.vscode-remote/pip
mkdir -p $HOME/.vscode-remote/npm
mkdir -p $HOME/.vscode-remote/go
mkdir -p $HOME/.vscode-remote/project

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
    -v $HOME/.vscode-remote/pip:/home/vscode/.local/lib/python3.10/site-packages \
    -v $HOME/.vscode-remote/pip-cache:/root/.cache/pip \
    -v $HOME/.vscode-remote/npm:/home/vscode/.npm \
    -v $HOME/.vscode-remote/go:/home/vscode/go \
    -v $HOME/.vscode-remote/project:/home/vscode/project \
    --hostname vscode-remote \
    -e USER_PASSWORD=$USER_PASSWORD \
    $IMAGE_NAME

# 设置密码 (如果与镜像默认密码不同)
if [ "$USER_PASSWORD" != "vscode" ]; then
    docker exec $CONTAINER_NAME bash -c "echo vscode:$USER_PASSWORD | chpasswd"
fi

echo ""
echo "==================================="
echo "容器启动成功！"
echo "==================================="
echo "容器名称: $CONTAINER_NAME"
echo "SSH 端口: $SSH_PORT"
echo "用户名: vscode"
echo "密码: $USER_PASSWORD"
echo "重启策略: unless-stopped (自动重启)"
echo ""
echo "持久化目录:"
echo "  - pip 包: $HOME/.vscode-remote/pip"
echo "  - pip 缓存: $HOME/.vscode-remote/pip-cache"
echo "  - npm 包: $HOME/.vscode-remote/npm"
echo "  - go 包: $HOME/.vscode-remote/go"
echo "  - 项目目录: $HOME/.vscode-remote/project"
echo ""
echo "VSCode SSH 连接配置 (~/.ssh/config):"
echo ""
echo "Host vscode-remote"
echo "    HostName localhost"
echo "    Port $SSH_PORT"
echo "    User vscode"
echo "==================================="
