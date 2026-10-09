#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PX4_DIR="${ROOT_DIR}/PX4-Autopilot"

XRCE_PORT="${XRCE_PORT:-8888}"
MAKE_TARGET="${MAKE_TARGET:-gz_x500_depth}"
PX4_DAEMON="${PX4_DAEMON:-0}"

px4_pid=""
px4_pgid=""
agent_pid=""
cleanup_started=0

stop_process_group() {
  local pgid="$1"

  if [[ -z "${pgid}" ]] || ! kill -0 -- "-${pgid}" 2>/dev/null; then
    return
  fi

  kill -INT -- "-${pgid}" 2>/dev/null || true
  for _ in 1 2 3 4 5; do
    if ! kill -0 -- "-${pgid}" 2>/dev/null; then
      return
    fi
    sleep 1
  done

  kill -TERM -- "-${pgid}" 2>/dev/null || true
}

cleanup() {
  if (( cleanup_started )); then
    return
  fi
  cleanup_started=1

  echo ""
  echo "[run_px4_sim] Stopping..."

  if [[ -n "${agent_pid}" ]] && kill -0 "${agent_pid}" 2>/dev/null; then
    kill "${agent_pid}" 2>/dev/null || true
    wait "${agent_pid}" 2>/dev/null || true
  fi

  stop_process_group "${px4_pgid}"

  if [[ -n "${px4_pid}" ]]; then
    wait "${px4_pid}" 2>/dev/null || true
  fi

  echo "[run_px4_sim] Done."
}

handle_shutdown_signal() {
  cleanup
  exit 0
}

trap cleanup EXIT
trap handle_shutdown_signal INT TERM

cd "${PX4_DIR}"

if [[ "${PX4_DAEMON}" == "1" ]]; then
  px4_binary="${PX4_DIR}/build/px4_sitl_default/bin/px4"
  px4_run_dir="${PX4_DIR}/build/px4_sitl_default/src/modules/simulation/gz_bridge"

  echo "[run_px4_sim] Building PX4 SITL for daemon mode"
  make px4_sitl_default

  if [[ ! -x "${px4_binary}" || ! -d "${px4_run_dir}" ]]; then
    echo "[run_px4_sim] PX4 SITL build output is incomplete." >&2
    exit 1
  fi

  echo "[run_px4_sim] Starting PX4 SITL in daemon mode: ${MAKE_TARGET}"
  setsid --wait bash -c '
    cd "$1"
    exec env PX4_SIM_MODEL="$2" "$3" -d
  ' run_px4_sitl "${px4_run_dir}" "${MAKE_TARGET}" "${px4_binary}" &
  px4_pid=$!
  px4_pgid="${px4_pid}"
else
  echo "[run_px4_sim] Starting PX4 SITL: make px4_sitl ${MAKE_TARGET}"
  setsid --wait make px4_sitl "${MAKE_TARGET}" &
  px4_pid=$!
  px4_pgid="${px4_pid}"
fi

sleep 2

echo "[run_px4_sim] Starting MicroXRCEAgent on UDP4 port ${XRCE_PORT}"
MicroXRCEAgent udp4 -p "${XRCE_PORT}" &
agent_pid=$!

echo "[run_px4_sim] PX4 PID=${px4_pid} | MicroXRCEAgent PID=${agent_pid}"
echo "[run_px4_sim] Ctrl+C to stop."

wait "${px4_pid}"
