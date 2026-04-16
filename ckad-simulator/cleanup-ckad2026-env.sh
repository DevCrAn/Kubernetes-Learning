#!/bin/bash
#
# CKAD 2026 Real Exam Practice - Cleanup Script
# Removes all resources created by setup-ckad2026-env.sh
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║       CKAD 2026 Real Exam Practice - Cleanup                 ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

progress() { echo -e "${GREEN}[✓]${NC} $1"; }
warn()     { echo -e "${YELLOW}[!]${NC} $1"; }

# Delete namespaces (this removes all resources inside)
NAMESPACES=(
    "ckad-secrets"
    "ckad-cronjob"
    "ckad-rbac"
    "ckad-canary"
    "ckad-netpol"
    "ckad-rollout"
    "ckad-probes"
    "ckad-security"
    "ckad-ingress"
    "ckad-quota"
    "ckad-scale"
    "ckad-logs"
    "ckad-api"
    "ckad-resume"
    "ckad-sa-fix"
    "ckad-svc-fix"
    "ckad-cronjob2"
    "ckad-resources"
    "ckad-netpol2"
    "ckad-jobs"
    "ckad-quota-fix"
)

echo "Deleting namespaces..."
for ns in "${NAMESPACES[@]}"; do
    if kubectl get namespace "$ns" &> /dev/null; then
        kubectl delete namespace "$ns" --timeout=60s 2>/dev/null &
        progress "Deleting namespace $ns (background)"
    else
        warn "Namespace $ns not found, skipping"
    fi
done

# Delete resources in default namespace (Q6)
echo ""
echo "Cleaning up default namespace resources..."
kubectl delete deployment broken-app -n default 2>/dev/null || true
progress "Cleaned up Q6 resources in default"

# Wait for namespace deletions
echo ""
echo "Waiting for namespace deletions to complete..."
wait
progress "All namespace deletions initiated"

# Clean up /opt/course exam directories
echo ""
echo "Cleaning up exam directories..."
for d in e6 e9 e11 e14 e15 e17 e18; do
    sudo rm -rf "/opt/course/$d" 2>/dev/null || true
done
progress "Exam directories cleaned"

# Remove Docker images from Q17/Q18
docker rmi web-app:1.0 2>/dev/null || true
docker rmi api-service:2.5 2>/dev/null || true
progress "Docker images cleaned"

# Remove exam timer
rm -f /tmp/ckad-exam-2026-start-time 2>/dev/null || true

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗"
echo "║              CLEANUP COMPLETE!                               ║"
echo "╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Run ./setup-ckad2026-env.sh to set up the environment again."
echo ""
