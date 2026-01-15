# Makefile for VSCode Remote Docker Container

IMAGE_NAME := vscode-remote
CONTAINER_NAME := vscode-dev
SSH_PORT := 2222
SSH_USER := root
ROOT_PASSWORD ?= root

# 持久化目录
DATA_DIR := $(HOME)/.vscode-remote
DIRS := $(DATA_DIR)/pip $(DATA_DIR)/pip-cache $(DATA_DIR)/npm $(DATA_DIR)/go \
        $(DATA_DIR)/workspace $(DATA_DIR)/project $(DATA_DIR)/vscode-server $(DATA_DIR)/claude

# 颜色定义
COLOR_RESET := \033[0m
COLOR_BOLD := \033[1m
COLOR_GREEN := \033[32m
COLOR_YELLOW := \033[33m
COLOR_BLUE := \033[34m

.PHONY: help build start stop restart clean ssh logs

help:
	@echo "$(COLOR_BOLD)VSCode Remote Docker Container - Makefile$(COLOR_RESET)"
	@echo ""
	@echo "$(COLOR_BLUE)Available targets:$(COLOR_RESET)"
	@echo "  $(COLOR_GREEN)make$(COLOR_RESET)            - Start the container (default)"
	@echo "  $(COLOR_GREEN)make build$(COLOR_RESET)         - Build the Docker image"
	@echo "  $(COLOR_GREEN)make stop$(COLOR_RESET)          - Stop the container"
	@echo "  $(COLOR_GREEN)make restart$(COLOR_RESET)       - Restart the container"
	@echo "  $(COLOR_GREEN)make clean$(COLOR_RESET)         - Remove the container"
	@echo "  $(COLOR_GREEN)make ssh$(COLOR_RESET)            - SSH into the container"
	@echo "  $(COLOR_GREEN)make logs$(COLOR_RESET)           - View container logs"
	@echo ""
	@echo "$(COLOR_YELLOW)Custom variables:$(COLOR_RESET)"
	@echo "  $(COLOR_GREEN)SSH_PORT$(COLOR_RESET)         - Custom SSH port (default: 2222)"
	@echo "  $(COLOR_GREEN)ROOT_PASSWORD$(COLOR_RESET)   - Root password (default: root)"
	@echo ""
	@echo "$(COLOR_YELLOW)Example:$(COLOR_RESET)"
	@echo "  make SSH_PORT=2223 ROOT_PASSWORD=mypass"

start: $(DATA_DIR)
	@echo "$(COLOR_GREEN)创建持久化目录...$(COLOR_RESET)"
	@mkdir -p $(DIRS)
	@if docker ps -a | grep -q $(CONTAINER_NAME); then \
		echo "$(COLOR_YELLOW)停止并删除现有容器...$(COLOR_RESET)"; \
		docker stop $(CONTAINER_NAME) 2>/dev/null || true; \
		docker rm $(CONTAINER_NAME) 2>/dev/null || true; \
	fi
	@echo "$(COLOR_GREEN)启动容器...$(COLOR_RESET)"
	@docker run -d \
		--name $(CONTAINER_NAME) \
		--restart unless-stopped \
		-p $(SSH_PORT):22 \
		-v $(DATA_DIR)/pip:/root/.local/lib/python3.12/site-packages \
		-v $(DATA_DIR)/pip-cache:/root/.cache/pip \
		-v $(DATA_DIR)/npm:/root/.npm \
		-v $(DATA_DIR)/go:/root/go \
		-v $(DATA_DIR)/workspace:/root/workspace \
		-v $(DATA_DIR)/project:/root/project \
		-v $(DATA_DIR)/vscode-server:/root/.vscode-server \
		-v $(DATA_DIR)/claude:/root/.claude \
		--hostname vscode-remote \
		$(IMAGE_NAME)
	@if [ "$(ROOT_PASSWORD)" != "root" ]; then \
		docker exec $(CONTAINER_NAME) bash -c "echo root:$$ROOT_PASSWORD | chpasswd"; \
	fi
	@echo ""
	@echo "$(COLOR_BOLD)===================================${COLOR_RESET}"
	@echo "$(COLOR_GREEN)容器启动成功！$(COLOR_RESET)"
	@echo "$(COLOR_BOLD)===================================${COLOR_RESET}"
	@echo "容器名称: $(CONTAINER_NAME)"
	@echo "SSH 端口: $(SSH_PORT)"
	@echo "用户名: $(SSH_USER)"
	@echo "密码: $(ROOT_PASSWORD)"
	@echo "重启策略: unless-stopped (自动重启)"
	@echo ""
	@echo "$(COLOR_BLUE)持久化目录:$(COLOR_RESET)"
	@echo "  - pip 包: $(DATA_DIR)/pip"
	@echo "  - pip 缓存: $(DATA_DIR)/pip-cache"
	@echo "  - npm 包: $(DATA_DIR)/npm"
	@echo "  - go 包: $(DATA_DIR)/go"
	@echo "  - workspace: $(DATA_DIR)/workspace"
	@echo "  - vscode-server: $(DATA_DIR)/vscode-server"
	@echo "  - claude: $(DATA_DIR)/claude"
	@echo "  - 项目目录: $(DATA_DIR)/project"
	@echo ""
	@echo "$(COLOR_BLUE)VSCode SSH 连接配置 (~/.ssh/config):$(COLOR_RESET)"
	@echo ""
	@echo "Host vscode-remote"
	@echo "    HostName localhost"
	@echo "    Port $(SSH_PORT)"
	@echo "    User $(SSH_USER)"
	@echo "$(COLOR_BOLD)===================================${COLOR_RESET)"

build:
	@echo "$(COLOR_GREEN)构建 Docker 镜像...$(COLOR_RESET)"
	docker build -t $(IMAGE_NAME) .

stop:
	@echo "$(COLOR_YELLOW)停止容器...$(COLOR_RESET)"
	docker stop $(CONTAINER_NAME) || true

restart: stop start

clean:
	@echo "$(COLOR_YELLOW)删除容器...$(COLOR_RESET)"
	-docker stop $(CONTAINER_NAME) 2>/dev/null || true
	docker rm $(CONTAINER_NAME) 2>/dev/null || true

ssh:
	docker exec -it $(CONTAINER_NAME) bash

logs:
	docker logs -f $(CONTAINER_NAME)

.DEFAULT_GOAL := start
