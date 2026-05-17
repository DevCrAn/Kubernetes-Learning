# CKAD 2026 Extended Practice Question Bank (English)

This bank contains 34 hands-on questions aligned with Kubernetes v1.35 topics and common CKAD real-exam patterns.

Suggested timing:
- 2 hours
- 15 to 20 core tasks in a real session, but practice all 34 to build speed

---

## Q1 - CronJob with history and execution timeout
Quick Reference:
- Context: k8s
- Namespace: default

Task:
1. Create a CronJob named ppi.
2. Use one container named pi with image perl:5.
3. Command: perl -Mbignum=bpi -wle print bpi(2000)
4. Schedule: every 5 minutes.
5. Keep 2 successful jobs and 4 failed jobs.
6. Pod restartPolicy must be Never.
7. Pod execution must stop after 8 seconds.
8. Create a manual test job named ppi-test from CronJob ppi.

## Q2 - CronJob manifest from file
Quick Reference:
- Context: k8s
- Namespace: default

Task:
1. Define the manifest in /ckad/CKAD00016/periodic.yaml.
2. Create a CronJob named hello, container name hello, image busybox:stable.
3. Run date every minute.
4. Ensure each execution is terminated after 10 seconds if not complete.
5. Apply the manifest.
6. Verify at least one successful execution.

## Q3 - Build image and export OCI tar
Quick Reference:
- Context: container task
- Path: /ckad/DF/Dockerfile

Task:
1. Build image centos:8.2 from existing Dockerfile.
2. Export the image in OCI format to /ckad/DF/centos-8.2.tar.

## Q4 - Multi-container deployment with sidecar pattern
Quick Reference:
- Context: k8s
- Namespace: default

Task:
1. Create ConfigMap from /ckad/KDMC00102/fluentd-configmap.yaml.
2. Create Deployment deploymenb-web with:
- Main container logger-123, image lfccncf/busybox:1.
- Main command writes to /ckad/log/input.log every 10 seconds.
- Sidecar container adaptor-dev, image lfccncf/fluentd:v0.12.
- Sidecar reads input log and writes JSON to /ckad/log/output.*
3. Both containers must share an emptyDir volume mounted at /ckad/log.
4. Mount the fluentd ConfigMap into sidecar at /fluentd/etc.

## Q5 - Init container prepares web content
Quick Reference:
- Context: k8s-cluster2
- Namespace: frontend

Task:
1. Create Pod web-app in namespace frontend.
2. Add init container init-config with image busybox.
3. Init container must create /work-dir/index.html containing: <h1>Hello CKAD</h1>
4. Add main container nginx with image nginx.
5. Mount shared emptyDir volume html at /usr/share/nginx/html in nginx container.

## Q6 - PV, PVC and Pod with persistent storage
Quick Reference:
- Context: k8s
- Namespace: default

Task:
1. On node02, create /opt/KDSP00101/data/index.html with content WEPKEY=7789.
2. Create PV task-pv-volume:
- Capacity 2Gi
- hostPath /opt/KDSP00101/data
- Access mode ReadWriteOnce
- StorageClass keys
3. Create PVC task-pv-claim:
- Request 200Mi
- Access mode ReadWriteOnce
- StorageClass keys
4. Create Pod labeled app=my-storage-app that mounts this PVC at /usr/share/nginx/html.

## Q7 - Canary deployment
Quick Reference:
- Context: k8s
- Namespace: goshawk

Task:
1. Existing Service chipmunk-service points to current-chipmunk-deployment with 5 Pods.
2. Create canary-chipmunk-deployment in same namespace based on existing deployment.
3. Configure both deployments so total running pods are 10.
4. Configure labels/selectors so about 40 percent of Service traffic can reach canary Pods.

## Q8 - Update image and rollback deployment
Quick Reference:
- Context: k8s
- Namespace: ckad00015

Task:
1. Update deployment webapp rolling update settings:
- maxSurge: 10%
- maxUnavailable: 4
2. Update image to lfccncf/nginx:1.13.7.
3. Rollback webapp to the previous revision.

## Q9 - Helm install and upgrade
Quick Reference:
- Context: k8s-cluster1
- Namespace: data

Task:
1. Add Helm repo https://charts.bitnami.com/bitnami.
2. Install release cache with chart bitnami/redis in namespace data.
3. Upgrade release and set replica.replicaCount to 3.

## Q10 - Fix deprecated API in manifest
Quick Reference:
- Context: k8s
- Namespace: garfish

Task:
1. Fix API deprecations in /ckad/credible-mite/www.yaml so it works on modern Kubernetes.
2. Deploy the fixed manifest in namespace garfish.

## Q11 - Find and fix broken liveness probe
Quick Reference:
- Context: dk8s
- Namespace: any

Task:
1. Find the Pod failing due to liveness probe issues.
2. Write namespace/podname to /ckad/CKAD00011/broken.txt.
3. Save related error events in wide format to /ckad/CKAD00011/error.txt.
4. Fix the liveness probe issue.

## Q12 - Add readiness probe to existing deployment
Quick Reference:
- Context: dk8s
- Deployment: probe-http

Task:
1. Modify deployment probe-http to add readinessProbe:
- httpGet path /healthz/return200
- Port 80
- initialDelaySeconds 15
- periodSeconds 20

## Q13 - Collect logs into file
Quick Reference:
- Context: k8s
- Pod source file: /opt/KDOB00201/counter.yaml

Task:
1. Deploy Pod counter from /opt/KDOB00201/counter.yaml.
2. Collect all currently available logs from the running Pod.
3. Save logs into /opt/KDOB00201/log_Output.txt.

## Q14 - Identify highest CPU Pod
Quick Reference:
- Context: k8s
- Namespace: cpu-stress

Task:
1. Monitor pods in namespace cpu-stress.
2. Identify the Pod with highest CPU usage.
3. Write the Pod name into /ckad/CKAD00010/pod.txt.

## Q15 - Pod requests in dedicated namespace
Quick Reference:
- Context: k8s
- Namespace: pod-resources

Task:
1. Create Pod nginx-resources in namespace pod-resources.
2. Container name nginx-resources, image nginx:1.16.
3. Set CPU request 40m.
4. Set memory request 50Mi.

## Q16 - Fix deployment resources using LimitRange
Quick Reference:
- Context: k8s
- Namespace: haddock
- Manifest: /ckad/chief-cardinal/nosql.yaml

Task:
1. Update deployment nosql resource settings so pods can run.
2. Memory request must be 15Mi.
3. Memory limit must be half of the maximum memory defined by namespace LimitRange.

## Q17 - Create ConfigMap and mount as volume
Quick Reference:
- Context: k8s
- Namespace: default

Task:
1. Create ConfigMap some-config with key3=value4.
2. Create Pod nginx-configmap with image nginx:stable.
3. Mount ConfigMap some-config as a volume at /some/path.

## Q18 - Create Secret and consume as env var
Quick Reference:
- Context: k8s
- Namespace: default

Task:
1. Create Secret another-secret with key1=value12.
2. Create Pod nginx-secret, image nginx:1.16.
3. Set env var COOL_VARIABLE from Secret another-secret key1.

## Q19 - SecurityContext runAsUser and no privilege escalation
Quick Reference:
- Context: k8s
- Namespace: quetzal
- Manifest: /ckad/daring-moccasin/broker-deployment.yaml

Task:
1. Update deployment broker-deployment container security settings.
2. Run as user ID 30000.
3. Disable privilege escalation.

## Q20 - Advanced SecurityContext hardening
Quick Reference:
- Context: k8s-cluster2
- Namespace: restricted

Task:
Create Pod secure-app with image nginx and:
- runAsUser: 1000
- runAsGroup: 3000
- fsGroup: 2000
- allowPrivilegeEscalation: false
- readOnlyRootFilesystem: true
- Drop all Linux capabilities

## Q21 - RBAC fix by selecting correct ServiceAccount
Quick Reference:
- Context: k8s
- Namespace: gorilla
- Manifest: /ckad/prompt-escargot/honeybee-deployment.yaml

Task:
1. Inspect logs from honeybee-deployment Pods and identify authorization issue.
2. Update honeybee-deployment to resolve forbidden access to serviceaccounts.

## Q22 - Create SA, Role and RoleBinding
Quick Reference:
- Context: k8s-cluster1
- Namespace: monitoring

Task:
1. Create ServiceAccount monitoring-sa.
2. Create Role pod-metrics-reader with get, list, watch on pods and pods/log.
3. Create RoleBinding monitoring-binding to bind role to monitoring-sa.

## Q23 - Deployment with env var
Quick Reference:
- Context: k8s
- Namespace: ckad00014

Task:
Create Deployment api with:
- 6 replicas
- Image nginx:1.16
- Env var NGINX_PORT=8000
- Expose container port 80

## Q24 - Set specific ServiceAccount on deployment
Quick Reference:
- Context: k8s
- Namespace: frontend

Task:
Update the existing deployment in namespace frontend so it uses ServiceAccount app.

## Q25 - NetworkPolicy task by changing Pod labels only
Quick Reference:
- Context: nk8s
- Namespace: ckad00018

Task:
1. Existing NetworkPolicies are already present.
2. Do not create new NetworkPolicies.
3. Update Pod ckad00018-newpod labels so policy allows traffic only with Pods front and db.

## Q26 - Create restricted NetworkPolicy for db
Quick Reference:
- Context: nk8s
- Namespace: secure

Task:
1. Create NetworkPolicy allowing ingress to app=db only from app=api on TCP 3306.
2. Also allow db Pod DNS resolution by allowing egress UDP 53.

## Q27 - Scale deployment and expose NodePort
Quick Reference:
- Context: k8s
- Namespace: ckad00017

Task:
1. Update deployment ckad00017-deployment to 5 replicas.
2. Add Pod label tier=dmz.
3. Create NodePort Service rover exposing deployment on TCP port 81.

## Q28 - Troubleshoot Ingress stack (3 resources)
Quick Reference:
- Context: k8s
- Namespace: ingress-ckad
- Manifests: /ckad/CKAD202206

Task:
1. Deployment is correct and must not be modified.
2. Service and Ingress are misconfigured.
3. Identify and fix issues, then recreate/apply corrected resources.

## Q29 - Troubleshoot Ingress with missing dependency
Quick Reference:
- Context: k8s
- Namespace: ingress-kk

Task:
1. Existing Ingress in ingress-kk is not reachable.
2. Deployment is correct and must not be modified.
3. Find root cause and fix it.

## Q30 - Service, ConfigMap and ambassador container
Quick Reference:
- Context: k8s
- Namespace: default

Task:
1. Update Service nginxsvc to expose port 9090.
2. Create ConfigMap haproxy-config from file /ckad/ambassador/haproxy.cfg.
3. Update Pod poller by adding ambassador-container:
- Image haproxy:lts
- Expose port 80
- Mount haproxy-config at /usr/local/etc/haproxy/

## Q31 - Find and fix deployment with wrong image
Quick Reference:
- Context: nk8s
- Namespace: default

Task:
1. Identify the failing deployment that uses an incorrect image.
2. Correct the image and recover the deployment.

## Q32 - Gateway API migration (v1.35)
Quick Reference:
- Context: k8s-cluster1
- Namespace: default

Task:
1. Create GatewayClass example-gc with controller example.com/gateway-controller.
2. Create Gateway my-gateway listening on HTTP port 80.
3. Create HTTPRoute app-route:
- Hostname app.example.com
- Path /api to Service api-svc port 80
- Path / to Service frontend-svc port 80

## Q33 - Native sidecar container (GA)
Quick Reference:
- Context: k8s-cluster2
- Namespace: logging

Task:
Create Pod native-sidecar-pod with:
1. Native sidecar using initContainers with restartPolicy Always:
- Name log-collector
- Image fluentd:v1.16
2. Main container:
- Name app
- Image nginx
3. Shared emptyDir mounted at /var/log/app in both containers.

## Q34 - In-place pod vertical scaling
Quick Reference:
- Context: k8s-cluster1
- Namespace: production

Task:
1. Existing Pod webapp-pod has CPU request 100m and limit 200m.
2. Update the running Pod in place (without recreation) to:
- CPU request 250m
- CPU limit 500m

---

## Suggested Practice Flow
1. Run setup script: ./setup-more-ckad2026-env.sh
2. Solve questions from this file.
3. Reset lab when needed: ./cleanup-more-ckad2026-env.sh && ./setup-more-ckad2026-env.sh
