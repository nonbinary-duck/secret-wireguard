#!/usr/bin/env bash
set -euo pipefail

conf_file="${1:-}"

if [[ -z "${conf_file}" || ! -f "${conf_file}" ]]; then
  echo "Usage: $0 /path/to/udpspeeder.conf" >&2
  exit 1
fi

trim() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

append_arg() {
  PARSED_ARGS+=("$1")
  if [[ $# -gt 1 ]]; then
    PARSED_ARGS+=("$2")
  fi
}

declare -a PARSED_ARGS=()

while IFS= read -r raw_line || [[ -n "${raw_line}" ]]; do
  line="$(trim "${raw_line}")"

  [[ -z "${line}" ]] && continue
  [[ "${line}" == \#* ]] && continue

  if [[ "${line}" != *"="* ]]; then
    echo "Invalid UDPspeeder config line (missing '='): ${line}" >&2
    exit 1
  fi

  key="${line%%=*}"
  value="${line#*=}"

  key="$(trim "${key}")"
  value="$(trim "${value}")"

  case "${key}" in
    mode)
      case "${value}" in
        server) append_arg "-s" ;;
        client) append_arg "-c" ;;
        *)
          echo "Invalid value for mode: ${value}" >&2
          exit 1
          ;;
      esac
      ;;
    listen) append_arg "-l" "${value}" ;;
    remote) append_arg "-r" "${value}" ;;
    key) append_arg "-k" "${value}" ;;
    fec) append_arg "-f" "${value}" ;;
    timeout) append_arg "--timeout" "${value}" ;;
    report) append_arg "--report" "${value}" ;;
    fec_mode) append_arg "--mode" "${value}" ;;
    mtu) append_arg "--mtu" "${value}" ;;
    jitter) append_arg "-j" "${value}" ;;
    interval) append_arg "-i" "${value}" ;;
    random_drop) append_arg "--random-drop" "${value}" ;;
    disable_obscure) append_arg "--disable-obscure" "${value}" ;;
    disable_checksum) append_arg "--disable-checksum" "${value}" ;;
    fifo) append_arg "--fifo" "${value}" ;;
    queue_len) append_arg "-q" "${value}" ;;
    decode_buf) append_arg "--decode-buf" "${value}" ;;
    delay_capacity) append_arg "--delay-capacity" "${value}" ;;
    disable_fec) append_arg "--disable-fec" "${value}" ;;
    sock_buf) append_arg "--sock-buf" "${value}" ;;
    out_addr) append_arg "--out-addr" "${value}" ;;
    out_interface) append_arg "--out-interface" "${value}" ;;
    log_level) append_arg "--log-level" "${value}" ;;
    log_position)
      if [[ "${value}" == "1" ]]; then
        append_arg "--log-position"
      fi
      ;;
    disable_color)
      if [[ "${value}" == "1" ]]; then
        append_arg "--disable-color"
      fi
      ;;
    *)
      echo "Unsupported UDPspeeder config key: ${key}" >&2
      exit 1
      ;;
  esac
done < "${conf_file}"

printf '%s\0' "${PARSED_ARGS[@]}"