FROM ubuntu:24.04

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY

ENV HTTP_PROXY=${HTTP_PROXY} \
    HTTPS_PROXY=${HTTPS_PROXY} \
    NO_PROXY=${NO_PROXY} \
    http_proxy=${HTTP_PROXY} \
    https_proxy=${HTTPS_PROXY} \
    no_proxy=${NO_PROXY}

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    nginx \
    python3 \
    tpm2-tools \
    wget && \
    rm -rf /var/lib/apt/lists/*

# Install trustauthority-cli
RUN curl -fsSL https://raw.githubusercontent.com/intel/trustauthority-client-for-go/main/release/install-tdx-cli.sh | CLI_VERSION=v1.11.0 bash - && \
    command -v trustauthority-cli

WORKDIR /app

COPY entrypoint.sh /app/entrypoint.sh
COPY token_server.py /app/token_server.py
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/share/nginx/html/index.html

RUN chmod +x /app/entrypoint.sh

EXPOSE 12780

ENTRYPOINT ["/app/entrypoint.sh"]