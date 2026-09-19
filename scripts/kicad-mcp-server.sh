#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
ENTRY_POINT="${ROOT_DIR}/.tools/kicad-mcp/dist/index.js"

if [[ ! -f "${ENTRY_POINT}" ]]; then
  printf 'KiCad MCP is not installed. Run ./bootstrap.sh first.\n' >&2
  exit 1
fi

exec node "${ENTRY_POINT}"
