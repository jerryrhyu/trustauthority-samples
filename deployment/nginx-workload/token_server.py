#!/usr/bin/env python3

import json
import os
import subprocess
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlparse

TRUSTAUTHORITY_CLI = os.environ.get("TRUSTAUTHORITY_CLI", "trustauthority-cli")
CONFIG_PATH = os.environ.get("TRUSTAUTHORITY_CONFIG", "/app/config.json")
TOKEN_SERVICE_HOST = os.environ.get("TOKEN_SERVICE_HOST", "127.0.0.1")
TOKEN_SERVICE_PORT = int(os.environ.get("TOKEN_SERVICE_PORT", "8081"))
TOKEN_COMMAND_TIMEOUT_SEC = int(os.environ.get("TOKEN_COMMAND_TIMEOUT_SEC", "90"))


def fetch_attestation_token() -> str:
    command = [
        TRUSTAUTHORITY_CLI,
        "token",
        "--config",
        CONFIG_PATH,
        "--no-eventlog",
    ]
    process = subprocess.run(command, capture_output=True, text=True, timeout=TOKEN_COMMAND_TIMEOUT_SEC, check=False)
    if process.returncode != 0:
        stderr = (process.stderr or "").strip()
        stdout = (process.stdout or "").strip()
        detail = stderr or stdout or f"{TRUSTAUTHORITY_CLI} exited with code {process.returncode}"
        raise RuntimeError(detail)

    token = (process.stdout or "").strip()
    if not token:
        raise RuntimeError("No attestation token returned by trustauthority-cli")

    return token


class TokenHandler(BaseHTTPRequestHandler):
    def log_message(self, _format: str, *_args) -> None:
        return

    def _write_json(self, status_code: int, payload: dict) -> None:
        body = json.dumps(payload).encode("utf-8")
        self.send_response(status_code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Cache-Control", "no-store")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self) -> None:
        parsed = urlparse(self.path)
        if parsed.path != "/api/token":
            self._write_json(404, {"error": "not found"})
            return

        try:
            token = fetch_attestation_token()
        except subprocess.TimeoutExpired:
            self._write_json(504, {"error": "Timed out while requesting attestation token"})
            return
        except Exception as err:
            self._write_json(500, {"error": str(err)})
            return

        self._write_json(200, {"attestation_token": token})


if __name__ == "__main__":
    server = ThreadingHTTPServer((TOKEN_SERVICE_HOST, TOKEN_SERVICE_PORT), TokenHandler)
    server.serve_forever()