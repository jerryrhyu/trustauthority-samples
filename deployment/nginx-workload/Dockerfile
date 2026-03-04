FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    nginx \
    python3 \
    tpm2-tools \
    wget && \
    rm -rf /var/lib/apt/lists/*

# Install tdx-cli / trustauthority-cli
RUN curl -L https://raw.githubusercontent.com/intel/trustauthority-client-for-go/main/release/install-tdx-cli.sh | CLI_VERSION=v1.11.0 bash -

WORKDIR /app

COPY deployment/nginx-workload/entrypoint.sh /app/entrypoint.sh
COPY deployment/nginx-workload/token_server.py /app/token_server.py
COPY deployment/nginx-workload/nginx.conf /etc/nginx/nginx.conf
COPY deployment/nginx-workload/index.html /usr/share/nginx/html/index.html

RUN chmod +x /app/entrypoint.sh

EXPOSE 12780

ENTRYPOINT ["/app/entrypoint.sh"]