#!/usr/bin/env bash

set -euo pipefail

echo "Inicializando Minikube..."
minikube start --driver=docker --kubernetes-version=v1.35.0

kubectl cluster-info || true

echo "Esperando a que el API Server esté disponible..."
# No todos los clústeres exponen deployment/kube-apiserver en kube-system,
# intentar esperar por el endpoint del servidor API como fallback.
if kubectl wait --for=condition=Available --timeout=90s deployment/kube-apiserver -n kube-system 2>/dev/null; then
	:
else
	echo "No se pudo usar deployment/kube-apiserver; comprobando endpoint del API Server..."
	kubectl get --raw='/readyz' >/dev/null 2>&1 || true
fi

# Añadir alias 'k' y autocompletado de kubectl de forma idempotente
BASHRC_FILE="$HOME/.bashrc"

ensure_line() {
	local line="$1"
	local file="$2"
	grep -Fqx -- "$line" "$file" 2>/dev/null || echo "$line" >> "$file"
}

echo "Configurando alias 'k' y autocompletado de kubectl en $BASHRC_FILE"

# Alias corto
ensure_line "alias k=kubectl" "$BASHRC_FILE"

# Autocompletado: si kubectl tiene el comando 'completion', habilítalo para bash
if command -v kubectl >/dev/null 2>&1; then
	# Agregar la línea que genera el completado si no existe
	ensure_line "source <(kubectl completion bash 2>/dev/null) 2>/dev/null || true" "$BASHRC_FILE"
	# Asegurar también que el completado para el alias 'k' esté enlazado
	ensure_line "complete -o default -F __start_kubectl k 2>/dev/null || true" "$BASHRC_FILE"
else
	echo "Advertencia: 'kubectl' no está en PATH. No se añadió autocompletado." >&2
fi

# Recargar el .bashrc sólo si estamos dentro de una sesión interactiva bash
if [ -n "${PS1-}" ] && [ "$(basename -- "$SHELL")" = "bash" ]; then
	# shellcheck disable=SC1090
	source "$BASHRC_FILE" || true
fi

echo "Minikube started successfully with Kubernetes v1.35.0"

