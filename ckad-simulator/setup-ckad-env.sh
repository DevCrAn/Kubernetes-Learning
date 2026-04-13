#!/bin/bash
#
# CKAD Simulator Environment Setup Script
# Based on Killer.sh CKAD Simulator - Kubernetes 1.35
#
# This script configures your Kubernetes cluster to practice
# all 25 questions from the CKAD simulator
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║          CKAD Simulator Environment Setup                    ║"
echo "║          Based on Killer.sh - Kubernetes 1.35                ║"
echo "║          25 Questions + Exam Runner                          ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Helper functions
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
    "earth"      # Q12, Preview Q3
    "jupiter"    # Q19
    "mars"       # Q18
    "mercury"    # Q4 (Helm), Q16
    "moon"       # Q13, Q14, Q15
    "neptune"    # Q3, Q5, Q7, Q8, Q21
    "pluto"      # Q9, Q10, Preview Q1
    "saturn"     # Q7
    "sun"        # Q22, Preview Q2
    "venus"      # Q20
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
# STEP 2: Create ServiceAccounts and Secrets
# ============================================================================
echo ""
echo -e "${CYAN}=== Step 2: Creating ServiceAccounts and Secrets ===${NC}"

kubectl apply -f "${SCRIPT_DIR}/resources/serviceaccounts.yaml"
progress "ServiceAccounts created (neptune-sa-v2, sa-sun-deploy)"

kubectl apply -f "${SCRIPT_DIR}/resources/secrets.yaml"
progress "Secrets created (neptune-secret-1)"

# ============================================================================
# STEP 3: Create Saturn Pods (Q7)
# ============================================================================
echo ""
echo -e "${CYAN}=== Step 3: Creating Saturn Pods (Q7) ===${NC}"

kubectl apply -f "${SCRIPT_DIR}/resources/saturn-pods.yaml"
progress "6 webserver Pods in saturn (one has annotation: my-happy-shop)"

# ============================================================================
# STEP 4: Create Pluto resources (Q9, Preview Q1)
# ============================================================================
echo ""
echo -e "${CYAN}=== Step 4: Creating Pluto resources (Q9, PQ1) ===${NC}"

kubectl apply -f "${SCRIPT_DIR}/resources/pluto-pods.yaml"
progress "Pod holy-api in pluto"

kubectl apply -f "${SCRIPT_DIR}/resources/pluto-deployments.yaml"
progress "Deployment project-23-api in pluto"

# ============================================================================
# STEP 5: Create Earth resources (Q12, Preview Q3)
# ============================================================================
echo ""
echo -e "${CYAN}=== Step 5: Creating Earth resources (Q12, PQ3) ===${NC}"

kubectl apply -f "${SCRIPT_DIR}/resources/earth-resources.yaml"
progress "Earth Deployments and Services (earth-3cc-web has broken readinessProbe)"

# ============================================================================
# STEP 6: Create Neptune resources (Q5, Q8)
# ============================================================================
echo ""
echo -e "${CYAN}=== Step 6: Creating Neptune resources (Q5, Q8) ===${NC}"

kubectl apply -f "${SCRIPT_DIR}/resources/neptune-resources.yaml"
progress "Deployment api-new-c32 in neptune (initial)"

# Create rollout history for Q8
info "Creating rollout history for api-new-c32..."
kubectl rollout status deployment/api-new-c32 -n neptune --timeout=30s 2>/dev/null || true
sleep 1

# Revision 2
kubectl set image deployment/api-new-c32 -n neptune api=nginx:1.17.3-alpine 2>/dev/null || true
kubectl annotate deployment/api-new-c32 -n neptune kubernetes.io/change-cause="update to nginx 1.17.3" --overwrite 2>/dev/null || true
kubectl rollout status deployment/api-new-c32 -n neptune --timeout=30s 2>/dev/null || true
sleep 1

# Revision 3
kubectl set image deployment/api-new-c32 -n neptune api=nginx:1.19-alpine 2>/dev/null || true
kubectl annotate deployment/api-new-c32 -n neptune kubernetes.io/change-cause="update to nginx 1.19" --overwrite 2>/dev/null || true
kubectl rollout status deployment/api-new-c32 -n neptune --timeout=30s 2>/dev/null || true
sleep 1

# Revision 4 - BROKEN (typo in image name: ngnix instead of nginx)
kubectl set image deployment/api-new-c32 -n neptune api=ngnix:1.21-alpine 2>/dev/null || true
kubectl annotate deployment/api-new-c32 -n neptune kubernetes.io/change-cause="update to ngnix 1.21 - LATEST" --overwrite 2>/dev/null || true
progress "Rollout history created (revision 4 has ImagePullBackOff - typo in image)"

# ============================================================================
# STEP 7: Create Moon resources (Q13, Q14, Q15)
# ============================================================================
echo ""
echo -e "${CYAN}=== Step 7: Creating Moon resources (Q13, Q14, Q15) ===${NC}"

# Apply secret-handler pod first (it doesn't depend on missing ConfigMap)
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: secret-handler
  namespace: moon
spec:
  containers:
  - name: secret-handler
    image: nginx:1.17.3-alpine
    ports:
    - containerPort: 80
EOF
progress "Pod secret-handler in moon (Q14)"

# Apply web-moon deployment - pods will fail because ConfigMap doesn't exist
kubectl apply -f - <<EOF 2>/dev/null || true
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-moon
  namespace: moon
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-moon
  template:
    metadata:
      labels:
        app: web-moon
    spec:
      volumes:
      - name: html-volume
        configMap:
          name: configmap-web-moon-html
      containers:
      - name: nginx
        image: nginx:1.17.3-alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: html-volume
          mountPath: /usr/share/nginx/html
EOF
progress "Deployment web-moon in moon (waiting for ConfigMap - Q15 exercise)"

# ============================================================================
# STEP 8: Create Sun resources (Q22, PQ2)
# ============================================================================
echo ""
echo -e "${CYAN}=== Step 8: Creating Sun resources (Q22, PQ2) ===${NC}"

kubectl apply -f "${SCRIPT_DIR}/resources/sun-resources.yaml"
progress "Sun Pods with type labels (worker, runner) and Deployment"

# ============================================================================
# STEP 9: Create Mercury resources (Q4 Helm, Q16)
# ============================================================================
echo ""
echo -e "${CYAN}=== Step 9: Creating Mercury resources (Q16) ===${NC}"

kubectl apply -f "${SCRIPT_DIR}/resources/mercury-resources.yaml"
progress "Cleaner Deployment in mercury (Q16)"

# ============================================================================
# STEP 10: Create Mars resources (Q18)
# ============================================================================
echo ""
echo -e "${CYAN}=== Step 10: Creating Mars resources (Q18) ===${NC}"

kubectl apply -f "${SCRIPT_DIR}/resources/mars-resources.yaml"
progress "Mars manager-api with MISCONFIGURED Service selector"

# ============================================================================
# STEP 11: Create Jupiter resources (Q19)
# ============================================================================
echo ""
echo -e "${CYAN}=== Step 11: Creating Jupiter resources (Q19) ===${NC}"

kubectl apply -f "${SCRIPT_DIR}/resources/jupiter-resources.yaml"
progress "Jupiter crew Deployment and ClusterIP Service"

# ============================================================================
# STEP 12: Create Venus resources (Q20)
# ============================================================================
echo ""
echo -e "${CYAN}=== Step 12: Creating Venus resources (Q20) ===${NC}"

kubectl apply -f "${SCRIPT_DIR}/resources/venus-resources.yaml"
progress "Venus api and frontend Deployments with Services"

# ============================================================================
# STEP 13: Setup Helm releases (Q4)
# ============================================================================
echo ""
echo -e "${CYAN}=== Step 13: Setting up Helm releases for Q4 ===${NC}"

if command -v helm &> /dev/null; then
    HELM_CHARTS_DIR="${SCRIPT_DIR}/helm-charts"
    HELM_REPO_DIR="/tmp/killershell-helm-repo"

    # Package charts for local repo
    mkdir -p "${HELM_REPO_DIR}"
    helm package "${HELM_CHARTS_DIR}/nginx" -d "${HELM_REPO_DIR}" 2>/dev/null || true
    helm package "${HELM_CHARTS_DIR}/nginx-0.1.0" -d "${HELM_REPO_DIR}" 2>/dev/null || true
    helm package "${HELM_CHARTS_DIR}/apache" -d "${HELM_REPO_DIR}" 2>/dev/null || true
    helm repo index "${HELM_REPO_DIR}" 2>/dev/null || true

    # Start local chart repository server
    pkill -f "python3 -m http.server 8879" 2>/dev/null || true
    sleep 1
    cd "${HELM_REPO_DIR}" && nohup python3 -m http.server 8879 &>/dev/null &
    HELM_SERVER_PID=$!
    sleep 2
    cd "${SCRIPT_DIR}"

    # Add local repo as 'killershell'
    helm repo remove killershell 2>/dev/null || true
    helm repo add killershell http://localhost:8879 2>/dev/null || true
    helm repo update 2>/dev/null || true
    progress "Local Helm repo 'killershell' configured at http://localhost:8879"

    # Install release apiv1 (student must DELETE this)
    if ! helm status internal-issue-report-apiv1 -n mercury &>/dev/null; then
        helm install internal-issue-report-apiv1 killershell/nginx \
            -n mercury --set replicaCount=1 2>/dev/null || warn "Failed to install apiv1"
    fi
    progress "Helm release: internal-issue-report-apiv1 (DELETE this)"

    # Install release apiv2 with OLDER version (student must UPGRADE this)
    if ! helm status internal-issue-report-apiv2 -n mercury &>/dev/null; then
        helm install internal-issue-report-apiv2 killershell/nginx \
            -n mercury --version 0.1.0 --set replicaCount=1 2>/dev/null || warn "Failed to install apiv2"
    fi
    progress "Helm release: internal-issue-report-apiv2 v0.1.0 (UPGRADE this)"

    # Create broken release stuck in pending-install
    if ! helm status internal-issue-report-daniel -n mercury &>/dev/null 2>&1; then
        info "Creating broken Helm release (pending-install)..."
        # Install in background with --wait and kill to leave pending-install
        timeout 3 helm install internal-issue-report-daniel killershell/nginx \
            -n mercury --set image.repository=invalid-reg/invalid \
            --set image.tag=nonexistent --wait --timeout 2s 2>/dev/null || true

        # Check if release exists; if not (timeout killed it), create manually
        if ! helm ls -n mercury -a 2>/dev/null | grep -q "internal-issue-report-daniel"; then
            # Fallback: install without --wait
            helm install internal-issue-report-daniel killershell/nginx \
                -n mercury --set image.repository=invalid-reg/invalid \
                --set image.tag=nonexistent 2>/dev/null || true
        fi
    fi
    progress "Helm release: internal-issue-report-daniel (BROKEN - find and delete)"

    echo ""
    info "Helm releases in mercury namespace:"
    helm ls -n mercury -a 2>/dev/null || true
else
    warn "Helm is not installed. Q4 (Helm Management) will not be fully available."
    warn "Install Helm: curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash"
fi

# ============================================================================
# STEP 14: Create directory structure and copy templates
# ============================================================================
echo ""
echo -e "${CYAN}=== Step 14: Creating directory structure and templates ===${NC}"

# Create answer directories
for i in {1..22}; do
    sudo mkdir -p "/opt/course/$i"
done
sudo mkdir -p /opt/course/p1 /opt/course/p2 /opt/course/p3
sudo chmod -R 777 /opt/course

# Copy template files
TEMPLATES_DIR="${SCRIPT_DIR}/templates"

cp "${TEMPLATES_DIR}/q9/holy-api-pod.yaml" "/opt/course/9/holy-api-pod.yaml" 2>/dev/null || true
progress "Q9:  /opt/course/9/holy-api-pod.yaml"

if [ -d "${TEMPLATES_DIR}/q11/image" ]; then
    cp -r "${TEMPLATES_DIR}/q11/image" "/opt/course/11/" 2>/dev/null || true
    progress "Q11: /opt/course/11/image/ (Dockerfile + main.go)"
fi

cp "${TEMPLATES_DIR}/q14/secret-handler.yaml" "/opt/course/14/secret-handler.yaml" 2>/dev/null || true
cp "${TEMPLATES_DIR}/q14/secret2.yaml" "/opt/course/14/secret2.yaml" 2>/dev/null || true
progress "Q14: /opt/course/14/ (secret-handler.yaml + secret2.yaml)"

cp "${TEMPLATES_DIR}/q15/web-moon.html" "/opt/course/15/web-moon.html" 2>/dev/null || true
progress "Q15: /opt/course/15/web-moon.html"

cp "${TEMPLATES_DIR}/q16/cleaner.yaml" "/opt/course/16/cleaner.yaml" 2>/dev/null || true
progress "Q16: /opt/course/16/cleaner.yaml"

cp "${TEMPLATES_DIR}/q17/test-init-container.yaml" "/opt/course/17/test-init-container.yaml" 2>/dev/null || true
progress "Q17: /opt/course/17/test-init-container.yaml"

cp "${SCRIPT_DIR}/resources/project-23-api.yaml" "/opt/course/p1/project-23-api.yaml" 2>/dev/null || true
progress "PQ1: /opt/course/p1/project-23-api.yaml"

progress "All template files copied to /opt/course/"

# ============================================================================
# STEP 15: Setup Docker registry for Q11
# ============================================================================
echo ""
echo -e "${CYAN}=== Step 15: Docker registry setup for Q11 ===${NC}"

if command -v docker &> /dev/null; then
    if ! docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^registry$"; then
        docker run -d -p 5000:5000 --restart=always --name registry registry:2 2>/dev/null || \
            warn "Registry container may already exist"
    fi

    if ! grep -q "registry.killer.sh" /etc/hosts 2>/dev/null; then
        echo "127.0.0.1 registry.killer.sh" | sudo tee -a /etc/hosts > /dev/null 2>/dev/null || true
    fi
    progress "Docker registry available at registry.killer.sh:5000"
else
    warn "Docker not available. Q11 (container builds) will be limited."
fi

# ============================================================================
# STEP 16: Configure bash environment
# ============================================================================
echo ""
echo -e "${CYAN}=== Step 16: Configuring bash environment ===${NC}"

cat > ~/.ckad-env << 'ENVEOF'
# CKAD Exam Environment Variables
alias k=kubectl
alias kn='kubectl config set-context --current --namespace'
export do="--dry-run=client -o yaml"
export now="--force --grace-period 0"

# Autocompletion
source <(kubectl completion bash 2>/dev/null) 2>/dev/null || true
complete -F __start_kubectl k 2>/dev/null || true
source <(helm completion bash 2>/dev/null) 2>/dev/null || true

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
info "Run 'source ~/.ckad-env' to load aliases"

# ============================================================================
# SUMMARY
# ============================================================================
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗"
echo "║                    SETUP COMPLETE!                            ║"
echo "╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Namespaces:${NC} earth, jupiter, mars, mercury, moon, neptune, pluto, saturn, sun, venus"
echo ""
echo -e "${GREEN}Resources created per question:${NC}"
echo "  Q1  Namespaces            - All namespaces ready"
echo "  Q2  Pods                  - (student creates)"
echo "  Q3  Job                   - neptune namespace ready"
echo "  Q4  Helm Management       - 3 Helm releases in mercury + killershell repo"
echo "  Q5  ServiceAccount/Secret - neptune-sa-v2 + neptune-secret-1"
echo "  Q6  ReadinessProbe        - (student creates)"
echo "  Q7  Pod Migration         - 6 webserver pods in saturn (my-happy-shop)"
echo "  Q8  Deployment Rollouts   - api-new-c32 with broken revision in neptune"
echo "  Q9  Pod->Deployment       - holy-api Pod + template at /opt/course/9/"
echo "  Q10 Service/Logs          - (student creates in pluto)"
echo "  Q11 Containers            - Build files at /opt/course/11/ + registry"
echo "  Q12 Storage PV/PVC        - earth namespace ready"
echo "  Q13 StorageClass PVC      - moon namespace ready"
echo "  Q14 Secrets               - secret-handler Pod + templates in moon"
echo "  Q15 ConfigMap             - web-moon Deployment waiting for ConfigMap"
echo "  Q16 Sidecar               - cleaner Deployment + template in mercury"
echo "  Q17 InitContainer         - template at /opt/course/17/"
echo "  Q18 Service Misconfig     - manager-api with wrong selector in mars"
echo "  Q19 ClusterIP->NodePort   - jupiter-crew deploy+svc in jupiter"
echo "  Q20 NetworkPolicy         - api + frontend in venus"
echo "  Q21 Requests/Limits       - neptune-sa-v2 ready"
echo "  Q22 Labels/Annotations    - Pods with type labels in sun"
echo "  PQ1 LivenessProbe         - project-23-api + template"
echo "  PQ2 Deploy+Service        - sa-sun-deploy SA ready"
echo "  PQ3 Service Fix           - earth-3cc-web with broken readinessProbe"
echo ""
echo -e "${YELLOW}To start practicing:${NC}"
echo "  1. source ~/.ckad-env"
echo "  2. ./exam-runner.sh start        # Start timed exam (2 hours)"
echo "  3. Solve questions from questions-en.md or questions-es.md"
echo "  4. ./exam-runner.sh evaluate     # Check your answers"
echo ""
echo -e "${YELLOW}To reset:${NC}"
echo "  ./cleanup-ckad-env.sh && ./setup-ckad-env.sh"
echo ""
