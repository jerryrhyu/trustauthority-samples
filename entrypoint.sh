#!/bin/bash
set -euo pipefail

required_vars=(
    TRUSTAUTHORITY_API_URL
    TRUSTAUTHORITY_API_KEY
)

for var_name in "${required_vars[@]}"; do
    if [[ -z "${!var_name:-}" ]]; then
        echo "Error: ${var_name} must be present"
        exit 1
    fi
done

: "${PLATFORM:=azure}"

cat <<EOF > /app/config.json
{
  "trustauthority_api_url": "${TRUSTAUTHORITY_API_URL}",
  "trustauthority_api_key": "${TRUSTAUTHORITY_API_KEY}"
}
EOF

python3 /app/token_server.py &
token_server_pid=$!

cleanup() {
    if kill -0 "${token_server_pid}" >/dev/null 2>&1; then
        kill "${token_server_pid}" >/dev/null 2>&1 || true
    fi
}

trap cleanup EXIT INT TERM

exec nginx -g "daemon off;"