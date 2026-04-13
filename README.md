# Kubernetes-Learning: CKAD Practice Simulator

A free, open-source CKAD (Certified Kubernetes Application Developer) exam simulator inspired by [Killer Shell](https://killer.sh), designed to run in **GitHub Codespaces** with a single command.

## Features

- **25 exam questions** (22 + 3 preview) based on the official Killer Shell CKAD simulator
- **2-hour timed exam** just like the real CKAD
- **Automatic answer evaluation** with scoring and pass/fail result (66% to pass)
- **Complete environment setup** with all pre-existing resources
- **Helm support** with local chart repository simulating `killershell/` charts
- **Docker registry** for container build exercises
- **Bilingual** questions available in English and Spanish
- **One-command setup** - everything provisioned automatically
- **Kubernetes 1.35** matching the current CKAD exam version

## Quick Start (GitHub Codespaces)

### 1. Open in Codespaces

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/DevCrAn/Kubernetes-Learning/codespaces)

Or from the repo page: **Code** > **Codespaces** > **Create codespace on main**

> The devcontainer automatically starts Minikube with K8s 1.35.

### 2. Setup the Exam Environment

```bash
cd ckad-simulator
./setup-ckad-env.sh
source ~/.ckad-env
```

### 3. Start the Exam

```bash
./exam-runner.sh start               # English
./exam-runner.sh start --lang es     # Spanish
```

### 4. Solve Questions

Open `questions-en.md` (or `questions-es.md`) and start solving. Save your work in `/opt/course/<question-number>/`.

### 5. Check Your Score

```bash
./exam-runner.sh evaluate    # Check answers anytime
./exam-runner.sh status      # Check remaining time
./exam-runner.sh end         # Finish and get final score
```

### 6. Reset and Try Again

```bash
./cleanup-ckad-env.sh && ./setup-ckad-env.sh
```

## Exam Runner Commands

| Command | Description |
|---------|-------------|
| `./exam-runner.sh start [--lang en\|es]` | Start a new 2-hour exam session |
| `./exam-runner.sh status` | Show time remaining and progress |
| `./exam-runner.sh timer` | Live countdown timer |
| `./exam-runner.sh evaluate` | Evaluate answers and show score |
| `./exam-runner.sh end` | End exam and show final results |
| `./exam-runner.sh reset` | Reset exam timer |
| `./exam-runner.sh questions [--lang en\|es]` | Display questions |

## Project Structure

```
Kubernetes-Learning/
├── .devcontainer/                  # GitHub Codespaces configuration
│   ├── devcontainer.json
│   └── Dockerfile                  # kubectl 1.35, Helm, yq, etc.
├── ckad-simulator/
│   ├── setup-ckad-env.sh          # One-command environment setup
│   ├── cleanup-ckad-env.sh        # Clean environment for retry
│   ├── exam-runner.sh             # Exam timer and management
│   ├── exam-evaluator.sh          # Automatic answer checker
│   ├── questions-en.md            # 25 questions (English)
│   ├── questions-es.md            # 25 questions (Spanish)
│   ├── tips-en.md                 # Exam tips (English)
│   ├── tips-es.md                 # Exam tips (Spanish)
│   ├── resources/                 # Kubernetes YAML resources
│   │   ├── serviceaccounts.yaml   # Q5, PQ2
│   │   ├── secrets.yaml           # Q5
│   │   ├── saturn-pods.yaml       # Q7
│   │   ├── pluto-pods.yaml        # Q9
│   │   ├── pluto-deployments.yaml # PQ1
│   │   ├── earth-resources.yaml   # Q12, PQ3
│   │   ├── neptune-resources.yaml # Q8
│   │   ├── moon-resources.yaml    # Q14, Q15
│   │   ├── sun-resources.yaml     # Q22, PQ2
│   │   ├── mercury-resources.yaml # Q16
│   │   ├── mars-resources.yaml    # Q18
│   │   ├── jupiter-resources.yaml # Q19
│   │   ├── venus-resources.yaml   # Q20
│   │   └── project-23-api.yaml    # PQ1
│   ├── templates/                 # Files copied to /opt/course/
│   │   ├── q9/                    # holy-api-pod.yaml
│   │   ├── q11/image/             # Dockerfile + main.go
│   │   ├── q14/                   # secret-handler.yaml + secret2.yaml
│   │   ├── q15/                   # web-moon.html
│   │   ├── q16/                   # cleaner.yaml
│   │   └── q17/                   # test-init-container.yaml
│   └── helm-charts/               # Local Helm charts for Q4
│       ├── nginx/                 # v0.2.0
│       ├── nginx-0.1.0/           # v0.1.0 (for upgrade exercise)
│       └── apache/                # v0.1.0
├── scripts/
│   ├── start-minikube.sh          # Minikube startup
│   ├── stop-minikube.sh           # Minikube shutdown
│   ├── minikube.sh                # Minikube management tool
│   └── enable-k.sh               # kubectl alias setup
└── README.md                      # This file
```

## Question Coverage

| # | Topic | Namespace | Pre-existing Resources | Weight |
|---|-------|-----------|----------------------|--------|
| Q1 | Namespaces | all | Namespaces | 2% |
| Q2 | Pods | default | - | 4% |
| Q3 | Job | neptune | Namespace | 5% |
| Q4 | Helm Management | mercury | 3 Helm releases + `killershell` repo | 8% |
| Q5 | ServiceAccount, Secret | neptune | `neptune-sa-v2`, `neptune-secret-1` | 4% |
| Q6 | ReadinessProbe | default | - | 5% |
| Q7 | Pod Migration | saturn→neptune | 6 webserver pods (one is `my-happy-shop`) | 4% |
| Q8 | Deployment Rollouts | neptune | `api-new-c32` with broken revision 4 | 5% |
| Q9 | Pod→Deployment | pluto | `holy-api` Pod + YAML template | 6% |
| Q10 | Service, Logs | pluto | - | 6% |
| Q11 | Container Builds | - | Dockerfile + Go app + registry | 7% |
| Q12 | PV, PVC, Volume | earth | Namespace | 6% |
| Q13 | StorageClass, PVC | moon | Namespace | 5% |
| Q14 | Secret Volumes/Env | moon | `secret-handler` Pod + YAML templates | 6% |
| Q15 | ConfigMap Volume | moon | `web-moon` Deployment | 4% |
| Q16 | Logging Sidecar | mercury | `cleaner` Deployment + YAML | 5% |
| Q17 | InitContainer | default | Deployment YAML template | 5% |
| Q18 | Service Misconfig | mars | `manager-api-svc` with wrong selector | 3% |
| Q19 | ClusterIP→NodePort | jupiter | `jupiter-crew-deploy` + `jupiter-crew-svc` | 4% |
| Q20 | NetworkPolicy | venus | `api` + `frontend` Deployments + Services | 6% |
| Q21 | Requests/Limits, SA | neptune | `neptune-sa-v2` | 4% |
| Q22 | Labels, Annotations | sun | Pods with `type: worker/runner` labels | 3% |
| PQ1 | LivenessProbe | pluto | `project-23-api` + YAML | 4% |
| PQ2 | Deploy + Service | sun | `sa-sun-deploy` | 5% |
| PQ3 | Service Fix | earth | `earth-3cc-web` with broken readinessProbe | 3% |

## Exam Environment

### Pre-configured aliases (like the real exam)

```bash
alias k=kubectl
alias kn='kubectl config set-context --current --namespace'
export do="--dry-run=client -o yaml"
export now="--force --grace-period 0"
```

### Allowed documentation (same as real exam)

- https://kubernetes.io/docs
- https://kubernetes.io/blog
- https://helm.sh/docs

### Scoring

- **Total**: 100 points across 25 questions
- **Passing score**: 66%
- **Time limit**: 2 hours

## Requirements

- **GitHub Codespaces** (recommended) or any Linux environment with Docker
- **2-core, 8GB RAM** Codespace machine type (minimum)
- Internet access for pulling container images

## Differences from Killer Shell

| Feature | Killer Shell | This Simulator |
|---------|-------------|----------------|
| Cost | ~$30-40 per session | Free |
| Time limit | 36 hours access | Unlimited retries |
| Infrastructure | Multi-node cluster | Single-node Minikube |
| SSH to nodes | Yes (`ssh ckadXXXX`) | Direct (single instance) |
| Auto-scoring | Yes | Yes (approximate) |
| Helm repo | `killershell/` (remote) | `killershell/` (local) |
| Docker/Podman | Yes | Yes (via Docker-in-Docker) |
| K8s version | 1.35 | 1.35 (configurable) |

> **Note**: Since this runs on a single Minikube node, ignore the `ssh ckadXXXX` instructions
> in the questions. All questions can be answered directly in the terminal.

## Tips for the Exam

Read the full tips in [tips-en.md](ckad-simulator/tips-en.md) or [tips-es.md](ckad-simulator/tips-es.md).

Key shortcuts:
- Use `k` instead of `kubectl`
- Use `$do` for `--dry-run=client -o yaml`
- Use `$now` for `--force --grace-period 0`
- Practice imperative commands: `k run`, `k create`, `k expose`
- Use `k explain <resource>.spec` for quick API reference

## Contributing

Contributions welcome! Areas to improve:
- Additional practice questions
- More precise answer evaluation
- Multi-node cluster support (kind/k3s)
- Web-based question viewer with timer UI
- Solution explanations

## License

This project is for educational purposes. The questions are inspired by the Killer Shell CKAD simulator format. Please support the official [Killer Shell](https://killer.sh) for the best exam preparation experience.
