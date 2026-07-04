#!/usr/bin/env bash
# Load secrets from .env into the process environment, then launch the
# nanobot gateway from source (via uv). The key never appears on the
# command line — it is read from .env at runtime.
#
# Usage (from anywhere):
#   bash start_gateway.sh
set -euo pipefail

# Resolve repo root (this script lives at the repo root).
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

if [ ! -f .env ]; then
  echo "ERROR: .env not found at $ROOT/.env — create it with ZHIPUAI_API_KEY=..." >&2
  exit 1
fi

# Auto-export every assignment in .env, then source it.
set -a
# shellcheck disable=SC1091
. ./.env
set +a

if [ -z "${ZHIPUAI_API_KEY:-}" ]; then
  echo "ERROR: ZHIPUAI_API_KEY is empty in $ROOT/.env" >&2
  exit 1
fi

echo "Starting nanobot gateway (DeepSeek key loaded from .env)..."
exec uv run nanobot gateway
