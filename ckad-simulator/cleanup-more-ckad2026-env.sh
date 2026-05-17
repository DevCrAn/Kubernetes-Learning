#!/bin/bash
#
# CKAD 2026 Extended Lab Cleanup (34 Questions)
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

progress() { echo -e "${GREEN}[+]${NC} $1"; }
warn()     { echo -e "${YELLOW}[!]${NC} $1"; }

echo -e "${CYAN}"
echo "=============================================================="
echo " CKAD 2026 Extended Lab Cleanup"
echo "=============================================================="
echo -e "${NC}"

NAMESPACES=(
    "frontend"
    "goshawk"
    "ckad00015"
    "data"
    "garfish"
    "dk8s"
    "cpu-stress"
    "pod-resources"
    "haddock"
    "quetzal"
    "restricted"
    "gorilla"
    "monitoring"
    "ckad00014"
    "ckad00018"
    "secure"
    "ckad00017"
    "ingress-ckad"
    "ingress-kk"
    "logging"
    "production"
)

echo "Deleting namespaces..."
for ns in "${NAMESPACES[@]}"; do
    if kubectl get namespace "$ns" >/dev/null 2>&1; then
        kubectl delete namespace "$ns" --timeout=60s >/dev/null 2>&1 &
        progress "Deleting namespace $ns in background"
    else
        warn "Namespace $ns not found"
    fi
done

echo ""
echo "Cleaning default namespace seeded resources..."
kubectl delete deployment nginxsvc-backend -n default >/dev/null 2>&1 || true
kubectl delete service nginxsvc -n default >/dev/null 2>&1 || true
kubectl delete pod poller -n default >/dev/null 2>&1 || true
kubectl delete deployment broken-image-deployment -n default >/dev/null 2>&1 || true
kubectl delete deployment api-app -n default >/dev/null 2>&1 || true
kubectl delete service api-svc -n default >/dev/null 2>&1 || true
kubectl delete deployment frontend-svc-backend -n default >/dev/null 2>&1 || true
kubectl delete service frontend-svc -n default >/dev/null 2>&1 || true
progress "Default namespace cleanup complete"

echo ""
echo "Removing lab files..."
sudo rm -rf /ckad/CKAD00016 \
            /ckad/DF \
            /ckad/KDMC00102 \
            /ckad/goshawk \
            /ckad/credible-mite \
            /ckad/CKAD00011 \
            /ckad/CKAD00010 \
            /ckad/chief-cardinal \
            /ckad/daring-moccasin \
            /ckad/prompt-escargot \
            /ckad/CKAD202206 \
            /ckad/ambassador >/dev/null 2>&1 || true

sudo rm -rf /opt/KDOB00201 >/dev/null 2>&1 || true
progress "Training files removed"

docker rmi centos:8.2 >/dev/null 2>&1 || true
rm -f /tmp/ckad-exam-start-time >/dev/null 2>&1 || true

wait || true


echo ""
echo -e "${GREEN}Extended CKAD 2026 cleanup completed.${NC}"
echo ""
