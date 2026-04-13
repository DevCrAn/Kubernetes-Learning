#!/bin/bash
#
# CKAD Simulator Environment Cleanup Script
# Removes all resources created by setup-ckad-env.sh
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║           CKAD Simulator Environment Cleanup                 ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

progress() { echo -e "${GREEN}[✓]${NC} $1"; }
info()     { echo -e "${BLUE}[i]${NC} $1"; }
warn()     { echo -e "${YELLOW}[!]${NC} $1"; }

# Confirm before deleting
echo -e "${YELLOW}WARNING!${NC}"
echo "This script will delete:"
echo "  - Namespaces: earth, jupiter, mars, mercury, moon, neptune, pluto, saturn, sun, venus"
echo "  - All Kubernetes resources in those namespaces"
echo "  - Directories /opt/course/*"
echo "  - Helm repo 'killershell'"
echo "  - Docker registry container"
echo "  - Exam timer state"
echo ""
read -p "Are you sure you want to continue? (y/N): " confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" && "$confirm" != "s" && "$confirm" != "S" ]]; then
    echo "Operation cancelled."
    exit 0
fi

# Stop Helm repo server
echo ""
echo -e "${CYAN}=== Stopping Helm repo server ===${NC}"
pkill -f "python3 -m http.server 8879" 2>/dev/null || true
helm repo remove killershell 2>/dev/null || true
rm -rf /tmp/killershell-helm-repo 2>/dev/null || true
progress "Helm repo server stopped"

# Stop Docker registry
echo ""
echo -e "${CYAN}=== Stopping Docker registry ===${NC}"
if command -v docker &> /dev/null; then
    docker stop registry 2>/dev/null || true
    docker rm registry 2>/dev/null || true
    progress "Docker registry stopped"
fi

# Remove exam timer state
echo ""
echo -e "${CYAN}=== Cleaning exam state ===${NC}"
rm -f /tmp/ckad-exam-start-time 2>/dev/null || true
rm -f /tmp/ckad-exam-end-time 2>/dev/null || true
progress "Exam timer state cleaned"

# Delete namespaces
echo ""
echo -e "${CYAN}=== Deleting Namespaces ===${NC}"

NAMESPACES=(
    "earth"
    "jupiter"
    "mars"
    "mercury"
    "moon"
    "neptune"
    "pluto"
    "saturn"
    "sun"
    "venus"
)

for ns in "${NAMESPACES[@]}"; do
    if kubectl get namespace "$ns" &> /dev/null; then
        kubectl delete namespace "$ns" --wait=false
        progress "Namespace $ns marked for deletion"
    else
        warn "Namespace $ns does not exist, skipping..."
    fi
done

# Clean /opt/course
echo ""
echo -e "${CYAN}=== Cleaning /opt/course ===${NC}"

if [ -d "/opt/course" ]; then
    sudo rm -rf /opt/course
    progress "/opt/course removed"
else
    warn "/opt/course does not exist"
fi

# Clean resources in default namespace (Q6, Q17)
echo ""
echo -e "${CYAN}=== Cleaning default namespace resources ===${NC}"
kubectl delete pod pod1 pod6 -n default 2>/dev/null || true
kubectl delete deployment test-init-container -n default 2>/dev/null || true
progress "Default namespace cleaned"

# Wait for namespaces to be deleted
echo ""
echo -e "${CYAN}=== Waiting for namespaces to be fully deleted ===${NC}"
info "This may take a few minutes..."

for ns in "${NAMESPACES[@]}"; do
    while kubectl get namespace "$ns" &> /dev/null 2>&1; do
        echo -n "."
        sleep 2
    done
done

echo ""
progress "All namespaces deleted"

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗"
echo "║               CLEANUP COMPLETE!                               ║"
echo "╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Run ./setup-ckad-env.sh to set up a fresh environment."
echo ""
