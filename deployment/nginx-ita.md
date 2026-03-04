## NGINX Intel Trust Authority Demo

This sample provides a containerized NGINX workload at `deployment/nginx-workload`.
The page fetches an Intel Trust Authority attestation token at request time by calling
`trustauthority-cli` inside the workload and renders the token in the browser.

### Design goals

- The workload includes Intel Trust Authority CLI (`trustauthority-cli`) for attestation.
- The workload runs NGINX.
- When a user accesses the NGINX page, it fetches an Intel Trust Authority token and displays it.
- The workload accepts an env file with:
  - `TRUSTAUTHORITY_BASE_URL=https://portal.trustauthority.intel.com`
  - `TRUSTAUTHORITY_API_URL=https://api.trustauthority.intel.com`
  - `TRUSTAUTHORITY_API_KEY=<API Key>`

### Build

From the repository root:

```bash
docker build --no-cache -f deployment/nginx-workload/Dockerfile -t ita-nginx-demo .
```

### Deploy

1. Copy and edit the env file:

   ```bash
   cp deployment/nginx-workload/workload.env /tmp/nginx-ita.env
   ```

   Update the `<ITA API Key>` placeholder.

2. Run the container (example for Intel TDX VM):

   ```bash
   docker run --name ita-nginx-demo -d --restart=always --privileged \
     --env-file /tmp/nginx-ita.env \
     -v /sys/kernel/config:/sys/kernel/config \
     -p 12780:12780 \
     ita-nginx-demo:latest
   ```

   > If running on Azure confidential VM with Intel TDX, use `--device=/dev/tpmrm0`
   > and `--group-add $(getent group tss | cut -d: -f3)` instead of `--privileged`.

3. Open `http://<host-ip>:12780`.

The page calls `/api/token`, which executes `trustauthority-cli token` using
the generated `/app/config.json` and displays the returned token.
