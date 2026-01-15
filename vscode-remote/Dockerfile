FROM swr.cn-north-4.myhuaweicloud.com/ddn-k8s/mcr.microsoft.com/devcontainers/cpp:ubuntu-24.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Use Aliyun mirror for Ubuntu
RUN rm -f /etc/apt/sources.list.d/* && \
    echo "deb https://mirrors.aliyun.com/ubuntu/ noble main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb https://mirrors.aliyun.com/ubuntu/ noble-security main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.aliyun.com/ubuntu/ noble-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.aliyun.com/ubuntu/ noble-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.aliyun.com/ubuntu/ noble-proposed main restricted universe multiverse" >> /etc/apt/sources.list

# Set timezone
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install basic dependencies
RUN apt-get update && apt-get install -y \
    sudo \
    curl \
    wget \
    git \
    vim \
    nano \
    build-essential \
    python3 \
    python3-pip \
    python3-venv \
    nodejs \
    npm \
    openssh-server \
    ca-certificates \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code

# Install Docker CLI for running Docker inside container
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && apt-get install -y docker-ce-cli && rm -rf /var/lib/apt/lists/*

# Install Go
ENV GO_VERSION=1.25.0
RUN wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    rm go${GO_VERSION}.linux-amd64.tar.gz && \
    ln -s /usr/local/go/bin/go /usr/local/bin/go && \
    ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt

# Create a non-root user with sudo access
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG USER_PASSWORD=vscode

RUN if ! id -u $USERNAME >/dev/null 2>&1; then \
        groupadd --gid $USER_GID $USERNAME; \
        useradd --uid $USER_UID --gid $USER_GID -m $USERNAME; \
    fi && \
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    echo $USERNAME:$USER_PASSWORD | chpasswd && \
    chmod 0440 /etc/sudoers.d/$USERNAME

# Setup SSH server for remote connection
RUN mkdir -p /var/run/sshd /root/.ssh/authorized_keys.d \
    && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config \
    && echo 'AuthorizedKeysFile /root/.ssh/authorized_keys.d/keys' >> /etc/ssh/sshd_config

# Set root password (change this for production!)
RUN echo 'root:root' | chpasswd

# Expose SSH port
EXPOSE 22

# Start SSH server
CMD ["/usr/sbin/sshd", "-D"]
