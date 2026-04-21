#!/usr/bin/env bash
set -euo pipefail

UDP2RAW_CONF="${UDP2RAW_CONF:-/config/udp2raw/client.conf}"
WG_CONF="${WG_CONF:-/config/wg_confs/wg0.conf}"

if [[ ! -f "${UDP2RAW_CONF}" ]]; then
  echo "Missing udp2raw config: ${UDP2RAW_CONF}" >&2
  exit 1
fi

if [[ ! -f "${WG_CONF}" ]]; then
  echo "Missing WireGuard config: ${WG_CONF}" >&2
  exit 1
fi

echo "[SecretWireguard] Starting udp2raw (client)"
/usr/local/bin/udp2raw --conf-file "${UDP2RAW_CONF}" &
UDP2RAW_PID=$!

cleanup() {
  echo "[SecretWireguard] Stopping"
  wg-quick down "${WG_CONF}" 2>/dev/null || true
  kill "${UDP2RAW_PID}" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

sleep 1

echo "[SecretWireguard] Starting WireGuard"
wg-quick up "${WG_CONF}"

echo "[SecretWireguard] Running"
wait "${UDP2RAW_PID}"