#!/usr/bin/env bash
set -euo pipefail

UDP2RAW_CONF="${UDP2RAW_CONF:-/config/udp2raw/client.conf}"
UDPSPEEDER_CONF="${UDPSPEEDER_CONF:-/config/udpspeeder/client.conf}"
WG_CONF="${WG_CONF:-/config/wg_confs/wg0.conf}"

for f in "${UDP2RAW_CONF}" "${UDPSPEEDER_CONF}" "${WG_CONF}"; do
  [[ -f "${f}" ]] || { echo "Missing config: ${f}" >&2; exit 1; }
done

declare -a UDPSPEEDER_ARGS=()
while IFS= read -r -d '' arg; do
  UDPSPEEDER_ARGS+=("${arg}")
done < <(/usr/local/bin/parse-udpspeeder-conf.sh "${UDPSPEEDER_CONF}")

echo "[SecretWireguard] Starting udp2raw (client)"
/usr/local/bin/udp2raw --conf-file "${UDP2RAW_CONF}" &
UDP2RAW_PID=$!

echo "[SecretWireguard] Starting UDPspeeder (client)"
/usr/local/bin/speederv2 "${UDPSPEEDER_ARGS[@]}" &
UDPSPEEDER_PID=$!

cleanup() {
  echo "[SecretWireguard] Stopping"
  wg-quick down "${WG_CONF}" 2>/dev/null || true
  kill "${UDPSPEEDER_PID}" 2>/dev/null || true
  kill "${UDP2RAW_PID}" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

sleep 1

echo "[SecretWireguard] Starting WireGuard"
wg-quick up "${WG_CONF}"

echo "[SecretWireguard] Running"
wait "${UDP2RAW_PID}" "${UDPSPEEDER_PID}"