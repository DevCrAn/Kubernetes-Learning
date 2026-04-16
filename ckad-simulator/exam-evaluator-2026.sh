#!/bin/bash
#
# CKAD 2026 Real Exam Practice - Answer Evaluator
# Automatically checks answers for all 25 questions
# Total: 127 points | Pass: 66% (84 points)
#

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

TOTAL_SCORE=0
MAX_SCORE=0
PASSED_COUNT=0
FAILED_COUNT=0
SKIPPED_COUNT=0

declare -A Q_RESULT
declare -A Q_DETAIL

pass()    { local q="$1" w="$2" d="$3"; TOTAL_SCORE=$((TOTAL_SCORE + w)); Q_RESULT[$q]="PASS"; Q_DETAIL[$q]="$d"; ((PASSED_COUNT++)) || true; }
fail()    { local q="$1" d="$2"; Q_RESULT[$q]="FAIL"; Q_DETAIL[$q]="$d"; ((FAILED_COUNT++)) || true; }
skip()    { local q="$1" d="$2"; Q_RESULT[$q]="SKIP"; Q_DETAIL[$q]="$d"; ((SKIPPED_COUNT++)) || true; }
partial() { local q="$1" e="$2" w="$3" d="$4"; TOTAL_SCORE=$((TOTAL_SCORE + e)); Q_RESULT[$q]="PARTIAL"; Q_DETAIL[$q]="$d (${e}/${w} pts)"; ((PASSED_COUNT++)) || true; }

# ============================================================================
# Q1: Secret from Hardcoded Variables (6 pts)
# ============================================================================
evaluate_q1() {
    local w=6; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    # Check Secret exists
    if kubectl get secret db-credentials -n ckad-secrets &>/dev/null; then
        score=$((score + 1))

        # Check Secret has correct keys
        local keys
        keys=$(kubectl get secret db-credentials -n ckad-secrets -o jsonpath='{.data}' 2>/dev/null)
        [[ "$keys" == *"DB_USER"* ]] && score=$((score + 1))
        [[ "$keys" == *"DB_PASS"* ]] && score=$((score + 1))
    fi

    # Check Deployment uses secretKeyRef
    if kubectl get deployment api-server -n ckad-secrets &>/dev/null; then
        local env_config
        env_config=$(kubectl get deployment api-server -n ckad-secrets -o jsonpath='{.spec.template.spec.containers[0].env}' 2>/dev/null)
        if [[ "$env_config" == *"secretKeyRef"* ]]; then
            score=$((score + 2))
        fi

        # Check deployment is running
        local ready
        ready=$(kubectl get deployment api-server -n ckad-secrets -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
        [[ "$ready" -ge 1 ]] && score=$((score + 1))
    fi

    if [[ $score -eq $w ]]; then
        pass "Q1" $w "Secret created + Deployment updated with secretKeyRef"
    elif [[ $score -gt 0 ]]; then
        partial "Q1" $score $w "Some requirements met"
    else
        fail "Q1" "Secret db-credentials not found or Deployment not updated"
    fi
}

# ============================================================================
# Q2: CronJob (5 pts)
# ============================================================================
evaluate_q2() {
    local w=5; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    if kubectl get cronjob log-cleaner -n ckad-cronjob &>/dev/null; then
        score=$((score + 1))

        local schedule
        schedule=$(kubectl get cronjob log-cleaner -n ckad-cronjob -o jsonpath='{.spec.schedule}' 2>/dev/null)
        [[ "$schedule" == "*/30 * * * *" ]] && score=$((score + 1))

        local completions
        completions=$(kubectl get cronjob log-cleaner -n ckad-cronjob -o jsonpath='{.spec.jobTemplate.spec.completions}' 2>/dev/null)
        [[ "$completions" == "2" ]] && score=$((score + 1))

        local backoff
        backoff=$(kubectl get cronjob log-cleaner -n ckad-cronjob -o jsonpath='{.spec.jobTemplate.spec.backoffLimit}' 2>/dev/null)
        [[ "$backoff" == "3" ]] && score=$((score + 1))

        local deadline
        deadline=$(kubectl get cronjob log-cleaner -n ckad-cronjob -o jsonpath='{.spec.jobTemplate.spec.activeDeadlineSeconds}' 2>/dev/null)
        [[ "$deadline" == "30" ]] && score=$((score + 1))
    fi

    if [[ $score -eq $w ]]; then
        pass "Q2" $w "CronJob with correct schedule, completions, backoff, deadline"
    elif [[ $score -gt 0 ]]; then
        partial "Q2" $score $w "CronJob exists but some settings wrong"
    else
        fail "Q2" "CronJob log-cleaner not found in ckad-cronjob"
    fi
}

# ============================================================================
# Q3: RBAC - SA, Role, RoleBinding (7 pts)
# ============================================================================
evaluate_q3() {
    local w=7; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    # Check SA
    if kubectl get sa log-sa -n ckad-rbac &>/dev/null; then
        score=$((score + 1))
    fi

    # Check Role
    if kubectl get role log-role -n ckad-rbac &>/dev/null; then
        score=$((score + 1))
        local verbs
        verbs=$(kubectl get role log-role -n ckad-rbac -o jsonpath='{.rules[0].verbs}' 2>/dev/null)
        [[ "$verbs" == *"get"* && "$verbs" == *"list"* && "$verbs" == *"watch"* ]] && score=$((score + 1))

        local resources
        resources=$(kubectl get role log-role -n ckad-rbac -o jsonpath='{.rules[0].resources}' 2>/dev/null)
        [[ "$resources" == *"pods"* ]] && score=$((score + 1))
    fi

    # Check RoleBinding
    if kubectl get rolebinding log-rb -n ckad-rbac &>/dev/null; then
        score=$((score + 1))
    fi

    # Check Pod uses correct SA
    if kubectl get pod log-collector -n ckad-rbac &>/dev/null; then
        local sa
        sa=$(kubectl get pod log-collector -n ckad-rbac -o jsonpath='{.spec.serviceAccountName}' 2>/dev/null)
        [[ "$sa" == "log-sa" ]] && score=$((score + 2))
    fi

    if [[ $score -eq $w ]]; then
        pass "Q3" $w "SA, Role, RoleBinding created + Pod updated"
    elif [[ $score -gt 0 ]]; then
        partial "Q3" $score $w "Some RBAC components created"
    else
        fail "Q3" "No RBAC components found"
    fi
}

# ============================================================================
# Q4: Canary Deployment (6 pts)
# ============================================================================
evaluate_q4() {
    local w=6; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    # Check canary Deployment exists
    if kubectl get deployment webapp-canary -n ckad-canary &>/dev/null; then
        score=$((score + 2))

        local replicas
        replicas=$(kubectl get deployment webapp-canary -n ckad-canary -o jsonpath='{.spec.replicas}' 2>/dev/null)
        [[ "$replicas" == "1" ]] && score=$((score + 1))

        local image
        image=$(kubectl get deployment webapp-canary -n ckad-canary -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
        [[ "$image" == "nginx:1.25" ]] && score=$((score + 1))

        # Check labels include app=webapp
        local app_label
        app_label=$(kubectl get deployment webapp-canary -n ckad-canary -o jsonpath='{.spec.template.metadata.labels.app}' 2>/dev/null)
        [[ "$app_label" == "webapp" ]] && score=$((score + 1))

        # Check version=v2
        local ver_label
        ver_label=$(kubectl get deployment webapp-canary -n ckad-canary -o jsonpath='{.spec.template.metadata.labels.version}' 2>/dev/null)
        [[ "$ver_label" == "v2" ]] && score=$((score + 1))
    fi

    if [[ $score -eq $w ]]; then
        pass "Q4" $w "Canary Deployment with correct replicas, image, labels"
    elif [[ $score -gt 0 ]]; then
        partial "Q4" $score $w "Canary Deployment partially configured"
    else
        fail "Q4" "Deployment webapp-canary not found"
    fi
}

# ============================================================================
# Q5: Fix NetworkPolicy Labels (5 pts)
# ============================================================================
evaluate_q5() {
    local w=5; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    # Check frontend label
    local fe_label
    fe_label=$(kubectl get pod frontend -n ckad-netpol -o jsonpath='{.metadata.labels.role}' 2>/dev/null)
    [[ "$fe_label" == "frontend" ]] && score=$((score + 2))

    # Check backend label
    local be_label
    be_label=$(kubectl get pod backend -n ckad-netpol -o jsonpath='{.metadata.labels.role}' 2>/dev/null)
    [[ "$be_label" == "backend" ]] && score=$((score + 2))

    # Check database label
    local db_label
    db_label=$(kubectl get pod database -n ckad-netpol -o jsonpath='{.metadata.labels.role}' 2>/dev/null)
    [[ "$db_label" == "db" ]] && score=$((score + 1))

    if [[ $score -eq $w ]]; then
        pass "Q5" $w "All Pod labels fixed to match NetworkPolicies"
    elif [[ $score -gt 0 ]]; then
        partial "Q5" $score $w "Some Pod labels updated"
    else
        fail "Q5" "Pod labels not updated"
    fi
}

# ============================================================================
# Q6: Fix Broken Deployment YAML (4 pts)
# ============================================================================
evaluate_q6() {
    local w=4; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    if kubectl get deployment broken-app -n default &>/dev/null; then
        score=$((score + 2))

        # Check selector exists
        local selector
        selector=$(kubectl get deployment broken-app -n default -o jsonpath='{.spec.selector.matchLabels}' 2>/dev/null)
        [[ -n "$selector" ]] && score=$((score + 1))

        # Check pods are running
        local ready
        ready=$(kubectl get deployment broken-app -n default -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
        [[ "$ready" -ge 1 ]] && score=$((score + 1))
    fi

    if [[ $score -eq $w ]]; then
        pass "Q6" $w "Deployment fixed and running"
    elif [[ $score -gt 0 ]]; then
        partial "Q6" $score $w "Deployment partially fixed"
    else
        fail "Q6" "Deployment broken-app not found in default"
    fi
}

# ============================================================================
# Q7: Rolling Update + Rollback (5 pts)
# ============================================================================
evaluate_q7() {
    local w=5; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    if kubectl get deployment web-app -n ckad-rollout &>/dev/null; then
        # Check strategy
        local maxSurge
        maxSurge=$(kubectl get deployment web-app -n ckad-rollout -o jsonpath='{.spec.strategy.rollingUpdate.maxSurge}' 2>/dev/null)
        [[ "$maxSurge" == "1" ]] && score=$((score + 1))

        local maxUnavail
        maxUnavail=$(kubectl get deployment web-app -n ckad-rollout -o jsonpath='{.spec.strategy.rollingUpdate.maxUnavailable}' 2>/dev/null)
        [[ "$maxUnavail" == "0" ]] && score=$((score + 1))

        # Check image is rolled back to 1.24
        local image
        image=$(kubectl get deployment web-app -n ckad-rollout -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
        [[ "$image" == "nginx:1.24" ]] && score=$((score + 2))

        # Check rollout history has multiple revisions
        local revisions
        revisions=$(kubectl rollout history deployment/web-app -n ckad-rollout 2>/dev/null | grep -c "^[0-9]" || echo "0")
        [[ $revisions -ge 2 ]] && score=$((score + 1))
    fi

    if [[ $score -eq $w ]]; then
        pass "Q7" $w "Strategy set, update + rollback completed"
    elif [[ $score -gt 0 ]]; then
        partial "Q7" $score $w "Some rollout steps completed"
    else
        fail "Q7" "Deployment web-app not found or not modified"
    fi
}

# ============================================================================
# Q8: Readiness Probe HTTP GET (4 pts)
# ============================================================================
evaluate_q8() {
    local w=4; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    if kubectl get deployment api-deploy -n ckad-probes &>/dev/null; then
        local probe_path
        probe_path=$(kubectl get deployment api-deploy -n ckad-probes -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.path}' 2>/dev/null)
        [[ "$probe_path" == "/ready" ]] && score=$((score + 1))

        local probe_port
        probe_port=$(kubectl get deployment api-deploy -n ckad-probes -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.port}' 2>/dev/null)
        [[ "$probe_port" == "80" ]] && score=$((score + 1))

        local initial_delay
        initial_delay=$(kubectl get deployment api-deploy -n ckad-probes -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.initialDelaySeconds}' 2>/dev/null)
        [[ "$initial_delay" == "5" ]] && score=$((score + 1))

        local period
        period=$(kubectl get deployment api-deploy -n ckad-probes -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.periodSeconds}' 2>/dev/null)
        [[ "$period" == "10" ]] && score=$((score + 1))
    fi

    if [[ $score -eq $w ]]; then
        pass "Q8" $w "Readiness probe correctly configured"
    elif [[ $score -gt 0 ]]; then
        partial "Q8" $score $w "Readiness probe partially configured"
    else
        fail "Q8" "No readiness probe found on api-deploy"
    fi
}

# ============================================================================
# Q9: SecurityContext (5 pts)
# ============================================================================
evaluate_q9() {
    local w=5; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    if kubectl get deployment secure-app -n ckad-security &>/dev/null; then
        # Pod-level runAsUser
        local run_as_user
        run_as_user=$(kubectl get deployment secure-app -n ckad-security -o jsonpath='{.spec.template.spec.securityContext.runAsUser}' 2>/dev/null)
        [[ "$run_as_user" == "30000" ]] && score=$((score + 1))

        # Container-level allowPrivilegeEscalation
        local priv_esc
        priv_esc=$(kubectl get deployment secure-app -n ckad-security -o jsonpath='{.spec.template.spec.containers[0].securityContext.allowPrivilegeEscalation}' 2>/dev/null)
        [[ "$priv_esc" == "false" ]] && score=$((score + 1))

        # Container-level capability NET_ADMIN
        local caps
        caps=$(kubectl get deployment secure-app -n ckad-security -o jsonpath='{.spec.template.spec.containers[0].securityContext.capabilities.add}' 2>/dev/null)
        [[ "$caps" == *"NET_ADMIN"* ]] && score=$((score + 1))
    fi

    # Check saved yaml
    [[ -f "/opt/course/e9/secure-app-updated.yaml" ]] && score=$((score + 1))

    # Check deployment running
    if kubectl get deployment secure-app -n ckad-security &>/dev/null; then
        local ready
        ready=$(kubectl get deployment secure-app -n ckad-security -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
        [[ "$ready" -ge 1 ]] && score=$((score + 1))
    fi

    if [[ $score -eq $w ]]; then
        pass "Q9" $w "SecurityContext fully configured + YAML saved"
    elif [[ $score -gt 0 ]]; then
        partial "Q9" $score $w "Some security settings applied"
    else
        fail "Q9" "SecurityContext not configured"
    fi
}

# ============================================================================
# Q10: Create Ingress (5 pts)
# ============================================================================
evaluate_q10() {
    local w=5; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    if kubectl get ingress web-ingress -n ckad-ingress &>/dev/null; then
        score=$((score + 2))

        local host
        host=$(kubectl get ingress web-ingress -n ckad-ingress -o jsonpath='{.spec.rules[0].host}' 2>/dev/null)
        [[ "$host" == "web.example.com" ]] && score=$((score + 1))

        local svc_name
        svc_name=$(kubectl get ingress web-ingress -n ckad-ingress -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' 2>/dev/null)
        [[ "$svc_name" == "web-svc" ]] && score=$((score + 1))

        local svc_port
        svc_port=$(kubectl get ingress web-ingress -n ckad-ingress -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}' 2>/dev/null)
        [[ "$svc_port" == "8080" ]] && score=$((score + 1))
    fi

    if [[ $score -eq $w ]]; then
        pass "Q10" $w "Ingress created with correct host, service, port"
    elif [[ $score -gt 0 ]]; then
        partial "Q10" $score $w "Ingress partially configured"
    else
        fail "Q10" "Ingress web-ingress not found"
    fi
}

# ============================================================================
# Q11: Fix Ingress PathType (3 pts)
# ============================================================================
evaluate_q11() {
    local w=3; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    if kubectl get ingress api-ingress -n ckad-ingress &>/dev/null; then
        score=$((score + 1))

        local path_type
        path_type=$(kubectl get ingress api-ingress -n ckad-ingress -o jsonpath='{.spec.rules[0].http.paths[0].pathType}' 2>/dev/null)
        [[ "$path_type" == "Prefix" || "$path_type" == "Exact" || "$path_type" == "ImplementationSpecific" ]] && score=$((score + 1))

        local path
        path=$(kubectl get ingress api-ingress -n ckad-ingress -o jsonpath='{.spec.rules[0].http.paths[0].path}' 2>/dev/null)
        [[ "$path" == "/api" ]] && score=$((score + 1))
    fi

    if [[ $score -eq $w ]]; then
        pass "Q11" $w "Ingress pathType fixed and applied"
    elif [[ $score -gt 0 ]]; then
        partial "Q11" $score $w "Ingress partially fixed"
    else
        fail "Q11" "Ingress api-ingress not found"
    fi
}

# ============================================================================
# Q12: ResourceQuota Pod (5 pts)
# ============================================================================
evaluate_q12() {
    local w=5; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    if kubectl get pod resource-pod -n ckad-quota &>/dev/null; then
        score=$((score + 1))

        local image
        image=$(kubectl get pod resource-pod -n ckad-quota -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)
        [[ "$image" == "nginx:1.25" ]] && score=$((score + 1))

        # Check limits (should be half of quota: cpu=1, memory=2Gi)
        local cpu_limit
        cpu_limit=$(kubectl get pod resource-pod -n ckad-quota -o jsonpath='{.spec.containers[0].resources.limits.cpu}' 2>/dev/null)
        [[ "$cpu_limit" == "1" || "$cpu_limit" == "1000m" ]] && score=$((score + 1))

        local mem_limit
        mem_limit=$(kubectl get pod resource-pod -n ckad-quota -o jsonpath='{.spec.containers[0].resources.limits.memory}' 2>/dev/null)
        [[ "$mem_limit" == "2Gi" ]] && score=$((score + 1))

        # Check requests
        local cpu_req
        cpu_req=$(kubectl get pod resource-pod -n ckad-quota -o jsonpath='{.spec.containers[0].resources.requests.cpu}' 2>/dev/null)
        [[ "$cpu_req" == "100m" ]] && score=$((score + 1))
    fi

    if [[ $score -eq $w ]]; then
        pass "Q12" $w "Pod with correct resource limits (half of quota)"
    elif [[ $score -gt 0 ]]; then
        partial "Q12" $score $w "Pod exists but resource limits incorrect"
    else
        fail "Q12" "Pod resource-pod not found in ckad-quota"
    fi
}

# ============================================================================
# Q13: Scale + Label + NodePort (6 pts)
# ============================================================================
evaluate_q13() {
    local w=6; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    if kubectl get deployment frontend-deploy -n ckad-scale &>/dev/null; then
        # Check label
        local func_label
        func_label=$(kubectl get deployment frontend-deploy -n ckad-scale -o jsonpath='{.spec.template.metadata.labels.func}' 2>/dev/null)
        [[ "$func_label" == "webFrontEnd" ]] && score=$((score + 1))

        # Check replicas
        local replicas
        replicas=$(kubectl get deployment frontend-deploy -n ckad-scale -o jsonpath='{.spec.replicas}' 2>/dev/null)
        [[ "$replicas" == "4" ]] && score=$((score + 1))
    fi

    # Check NodePort Service
    if kubectl get svc frontend-svc -n ckad-scale &>/dev/null; then
        score=$((score + 1))

        local svc_type
        svc_type=$(kubectl get svc frontend-svc -n ckad-scale -o jsonpath='{.spec.type}' 2>/dev/null)
        [[ "$svc_type" == "NodePort" ]] && score=$((score + 1))

        local port
        port=$(kubectl get svc frontend-svc -n ckad-scale -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)
        [[ "$port" == "8080" ]] && score=$((score + 1))

        # Check endpoints exist
        local endpoints
        endpoints=$(kubectl get endpoints frontend-svc -n ckad-scale -o jsonpath='{.subsets}' 2>/dev/null)
        [[ -n "$endpoints" && "$endpoints" != "[]" ]] && score=$((score + 1))
    fi

    if [[ $score -eq $w ]]; then
        pass "Q13" $w "Scaled, labeled, and NodePort Service created"
    elif [[ $score -gt 0 ]]; then
        partial "Q13" $score $w "Some scale/label/service tasks completed"
    else
        fail "Q13" "No changes found"
    fi
}

# ============================================================================
# Q14: Pod Logs + Metrics (4 pts)
# ============================================================================
evaluate_q14() {
    local w=4; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    # Check logger pod deployed
    if kubectl get pod logger -n ckad-logs &>/dev/null; then
        score=$((score + 1))
    fi

    # Check logs file
    if [[ -f "/opt/course/e14/pod-logs.txt" ]]; then
        local lines
        lines=$(wc -l < /opt/course/e14/pod-logs.txt 2>/dev/null || echo "0")
        [[ $lines -ge 1 ]] && score=$((score + 1))
    fi

    # Check top pod file
    if [[ -f "/opt/course/e14/top-pod.txt" ]]; then
        local top_content
        top_content=$(cat /opt/course/e14/top-pod.txt 2>/dev/null | tr -d '[:space:]')
        [[ "$top_content" == "cpu-high" ]] && score=$((score + 2))
    fi

    if [[ $score -eq $w ]]; then
        pass "Q14" $w "Pod deployed, logs captured, top pod identified"
    elif [[ $score -gt 0 ]]; then
        partial "Q14" $score $w "Some log/metric tasks completed"
    else
        fail "Q14" "No log/metric tasks completed"
    fi
}

# ============================================================================
# Q15: API Deprecation HPA (4 pts)
# ============================================================================
evaluate_q15() {
    local w=4; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    if kubectl get hpa web-hpa -n ckad-api &>/dev/null; then
        score=$((score + 2))

        local min_replicas
        min_replicas=$(kubectl get hpa web-hpa -n ckad-api -o jsonpath='{.spec.minReplicas}' 2>/dev/null)
        [[ "$min_replicas" == "2" ]] && score=$((score + 1))

        local max_replicas
        max_replicas=$(kubectl get hpa web-hpa -n ckad-api -o jsonpath='{.spec.maxReplicas}' 2>/dev/null)
        [[ "$max_replicas" == "10" ]] && score=$((score + 1))
    fi

    if [[ $score -eq $w ]]; then
        pass "Q15" $w "HPA created with correct API version"
    elif [[ $score -gt 0 ]]; then
        partial "Q15" $score $w "HPA partially configured"
    else
        fail "Q15" "HPA web-hpa not found in ckad-api"
    fi
}

# ============================================================================
# Q16: Rollout Resume (4 pts)
# ============================================================================
evaluate_q16() {
    local w=4; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    if kubectl get deployment web-paused -n ckad-resume &>/dev/null; then
        # Check image is updated
        local image
        image=$(kubectl get deployment web-paused -n ckad-resume -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
        [[ "$image" == "nginx:1.25" ]] && score=$((score + 2))

        # Check deployment is NOT paused
        local paused
        paused=$(kubectl get deployment web-paused -n ckad-resume -o jsonpath='{.spec.paused}' 2>/dev/null)
        [[ "$paused" != "true" ]] && score=$((score + 1))

        # Check pods are running with new image
        local ready
        ready=$(kubectl get deployment web-paused -n ckad-resume -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
        [[ "$ready" -ge 1 ]] && score=$((score + 1))
    fi

    if [[ $score -eq $w ]]; then
        pass "Q16" $w "Deployment resumed with nginx:1.25"
    elif [[ $score -gt 0 ]]; then
        partial "Q16" $score $w "Deployment partially updated"
    else
        fail "Q16" "Deployment web-paused not updated"
    fi
}

# ============================================================================
# Q17: Build Container Image and Save as Tarball (6 pts)
# Source: aravind4799 Q05, Reddit "appeared twice"
# ============================================================================
evaluate_q17() {
    local w=6; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    # Check if image exists
    if docker image inspect web-app:1.0 &>/dev/null; then
        score=$((score + 3))
    fi

    # Check if tarball was saved
    if [[ -f /opt/course/e17/web-app.tar ]]; then
        score=$((score + 2))
        # Check tarball is valid (contains layers)
        if tar tf /opt/course/e17/web-app.tar &>/dev/null; then
            score=$((score + 1))
        fi
    fi

    if [[ $score -eq $w ]]; then
        pass "Q17" $w "Image web-app:1.0 built and saved"
    elif [[ $score -gt 0 ]]; then
        partial "Q17" $score $w "Image partially built/saved"
    else
        fail "Q17" "Image web-app:1.0 not found"
    fi
}

# ============================================================================
# Q18: Build Second Image and Save as OCI Archive (5 pts)
# Source: Reddit "Docker/Podman appeared twice"
# ============================================================================
evaluate_q18() {
    local w=5; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    # Check if image exists
    if docker image inspect api-service:2.5 &>/dev/null; then
        score=$((score + 2))
    fi

    # Check if tarball was saved
    if [[ -f /opt/course/e18/api-service.tar ]]; then
        score=$((score + 2))
        # Check tarball is valid
        if tar tf /opt/course/e18/api-service.tar &>/dev/null; then
            score=$((score + 1))
        fi
    fi

    if [[ $score -eq $w ]]; then
        pass "Q18" $w "Image api-service:2.5 built and saved"
    elif [[ $score -gt 0 ]]; then
        partial "Q18" $score $w "Image partially built/saved"
    else
        fail "Q18" "Image api-service:2.5 not found"
    fi
}

# ============================================================================
# Q19: Fix Broken Pod with Correct ServiceAccount (5 pts)
# Source: aravind4799 Q04, vloidcloudtech Q04
# ============================================================================
evaluate_q19() {
    local w=5; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    if kubectl get pod metrics-pod -n ckad-sa-fix &>/dev/null; then
        # Check ServiceAccount is monitor-sa (the correct one)
        local sa
        sa=$(kubectl get pod metrics-pod -n ckad-sa-fix -o jsonpath='{.spec.serviceAccountName}' 2>/dev/null)
        if [[ "$sa" == "monitor-sa" ]]; then
            score=$((score + 3))
        fi

        # Check pod is running
        local phase
        phase=$(kubectl get pod metrics-pod -n ckad-sa-fix -o jsonpath='{.status.phase}' 2>/dev/null)
        [[ "$phase" == "Running" ]] && score=$((score + 2))
    fi

    if [[ $score -eq $w ]]; then
        pass "Q19" $w "Pod using monitor-sa and running"
    elif [[ $score -gt 0 ]]; then
        partial "Q19" $score $w "Pod partially fixed"
    else
        fail "Q19" "Pod metrics-pod not using correct SA"
    fi
}

# ============================================================================
# Q20: Fix Service Selector Mismatch (4 pts)
# Source: aravind4799 Q12, vloidcloudtech Q12, TiPunchLabs Oni Q9
# ============================================================================
evaluate_q20() {
    local w=4; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    if kubectl get svc web-svc -n ckad-svc-fix &>/dev/null; then
        # Check selector contains app=webapp
        local selector
        selector=$(kubectl get svc web-svc -n ckad-svc-fix -o jsonpath='{.spec.selector.app}' 2>/dev/null)
        [[ "$selector" == "webapp" ]] && score=$((score + 2))

        # Check endpoints exist (not empty)
        local endpoints
        endpoints=$(kubectl get endpoints web-svc -n ckad-svc-fix -o jsonpath='{.subsets[0].addresses}' 2>/dev/null)
        [[ -n "$endpoints" && "$endpoints" != "null" ]] && score=$((score + 2))
    fi

    if [[ $score -eq $w ]]; then
        pass "Q20" $w "Service selector fixed, endpoints connected"
    elif [[ $score -gt 0 ]]; then
        partial "Q20" $score $w "Service partially fixed"
    else
        fail "Q20" "Service web-svc not fixed"
    fi
}

# ============================================================================
# Q21: CronJob with History Limits (5 pts)
# Source: vloidcloudtech Q02, Reddit (historyLimits version)
# ============================================================================
evaluate_q21() {
    local w=5; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    if kubectl get cronjob backup-job -n ckad-cronjob2 &>/dev/null; then
        score=$((score + 1))

        # Check schedule
        local schedule
        schedule=$(kubectl get cronjob backup-job -n ckad-cronjob2 -o jsonpath='{.spec.schedule}' 2>/dev/null)
        [[ "$schedule" == "*/30 * * * *" ]] && score=$((score + 1))

        # Check successfulJobsHistoryLimit
        local succ
        succ=$(kubectl get cronjob backup-job -n ckad-cronjob2 -o jsonpath='{.spec.successfulJobsHistoryLimit}' 2>/dev/null)
        [[ "$succ" == "3" ]] && score=$((score + 1))

        # Check failedJobsHistoryLimit
        local fail_limit
        fail_limit=$(kubectl get cronjob backup-job -n ckad-cronjob2 -o jsonpath='{.spec.failedJobsHistoryLimit}' 2>/dev/null)
        [[ "$fail_limit" == "2" ]] && score=$((score + 1))

        # Check activeDeadlineSeconds
        local deadline
        deadline=$(kubectl get cronjob backup-job -n ckad-cronjob2 -o jsonpath='{.spec.jobTemplate.spec.activeDeadlineSeconds}' 2>/dev/null)
        [[ "$deadline" == "300" ]] && score=$((score + 1))
    fi

    if [[ $score -eq $w ]]; then
        pass "Q21" $w "CronJob backup-job with correct history limits"
    elif [[ $score -gt 0 ]]; then
        partial "Q21" $score $w "CronJob partially configured"
    else
        fail "Q21" "CronJob backup-job not found"
    fi
}

# ============================================================================
# Q22: Resource Requests/Limits from Namespace Max (5 pts)
# Source: Reddit "kubectl describe namespace dev to get the MAX"
# ============================================================================
evaluate_q22() {
    local w=5; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    if kubectl get pod resource-pod -n ckad-resources &>/dev/null; then
        score=$((score + 1))

        # Check memory request
        local mem_req
        mem_req=$(kubectl get pod resource-pod -n ckad-resources -o jsonpath='{.spec.containers[0].resources.requests.memory}' 2>/dev/null)
        [[ "$mem_req" == "128Mi" ]] && score=$((score + 1))

        # Check CPU limit is half of max (max=1, half=500m)
        local cpu_lim
        cpu_lim=$(kubectl get pod resource-pod -n ckad-resources -o jsonpath='{.spec.containers[0].resources.limits.cpu}' 2>/dev/null)
        [[ "$cpu_lim" == "500m" || "$cpu_lim" == "0.5" ]] && score=$((score + 1))

        # Check memory limit is half of max (max=1Gi, half=512Mi)
        local mem_lim
        mem_lim=$(kubectl get pod resource-pod -n ckad-resources -o jsonpath='{.spec.containers[0].resources.limits.memory}' 2>/dev/null)
        [[ "$mem_lim" == "512Mi" ]] && score=$((score + 1))

        # Check pod is running
        local phase
        phase=$(kubectl get pod resource-pod -n ckad-resources -o jsonpath='{.status.phase}' 2>/dev/null)
        [[ "$phase" == "Running" ]] && score=$((score + 1))
    fi

    if [[ $score -eq $w ]]; then
        pass "Q22" $w "Pod with correct resource limits (half of max)"
    elif [[ $score -gt 0 ]]; then
        partial "Q22" $score $w "Pod partially configured"
    else
        fail "Q22" "Pod resource-pod not found in ckad-resources"
    fi
}

# ============================================================================
# Q23: NetworkPolicy with Ingress AND Egress (6 pts)
# Source: Reddit "podSelector with ingress and egress for two pods"
# ============================================================================
evaluate_q23() {
    local w=6; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    if kubectl get networkpolicy api-netpol -n ckad-netpol2 &>/dev/null; then
        score=$((score + 1))

        local np_json
        np_json=$(kubectl get networkpolicy api-netpol -n ckad-netpol2 -o json 2>/dev/null)

        # Check podSelector targets app=api
        local pod_sel
        pod_sel=$(echo "$np_json" | jq -r '.spec.podSelector.matchLabels.app // empty' 2>/dev/null)
        [[ "$pod_sel" == "api" ]] && score=$((score + 1))

        # Check policyTypes includes both Ingress and Egress
        local policy_types
        policy_types=$(echo "$np_json" | jq -r '.spec.policyTypes[]' 2>/dev/null)
        [[ "$policy_types" == *"Ingress"* ]] && score=$((score + 1))
        [[ "$policy_types" == *"Egress"* ]] && score=$((score + 1))

        # Check ingress rule exists with port 80
        local ingress_port
        ingress_port=$(echo "$np_json" | jq -r '.spec.ingress[0].ports[0].port // empty' 2>/dev/null)
        [[ "$ingress_port" == "80" ]] && score=$((score + 1))

        # Check egress rule exists with port 5432
        local egress_port
        egress_port=$(echo "$np_json" | jq -r '.spec.egress[0].ports[0].port // empty' 2>/dev/null)
        [[ "$egress_port" == "5432" ]] && score=$((score + 1))
    fi

    if [[ $score -eq $w ]]; then
        pass "Q23" $w "NetworkPolicy with ingress+egress created"
    elif [[ $score -gt 0 ]]; then
        partial "Q23" $score $w "NetworkPolicy partially configured"
    else
        fail "Q23" "NetworkPolicy api-netpol not found"
    fi
}

# ============================================================================
# Q24: Job with Completions and Parallelism (5 pts)
# Source: TiPunchLabs Oni Q18
# ============================================================================
evaluate_q24() {
    local w=5; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    if kubectl get job batch-processor -n ckad-jobs &>/dev/null; then
        score=$((score + 1))

        # Check completions
        local completions
        completions=$(kubectl get job batch-processor -n ckad-jobs -o jsonpath='{.spec.completions}' 2>/dev/null)
        [[ "$completions" == "6" ]] && score=$((score + 1))

        # Check parallelism
        local parallelism
        parallelism=$(kubectl get job batch-processor -n ckad-jobs -o jsonpath='{.spec.parallelism}' 2>/dev/null)
        [[ "$parallelism" == "2" ]] && score=$((score + 1))

        # Check backoffLimit
        local backoff
        backoff=$(kubectl get job batch-processor -n ckad-jobs -o jsonpath='{.spec.backoffLimit}' 2>/dev/null)
        [[ "$backoff" == "4" ]] && score=$((score + 1))

        # Check job completed (at least some succeeded)
        local succeeded
        succeeded=$(kubectl get job batch-processor -n ckad-jobs -o jsonpath='{.status.succeeded}' 2>/dev/null || echo "0")
        [[ "$succeeded" -ge 1 ]] && score=$((score + 1))
    fi

    if [[ $score -eq $w ]]; then
        pass "Q24" $w "Job with 6 completions, 2 parallelism"
    elif [[ $score -gt 0 ]]; then
        partial "Q24" $score $w "Job partially configured"
    else
        fail "Q24" "Job batch-processor not found"
    fi
}

# ============================================================================
# Q25: Fix Deployment Exceeding ResourceQuota (5 pts)
# Source: TiPunchLabs Oni Q6, Reddit
# ============================================================================
evaluate_q25() {
    local w=5; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    if kubectl get deployment quota-app -n ckad-quota-fix &>/dev/null; then
        # Check pods are running (not stuck in Pending)
        local ready
        ready=$(kubectl get deployment quota-app -n ckad-quota-fix -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
        [[ "$ready" -ge 1 ]] && score=$((score + 2))

        # Check resource requests are within quota (cpu <= 250m per pod for 2 replicas)
        local cpu_req
        cpu_req=$(kubectl get deployment quota-app -n ckad-quota-fix -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}' 2>/dev/null)
        if [[ -n "$cpu_req" ]]; then
            # Convert to millicores for comparison
            local cpu_val
            if [[ "$cpu_req" == *m ]]; then
                cpu_val="${cpu_req%m}"
            else
                cpu_val=$((${cpu_req%%.*} * 1000))
            fi
            [[ "$cpu_val" -le 250 ]] && score=$((score + 1))
        fi

        # Check limits exist and are roughly 2x requests
        local cpu_lim
        cpu_lim=$(kubectl get deployment quota-app -n ckad-quota-fix -o jsonpath='{.spec.template.spec.containers[0].resources.limits.cpu}' 2>/dev/null)
        [[ -n "$cpu_lim" ]] && score=$((score + 1))

        local mem_lim
        mem_lim=$(kubectl get deployment quota-app -n ckad-quota-fix -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}' 2>/dev/null)
        [[ -n "$mem_lim" ]] && score=$((score + 1))
    fi

    if [[ $score -eq $w ]]; then
        pass "Q25" $w "Deployment fixed, pods running within quota"
    elif [[ $score -gt 0 ]]; then
        partial "Q25" $score $w "Deployment partially fixed"
    else
        fail "Q25" "Deployment quota-app still broken"
    fi
}

# ============================================================================
# Run all evaluations
# ============================================================================
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗"
echo "║       CKAD 2026 Real Exam Practice - Evaluating...           ║"
echo "╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

evaluate_q1
evaluate_q2
evaluate_q3
evaluate_q4
evaluate_q5
evaluate_q6
evaluate_q7
evaluate_q8
evaluate_q9
evaluate_q10
evaluate_q11
evaluate_q12
evaluate_q13
evaluate_q14
evaluate_q15
evaluate_q16
evaluate_q17
evaluate_q18
evaluate_q19
evaluate_q20
evaluate_q21
evaluate_q22
evaluate_q23
evaluate_q24
evaluate_q25

# ============================================================================
# Results
# ============================================================================
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗"
echo "║              CKAD 2026 - EVALUATION RESULTS                  ║"
echo "╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

printf "  ${BOLD}%-8s %-10s %-5s %s${NC}\n" "Question" "Status" "Pts" "Details"
echo "  ──────── ────────── ───── ──────────────────────────────────"

ALL_QUESTIONS=("Q1" "Q2" "Q3" "Q4" "Q5" "Q6" "Q7" "Q8" "Q9" "Q10" "Q11" "Q12" "Q13" "Q14" "Q15" "Q16" "Q17" "Q18" "Q19" "Q20" "Q21" "Q22" "Q23" "Q24" "Q25")
WEIGHT_MAP=("6" "5" "7" "6" "5" "4" "5" "4" "5" "5" "3" "5" "6" "4" "4" "4" "6" "5" "5" "4" "5" "5" "6" "5" "5")
TOPIC_MAP=(
    "Secret from Vars"
    "CronJob"
    "RBAC (SA+Role+RB)"
    "Canary Deployment"
    "NetworkPolicy Labels"
    "Fix Broken Deploy"
    "Rolling Update+Rollback"
    "Readiness Probe"
    "SecurityContext"
    "Create Ingress"
    "Fix Ingress PathType"
    "ResourceQuota Pod"
    "Scale+Label+NodePort"
    "Logs+Metrics"
    "API Deprecation HPA"
    "Rollout Resume"
    "Docker Build+Save"
    "Docker Build+OCI"
    "Fix Pod SA"
    "Fix Service Selector"
    "CronJob HistoryLimits"
    "Resource LimitRange"
    "NetPol Ingress+Egress"
    "Job Completions"
    "Fix Quota Deploy"
)

for i in "${!ALL_QUESTIONS[@]}"; do
    q="${ALL_QUESTIONS[$i]}"
    status="${Q_RESULT[$q]:-SKIP}"
    detail="${Q_DETAIL[$q]:-Not evaluated}"
    topic="${TOPIC_MAP[$i]}"
    weight="${WEIGHT_MAP[$i]}"
    color=""

    case "$status" in
        PASS)    color="${GREEN}" ;;
        FAIL)    color="${RED}" ;;
        PARTIAL) color="${YELLOW}" ;;
        SKIP)    color="${DIM}" ;;
    esac

    printf "  ${color}%-8s %-10s %-5s %s - %s${NC}\n" "$q" "$status" "/${weight}" "$topic" "$detail"
done

echo ""
echo "  ──────── ────────── ───── ──────────────────────────────────"
echo ""

percentage=0
if [[ $MAX_SCORE -gt 0 ]]; then
    percentage=$(( (TOTAL_SCORE * 100) / MAX_SCORE ))
fi

pass_fail="${RED}FAIL${NC}"
if [[ $percentage -ge 66 ]]; then
    pass_fail="${GREEN}PASS${NC}"
fi

echo -e "  ${BOLD}Score: ${TOTAL_SCORE}/${MAX_SCORE} points (${percentage}%)${NC}"
echo -e "  ${BOLD}Result: ${pass_fail}  (66% required to pass)${NC}"
echo ""
echo -e "  Questions: ${GREEN}${PASSED_COUNT} passed${NC} | ${RED}${FAILED_COUNT} failed${NC} | ${DIM}${SKIPPED_COUNT} skipped${NC}"
echo ""

if [[ $percentage -ge 66 ]]; then
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗"
    echo "║    CONGRATULATIONS! You passed the CKAD 2026 practice!      ║"
    echo "╚══════════════════════════════════════════════════════════════╝${NC}"
else
    echo -e "${YELLOW}Keep practicing! Focus on the failed questions and try again.${NC}"
    echo -e "${YELLOW}Tip: Run ./cleanup-ckad2026-env.sh && ./setup-ckad2026-env.sh to reset.${NC}"
fi
echo ""
