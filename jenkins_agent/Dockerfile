FROM alpine:3.18

# Dependencias básicas + SSL
RUN apk add --no-cache bash curl git docker-cli py3-pip make unzip gettext tar gzip ca-certificates && \
    update-ca-certificates

# kubectl
RUN STABLE=$(curl -L -s https://dl.k8s.io/release/stable.txt | xargs) && \
    curl -LO https://dl.k8s.io/release/${STABLE}/bin/linux/amd64/kubectl && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

# Helm
RUN curl -LO https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz && \
    tar -zxvf helm-v3.12.0-linux-amd64.tar.gz && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    chmod +x /usr/local/bin/helm && \
    rm -rf linux-amd64 helm-v3.12.0-linux-amd64.tar.gz

# Kind
RUN curl -Lo /usr/local/bin/kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64 && \
    chmod +x /usr/local/bin/kind

# Docker Compose (opcional)
RUN curl -L "https://github.com/docker/compose/releases/download/v2.22.0/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

# Docker socket
ENV DOCKER_HOST=unix:///var/run/docker.sock

CMD ["tail", "-f", "/dev/null"]
