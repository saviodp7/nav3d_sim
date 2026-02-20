#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PX4_DIR="${ROOT_DIR}/PX4-Autopilot"

XRCE_PORT="${XRCE_PORT:-8888}"
MAKE_TARGET="${MAKE_TARGET:-gz_x500_depth}"

px4_pid=""
agent_pid=""

cleanup() {
  echo ""
  echo "[run_px4_sim] Stopping..."

  if [[ -n "${agent_pid}" ]] && kill -0 "${agent_pid}" 2>/dev/null; then
    kill "${agent_pid}" 2>/dev/null || true
    wait "${agent_pid}" 2>/dev/null || true
  fi

  if [[ -n "${px4_pid}" ]] && kill -0 "${px4_pid}" 2>/dev/null; then
    kill "${px4_pid}" 2>/dev/null || true
    wait "${px4_pid}" 2>/dev/null || true
  fi

  echo "[run_px4_sim] Done."
}
trap cleanup EXIT INT TERM

cd "${PX4_DIR}"

echo "[run_px4_sim] Starting PX4 SITL: make px4_sitl ${MAKE_TARGET}"
make px4_sitl "${MAKE_TARGET}" &
px4_pid=$!

sleep 2

echo "[run_px4_sim] Starting MicroXRCEAgent on UDP4 port ${XRCE_PORT}"
MicroXRCEAgent udp4 -p "${XRCE_PORT}" &
agent_pid=$!

echo "[run_px4_sim] PX4 PID=${px4_pid} | MicroXRCEAgent PID=${agent_pid}"
echo "[run_px4_sim] Ctrl+C to stop."

wait "${px4_pid}"
