FROM alpine:3.18

# Base tools + Java
RUN apk add --no-cache \
    bash curl git py3-pip make unzip gettext tar gzip ca-certificates \
    openjdk17-jre && \
    update-ca-certificates

# kubectl
RUN STABLE=$(curl -L -s https://dl.k8s.io/release/stable.txt | xargs) && \
    curl -LO https://dl.k8s.io/release/${STABLE}/bin/linux/amd64/kubectl && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

# --------------------------------------------------
# Docker CLI (client only)
# --------------------------------------------------
RUN curl -L https://download.docker.com/linux/static/stable/x86_64/docker-24.0.5.tgz | tar -xz && \
    mv docker/docker /usr/local/bin/ && \
    chmod +x /usr/local/bin/docker && \
    rm -rf docker

# --------------------------------------------------
# Helm
# --------------------------------------------------
RUN curl -LO https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz && \
    tar -zxvf helm-v3.12.0-linux-amd64.tar.gz && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    chmod +x /usr/local/bin/helm && \
    rm -rf linux-amd64 helm-v3.12.0-linux-amd64.tar.gz

# Kind
RUN curl -Lo /usr/local/bin/kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64 && \
    chmod +x /usr/local/bin/kind

ENV DOCKER_HOST=unix:///var/run/docker.sock

# Create Jenkins working directory
RUN mkdir -p /home/jenkins

# Set working directory for the agent
WORKDIR /home/jenkins

CMD ["sleep", "infinity"]
