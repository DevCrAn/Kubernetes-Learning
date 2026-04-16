# CKAD 2026 Real Exam Practice Questions

> **25 questions** based on topics confirmed by the community (Reddit r/ckad) as appearing
> in the actual CKAD exam 2026. Aligned with Kubernetes v1.35.
>
> Sources: aravind4799/CKAD-Practice-Questions, vloidcloudtech/ckad-labs,
> TiPunchLabs/ckad-dojo, manik-singhal/CKAD-2025, dgkanatsios/CKAD-exercises,
> Reddit r/ckad community experiences (u/jorotg 90%, u/Last_Tomato_2818 74%).
>
> **Total: 127 points | Passing: 66% (84 points) | Time: 2 hours**

---

## Question 1 | Create Secret from Hardcoded Variables (6 pts)

In namespace `ckad-secrets`, Deployment `api-server` exists with hard-coded environment variables:

- `DB_USER=admin`
- `DB_PASS=S3cretP@ss!`

Your task:

1. Create a Secret named `db-credentials` in namespace `ckad-secrets` containing these credentials
2. Update Deployment `api-server` to use the Secret via `valueFrom.secretKeyRef` instead of the hardcoded values
3. Do **not** change the Deployment name, namespace, or number of replicas
4. Verify the Deployment rolls out successfully with `kubectl rollout status`

> **Docs:** https://kubernetes.io/docs/concepts/configuration/secret/

---

## Question 2 | Create CronJob with Schedule and Limits (5 pts)

Create a CronJob named `log-cleaner` in namespace `ckad-cronjob` with the following specifications:

- **Schedule:** Run every 30 minutes (`*/30 * * * *`)
- **Image:** `busybox:1.36`
- **Container name:** `cleaner`
- **Command:** `echo "Log cleanup completed at $(date)"`
- **completions:** `2`
- **backoffLimit:** `3`
- **activeDeadlineSeconds:** `30`
- **restartPolicy:** `Never`

Verify execution by creating a Job manually from the CronJob:
```
kubectl create job log-cleaner-test --from=cronjob/log-cleaner -n ckad-cronjob
```

> **Docs:** https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/

---

## Question 3 | ServiceAccount, Role, and RoleBinding (7 pts)

In namespace `ckad-rbac`, Pod `log-collector` exists but is failing with authorization errors.

Check the Pod logs to understand the issue:
```
kubectl logs -n ckad-rbac log-collector
```

The logs show: `User "system:serviceaccount:ckad-rbac:default" cannot list resource "pods" in namespace "ckad-rbac"`

Your task:

1. Create a ServiceAccount named `log-sa` in namespace `ckad-rbac`
2. Create a Role named `log-role` in namespace `ckad-rbac` that grants `get`, `list`, and `watch` on resource `pods`
3. Create a RoleBinding named `log-rb` in namespace `ckad-rbac` binding `log-role` to `log-sa`
4. Update Pod `log-collector` to use ServiceAccount `log-sa` (delete and recreate if needed)

> **Docs:** https://kubernetes.io/docs/reference/access-authn-authz/rbac/

---

## Question 4 | Canary Deployment (6 pts)

In namespace `ckad-canary`, the following resources exist:

- Deployment `webapp-stable` with 4 replicas, labels `app=webapp, version=v1`, image `nginx:1.24`
- Service `webapp-svc` with selector `app=webapp`

Your task:

1. Create a new Deployment named `webapp-canary` in namespace `ckad-canary` with:
   - **1 replica**
   - Labels on pods: `app=webapp, version=v2`
   - Image: `nginx:1.25`
2. Both Deployments should be selected by Service `webapp-svc` (traffic split ~80/20)
3. Verify both versions appear in the Service endpoints

> **Note:** This is a manual canary pattern where traffic is split based on replica counts. Do NOT use Ingress, Service Mesh, or external load balancers.

> **Docs:** https://kubernetes.io/docs/concepts/workloads/controllers/deployment/

---

## Question 5 | Fix NetworkPolicy by Updating Pod Labels (5 pts)

In namespace `ckad-netpol`, three Pods exist:

- `frontend` with label `role=wrong-frontend`
- `backend` with label `role=wrong-backend`
- `database` with label `role=wrong-db`

Three NetworkPolicies also exist:

- `deny-all` (default deny all ingress)
- `allow-frontend-to-backend` (allows ingress to pods with `role=backend` from pods with `role=frontend`)
- `allow-backend-to-db` (allows ingress to pods with `role=db` from pods with `role=backend`)

Your task: Update the Pod labels (do **NOT** modify NetworkPolicies) to enable the communication chain:
`frontend` → `backend` → `database`

> **Time Saver Tip:** Use `kubectl label pod <name> role=<value> --overwrite -n ckad-netpol`

> **Docs:** https://kubernetes.io/docs/concepts/services-networking/network-policies/

---

## Question 6 | Fix Broken Deployment YAML (4 pts)

File `/opt/course/e6/broken-deploy.yaml` contains a Deployment manifest that fails to apply.

The file has the following issues:

1. Uses deprecated API version `extensions/v1beta1`
2. Missing required `selector` field
3. Namespace is not set

Your task:

1. Fix the YAML file:
   - Use `apiVersion: apps/v1`
   - Add a proper `spec.selector.matchLabels` that matches the template labels
   - Set namespace to `default`
2. Apply the fixed manifest
3. Verify the Deployment is running with `kubectl rollout status`

> **Docs:** https://kubernetes.io/docs/concepts/workloads/controllers/deployment/

---

## Question 7 | Rolling Update with Strategy + Rollback (5 pts)

In namespace `ckad-rollout`, Deployment `web-app` exists with image `nginx:1.24` and 4 replicas.

Your task:

1. Update the Deployment strategy to:
   - `maxSurge: 1`
   - `maxUnavailable: 0`
2. Perform a rolling update changing the image to `nginx:1.25`
3. Record the change cause: `"update to nginx 1.25"`
4. Verify the rollout completes successfully
5. Then rollback to the previous revision
6. Verify the rollback by checking the image is `nginx:1.24` again

> **Docs:** https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#rolling-update-deployment

---

## Question 8 | Add Readiness Probe to Deployment (4 pts)

In namespace `ckad-probes`, Deployment `api-deploy` exists with a container named `api` listening on port `80`.

Your task: Add a **readinessProbe** to the Deployment with:

- **Probe type:** HTTP GET
- **Path:** `/ready`
- **Port:** `80`
- **initialDelaySeconds:** `5`
- **periodSeconds:** `10`

Do not modify any other settings. Ensure the Deployment rolls out successfully.

> **Docs:** https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/

---

## Question 9 | SecurityContext: runAsUser + Capabilities (5 pts)

In namespace `ckad-security`, Deployment `secure-app` exists without any security context.

The manifest file is available at `/opt/course/e9/secure-app.yaml`.

Your task:

1. Set Pod-level `runAsUser: 30000`
2. Set container-level `allowPrivilegeEscalation: false`
3. Add container-level capability `NET_ADMIN`
4. Apply the updated manifest
5. Save the updated YAML to `/opt/course/e9/secure-app-updated.yaml`

> **Note:** Capabilities and `allowPrivilegeEscalation` are set at the container level, not Pod level.

> **Docs:** https://kubernetes.io/docs/tasks/configure-pod-container/security-context/

---

## Question 10 | Create Ingress Resource (5 pts)

In namespace `ckad-ingress`, the following resources exist:

- Deployment `web-deploy` with Pods labeled `app=web`
- Service `web-svc` with selector `app=web` on port `8080`

Your task: Create an Ingress named `web-ingress` in namespace `ckad-ingress` that:

- Routes host `web.example.com`
- Path `/` with `pathType: Prefix`
- Backend Service `web-svc` on port `8080`
- Uses API version `networking.k8s.io/v1`

> **Docs:** https://kubernetes.io/docs/concepts/services-networking/ingress/

---

## Question 11 | Fix Ingress PathType (3 pts)

File `/opt/course/e11/fix-ingress.yaml` contains an Ingress manifest that fails to apply due to an invalid `pathType` value.

Your task:

1. Try to apply the file and note the error
2. Fix the `pathType` to a valid value (valid options: `Prefix`, `Exact`, or `ImplementationSpecific`)
3. Ensure the Ingress routes path `/api` to Service `api-svc` on port `8080`
4. Apply the fixed manifest in namespace `ckad-ingress`

> **Docs:** https://kubernetes.io/docs/concepts/services-networking/ingress/#path-types

---

## Question 12 | ResourceQuota - Create Pod with Limits (5 pts)

In namespace `ckad-quota`, a ResourceQuota named `compute-quota` exists that sets resource limits for the namespace.

Your task:

1. Check the ResourceQuota to see the limits set: `kubectl describe quota compute-quota -n ckad-quota`
2. Create a Pod named `resource-pod` in namespace `ckad-quota` with:
   - **Image:** `nginx:1.25`
   - **Container name:** `web`
   - Set the CPU and memory **limits** to exactly **half** of the quota limits
   - Set CPU request to `100m` and memory request to `128Mi`

> **Docs:** https://kubernetes.io/docs/concepts/policy/resource-quotas/

---

## Question 13 | Scale Deployment + Add Label + NodePort Service (6 pts)

In namespace `ckad-scale`, Deployment `frontend-deploy` already exists with 2 replicas.

Your task:

1. Add the label `func=webFrontEnd` to the Deployment's Pod template metadata
2. Scale the Deployment to **4 replicas**
3. Create a NodePort Service named `frontend-svc` in namespace `ckad-scale` that:
   - Type: `NodePort`
   - Exposes service on TCP port `8080`
   - Maps to the Pods from `frontend-deploy`

> **Docs:** https://kubernetes.io/docs/concepts/services-networking/service/#nodeport

---

## Question 14 | Pod Logs + Metrics Troubleshooting (4 pts)

**Task 1:**

Deploy the Pod using the spec file at `/opt/course/e14/logger-pod.yaml` in namespace `ckad-logs`.

Retrieve all currently available logs from the running Pod and store them to the file `/opt/course/e14/pod-logs.txt`.

**Task 2:**

In namespace `ckad-logs`, multiple Pods are running. Find the Pod consuming the **most CPU** using `kubectl top` and write **only the Pod name** to `/opt/course/e14/top-pod.txt`.

> **Docs:** https://kubernetes.io/docs/reference/kubectl/generated/kubectl_logs/

---

## Question 15 | API Deprecation - Fix HPA Manifest (4 pts)

A team tries to apply the HPA manifest at `/opt/course/e15/ckad-hpa.yaml`, which was originally created on an older Kubernetes cluster.

Your task:

1. Identify the correct API version that should be used for HorizontalPodAutoscaler on Kubernetes v1.35
2. Update the manifest to use the correct `apiVersion`
3. Apply the fixed manifest in namespace `ckad-api`
4. Verify the HPA is created successfully

> **Hint:** Use `kubectl api-resources | grep -i horizontalpodautoscaler` to find the correct API group and version.

> **Docs:** https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/

---

## Question 16 | Rollout Resume Paused Deployment (4 pts)

In namespace `ckad-resume`, Deployment `web-paused` is currently **paused** and has image `nginx:1.24`.

Your task:

1. Update the Deployment image to `nginx:1.25`
2. Notice that `kubectl rollout status` shows no progress (the Deployment is paused)
3. Resume the Deployment rollout using `kubectl rollout resume`
4. Verify the rollout completes and the new image is running

> **Docs:** https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#pausing-and-resuming-a-rollout

---

## Question 17 | Build Container Image and Save as Tarball (6 pts)

> **Source:** aravind4799 Q05, vloidcloudtech Q05, TiPunchLabs Dojo Amaterasu Q1.
> This type of question appeared **TWICE** on the real CKAD exam (Reddit u/Last_Tomato_2818).

On the node, directory `/opt/course/e17/image/` contains a valid `Dockerfile` and an `index.html` file.

Your task:

1. Build a container image using Docker (or Podman) with name **`web-app:1.0`** using `/opt/course/e17/image/` as build context
2. Save the image as a tarball to **`/opt/course/e17/web-app.tar`**

**Commands reference:**
```bash
# Build
docker build -t web-app:1.0 /opt/course/e17/image/
# Save
docker save -o /opt/course/e17/web-app.tar web-app:1.0
```

> **Note:** The real exam may use Podman instead of Docker. The commands are nearly identical:
> `podman build -t ...`, `podman save -o ...`

> **Docs:** https://docs.docker.com/reference/cli/docker/image/build/

---

## Question 18 | Build Second Image and Save as OCI Archive (5 pts)

> **Source:** Reddit u/Last_Tomato_2818: "Docker/Podman appeared twice. They give you the image name and version."

On the node, directory `/opt/course/e18/image/` contains a `Dockerfile` for an API application.

Your task:

1. Build a container image using Docker (or Podman) with name **`api-service`** and tag **`2.5`** using `/opt/course/e18/image/` as build context
2. Save the image as a tarball in **OCI format** to **`/opt/course/e18/api-service.tar`**

**Podman OCI save command (for reference):**
```bash
podman save --format oci-archive -o /opt/course/e18/api-service.tar api-service:2.5
```

**Docker save command (for reference):**
```bash
docker save -o /opt/course/e18/api-service.tar api-service:2.5
```

> **Docs:** https://docs.docker.com/reference/cli/docker/image/save/

---

## Question 19 | Fix Broken Pod with Correct ServiceAccount (5 pts)

> **Source:** aravind4799 Q04, vloidcloudtech Q04. Reddit confirms RBAC appeared twice.

In namespace `ckad-sa-fix`, Pod `metrics-pod` is using ServiceAccount `wrong-sa` and receiving authorization errors.

Multiple ServiceAccounts, Roles, and RoleBindings already exist in the namespace:

- **ServiceAccounts:** `monitor-sa`, `wrong-sa`, `admin-sa`
- **Roles:** `metrics-reader`, `full-access`, `view-only`
- **RoleBindings:** `monitor-binding`, `admin-binding`

Your task:

1. Investigate the existing Roles and RoleBindings to find which ServiceAccount has the correct permissions to read pods
2. Update Pod `metrics-pod` to use the correct ServiceAccount (delete and recreate)
3. Verify the Pod stops showing authorization errors

**Hint:** Use `kubectl describe rolebinding -n ckad-sa-fix` to see which SA is bound to which Role.

> **Docs:** https://kubernetes.io/docs/concepts/security/service-accounts/

---

## Question 20 | Fix Service Selector Mismatch (4 pts)

> **Source:** aravind4799 Q12, vloidcloudtech Q12, TiPunchLabs Dojo Oni Q9.

In namespace `ckad-svc-fix`, Deployment `web-app` exists with Pods labeled `app=webapp, tier=frontend`.

Service `web-svc` exists but has an incorrect selector `app=wrongapp`. Traffic is not reaching the Pods.

Your task:

1. Identify the selector mismatch: `kubectl get endpoints web-svc -n ckad-svc-fix` (shows `<none>`)
2. Fix the Service selector so it matches the Deployment's Pod labels
3. Verify with `kubectl get endpoints web-svc -n ckad-svc-fix` (should show Pod IPs)

> **Docs:** https://kubernetes.io/docs/concepts/services-networking/service/

---

## Question 21 | CronJob with History Limits (5 pts)

> **Source:** vloidcloudtech Q02, Reddit u/Last_Tomato_2818: "Use .spec.successfulJobsHistoryLimit and .spec.failedJobsHistoryLimit"
> **Note:** This is the version that matches the real exam. Our Q2 uses completions/backoffLimit — this one uses historyLimits.

Create a CronJob named `backup-job` in namespace `ckad-cronjob2` with the following specifications:

- **Schedule:** Run every 30 minutes (`*/30 * * * *`)
- **Image:** `busybox:1.36`
- **Container name:** `backup`
- **Command:** `echo "Backup completed at $(date)"`
- **successfulJobsHistoryLimit:** `3`
- **failedJobsHistoryLimit:** `2`
- **activeDeadlineSeconds:** `300`
- **restartPolicy:** `Never`

> **Tip:** Use `kubectl explain cronjob.spec` to find the correct field locations.

> **Docs:** https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/

---

## Question 22 | Resource Requests and Limits from Namespace Max (5 pts)

> **Source:** Reddit u/Last_Tomato_2818: "They give you request memory. For limits, they say half of namespace maximum memory. Run kubectl describe namespace dev to get the MAX, then calculate half."
> **Note:** This is different from Q12 (ResourceQuota). Here you use `describe namespace` to find limits.

In namespace `ckad-resources`, a LimitRange named `resource-limits` exists that sets default and max resource values.

Your task:

1. Inspect the namespace limits: `kubectl describe limitrange resource-limits -n ckad-resources`
2. Create a Pod named `resource-pod` in namespace `ckad-resources` with:
   - **Image:** `nginx:1.25`
   - **Container name:** `web`
   - Set memory **request** to `128Mi`
   - Set CPU **request** to `100m`
   - Set memory **limit** to exactly **half** of the max memory limit
   - Set CPU **limit** to exactly **half** of the max CPU limit

> **Docs:** https://kubernetes.io/docs/concepts/policy/limit-range/

---

## Question 23 | Create NetworkPolicy with Ingress AND Egress (6 pts)

> **Source:** Reddit u/Last_Tomato_2818: "Simple question: podSelector with ingress and egress for two pods. Just know the labels and copy from documentation."
> **Note:** Our Q5 is about fixing labels — this one is about creating a full NetworkPolicy from scratch.

In namespace `ckad-netpol2`, two Pods exist:

- `api-pod` with label `app=api`
- `db-pod` with label `app=database`

Create a NetworkPolicy named `api-netpol` in namespace `ckad-netpol2` that:

1. **Applies to** pods with label `app=api` (podSelector)
2. **Allows ingress** on port `80` (TCP) **only from** pods with label `app=frontend`
3. **Allows egress** on port `5432` (TCP) **only to** pods with label `app=database`

> **Important:** The policy should restrict both ingress AND egress. Pods not matching the selectors should be denied.

> **Docs:** https://kubernetes.io/docs/concepts/services-networking/network-policies/

---

## Question 24 | Job with Completions and Parallelism (5 pts)

> **Source:** TiPunchLabs Dojo Oni Q18. Jobs appear regularly in the CKAD exam.

Create a Job named `batch-processor` in namespace `ckad-jobs` with:

- **Image:** `busybox:1.36`
- **Container name:** `processor`
- **Command:** `echo "Processing batch item"`
- **completions:** `6` (6 total items to process)
- **parallelism:** `2` (2 items processed at a time)
- **restartPolicy:** `Never`
- **backoffLimit:** `4`

Wait for the Job to complete and verify all 6 pods ran successfully.

> **Docs:** https://kubernetes.io/docs/concepts/workloads/controllers/job/

---

## Question 25 | Fix Deployment Exceeding Namespace ResourceQuota (5 pts)

> **Source:** TiPunchLabs Dojo Oni Q6, Reddit: "Your deployment resources should match the namespace resources."

In namespace `ckad-quota-fix`, a ResourceQuota named `compute-quota` exists and a Deployment named `quota-app` has Pods stuck in **Pending** state because its resource requests exceed the namespace quota.

Your task:

1. Inspect the ResourceQuota: `kubectl describe quota compute-quota -n ckad-quota-fix`
2. Inspect the Deployment's current resource settings: `kubectl get deploy quota-app -n ckad-quota-fix -o yaml`
3. Reduce the Deployment's resource **requests** so the Pods can be scheduled within the quota
4. Keep resource **limits** at **double** the requests
5. Ensure the Deployment has running Pods after the fix

> **Hint:** The quota allows `requests.cpu: 500m`, `requests.memory: 512Mi`. Adjust the Deployment accordingly.

> **Docs:** https://kubernetes.io/docs/concepts/policy/resource-quotas/

---

## Tips for the Real CKAD Exam

> These tips come directly from Reddit users who passed the CKAD exam (u/jorotg 90%, u/Last_Tomato_2818 74%).

- **Use imperative commands** whenever possible: `kubectl create`, `kubectl expose`, `kubectl run`, `kubectl set image`
- **Use `--dry-run=client -o yaml`** to generate YAML and then modify it
- **Always check rollout status** after modifying Deployments: `kubectl rollout status deploy/<name>`
- **If rollout status shows "Waiting..."** and you're sure your work is correct: try `kubectl rollout resume deployment <name>` — this saved multiple Reddit users 10+ minutes!
- **Use `kubectl apply`**, NOT `kubectl replace --force` for rollout questions (replace causes issues with rollback history)
- **Use `kubectl label`** to quickly add/change labels instead of editing YAML
- **Use vim shortcuts**: `:set nu` (line numbers), `dd` (delete line), `yy` (copy), `p` (paste), `shift+v` (select lines)
- **Use `#`** before a command to save it in history without executing
- **Switch namespace**: `kubectl config set-context --current --namespace=<ns>` or use `-n <ns>`
- **Always add the namespace** — forgetting `-n <namespace>` is a common point loss
- **Docker/Podman commands are nearly identical**: `docker build` = `podman build`, `docker save` = `podman save`
- **Read the ENTIRE question** — sometimes critical details are in the last sentence
- **Flag hard questions** and come back later when less stressed
- **After editing a Deployment**, double-check: new Pods running? Service has endpoints? `rollout status` succeeds?
- **Know how to search k8s docs** for: Ingress, NetworkPolicy, CronJob, RBAC, SecurityContext, ResourceQuota
- **What's NOT on the exam** (per Reddit 2026): Helm, PV/PVC, ConfigMaps, Init Containers, Sidecar Containers, CRDs, Kustomize
