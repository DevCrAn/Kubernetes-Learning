#!/bin/bash
#
# CKAD Simulator Environment Setup Script
# Based on Killer.sh CKAD Simulator
# 
# Este script configura tu entorno de Minikube para practicar
# las preguntas del simulador CKAD de killer.sh
#

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║           CKAD Simulator Environment Setup                   ║"
echo "║           Based on Killer.sh CKAD Simulator                  ║"
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

error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Verificar que kubectl está disponible
if ! command -v kubectl &> /dev/null; then
    error "kubectl no está instalado. Por favor instálalo primero."
    exit 1
fi

# Verificar conexión al clúster
if ! kubectl cluster-info &> /dev/null; then
    error "No se puede conectar al clúster de Kubernetes."
    error "Asegúrate de que Minikube esté corriendo: minikube start"
    exit 1
fi

progress "Conexión al clúster verificada"

# ============================================================================
# PASO 1: Crear Namespaces
# ============================================================================
echo ""
echo -e "${CYAN}=== Paso 1: Creando Namespaces ===${NC}"

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
        warn "Namespace $ns ya existe, omitiendo..."
    else
        kubectl create namespace "$ns"
        progress "Namespace $ns creado"
    fi
done

# ============================================================================
# PASO 2: Crear ServiceAccounts y Secrets
# ============================================================================
echo ""
echo -e "${CYAN}=== Paso 2: Creando ServiceAccounts y Secrets ===${NC}"

kubectl apply -f "${SCRIPT_DIR}/resources/serviceaccounts.yaml"
progress "ServiceAccounts creados"

kubectl apply -f "${SCRIPT_DIR}/resources/secrets.yaml"
progress "Secrets creados"

# ============================================================================
# PASO 3: Crear Pods en saturn (webservers para Question 7)
# ============================================================================
echo ""
echo -e "${CYAN}=== Paso 3: Creando Pods en saturn (para Q7) ===${NC}"

kubectl apply -f "${SCRIPT_DIR}/resources/saturn-pods.yaml"
progress "Pods de saturn creados"

# ============================================================================
# PASO 4: Crear Pods en pluto (para Preview Q1)
# ============================================================================
echo ""
echo -e "${CYAN}=== Paso 4: Creando Pods en pluto ===${NC}"

kubectl apply -f "${SCRIPT_DIR}/resources/pluto-pods.yaml"
progress "Pods de pluto creados"

# ============================================================================
# PASO 5: Crear Deployments y Services en earth (para Q12)
# ============================================================================
echo ""
echo -e "${CYAN}=== Paso 5: Creando recursos en earth (para Q12) ===${NC}"

kubectl apply -f "${SCRIPT_DIR}/resources/earth-resources.yaml"
progress "Deployments y Services de earth creados"

# ============================================================================
# PASO 6: Crear Deployments en neptune (para Q8)
# ============================================================================
echo ""
echo -e "${CYAN}=== Paso 6: Creando recursos en neptune (para Q8) ===${NC}"

kubectl apply -f "${SCRIPT_DIR}/resources/neptune-resources.yaml"
progress "Recursos de neptune creados"

# ============================================================================
# PASO 7: Crear Deployments en pluto (para Preview Q1)
# ============================================================================
echo ""
echo -e "${CYAN}=== Paso 7: Creando recursos en pluto (para Preview Q1) ===${NC}"

kubectl apply -f "${SCRIPT_DIR}/resources/pluto-deployments.yaml"
progress "Deployments de pluto creados"

# ============================================================================
# PASO 8: Crear Pods en sun (para Q20)
# ============================================================================
echo ""
echo -e "${CYAN}=== Paso 8: Creando recursos en sun ===${NC}"

kubectl apply -f "${SCRIPT_DIR}/resources/sun-resources.yaml"
progress "Recursos de sun creados"

# ============================================================================
# PASO 8b: Crear recursos en mercury, mars y jupiter
# ============================================================================
echo ""
echo -e "${CYAN}=== Paso 8b: Creando recursos en mercury, mars y jupiter ===${NC}"

kubectl apply -f "${SCRIPT_DIR}/resources/mercury-resources.yaml"
progress "Recursos de mercury creados"

kubectl apply -f "${SCRIPT_DIR}/resources/mars-resources.yaml"
progress "Recursos de mars creados"

kubectl apply -f "${SCRIPT_DIR}/resources/jupiter-resources.yaml"
progress "Recursos de jupiter creados"

# ============================================================================
# PASO 9: Crear estructura de directorios para las respuestas
# ============================================================================
echo ""
echo -e "${CYAN}=== Paso 9: Creando estructura de directorios ===${NC}"

# Crear directorios para guardar respuestas
for i in {1..22}; do
    mkdir -p "/opt/course/$i"
done

# Crear directorio para Preview Questions
mkdir -p "/opt/course/p1"
mkdir -p "/opt/course/p2"

progress "Directorios /opt/course/1-22 creados"
progress "Directorios /opt/course/p1-p2 creados"

# Copiar archivos YAML que deben pre-existir
cp "${SCRIPT_DIR}/resources/project-23-api.yaml" "/opt/course/p1/" 2>/dev/null || true
progress "Archivo project-23-api.yaml copiado a /opt/course/p1/"

# ============================================================================
# PASO 10: Configurar alias y variables de entorno (simulando el examen)
# ============================================================================
echo ""
echo -e "${CYAN}=== Paso 10: Configurando alias y variables de entorno ===${NC}"

# Crear archivo de configuración para bash
cat > ~/.ckad-env << 'EOF'
# CKAD Exam Environment Variables
alias k=kubectl
alias kn='kubectl config set-context --current --namespace'
export do="--dry-run=client -o yaml"
export now="--force --grace-period 0"

# Autocompletado de kubectl
source <(kubectl completion bash)
complete -F __start_kubectl k

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  CKAD Practice Environment Loaded!"
echo "  Aliases disponibles:"
echo "    k     = kubectl"
echo "    kn    = cambiar namespace actual"
echo "  Variables:"
echo "    \$do   = --dry-run=client -o yaml"
echo "    \$now  = --force --grace-period 0"
echo "═══════════════════════════════════════════════════════════"
echo ""
EOF

progress "Archivo ~/.ckad-env creado"
info "Ejecuta 'source ~/.ckad-env' para cargar los alias"

# ============================================================================
# RESUMEN
# ============================================================================
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗"
echo "║              ¡SETUP COMPLETADO!                              ║"
echo "╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Namespaces creados:${NC}"
echo "  earth, jupiter, mars, mercury, neptune, pluto, saturn, sun, shell-intern"
echo ""
echo -e "${GREEN}Recursos creados:${NC}"
echo "  - 6 Pods webserver en saturn (Q7)"
echo "  - Pod holy-api en pluto (Preview Q1)"
echo "  - Deployments y Services en earth (Q12)"
echo "  - Deployment api-new-c32 en neptune (Q8)"
echo "  - Deployment project-23-api en pluto (Preview Q1)"
echo "  - ServiceAccount neptune-sa-v2 en neptune (Q5)"
echo "  - Secret neptune-secret-1 en neptune (Q5)"
echo ""
echo -e "${YELLOW}Para empezar a practicar:${NC}"
echo "  1. source ~/.ckad-env"
echo "  2. Abre el archivo 'Killer Shell - Exam Simulators.html' en tu navegador"
echo "  3. ¡Empieza a resolver las preguntas!"
echo ""
echo -e "${YELLOW}Para resetear el entorno:${NC}"
echo "  ./cleanup-ckad-env.sh"
echo ""
