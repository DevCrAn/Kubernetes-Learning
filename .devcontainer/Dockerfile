FROM ubuntu:22.04

ARG K8S_VERSION=v1.35.0

ENV DEBIAN_FRONTEND=noninteractive
ENV K8S_VERSION=${K8S_VERSION}

RUN apt-get update && apt-get install -y \
    curl wget apt-transport-https ca-certificates gnupg lsb-release sudo \
    conntrack socat iptables git vim nano \
    python3 \
    jq \
    bash-completion \
    && rm -rf /var/lib/apt/lists/*

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/${K8S_VERSION}/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/

# Install Minikube
RUN curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
    && chmod +x minikube \
    && mv minikube /usr/local/bin/

# Install Helm 3
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install yq
RUN wget -q https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq \
    && chmod +x /usr/local/bin/yq

# Setup user for Codespaces
RUN useradd -ms /bin/bash vscode && echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER vscode

# Configure kubectl alias, completion, and exam-like env vars
RUN echo 'alias k=kubectl' >> /home/vscode/.bashrc && \
    echo 'source <(kubectl completion bash 2>/dev/null) 2>/dev/null || true' >> /home/vscode/.bashrc && \
    echo 'complete -o default -F __start_kubectl k 2>/dev/null || true' >> /home/vscode/.bashrc && \
    echo 'export do="--dry-run=client -o yaml"' >> /home/vscode/.bashrc && \
    echo 'export now="--force --grace-period 0"' >> /home/vscode/.bashrc && \
    echo 'source <(helm completion bash 2>/dev/null) 2>/dev/null || true' >> /home/vscode/.bashrc

WORKDIR /home/vscode
