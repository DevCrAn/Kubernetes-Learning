#!/bin/bash
#
# CKAD 2026 Extended Lab Setup (34 Questions)
# Based on more-questions-ckad2026.md
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

progress() { echo -e "${GREEN}[+]${NC} $1"; }
info()     { echo -e "${BLUE}[i]${NC} $1"; }
warn()     { echo -e "${YELLOW}[!]${NC} $1"; }
error()    { echo -e "${RED}[x]${NC} $1"; }

write_root_file() {
    local path="$1"
    shift
    local content="$*"
    echo "$content" | sudo tee "$path" >/dev/null
}

echo -e "${CYAN}"
echo "=============================================================="
echo " CKAD 2026 Extended Lab Setup"
echo " 34 questions focused on real exam patterns"
echo "=============================================================="
echo -e "${NC}"

if ! command -v kubectl >/dev/null 2>&1; then
    error "kubectl is not installed"
    exit 1
fi

if ! kubectl cluster-info >/dev/null 2>&1; then
    error "Cannot connect to Kubernetes cluster"
    error "Start your cluster first (for example: minikube start)"
    exit 1
fi

progress "Cluster connection verified"

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

echo ""
echo -e "${CYAN}Creating namespaces...${NC}"
for ns in "${NAMESPACES[@]}"; do
    if kubectl get namespace "$ns" >/dev/null 2>&1; then
        warn "Namespace $ns already exists"
    else
        kubectl create namespace "$ns" >/dev/null
        progress "Namespace $ns created"
    fi
done

echo ""
echo -e "${CYAN}Applying seeded lab resources...${NC}"
kubectl apply -f "${SCRIPT_DIR}/resources/ckad2026-more-resources.yaml" >/dev/null
progress "Seed resources applied"

echo ""
echo -e "${CYAN}Creating training files in /ckad and /opt...${NC}"

sudo mkdir -p /ckad/CKAD00016
sudo mkdir -p /ckad/DF
sudo mkdir -p /ckad/KDMC00102
sudo mkdir -p /ckad/goshawk
sudo mkdir -p /ckad/credible-mite
sudo mkdir -p /ckad/CKAD00011
sudo mkdir -p /ckad/CKAD00010
sudo mkdir -p /ckad/chief-cardinal
sudo mkdir -p /ckad/daring-moccasin
sudo mkdir -p /ckad/prompt-escargot
sudo mkdir -p /ckad/CKAD202206
sudo mkdir -p /ckad/ambassador
sudo mkdir -p /opt/KDOB00201

sudo chmod -R 777 /ckad /opt/KDOB00201

write_root_file /ckad/CKAD00016/periodic.yaml "# Create your CronJob manifest here"

write_root_file /ckad/DF/Dockerfile "FROM centos:8\nCMD [\"/bin/bash\"]"

write_root_file /ckad/KDMC00102/fluentd-configmap.yaml "apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentd-config
  namespace: default
data:
  fluent.conf: |
    <source>
      @type tail
      path /ckad/log/input.log
      pos_file /var/log/fluentd-input.pos
      tag ckad.input
      <parse>
        @type none
      </parse>
    </source>
    <match ckad.input>
      @type file
      path /ckad/log/output
      append true
      <format>
        @type json
      </format>
    </match>"

write_root_file /ckad/goshawk/current-chipmunk-deployment.yaml "apiVersion: apps/v1
kind: Deployment
metadata:
  name: current-chipmunk-deployment
  namespace: goshawk
spec:
  replicas: 5
  selector:
    matchLabels:
      app: chipmunk
      release: stable
  template:
    metadata:
      labels:
        app: chipmunk
        release: stable
    spec:
      containers:
      - name: chipmunk
        image: nginx:1.24
        ports:
        - containerPort: 80"

write_root_file /ckad/credible-mite/www.yaml "apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: www
  namespace: garfish
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: www
    spec:
      containers:
      - name: web
        image: nginx:1.16
        ports:
        - containerPort: 80"

write_root_file /ckad/CKAD00011/broken.txt ""
write_root_file /ckad/CKAD00011/error.txt ""
write_root_file /ckad/CKAD00010/pod.txt ""

write_root_file /opt/KDOB00201/counter.yaml "apiVersion: v1
kind: Pod
metadata:
  name: counter
  namespace: default
spec:
  containers:
  - name: count
    image: busybox:1.36
    command:
    - sh
    - -c
    - i=0; while true; do echo \"counter: \$i\"; i=\$((i+1)); sleep 2; done"

write_root_file /opt/KDOB00201/log_Output.txt ""

write_root_file /ckad/chief-cardinal/nosql.yaml "apiVersion: apps/v1
kind: Deployment
metadata:
  name: nosql
  namespace: haddock
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nosql
  template:
    metadata:
      labels:
        app: nosql
    spec:
      containers:
      - name: nosql
        image: redis:7.2-alpine
        resources:
          requests:
            memory: 128Mi
          limits:
            memory: 128Mi"

write_root_file /ckad/daring-moccasin/broker-deployment.yaml "apiVersion: apps/v1
kind: Deployment
metadata:
  name: broker-deployment
  namespace: quetzal
spec:
  replicas: 2
  selector:
    matchLabels:
      app: broker
  template:
    metadata:
      labels:
        app: broker
    spec:
      containers:
      - name: broker
        image: nginx:1.25
        ports:
        - containerPort: 80"

write_root_file /ckad/prompt-escargot/honeybee-deployment.yaml "apiVersion: apps/v1
kind: Deployment
metadata:
  name: honeybee-deployment
  namespace: gorilla
spec:
  replicas: 1
  selector:
    matchLabels:
      app: honeybee
  template:
    metadata:
      labels:
        app: honeybee
    spec:
      serviceAccountName: default
      containers:
      - name: honeybee
        image: bitnami/kubectl:1.31
        command:
        - sh
        - -c
        - while true; do kubectl get serviceaccounts -n gorilla 1>/tmp/out 2>/tmp/err; cat /tmp/out /tmp/err; sleep 5; done"

write_root_file /ckad/CKAD202206/deployment.yaml "apiVersion: apps/v1
kind: Deployment
metadata:
  name: ingress-ckad-app
  namespace: ingress-ckad
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ingress-ckad-app
  template:
    metadata:
      labels:
        app: ingress-ckad-app
    spec:
      containers:
      - name: web
        image: nginx:1.25
        ports:
        - containerPort: 80"

write_root_file /ckad/CKAD202206/service.yaml "apiVersion: v1
kind: Service
metadata:
  name: ingress-ckad-svc
  namespace: ingress-ckad
spec:
  selector:
    app: wrong-selector
  ports:
  - port: 80
    targetPort: 80"

write_root_file /ckad/CKAD202206/ingress.yaml "apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-ckad-ing
  namespace: ingress-ckad
spec:
  rules:
  - host: ingress-ckad.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: ingress-ckad-missing-svc
            port:
              number: 80"

write_root_file /ckad/ambassador/haproxy.cfg "global
    daemon

defaults
    mode http
    timeout connect 5s
    timeout client 30s
    timeout server 30s

frontend http-in
    bind *:80
    default_backend app-backend

backend app-backend
    server nginxsvc nginxsvc:9090"

if [[ ! -f ~/.ckad-env ]]; then
cat > ~/.ckad-env << 'ENVEOF'
alias k=kubectl
alias kn='kubectl config set-context --current --namespace'
export do='--dry-run=client -o yaml'
export now='--force --grace-period 0'
source <(kubectl completion bash 2>/dev/null) 2>/dev/null || true
complete -F __start_kubectl k 2>/dev/null || true
ENVEOF
progress "Created ~/.ckad-env"
fi

echo ""
info "Waiting briefly for key deployments"
kubectl rollout status deployment/current-chipmunk-deployment -n goshawk --timeout=60s >/dev/null 2>&1 || true
kubectl rollout status deployment/webapp -n ckad00015 --timeout=60s >/dev/null 2>&1 || true
kubectl rollout status deployment/honeybee-deployment -n gorilla --timeout=60s >/dev/null 2>&1 || true
kubectl rollout status deployment/frontend-deployment -n frontend --timeout=60s >/dev/null 2>&1 || true


echo ""
echo -e "${GREEN}Extended CKAD 2026 lab is ready.${NC}"
echo ""
echo "Use this question bank in English:"
echo "  ckad-simulator/more-questions-ckad2026-en.md"
echo ""
echo "Optional reset:"
echo "  ./cleanup-more-ckad2026-env.sh && ./setup-more-ckad2026-env.sh"
echo ""
