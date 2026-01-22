#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PX4_DIR="${ROOT_DIR}/PX4-Autopilot"
PX4_MSGS_DIR="${ROOT_DIR}/ros2_ws/src/px4_msgs"

PX4_BRANCH="${PX4_BRANCH:-release/1.14}"
PX4_MSGS_BRANCH="${PX4_MSGS_BRANCH:-main}"

PX4_URL="${PX4_URL:-https://github.com/PX4/PX4-Autopilot.git}"
PX4_MSGS_URL="${PX4_MSGS_URL:-https://github.com/PX4/px4_msgs.git}"

mkdir -p "$(dirname "${PX4_DIR}")" "$(dirname "${PX4_MSGS_DIR}")"

if [ -d "${PX4_DIR}/.git" ]; then
  echo "PX4 already present: ${PX4_DIR}"
else
  echo "Cloning PX4 into: ${PX4_DIR}"
  git clone --recursive --single-branch -b "${PX4_BRANCH}" "${PX4_URL}" "${PX4_DIR}"
fi

if [ -d "${PX4_MSGS_DIR}/.git" ]; then
  echo "PX4 messages already present: ${PX4_MSGS_DIR}"
else
  echo "Cloning PX4 messages into: ${PX4_MSGS_DIR}"
  git clone --single-branch -b "${PX4_MSGS_BRANCH}" "${PX4_MSGS_URL}" "${PX4_MSGS_DIR}"
fi
