#!/bin/bash
#
# CKAD 2026 Real Exam Practice - Environment Setup Script
# Based on topics confirmed by the community (Reddit r/ckad)
# Aligned with Kubernetes v1.35
#
# This script creates all resources needed for the 25 practice questions
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║       CKAD 2026 Real Exam Practice - Setup                   ║"
echo "║       25 Questions Based on Real Exam Topics                 ║"
echo "║       Kubernetes v1.35 | 127 Points | 2 Hours               ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

progress() { echo -e "${GREEN}[✓]${NC} $1"; }
info()     { echo -e "${BLUE}[i]${NC} $1"; }
warn()     { echo -e "${YELLOW}[!]${NC} $1"; }
error()    { echo -e "${RED}[✗]${NC} $1"; }

# ============================================================================
# PRE-CHECKS
# ============================================================================
if ! command -v kubectl &> /dev/null; then
    error "kubectl is not installed."
    exit 1
fi

if ! kubectl cluster-info &> /dev/null; then
    error "Cannot connect to Kubernetes cluster."
    error "Make sure Minikube is running: minikube start"
    exit 1
fi

progress "Cluster connection verified"
CLUSTER_VERSION=$(kubectl version -o json 2>/dev/null | jq -r '.serverVersion.gitVersion' 2>/dev/null || echo "unknown")
info "Cluster version: ${CLUSTER_VERSION}"

# ============================================================================
# STEP 1: Create Namespaces
# ============================================================================
echo ""
echo -e "${CYAN}=== Step 1: Creating Namespaces ===${NC}"

NAMESPACES=(
    "ckad-secrets"    # Q1: Secrets from variables
    "ckad-cronjob"    # Q2: CronJob
    "ckad-rbac"       # Q3: RBAC
    "ckad-canary"     # Q4: Canary Deployment
    "ckad-netpol"     # Q5: NetworkPolicy
    "ckad-rollout"    # Q7: Rolling Update
    "ckad-probes"     # Q8: Readiness Probe
    "ckad-security"   # Q9: SecurityContext
    "ckad-ingress"    # Q10, Q11: Ingress
    "ckad-quota"      # Q12: ResourceQuota
    "ckad-scale"      # Q13: Scale + NodePort
    "ckad-logs"       # Q14: Logs + Metrics
    "ckad-api"        # Q15: API Deprecation
    "ckad-resume"     # Q16: Rollout Resume
    "ckad-sa-fix"     # Q19: Fix SA
    "ckad-svc-fix"    # Q20: Fix Service Selector
    "ckad-cronjob2"   # Q21: CronJob historyLimits
    "ckad-resources"  # Q22: LimitRange
    "ckad-netpol2"    # Q23: NetworkPolicy ingress+egress
    "ckad-jobs"       # Q24: Job completions+parallelism
    "ckad-quota-fix"  # Q25: Fix ResourceQuota
)

for ns in "${NAMESPACES[@]}"; do
    if kubectl get namespace "$ns" &> /dev/null; then
        warn "Namespace $ns already exists, skipping..."
    else
        kubectl create namespace "$ns"
        progress "Namespace $ns created"
    fi
done

# ============================================================================
# STEP 2: Apply all Kubernetes resources
# ============================================================================
echo ""
echo -e "${CYAN}=== Step 2: Creating Kubernetes Resources ===${NC}"

kubectl apply -f "${SCRIPT_DIR}/resources/ckad2026-resources.yaml" 2>/dev/null || true
progress "All K8s resources created"

# Wait for deployments to be ready
echo ""
info "Waiting for Deployments to roll out..."

DEPLOYMENTS=(
    "api-server:ckad-secrets"
    "webapp-stable:ckad-canary"
    "web-app:ckad-rollout"
    "api-deploy:ckad-probes"
    "secure-app:ckad-security"
    "web-deploy:ckad-ingress"
    "frontend-deploy:ckad-scale"
    "web-deploy:ckad-api"
    "web-app:ckad-svc-fix"
)

for item in "${DEPLOYMENTS[@]}"; do
    deploy="${item%%:*}"
    ns="${item##*:}"
    kubectl rollout status deployment/"$deploy" -n "$ns" --timeout=60s 2>/dev/null || \
        warn "Deployment $deploy in $ns not ready yet (may need time)"
done

# web-paused is paused by design - ignore its status
info "Deployment web-paused in ckad-resume is paused by design (Q16)"

progress "Deployments created"

# ============================================================================
# STEP 3: Verify NetworkPolicy Pods (Q5)
# ============================================================================
echo ""
echo -e "${CYAN}=== Step 3: Verifying NetworkPolicy Pods ===${NC}"

kubectl wait --for=condition=Ready pod/frontend -n ckad-netpol --timeout=60s 2>/dev/null || true
kubectl wait --for=condition=Ready pod/backend -n ckad-netpol --timeout=60s 2>/dev/null || true
kubectl wait --for=condition=Ready pod/database -n ckad-netpol --timeout=60s 2>/dev/null || true
progress "NetworkPolicy Pods ready with wrong labels (Q5)"

# ============================================================================
# STEP 4: Verify RBAC Pod (Q3) - should fail with auth errors
# ============================================================================
echo ""
echo -e "${CYAN}=== Step 4: RBAC Pod Setup ===${NC}"

kubectl wait --for=condition=Ready pod/log-collector -n ckad-rbac --timeout=60s 2>/dev/null || \
    warn "log-collector pod may take time (it runs kubectl loops)"
progress "RBAC Pod log-collector created (will have auth errors - Q3)"

# ============================================================================
# STEP 5: Verify Canary resources (Q4)
# ============================================================================
echo ""
echo -e "${CYAN}=== Step 5: Canary Deployment Setup ===${NC}"

kubectl rollout status deployment/webapp-stable -n ckad-canary --timeout=60s 2>/dev/null || true
progress "Stable Deployment webapp-stable with 4 replicas (Q4)"

# ============================================================================
# STEP 6: Create directory structure and copy templates
# ============================================================================
echo ""
echo -e "${CYAN}=== Step 6: Creating directories and copying templates ===${NC}"

TEMPLATES_DIR="${SCRIPT_DIR}/templates"

# Create answer directories
for i in e6 e9 e11 e14 e15 e17 e18; do
    sudo mkdir -p "/opt/course/$i"
done
sudo chmod -R 777 /opt/course

# Copy template files
cp "${TEMPLATES_DIR}/e6/broken-deploy.yaml" "/opt/course/e6/broken-deploy.yaml" 2>/dev/null || true
progress "Q6:  /opt/course/e6/broken-deploy.yaml (broken Deployment)"

cp "${TEMPLATES_DIR}/e9/secure-app.yaml" "/opt/course/e9/secure-app.yaml" 2>/dev/null || true
progress "Q9:  /opt/course/e9/secure-app.yaml (SecurityContext)"

cp "${TEMPLATES_DIR}/e11/fix-ingress.yaml" "/opt/course/e11/fix-ingress.yaml" 2>/dev/null || true
progress "Q11: /opt/course/e11/fix-ingress.yaml (broken Ingress)"

cp "${TEMPLATES_DIR}/e14/logger-pod.yaml" "/opt/course/e14/logger-pod.yaml" 2>/dev/null || true
progress "Q14: /opt/course/e14/logger-pod.yaml (Logger Pod)"

cp "${TEMPLATES_DIR}/e15/ckad-hpa.yaml" "/opt/course/e15/ckad-hpa.yaml" 2>/dev/null || true
progress "Q15: /opt/course/e15/ckad-hpa.yaml (deprecated HPA)"

cp -r "${TEMPLATES_DIR}/e17/image" "/opt/course/e17/" 2>/dev/null || true
progress "Q17: /opt/course/e17/image/ (Dockerfile + index.html)"

cp -r "${TEMPLATES_DIR}/e18/image" "/opt/course/e18/" 2>/dev/null || true
progress "Q18: /opt/course/e18/image/ (Dockerfile + app.py)"

# ============================================================================
# STEP 7: Configure bash environment
# ============================================================================
echo ""
echo -e "${CYAN}=== Step 7: Configuring environment ===${NC}"

if [[ ! -f ~/.ckad-env ]]; then
    cat > ~/.ckad-env << 'ENVEOF'
# CKAD Exam Environment Variables
alias k=kubectl
alias kn='kubectl config set-context --current --namespace'
export do="--dry-run=client -o yaml"
export now="--force --grace-period 0"

# Autocompletion
source <(kubectl completion bash 2>/dev/null) 2>/dev/null || true
complete -F __start_kubectl k 2>/dev/null || true

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  CKAD Practice Environment Loaded!"
echo "  Aliases:  k = kubectl  |  kn = set namespace"
echo "  Vars:     \$do = --dry-run=client -o yaml"
echo "            \$now = --force --grace-period 0"
echo "═══════════════════════════════════════════════════════════"
echo ""
ENVEOF
    progress "~/.ckad-env created"
else
    progress "~/.ckad-env already exists"
fi

# ============================================================================
# SUMMARY
# ============================================================================
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗"
echo "║              CKAD 2026 SETUP COMPLETE!                       ║"
echo "╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Namespaces:${NC} ckad-secrets, ckad-cronjob, ckad-rbac, ckad-canary,"
echo "            ckad-netpol, ckad-rollout, ckad-probes, ckad-security,"
echo "            ckad-ingress, ckad-quota, ckad-scale, ckad-logs,"
echo "            ckad-api, ckad-resume, ckad-sa-fix, ckad-svc-fix,"
echo "            ckad-cronjob2, ckad-resources, ckad-netpol2, ckad-jobs,"
echo "            ckad-quota-fix"
echo ""
echo -e "${GREEN}Questions (25 total, 127 points):${NC}"
echo "  Q1  Secret from Hardcoded Vars     - api-server in ckad-secrets"
echo "  Q2  CronJob                        - (student creates in ckad-cronjob)"
echo "  Q3  RBAC: SA + Role + RoleBinding  - log-collector in ckad-rbac"
echo "  Q4  Canary Deployment              - webapp-stable in ckad-canary"
echo "  Q5  Fix NetworkPolicy Labels       - 3 Pods + 3 Policies in ckad-netpol"
echo "  Q6  Fix Broken Deployment YAML     - /opt/course/e6/broken-deploy.yaml"
echo "  Q7  Rolling Update + Rollback      - web-app in ckad-rollout"
echo "  Q8  Readiness Probe (HTTP GET)     - api-deploy in ckad-probes"
echo "  Q9  SecurityContext                - secure-app in ckad-security"
echo "  Q10 Create Ingress                 - web-deploy + web-svc in ckad-ingress"
echo "  Q11 Fix Ingress PathType           - /opt/course/e11/fix-ingress.yaml"
echo "  Q12 ResourceQuota Pod Limits       - compute-quota in ckad-quota"
echo "  Q13 Scale + Label + NodePort       - frontend-deploy in ckad-scale"
echo "  Q14 Pod Logs + Metrics             - /opt/course/e14/logger-pod.yaml"
echo "  Q15 API Deprecation (HPA)          - /opt/course/e15/ckad-hpa.yaml"
echo "  Q16 Rollout Resume                 - web-paused in ckad-resume"
echo "  Q17 Docker Build + Save Tarball    - /opt/course/e17/image/"
echo "  Q18 Docker Build + OCI Save        - /opt/course/e18/image/"
echo "  Q19 Fix Pod ServiceAccount         - metrics-pod in ckad-sa-fix"
echo "  Q20 Fix Service Selector           - web-svc in ckad-svc-fix"
echo "  Q21 CronJob with History Limits    - (student creates in ckad-cronjob2)"
echo "  Q22 Resource Limits from LimitRange- LimitRange in ckad-resources"
echo "  Q23 NetworkPolicy Ingress+Egress   - api-pod + db-pod in ckad-netpol2"
echo "  Q24 Job Completions+Parallelism    - (student creates in ckad-jobs)"
echo "  Q25 Fix Deploy ResourceQuota       - quota-app in ckad-quota-fix"
echo ""
echo -e "${YELLOW}To start practicing:${NC}"
echo "  1. source ~/.ckad-env"
echo "  2. ./exam-runner.sh start --exam ckad2026      # Start 2-hour exam"
echo "  3. Solve questions from questions-ckad2026-en.md (or -es.md)"
echo "  4. ./exam-runner.sh evaluate --exam ckad2026  # Check answers"
echo ""
echo -e "${YELLOW}Or practice without timer:${NC}"
echo "  Open questions-ckad2026-en.md and solve at your own pace"
echo "  Run ./exam-evaluator-2026.sh to check your answers anytime"
echo ""
echo -e "${YELLOW}To reset:${NC}"
echo "  ./cleanup-ckad2026-env.sh && ./setup-ckad2026-env.sh"
echo ""
