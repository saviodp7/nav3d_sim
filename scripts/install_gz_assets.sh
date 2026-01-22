#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PX4_DIR="${ROOT_DIR}/PX4-Autopilot"
SRC_GZ_DIR="${ROOT_DIR}/gz"
DST_GZ_DIR="${PX4_DIR}/Tools/simulation/gz"

mkdir -p "${DST_GZ_DIR}"

if [ -d "${SRC_GZ_DIR}/models" ]; then
  mkdir -p "${DST_GZ_DIR}/models"
  cp -a "${SRC_GZ_DIR}/models/." "${DST_GZ_DIR}/models/"
fi

if [ -d "${SRC_GZ_DIR}/worlds" ]; then
  mkdir -p "${DST_GZ_DIR}/worlds"
  cp -a "${SRC_GZ_DIR}/worlds/." "${DST_GZ_DIR}/worlds/"
fi

echo "Gazebo assets copied to ${DST_GZ_DIR}"
