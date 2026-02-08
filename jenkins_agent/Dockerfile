FROM debian:12-slim

# Install tools
RUN apt-get update && apt-get install -y \
    bash curl git python3-pip make unzip gettext tar gzip ca-certificates \
    openjdk-17-jre-headless && \
    rm -rf /var/lib/apt/lists/*

# kubectl (arm64/aarch64)
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl" && \
    chmod +x kubectl && mv kubectl /usr/local/bin/

# Docker CLI 26.1.4 (arm64/aarch64)
RUN curl -L https://download.docker.com/linux/static/stable/aarch64/docker-26.1.4.tgz | tar -xz && \
    mv docker/docker /usr/local/bin/ && rm -rf docker

# Helm 3.14.4 (arm64)
RUN curl -LO https://get.helm.sh/helm-v3.14.4-linux-arm64.tar.gz && \
    tar -zxvf helm-v3.14.4-linux-arm64.tar.gz && \
    mv linux-arm64/helm /usr/local/bin/helm && rm -rf linux-arm64 helm-*.tar.gz

# Kind 0.23.0 (arm64)
RUN curl -Lo /usr/local/bin/kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-arm64 && \
    chmod +x /usr/local/bin/kind

ENV DOCKER_HOST=unix:///var/run/docker.sock

WORKDIR /home/jenkins
CMD ["sleep", "infinity"]