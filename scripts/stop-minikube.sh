#!/usr/bin/env bash

set -euo pipefail

echo "Deteniendo Minikube..."
if command -v minikube >/dev/null 2>&1; then
  minikube stop || echo "minikube stop falló o ya estaba detenido"
else
  echo "minikube no está instalado o no está en PATH" >&2
fi

# Si se pasa --delete o -d, eliminar el clúster completamente
if [ "${1-}" = "--delete" ] || [ "${1-}" = "-d" ]; then
  if command -v minikube >/dev/null 2>&1; then
    echo "Eliminando clúster Minikube..."
    minikube delete || echo "minikube delete falló" >&2
  fi
fi

BASHRC_FILE="$HOME/.bashrc"
if [ -f "$BASHRC_FILE" ]; then
  echo "Eliminando alias y autocompletado de $BASHRC_FILE (si existen)..."
  sed -i.bak '/^alias k=kubectl$/d' "$BASHRC_FILE" || true
  sed -i.bak '/kubectl completion bash/d' "$BASHRC_FILE" || true
  sed -i.bak '/complete -o default -F __start_kubectl k/d' "$BASHRC_FILE" || true
  echo "Se creó una copia de seguridad: $BASHRC_FILE.bak"
else
  echo "$BASHRC_FILE no existe, nada que limpiar."
fi

echo "Para que los cambios surtan efecto en tu sesión actual ejecuta:"
echo "  source $BASHRC_FILE"
echo "O abre una nueva terminal Bash." 

echo "Listo."
