#!/usr/bin/env bash
# Este archivo está pensado para ser 'sourced' en la sesión actual:
#   source scripts/enable-k.sh
# NO lo ejecutes directamente (saldrá un aviso).

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  echo "Este archivo debe ser 'sourced', no ejecutado. Usa: source $0" >&2
  exit 1
fi

# Alias corto
alias k=kubectl

# Autocompletado en la sesión actual (si kubectl está disponible)
if command -v kubectl >/dev/null 2>&1; then
  # Definir el completado en el shell actual
  source <(kubectl completion bash 2>/dev/null) 2>/dev/null || true
  complete -o default -F __start_kubectl k 2>/dev/null || true
else
  echo "Advertencia: 'kubectl' no está en PATH; no se habilitó autocompletado." >&2
fi
