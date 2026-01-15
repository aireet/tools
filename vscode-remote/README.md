# VSCode Remote Docker Container

一个用于 VS Code Remote 开发的 Docker 容器环境。

## 功能特性

- 基于 Ubuntu 24.04
- 预装常用开发工具：
  - git, vim, nano
  - build-essential (gcc, g++, make)
  - Python 3 + pip + venv
  - Node.js + npm
  - Go 1.25.0
  - Docker CLI
  - Claude Code CLI
- SSH 服务器支持远程连接
- 非 root 用户支持 (默认用户名: vscode)
- 自动重启策略 (unless-stopped)
- SSH 公钥免密登录支持
- Claude Code 配置持久化

## 快速开始

### 1. 构建镜像

```bash
docker build -t vscode-remote .
```

### 2. 启动容器

```bash
./start.sh
```

### 3. VS Code Remote 连接

编辑 `~/.ssh/config`：
```
Host vscode-remote
    HostName localhost
    Port 2222
    User root
```

然后在 VS Code 中按 `Ctrl+Shift+P`，输入 `Remote-SSH: Connect to Host...`，选择 `vscode-remote`。

## 持久化目录

容器启动后，以下数据会持久化到 `~/.vscode-remote/`：

- `pip/` - Python 包
- `pip-cache/` - pip 缓存
- `npm/` - npm 包
- `go/` - Go 包
- `workspace/` - 开发代码目录
- `project/` - 项目目录
- `vscode-server/` - VS Code Server (避免重复下载)
- `claude/` - Claude Code 配置
- `ssh-keys/` - SSH 公钥 (免密登录)

## SSH 免密登录

添加公钥到持久化目录后，容器会自动使用公钥认证，无需密码：

```bash
# 1. 复制公钥到持久化目录
cp ~/.ssh/id_xxx.pub ~/.vscode-remote/ssh-keys/

# 2. 重启容器（或使用 make restart）
./start.sh
```

如果公钥已经在 `~/.vscode-remote/ssh-keys/` 目录中，重启容器后会自动应用。

## 环境变量

以下环境变量会自动从主机传递到容器：

- `ANTHROPIC_BASE_URL` - API 基础 URL
- `ANTHROPIC_AUTH_TOKEN` - API 认证令牌
- `ANTHROPIC_DEFAULT_SONNET_MODEL` - 默认 Sonnet 模型
- `ANTHROPIC_DEFAULT_OPUS_MODEL` - 默认 Opus 模型
- `ANTHROPIC_DEFAULT_HAIKU_MODEL` - 默认 Haiku 模型

## 自定义配置

### 修改 SSH 端口

```bash
./start.sh SSH_PORT=2223
```

### 修改 root 密码

```bash
./start.sh ROOT_PASSWORD=mypass
```

### 同时修改

```bash
./start.sh SSH_PORT=2223 ROOT_PASSWORD=mypass
```

## 其他命令

```bash
make help        # 查看帮助
make build        # 构建镜像
make stop         # 停止容器
make restart      # 重启容器
make clean        # 删除容器
make ssh          # 进入容器
make logs         # 查看日志
```

## 默认登录信息

| 用户名 | 密码 |
|--------|------|
| root   | root  |

## 注意事项

- 生产环境请修改默认密码或使用 SSH 公钥认证
- 默认 SSH 端口为 2222，可根据需要修改
- 时区设置为 Asia/Shanghai，可在 Dockerfile 中修改 `TZ` 环境变量
- Claude Code 配置会自动从 `~/.claude/settings.json` 复制到持久化目录
