#!/bin/bash
#
# CKAD Simulator Environment Cleanup Script
# 
# Este script elimina todos los recursos creados por setup-ckad-env.sh
# para poder empezar de nuevo con un entorno limpio
#

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║           CKAD Simulator Environment Cleanup                 ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Función para mostrar progreso
progress() {
    echo -e "${GREEN}[✓]${NC} $1"
}

info() {
    echo -e "${BLUE}[i]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Confirmar antes de eliminar
echo -e "${YELLOW}¡ATENCIÓN!${NC}"
echo "Este script eliminará:"
echo "  - Los namespaces: earth, jupiter, mars, mercury, neptune, pluto, saturn, sun, shell-intern"
echo "  - Todos los recursos de Kubernetes en esos namespaces"
echo "  - Los directorios /opt/course/*"
echo ""
read -p "¿Estás seguro de que deseas continuar? (s/N): " confirm

if [[ "$confirm" != "s" && "$confirm" != "S" ]]; then
    echo "Operación cancelada."
    exit 0
fi

echo ""
echo -e "${CYAN}=== Eliminando Namespaces ===${NC}"

NAMESPACES=(
    "earth"
    "jupiter"
    "mars"
    "mercury"
    "neptune"
    "pluto"
    "saturn"
    "sun"
    "shell-intern"
)

for ns in "${NAMESPACES[@]}"; do
    if kubectl get namespace "$ns" &> /dev/null; then
        kubectl delete namespace "$ns" --wait=false
        progress "Namespace $ns marcado para eliminación"
    else
        warn "Namespace $ns no existe, omitiendo..."
    fi
done

echo ""
echo -e "${CYAN}=== Eliminando directorios /opt/course ===${NC}"

if [ -d "/opt/course" ]; then
    rm -rf /opt/course/*
    progress "Contenido de /opt/course eliminado"
else
    warn "/opt/course no existe"
fi

echo ""
echo -e "${CYAN}=== Esperando a que los namespaces se eliminen ===${NC}"
info "Esto puede tomar unos minutos..."

for ns in "${NAMESPACES[@]}"; do
    while kubectl get namespace "$ns" &> /dev/null; do
        echo -n "."
        sleep 2
    done
done

echo ""
progress "Todos los namespaces eliminados"

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗"
echo "║              ¡CLEANUP COMPLETADO!                            ║"
echo "╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "El entorno ha sido limpiado. Puedes ejecutar ./setup-ckad-env.sh"
echo "para volver a configurar el entorno de práctica."
echo ""
