# CKAD Simulator Practice Environment

Complete CKAD exam simulator with 25 questions, 2-hour timer, and automatic answer evaluation.

## Quick Start

```bash
# 1. Setup (run once after Minikube is ready)
./setup-ckad-env.sh
source ~/.ckad-env

# 2. Start exam
./exam-runner.sh start

# 3. Solve questions (open questions-en.md or questions-es.md)

# 4. Check answers
./exam-runner.sh evaluate

# 5. End exam
./exam-runner.sh end

# 6. Reset for retry
./cleanup-ckad-env.sh && ./setup-ckad-env.sh
```

## What the Setup Creates

### Namespaces
| Namespace | Questions | Description |
|-----------|-----------|-------------|
| `earth` | Q12, PQ3 | PV/PVC exercises, broken readinessProbe |
| `jupiter` | Q19 | ClusterIP to NodePort conversion |
| `mars` | Q18 | Service misconfiguration |
| `mercury` | Q4, Q16 | Helm releases, sidecar logging |
| `moon` | Q13-Q15 | StorageClass, Secrets, ConfigMaps |
| `neptune` | Q3, Q5, Q7-Q8, Q21 | Jobs, ServiceAccounts, rollouts |
| `pluto` | Q9-Q10, PQ1 | Pod→Deployment, Services, probes |
| `saturn` | Q7 | Pod migration source |
| `sun` | Q22, PQ2 | Labels/annotations, Deployments |
| `venus` | Q20 | NetworkPolicy |

### Template Files (in /opt/course/)
| Path | Question | Content |
|------|----------|---------|
| `/opt/course/9/holy-api-pod.yaml` | Q9 | Pod template to convert to Deployment |
| `/opt/course/11/image/` | Q11 | Dockerfile + Go source for container build |
| `/opt/course/14/secret-handler.yaml` | Q14 | Pod template for Secret exercise |
| `/opt/course/14/secret2.yaml` | Q14 | Secret YAML to create and mount |
| `/opt/course/15/web-moon.html` | Q15 | HTML content for ConfigMap |
| `/opt/course/16/cleaner.yaml` | Q16 | Deployment template for sidecar |
| `/opt/course/17/test-init-container.yaml` | Q17 | Deployment template for InitContainer |
| `/opt/course/p1/project-23-api.yaml` | PQ1 | Deployment template for liveness probe |

### Helm Setup (Q4)
- Local `killershell` Helm repo at `http://localhost:8879`
- Release `internal-issue-report-apiv1` (nginx) → student must DELETE
- Release `internal-issue-report-apiv2` (nginx v0.1.0) → student must UPGRADE
- Release `internal-issue-report-daniel` (broken) → student must FIND and DELETE
- Charts available: `killershell/nginx` (0.1.0, 0.2.0), `killershell/apache` (0.1.0)

### Docker Registry (Q11)
- Local registry at `registry.killer.sh:5000`
- Used for building and pushing container images

## Environment Variables
```bash
alias k=kubectl                        # Short kubectl
alias kn='kubectl config set-context --current --namespace'
export do="--dry-run=client -o yaml"   # Dry-run shortcut
export now="--force --grace-period 0"  # Force delete shortcut
```

## Important Notes

- **No SSH needed**: Unlike Killer Shell, all questions run on the same Minikube instance. Ignore the `ssh ckadXXXX` instructions.
- **Helm repo**: The `killershell` repo is served locally. If it's not responding, restart with `./setup-ckad-env.sh`.
- **Scoring**: The evaluator provides approximate scoring. Some edge cases may not be perfectly detected.
- **K8s version**: Configured for 1.35 to match the current CKAD exam.
