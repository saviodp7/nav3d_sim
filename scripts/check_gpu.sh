#!/usr/bin/env bash
set -euo pipefail

nvidia_enabled=false

echo "== Compute GPU =="
if command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi >/dev/null 2>&1; then
  nvidia_enabled=true
  nvidia-smi
else
  echo "NVIDIA non esposta: container in modalita agnostica."
fi

echo
echo "== OpenGL renderer =="
if [[ -n "${DISPLAY:-}" ]] && command -v glxinfo >/dev/null 2>&1; then
  glx_output="$(glxinfo -B 2>&1 || true)"
  grep -E 'direct rendering|OpenGL vendor|OpenGL renderer|OpenGL core profile version' <<< "${glx_output}" || true

  if [[ "${nvidia_enabled}" == true ]] && ! grep -qi 'OpenGL renderer.*NVIDIA' <<< "${glx_output}"; then
    echo "ERRORE: NVIDIA e esposta, ma OpenGL non sta usando il renderer NVIDIA." >&2
    exit 1
  fi
else
  echo "Display grafico non disponibile; controllo OpenGL saltato."
fi

echo
echo "== Vulkan devices =="
if command -v vulkaninfo >/dev/null 2>&1; then
  vulkaninfo --summary 2>/dev/null | grep -E 'deviceName|driverName|driverInfo' || true
else
  echo "vulkaninfo non disponibile."
fi

echo
if [[ "${nvidia_enabled}" == true ]]; then
  echo "Accelerazione NVIDIA configurata correttamente."
else
  echo "Configurazione agnostica attiva; nessuna GPU NVIDIA richiesta."
fi
