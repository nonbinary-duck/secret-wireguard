#!/usr/bin/env bash
set -euo pipefail

mode="${SECRETWIREGUARD_MODE:-}"

if [[ -z "${mode}" ]]; then
  echo "SECRETWIREGUARD_MODE must be set to 'server' or 'client'" >&2
  exit 1
fi

case "${mode}" in
  server)
    exec /usr/local/bin/run-server.sh
    ;;
  client)
    exec /usr/local/bin/run-client.sh
    ;;
  *)
    echo "Invalid SECRETWIREGUARD_MODE: ${mode}" >&2
    exit 1
    ;;
esac