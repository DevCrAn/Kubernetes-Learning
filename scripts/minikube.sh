#!/usr/bin/env bash

set -euo pipefail

PROG_NAME=$(basename -- "$0")
BASHRC_FILE="$HOME/.bashrc"

usage() {
  cat <<EOF
Uso: $PROG_NAME <comando>

Comandos:
  start        Inicia Minikube y configura alias/autocompletado
  stop         Detiene Minikube (no borra el clúster)
  delete       Elimina el clúster Minikube
  restart      Reinicia Minikube
  status       Muestra el estado de Minikube
  enable-k     Añade alias 'k' y autocompletado a ~/.bashrc
  disable-k    Elimina alias y autocompletado de ~/.bashrc
  help         Muestra esta ayuda

Ejemplos:
  $PROG_NAME start
  $PROG_NAME stop
  $PROG_NAME delete
  $PROG_NAME enable-k
EOF
}

ensure_line() {
  local line="$1"
  local file="$2"
  mkdir -p "$(dirname "$file")"
  grep -Fqx -- "$line" "$file" 2>/dev/null || echo "$line" >> "$file"
}

remove_line_pattern() {
  local pattern="$1"
  local file="$2"
  if [ -f "$file" ]; then
    sed -i.bak -E "$pattern" "$file" || true
  fi
}

cmd_enable_k() {
  if ! command -v kubectl >/dev/null 2>&1; then
    echo "Advertencia: 'kubectl' no está en PATH. Aún así se añadirá la configuración a $BASHRC_FILE" >&2
  fi
  ensure_line "alias k=kubectl" "$BASHRC_FILE"
  ensure_line "source <(kubectl completion bash 2>/dev/null) 2>/dev/null || true" "$BASHRC_FILE"
  ensure_line "complete -o default -F __start_kubectl k 2>/dev/null || true" "$BASHRC_FILE"
  echo "Alias y autocompletado añadidos a $BASHRC_FILE (idempotente)."
  # Si estamos en bash interactivo, recargar ahora
  if [ -n "${PS1-}" ] && [ "$(basename -- "$SHELL")" = "bash" ]; then
    # shellcheck disable=SC1090
    source "$BASHRC_FILE" || true
    echo "Recargado $BASHRC_FILE en la sesión actual." 
  else
    echo "Abre una nueva terminal o ejecuta: source $BASHRC_FILE" 
  fi
}

cmd_disable_k() {
  echo "Eliminando alias/autocompletado de $BASHRC_FILE (se creará backup .bak)..."
  remove_line_pattern "s#^alias k=kubectl\$##" "$BASHRC_FILE"
  remove_line_pattern "s#kubectl completion bash.*##" "$BASHRC_FILE"
  remove_line_pattern "s#complete -o default -F __start_kubectl k.*##" "$BASHRC_FILE"
  echo "Hecho. Para aplicar: source $BASHRC_FILE"
}

cmd_start() {
  echo "Inicializando Minikube..."
  minikube start --driver=docker --kubernetes-version=v1.33.0
  kubectl cluster-info || true
  echo "Esperando a que el API Server esté disponible..."
  if kubectl wait --for=condition=Available --timeout=90s deployment/kube-apiserver -n kube-system 2>/dev/null; then
    :
  else
    kubectl get --raw='/readyz' >/dev/null 2>&1 || true
  fi
  cmd_enable_k
  echo "Minikube iniciado correctamente." 
}

cmd_stop() {
  echo "Deteniendo Minikube..."
  if command -v minikube >/dev/null 2>&1; then
    minikube stop || echo "minikube stop falló o ya estaba detenido" >&2
  else
    echo "minikube no está instalado o no está en PATH" >&2
  fi
}

cmd_delete() {
  echo "Eliminando clúster Minikube..."
  if command -v minikube >/dev/null 2>&1; then
    minikube delete || echo "minikube delete falló" >&2
  else
    echo "minikube no está instalado o no está en PATH" >&2
  fi
}

cmd_status() {
  if command -v minikube >/dev/null 2>&1; then
    minikube status || true
  else
    echo "minikube no está instalado o no está en PATH" >&2
  fi
}

if [ $# -lt 1 ]; then
  usage
  exit 1
fi

case "$1" in
  start)
    cmd_start
    ;;
  stop)
    cmd_stop
    ;;
  delete)
    cmd_delete
    ;;
  restart)
    cmd_stop
    cmd_start
    ;;
  status)
    cmd_status
    ;;
  enable-k)
    cmd_enable_k
    ;;
  disable-k)
    cmd_disable_k
    ;;
  help|-h|--help)
    usage
    ;;
  *)
    echo "Comando desconocido: $1" >&2
    usage
    exit 2
    ;;
esac
