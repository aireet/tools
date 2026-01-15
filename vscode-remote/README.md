# VSCode Remote Docker Container

一个用于 VS Code Remote 开发的 Docker 容器环境。

## 功能特性

- 基于 Ubuntu 22.04
- 预装常用开发工具：
  - git, vim, nano
  - build-essential (gcc, g++, make)
  - Python 3 + pip + venv
  - Node.js + npm
  - Go 1.25.0
  - Docker CLI
- SSH 服务器支持远程连接
- 非 root 用户支持 (默认用户名: vscode)

## 快速开始

### 1. 构建镜像

```bash
docker build -t vscode-remote .
```

### 2. 运行容器

#### 基础运行

```bash
docker run -d -p 2222:22 --name vscode-dev vscode-remote
```

#### 挂载本地目录

```bash
docker run -d -p 2222:22 -v /path/to/your/project:/home/vscode/project --name vscode-dev vscode-remote
```

#### 使用 Docker-in-Docker

如果需要在容器内运行 Docker 命令：

```bash
docker run -d -p 2222:22 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd)/project:/home/vscode/project \
  --name vscode-dev vscode-remote
```

### 3. 配置 VS Code Remote

#### 方法一：使用 Remote - SSH

1. 安装 VS Code 扩展：Remote - SSH
2. 配置 SSH 连接，编辑 `~/.ssh/config`：

```
Host vscode-remote
    HostName localhost
    Port 2222
    User vscode
```

3. 连接到远程主机：按 `F1` 或 `Ctrl+Shift+P`，输入 `Remote-SSH: Connect to Host...`，选择 `vscode-remote`

#### 方法二：使用 Remote - Containers

1. 安装 VS Code 扩展：Dev Containers
2. 按 `F1` 或 `Ctrl+Shift+P`，输入 `Dev Containers: Attach to Running Container...`
3. 选择 `vscode-dev` 容器

## 自定义配置

### 修改用户名

构建时指定用户名：

```bash
docker build --build-arg USERNAME=myuser -t vscode-remote .
```

### 修改 SSH 密码

编辑 Dockerfile，修改 `echo 'root:root' | chpasswd` 中的密码。

## 默认登录信息

| 用户名 | 密码 |
|--------|------|
| root   | root |
| vscode | (无密码，使用 SSH key 推荐) |

## 注意事项

- 生产环境请修改默认密码或使用 SSH 公钥认证
- 默认 SSH 端口为 2222，可根据需要修改
- 时区设置为 Asia/Shanghai，可在 Dockerfile 中修改 `TZ` 环境变量
