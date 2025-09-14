FROM ubuntu:22.04

# Evitar prompts interactivos
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl wget apt-transport-https ca-certificates gnupg lsb-release sudo \
    conntrack socat iptables git vim \
    && rm -rf /var/lib/apt/lists/*

# Instalar kubectl v1.33
RUN curl -LO "https://dl.k8s.io/release/v1.33.0/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/

# Instalar Minikube
RUN curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
    && chmod +x minikube \
    && mv minikube /usr/local/bin/

# Instalar k9s (opcional, herramienta para navegar el cluster)
RUN curl -sS https://webinstall.dev/k9s | bash

# Usuario sin root para Codespaces
RUN useradd -ms /bin/bash vscode && usermod -aG sudo vscode
USER vscode

RUN echo "alias k='kubectl'" >> /home/vscode/.bashrc
RUN echo "complete -F __start_kubectl k" >> /home/vscode/.bashrc


WORKDIR /home/vscode
