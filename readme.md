## NGINX Intel Trust Authority Demo

This sample provides a containerized NGINX workload at `deployment/nginx-workload`.
The page fetches an Intel Trust Authority attestation token at request time by calling
`trustauthority-cli` inside the workload and renders the token in the browser.

### Design goals

- The workload includes Intel Trust Authority CLI (`trustauthority-cli`) for attestation.
- The workload runs NGINX.
- When a user accesses the NGINX page, it fetches an Intel Trust Authority token and displays it.
- The workload accepts an env file with:
  - `TRUSTAUTHORITY_API_URL=https://api.trustauthority.intel.com`
  - `TRUSTAUTHORITY_API_KEY=<API Key>`

### Build

From the repository root:

```bash
docker build --no-cache -f deployment/nginx-workload/Dockerfile -t nginx-demo .
```

### Deploy

Run the container (example for Intel TDX VM):

   ```bash
   docker run --name nginx-demo -d --restart=always --privileged \
     --env-file workload.env \
     -v /sys/kernel/config:/sys/kernel/config \
     -p 0.0.0.0:12780:12780 \
     nginx-demo:latest
   ```

Open `http://<host-ip>:12780`.

The page calls `/api/token`, which executes `trustauthority-cli token` using the generated `/app/config.json` and displays the returned token.

### Verify with curl

1. Verify NGINX page is reachable:

   ```bash
    curl -i http://<host-ip>:12780/ | head -n 20
   ```

2. Verify token API:

   ```bash
    curl -sS http://<host-ip>:12780/api/token
   ```

   Expected success response:

   ```json
   {"attestation_token":"<jwt>"}
   ```

### Troubleshooting

- If `/api/token` returns an error, check container logs:

  ```bash
  docker logs --tail 200 nginx-demo
  ```
