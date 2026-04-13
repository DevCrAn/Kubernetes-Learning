#!/bin/bash
#
# CKAD Exam Evaluator
# Automatically checks answers for all 25 questions
# Scoring is approximate based on Killer Shell patterns
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

# Score tracking
declare -A Q_RESULT
declare -A Q_DETAIL

pass() {
    local q="$1"
    local weight="$2"
    local detail="$3"
    TOTAL_SCORE=$((TOTAL_SCORE + weight))
    Q_RESULT[$q]="PASS"
    Q_DETAIL[$q]="$detail"
    ((PASSED_COUNT++)) || true
}

fail() {
    local q="$1"
    local detail="$2"
    Q_RESULT[$q]="FAIL"
    Q_DETAIL[$q]="$detail"
    ((FAILED_COUNT++)) || true
}

skip() {
    local q="$1"
    local detail="$2"
    Q_RESULT[$q]="SKIP"
    Q_DETAIL[$q]="$detail"
    ((SKIPPED_COUNT++)) || true
}

partial() {
    local q="$1"
    local earned="$2"
    local weight="$3"
    local detail="$4"
    TOTAL_SCORE=$((TOTAL_SCORE + earned))
    Q_RESULT[$q]="PARTIAL"
    Q_DETAIL[$q]="$detail (${earned}/${weight} pts)"
    ((PASSED_COUNT++)) || true
}

# ============================================================================
# Q1: Namespaces (2 pts)
# ============================================================================
evaluate_q1() {
    local w=2; MAX_SCORE=$((MAX_SCORE + w))
    if [[ -f "/opt/course/1/namespaces" ]]; then
        local ns_count
        ns_count=$(wc -l < /opt/course/1/namespaces 2>/dev/null || echo 0)
        if [[ $ns_count -ge 10 ]]; then
            pass "Q1" $w "File exists with ${ns_count} namespaces"
        else
            partial "Q1" 1 $w "File exists but only ${ns_count} lines (expected 10+)"
        fi
    else
        fail "Q1" "File /opt/course/1/namespaces not found"
    fi
}

# ============================================================================
# Q2: Pods (4 pts)
# ============================================================================
evaluate_q2() {
    local w=4; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    # Check pod exists
    if kubectl get pod pod1 -n default &>/dev/null; then
        local image
        image=$(kubectl get pod pod1 -n default -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)
        local cname
        cname=$(kubectl get pod pod1 -n default -o jsonpath='{.spec.containers[0].name}' 2>/dev/null)

        if [[ "$image" == "httpd:2.4.41-alpine" ]]; then
            score=$((score + 1))
        fi
        if [[ "$cname" == "pod1-container" ]]; then
            score=$((score + 1))
        fi
    fi

    # Check command file
    if [[ -f "/opt/course/2/pod1-status-command.sh" ]]; then
        score=$((score + 2))
    fi

    if [[ $score -eq $w ]]; then
        pass "Q2" $w "Pod correct + command file exists"
    elif [[ $score -gt 0 ]]; then
        partial "Q2" $score $w "Partial: some checks passed"
    else
        fail "Q2" "Pod pod1 not found or command file missing"
    fi
}

# ============================================================================
# Q3: Job (5 pts)
# ============================================================================
evaluate_q3() {
    local w=5; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    if kubectl get job neb-new-job -n neptune &>/dev/null; then
        score=$((score + 1))
        local completions
        completions=$(kubectl get job neb-new-job -n neptune -o jsonpath='{.spec.completions}' 2>/dev/null)
        local parallelism
        parallelism=$(kubectl get job neb-new-job -n neptune -o jsonpath='{.spec.parallelism}' 2>/dev/null)
        local container
        container=$(kubectl get job neb-new-job -n neptune -o jsonpath='{.spec.template.spec.containers[0].name}' 2>/dev/null)

        [[ "$completions" == "3" ]] && score=$((score + 1))
        [[ "$parallelism" == "2" ]] && score=$((score + 1))
        [[ "$container" == "neb-new-job-container" ]] && score=$((score + 1))

        # Check pod label
        local label
        label=$(kubectl get job neb-new-job -n neptune -o jsonpath='{.spec.template.metadata.labels.id}' 2>/dev/null)
        [[ "$label" == "awesome-job" ]] && score=$((score + 1))
    fi

    if [[ $score -eq $w ]]; then
        pass "Q3" $w "Job correct: completions=3, parallelism=2, labels OK"
    elif [[ $score -gt 0 ]]; then
        partial "Q3" $score $w "Job exists but some settings incorrect"
    else
        fail "Q3" "Job neb-new-job not found in neptune"
    fi
}

# ============================================================================
# Q4: Helm Management (8 pts)
# ============================================================================
evaluate_q4() {
    local w=8; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    if ! command -v helm &>/dev/null; then
        skip "Q4" "Helm not installed"
        return
    fi

    # Check apiv1 is DELETED
    if ! helm status internal-issue-report-apiv1 -n mercury &>/dev/null 2>&1; then
        score=$((score + 2))
    fi

    # Check apiv2 is UPGRADED (version > 0.1.0)
    local apiv2_version
    apiv2_version=$(helm ls -n mercury -o json 2>/dev/null | jq -r '.[] | select(.name=="internal-issue-report-apiv2") | .chart' 2>/dev/null || echo "")
    if [[ -n "$apiv2_version" && "$apiv2_version" != "nginx-0.1.0" ]]; then
        score=$((score + 2))
    fi

    # Check apache is installed with 2 replicas
    if helm status internal-issue-report-apache -n mercury &>/dev/null 2>&1; then
        score=$((score + 1))
        local replicas
        replicas=$(kubectl get deployment -n mercury -l "app=internal-issue-report-apache" \
            -o jsonpath='{.items[0].spec.replicas}' 2>/dev/null || echo "0")
        # Also try the chart-generated name
        if [[ "$replicas" != "2" ]]; then
            replicas=$(kubectl get deployment internal-issue-report-apache-apache -n mercury \
                -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "0")
        fi
        [[ "$replicas" == "2" ]] && score=$((score + 1))
    fi

    # Check broken release is DELETED
    if ! helm status internal-issue-report-daniel -n mercury &>/dev/null 2>&1; then
        local broken_exists
        broken_exists=$(helm ls -n mercury -a 2>/dev/null | grep -c "internal-issue-report-daniel" || echo "0")
        [[ "$broken_exists" == "0" ]] && score=$((score + 2))
    fi

    if [[ $score -eq $w ]]; then
        pass "Q4" $w "All Helm operations correct"
    elif [[ $score -gt 0 ]]; then
        partial "Q4" $score $w "Some Helm operations completed"
    else
        fail "Q4" "No Helm operations completed"
    fi
}

# ============================================================================
# Q5: ServiceAccount Token (4 pts)
# ============================================================================
evaluate_q5() {
    local w=4; MAX_SCORE=$((MAX_SCORE + w))
    if [[ -f "/opt/course/5/token" ]]; then
        local content
        content=$(cat /opt/course/5/token 2>/dev/null)
        if [[ -n "$content" && ${#content} -gt 20 ]]; then
            pass "Q5" $w "Token file exists with content"
        else
            partial "Q5" 2 $w "Token file exists but content seems wrong"
        fi
    else
        fail "Q5" "File /opt/course/5/token not found"
    fi
}

# ============================================================================
# Q6: ReadinessProbe (5 pts)
# ============================================================================
evaluate_q6() {
    local w=5; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    if kubectl get pod pod6 -n default &>/dev/null; then
        score=$((score + 1))

        local image
        image=$(kubectl get pod pod6 -n default -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)
        [[ "$image" == "busybox:1.31.0" ]] && score=$((score + 1))

        # Check readiness probe
        local probe_cmd
        probe_cmd=$(kubectl get pod pod6 -n default -o jsonpath='{.spec.containers[0].readinessProbe.exec.command}' 2>/dev/null)
        [[ "$probe_cmd" == *"cat"* && "$probe_cmd" == *"/tmp/ready"* ]] && score=$((score + 1))

        local initial_delay
        initial_delay=$(kubectl get pod pod6 -n default -o jsonpath='{.spec.containers[0].readinessProbe.initialDelaySeconds}' 2>/dev/null)
        [[ "$initial_delay" == "5" ]] && score=$((score + 1))

        local period
        period=$(kubectl get pod pod6 -n default -o jsonpath='{.spec.containers[0].readinessProbe.periodSeconds}' 2>/dev/null)
        [[ "$period" == "10" ]] && score=$((score + 1))
    fi

    if [[ $score -eq $w ]]; then
        pass "Q6" $w "Pod with readinessProbe correct"
    elif [[ $score -gt 0 ]]; then
        partial "Q6" $score $w "Pod exists but probe config incomplete"
    else
        fail "Q6" "Pod pod6 not found"
    fi
}

# ============================================================================
# Q7: Pod migration saturn->neptune (4 pts)
# ============================================================================
evaluate_q7() {
    local w=4; MAX_SCORE=$((MAX_SCORE + w))

    # Check if my-happy-shop pod exists in neptune
    local found_neptune
    found_neptune=$(kubectl get pods -n neptune -o jsonpath='{range .items[*]}{.metadata.annotations.description}{"\n"}{end}' 2>/dev/null | grep -c "my-happy-shop" || echo "0")

    # Check if my-happy-shop pod is gone from saturn
    local found_saturn
    found_saturn=$(kubectl get pods -n saturn -o jsonpath='{range .items[*]}{.metadata.annotations.description}{"\n"}{end}' 2>/dev/null | grep -c "my-happy-shop" || echo "0")

    if [[ "$found_neptune" -ge 1 && "$found_saturn" == "0" ]]; then
        pass "Q7" $w "Pod migrated from saturn to neptune"
    elif [[ "$found_neptune" -ge 1 ]]; then
        partial "Q7" 3 $w "Pod in neptune but still exists in saturn"
    else
        fail "Q7" "my-happy-shop pod not found in neptune"
    fi
}

# ============================================================================
# Q8: Deployment Rollout (5 pts)
# ============================================================================
evaluate_q8() {
    local w=5; MAX_SCORE=$((MAX_SCORE + w))

    if kubectl get deployment api-new-c32 -n neptune &>/dev/null; then
        local image
        image=$(kubectl get deployment api-new-c32 -n neptune -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)

        # Check that it's NOT the bad image (ngnix typo)
        if [[ "$image" != *"ngnix"* && "$image" == *"nginx"* ]]; then
            # Check if pods are running
            local ready
            ready=$(kubectl get deployment api-new-c32 -n neptune -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
            if [[ "$ready" -ge 1 ]]; then
                pass "Q8" $w "Deployment rolled back to working revision (${image})"
            else
                partial "Q8" 3 $w "Image fixed but pods not fully ready"
            fi
        else
            fail "Q8" "Deployment still has broken image: ${image}"
        fi
    else
        fail "Q8" "Deployment api-new-c32 not found"
    fi
}

# ============================================================================
# Q9: Pod -> Deployment (6 pts)
# ============================================================================
evaluate_q9() {
    local w=6; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    # Check Deployment exists
    if kubectl get deployment holy-api -n pluto &>/dev/null; then
        score=$((score + 2))

        local replicas
        replicas=$(kubectl get deployment holy-api -n pluto -o jsonpath='{.spec.replicas}' 2>/dev/null)
        [[ "$replicas" == "3" ]] && score=$((score + 1))

        # Check security context
        local priv_esc
        priv_esc=$(kubectl get deployment holy-api -n pluto -o jsonpath='{.spec.template.spec.containers[0].securityContext.allowPrivilegeEscalation}' 2>/dev/null)
        local privileged
        privileged=$(kubectl get deployment holy-api -n pluto -o jsonpath='{.spec.template.spec.containers[0].securityContext.privileged}' 2>/dev/null)

        [[ "$priv_esc" == "false" ]] && score=$((score + 1))
        [[ "$privileged" == "false" ]] && score=$((score + 1))
    fi

    # Check saved yaml
    [[ -f "/opt/course/9/holy-api-deployment.yaml" ]] && score=$((score + 1))

    if [[ $score -eq $w ]]; then
        pass "Q9" $w "Deployment with security context + yaml saved"
    elif [[ $score -gt 0 ]]; then
        partial "Q9" $score $w "Some requirements met"
    else
        fail "Q9" "Deployment holy-api not found in pluto"
    fi
}

# ============================================================================
# Q10: Service + Logs (6 pts)
# ============================================================================
evaluate_q10() {
    local w=6; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    # Check Pod
    if kubectl get pod project-plt-6cc-api -n pluto &>/dev/null; then
        score=$((score + 1))
        local label
        label=$(kubectl get pod project-plt-6cc-api -n pluto -o jsonpath='{.metadata.labels.project}' 2>/dev/null)
        [[ "$label" == "plt-6cc-api" ]] && score=$((score + 1))
    fi

    # Check Service
    if kubectl get svc project-plt-6cc-svc -n pluto &>/dev/null; then
        score=$((score + 1))
        local port
        port=$(kubectl get svc project-plt-6cc-svc -n pluto -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)
        [[ "$port" == "3333" ]] && score=$((score + 1))
    fi

    # Check response file
    [[ -f "/opt/course/10/service_test.html" ]] && score=$((score + 1))
    [[ -f "/opt/course/10/service_test.log" ]] && score=$((score + 1))

    if [[ $score -eq $w ]]; then
        pass "Q10" $w "Pod, Service, and log files correct"
    elif [[ $score -gt 0 ]]; then
        partial "Q10" $score $w "Some requirements met"
    else
        fail "Q10" "Pod/Service not found in pluto"
    fi
}

# ============================================================================
# Q11: Container builds (7 pts)
# ============================================================================
evaluate_q11() {
    local w=7; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    # Check Dockerfile has ENV
    if [[ -f "/opt/course/11/image/Dockerfile" ]]; then
        if grep -q "SUN_CIPHER_ID" /opt/course/11/image/Dockerfile 2>/dev/null; then
            if grep -q "5b9c1065-e39d-4a43-a04a-e59bcea3e03f" /opt/course/11/image/Dockerfile 2>/dev/null; then
                score=$((score + 2))
            fi
        fi
    fi

    # Check Docker image exists
    if command -v docker &>/dev/null; then
        docker image inspect registry.killer.sh:5000/sun-cipher:v1-docker &>/dev/null 2>&1 && score=$((score + 1))
    fi

    # Check Podman image exists
    if command -v podman &>/dev/null; then
        sudo podman image inspect registry.killer.sh:5000/sun-cipher:v1-podman &>/dev/null 2>&1 && score=$((score + 1))
    fi

    # Check running container
    if command -v podman &>/dev/null; then
        sudo podman ps --format '{{.Names}}' 2>/dev/null | grep -q "sun-cipher" && score=$((score + 1))
    fi

    # Check logs file
    [[ -f "/opt/course/11/logs" ]] && score=$((score + 2))

    if [[ $score -eq $w ]]; then
        pass "Q11" $w "All container tasks completed"
    elif [[ $score -gt 0 ]]; then
        partial "Q11" $score $w "Some container tasks completed"
    else
        fail "Q11" "No container tasks completed"
    fi
}

# ============================================================================
# Q12: Storage PV/PVC (6 pts)
# ============================================================================
evaluate_q12() {
    local w=6; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    # Check PV
    if kubectl get pv earth-project-earthflower-pv &>/dev/null; then
        score=$((score + 1))
        local capacity
        capacity=$(kubectl get pv earth-project-earthflower-pv -o jsonpath='{.spec.capacity.storage}' 2>/dev/null)
        [[ "$capacity" == "2Gi" ]] && score=$((score + 1))
    fi

    # Check PVC
    if kubectl get pvc earth-project-earthflower-pvc -n earth &>/dev/null; then
        score=$((score + 1))
        local phase
        phase=$(kubectl get pvc earth-project-earthflower-pvc -n earth -o jsonpath='{.status.phase}' 2>/dev/null)
        [[ "$phase" == "Bound" ]] && score=$((score + 1))
    fi

    # Check Deployment
    if kubectl get deployment project-earthflower -n earth &>/dev/null; then
        score=$((score + 2))
    fi

    if [[ $score -eq $w ]]; then
        pass "Q12" $w "PV, PVC (Bound), and Deployment correct"
    elif [[ $score -gt 0 ]]; then
        partial "Q12" $score $w "Some storage components created"
    else
        fail "Q12" "No storage components found"
    fi
}

# ============================================================================
# Q13: StorageClass + PVC (5 pts)
# ============================================================================
evaluate_q13() {
    local w=5; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    # Check StorageClass
    if kubectl get storageclass moon-retain &>/dev/null; then
        score=$((score + 1))
        local provisioner
        provisioner=$(kubectl get storageclass moon-retain -o jsonpath='{.provisioner}' 2>/dev/null)
        local reclaim
        reclaim=$(kubectl get storageclass moon-retain -o jsonpath='{.reclaimPolicy}' 2>/dev/null)
        [[ "$provisioner" == "moon-retainer" ]] && score=$((score + 1))
        [[ "$reclaim" == "Retain" ]] && score=$((score + 1))
    fi

    # Check PVC
    if kubectl get pvc moon-pvc-126 -n moon &>/dev/null; then
        score=$((score + 1))
    fi

    # Check reason file
    [[ -f "/opt/course/13/pvc-126-reason" ]] && score=$((score + 1))

    if [[ $score -eq $w ]]; then
        pass "Q13" $w "StorageClass, PVC, and reason file correct"
    elif [[ $score -gt 0 ]]; then
        partial "Q13" $score $w "Some storage components created"
    else
        fail "Q13" "No storage components found"
    fi
}

# ============================================================================
# Q14: Secrets (6 pts)
# ============================================================================
evaluate_q14() {
    local w=6; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    # Check secret1
    if kubectl get secret secret1 -n moon &>/dev/null; then
        score=$((score + 1))
    fi

    # Check secret2
    if kubectl get secret secret2 -n moon &>/dev/null; then
        score=$((score + 1))
    fi

    # Check Pod has env vars
    if kubectl get pod secret-handler -n moon &>/dev/null; then
        local env_output
        env_output=$(kubectl get pod secret-handler -n moon -o jsonpath='{.spec.containers[0].env}' 2>/dev/null)
        [[ "$env_output" == *"SECRET1_USER"* ]] && score=$((score + 1))
        [[ "$env_output" == *"SECRET1_PASS"* ]] && score=$((score + 1))

        # Check secret2 volume mount
        local vol_mounts
        vol_mounts=$(kubectl get pod secret-handler -n moon -o jsonpath='{.spec.containers[0].volumeMounts}' 2>/dev/null)
        [[ "$vol_mounts" == *"/tmp/secret2"* ]] && score=$((score + 1))
    fi

    # Check saved yaml
    [[ -f "/opt/course/14/secret-handler-new.yaml" ]] && score=$((score + 1))

    if [[ $score -eq $w ]]; then
        pass "Q14" $w "Secrets + env vars + volume mount correct"
    elif [[ $score -gt 0 ]]; then
        partial "Q14" $score $w "Some secret requirements met"
    else
        fail "Q14" "No secret components found"
    fi
}

# ============================================================================
# Q15: ConfigMap (4 pts)
# ============================================================================
evaluate_q15() {
    local w=4; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    if kubectl get configmap configmap-web-moon-html -n moon &>/dev/null; then
        score=$((score + 2))

        # Check if index.html key exists
        local keys
        keys=$(kubectl get configmap configmap-web-moon-html -n moon -o jsonpath='{.data}' 2>/dev/null)
        [[ "$keys" == *"index.html"* ]] && score=$((score + 1))

        # Check if web-moon pods are running
        local ready
        ready=$(kubectl get deployment web-moon -n moon -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
        [[ "$ready" -ge 1 ]] && score=$((score + 1))
    fi

    if [[ $score -eq $w ]]; then
        pass "Q15" $w "ConfigMap created and Deployment running"
    elif [[ $score -gt 0 ]]; then
        partial "Q15" $score $w "ConfigMap partially configured"
    else
        fail "Q15" "ConfigMap configmap-web-moon-html not found"
    fi
}

# ============================================================================
# Q16: Logging sidecar (5 pts)
# ============================================================================
evaluate_q16() {
    local w=5; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    if kubectl get deployment cleaner -n mercury &>/dev/null; then
        # Check for sidecar container
        local containers
        containers=$(kubectl get deployment cleaner -n mercury -o jsonpath='{.spec.template.spec.containers[*].name}' 2>/dev/null)

        if [[ "$containers" == *"logger-con"* ]]; then
            score=$((score + 3))

            # Check logger image
            local logger_image
            logger_image=$(kubectl get deployment cleaner -n mercury -o jsonpath='{.spec.template.spec.containers[?(@.name=="logger-con")].image}' 2>/dev/null)
            [[ "$logger_image" == "busybox:1.31.0" ]] && score=$((score + 1))
        fi
    fi

    # Check saved yaml
    [[ -f "/opt/course/16/cleaner-new.yaml" ]] && score=$((score + 1))

    if [[ $score -eq $w ]]; then
        pass "Q16" $w "Sidecar container added correctly"
    elif [[ $score -gt 0 ]]; then
        partial "Q16" $score $w "Some sidecar requirements met"
    else
        fail "Q16" "Sidecar container logger-con not found"
    fi
}

# ============================================================================
# Q17: InitContainer (5 pts)
# ============================================================================
evaluate_q17() {
    local w=5; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    if kubectl get deployment test-init-container -n default &>/dev/null; then
        score=$((score + 1))

        # Check init container
        local init_containers
        init_containers=$(kubectl get deployment test-init-container -n default -o jsonpath='{.spec.template.spec.initContainers[*].name}' 2>/dev/null)

        if [[ "$init_containers" == *"init-con"* ]]; then
            score=$((score + 2))

            local init_image
            init_image=$(kubectl get deployment test-init-container -n default -o jsonpath='{.spec.template.spec.initContainers[?(@.name=="init-con")].image}' 2>/dev/null)
            [[ "$init_image" == "busybox:1.31.0" ]] && score=$((score + 1))
        fi

        # Check if pod is running and serving
        local ready
        ready=$(kubectl get deployment test-init-container -n default -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
        [[ "$ready" -ge 1 ]] && score=$((score + 1))
    fi

    if [[ $score -eq $w ]]; then
        pass "Q17" $w "InitContainer creating index.html correctly"
    elif [[ $score -gt 0 ]]; then
        partial "Q17" $score $w "Some initContainer requirements met"
    else
        fail "Q17" "Deployment test-init-container not found"
    fi
}

# ============================================================================
# Q18: Service misconfiguration (3 pts)
# ============================================================================
evaluate_q18() {
    local w=3; MAX_SCORE=$((MAX_SCORE + w))

    if kubectl get svc manager-api-svc -n mars &>/dev/null; then
        local selector
        selector=$(kubectl get svc manager-api-svc -n mars -o jsonpath='{.spec.selector.app}' 2>/dev/null)

        if [[ "$selector" == "manager-api" ]]; then
            # Check endpoints exist
            local endpoints
            endpoints=$(kubectl get endpoints manager-api-svc -n mars -o jsonpath='{.subsets}' 2>/dev/null)
            if [[ -n "$endpoints" && "$endpoints" != "[]" ]]; then
                pass "Q18" $w "Service selector fixed to 'manager-api'"
            else
                partial "Q18" 2 $w "Selector fixed but no endpoints yet"
            fi
        else
            fail "Q18" "Service selector still wrong: '${selector}' (should be 'manager-api')"
        fi
    else
        fail "Q18" "Service manager-api-svc not found in mars"
    fi
}

# ============================================================================
# Q19: ClusterIP -> NodePort (4 pts)
# ============================================================================
evaluate_q19() {
    local w=4; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    if kubectl get svc jupiter-crew-svc -n jupiter &>/dev/null; then
        local svc_type
        svc_type=$(kubectl get svc jupiter-crew-svc -n jupiter -o jsonpath='{.spec.type}' 2>/dev/null)
        [[ "$svc_type" == "NodePort" ]] && score=$((score + 2))

        local node_port
        node_port=$(kubectl get svc jupiter-crew-svc -n jupiter -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)
        [[ "$node_port" == "30100" ]] && score=$((score + 2))
    fi

    if [[ $score -eq $w ]]; then
        pass "Q19" $w "Service changed to NodePort:30100"
    elif [[ $score -gt 0 ]]; then
        partial "Q19" $score $w "Service partially configured"
    else
        fail "Q19" "Service jupiter-crew-svc not NodePort or missing"
    fi
}

# ============================================================================
# Q20: NetworkPolicy (6 pts)
# ============================================================================
evaluate_q20() {
    local w=6; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    if kubectl get networkpolicy np1 -n venus &>/dev/null; then
        score=$((score + 2))

        # Check policy has egress rules
        local egress
        egress=$(kubectl get networkpolicy np1 -n venus -o jsonpath='{.spec.egress}' 2>/dev/null)
        [[ -n "$egress" ]] && score=$((score + 2))

        # Check it targets frontend
        local pod_selector
        pod_selector=$(kubectl get networkpolicy np1 -n venus -o jsonpath='{.spec.podSelector}' 2>/dev/null)
        [[ "$pod_selector" == *"frontend"* ]] && score=$((score + 1))

        # Check DNS port exception
        [[ "$egress" == *"53"* ]] && score=$((score + 1))
    fi

    if [[ $score -eq $w ]]; then
        pass "Q20" $w "NetworkPolicy with egress rules and DNS exception"
    elif [[ $score -gt 0 ]]; then
        partial "Q20" $score $w "NetworkPolicy exists but incomplete"
    else
        fail "Q20" "NetworkPolicy np1 not found in venus"
    fi
}

# ============================================================================
# Q21: Requests/Limits + SA (4 pts)
# ============================================================================
evaluate_q21() {
    local w=4; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    if kubectl get deployment neptune-10ab -n neptune &>/dev/null; then
        local replicas
        replicas=$(kubectl get deployment neptune-10ab -n neptune -o jsonpath='{.spec.replicas}' 2>/dev/null)
        [[ "$replicas" == "3" ]] && score=$((score + 1))

        local sa
        sa=$(kubectl get deployment neptune-10ab -n neptune -o jsonpath='{.spec.template.spec.serviceAccountName}' 2>/dev/null)
        [[ "$sa" == "neptune-sa-v2" ]] && score=$((score + 1))

        local mem_request
        mem_request=$(kubectl get deployment neptune-10ab -n neptune -o jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}' 2>/dev/null)
        [[ "$mem_request" == "20Mi" ]] && score=$((score + 1))

        local mem_limit
        mem_limit=$(kubectl get deployment neptune-10ab -n neptune -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}' 2>/dev/null)
        [[ "$mem_limit" == "50Mi" ]] && score=$((score + 1))
    fi

    if [[ $score -eq $w ]]; then
        pass "Q21" $w "Deployment with resources and SA correct"
    elif [[ $score -gt 0 ]]; then
        partial "Q21" $score $w "Deployment exists but incomplete"
    else
        fail "Q21" "Deployment neptune-10ab not found"
    fi
}

# ============================================================================
# Q22: Labels/Annotations (3 pts)
# ============================================================================
evaluate_q22() {
    local w=3; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    # Check pods with type=worker have protected=true
    local workers_labeled
    workers_labeled=$(kubectl get pods -n sun -l type=worker,protected=true --no-headers 2>/dev/null | wc -l)
    [[ $workers_labeled -ge 2 ]] && score=$((score + 1))

    # Check pods with type=runner have protected=true
    local runners_labeled
    runners_labeled=$(kubectl get pods -n sun -l type=runner,protected=true --no-headers 2>/dev/null | wc -l)
    [[ $runners_labeled -ge 2 ]] && score=$((score + 1))

    # Check annotations
    local annotated
    annotated=$(kubectl get pods -n sun -l protected=true -o jsonpath='{range .items[*]}{.metadata.annotations.protected}{"\n"}{end}' 2>/dev/null | grep -c "do not delete this pod" || echo "0")
    [[ $annotated -ge 4 ]] && score=$((score + 1))

    if [[ $score -eq $w ]]; then
        pass "Q22" $w "Labels and annotations correctly applied"
    elif [[ $score -gt 0 ]]; then
        partial "Q22" $score $w "Some labels/annotations applied"
    else
        fail "Q22" "No labels/annotations found"
    fi
}

# ============================================================================
# Preview Q1: Liveness Probe (4 pts)
# ============================================================================
evaluate_pq1() {
    local w=4; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    if kubectl get deployment project-23-api -n pluto &>/dev/null; then
        local probe
        probe=$(kubectl get deployment project-23-api -n pluto -o jsonpath='{.spec.template.spec.containers[0].livenessProbe}' 2>/dev/null)

        if [[ -n "$probe" ]]; then
            score=$((score + 1))
            # Check port 80
            [[ "$probe" == *"80"* ]] && score=$((score + 1))
        fi

        local initial
        initial=$(kubectl get deployment project-23-api -n pluto -o jsonpath='{.spec.template.spec.containers[0].livenessProbe.initialDelaySeconds}' 2>/dev/null)
        [[ "$initial" == "10" ]] && score=$((score + 1))

        local period
        period=$(kubectl get deployment project-23-api -n pluto -o jsonpath='{.spec.template.spec.containers[0].livenessProbe.periodSeconds}' 2>/dev/null)
        [[ "$period" == "15" ]] && score=$((score + 1))
    fi

    # Check saved yaml
    [[ -f "/opt/course/p1/project-23-api-new.yaml" ]] && score=$((score + 0))  # bonus check

    if [[ $score -eq $w ]]; then
        pass "PQ1" $w "Liveness probe configured correctly"
    elif [[ $score -gt 0 ]]; then
        partial "PQ1" $score $w "Liveness probe partially configured"
    else
        fail "PQ1" "No liveness probe found on project-23-api"
    fi
}

# ============================================================================
# Preview Q2: Deployment + Service (5 pts)
# ============================================================================
evaluate_pq2() {
    local w=5; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    # Check Deployment
    if kubectl get deployment sunny -n sun &>/dev/null; then
        local replicas
        replicas=$(kubectl get deployment sunny -n sun -o jsonpath='{.spec.replicas}' 2>/dev/null)
        [[ "$replicas" == "4" ]] && score=$((score + 1))

        local sa
        sa=$(kubectl get deployment sunny -n sun -o jsonpath='{.spec.template.spec.serviceAccountName}' 2>/dev/null)
        [[ "$sa" == "sa-sun-deploy" ]] && score=$((score + 1))
    fi

    # Check Service
    if kubectl get svc sun-srv -n sun &>/dev/null; then
        score=$((score + 1))
        local port
        port=$(kubectl get svc sun-srv -n sun -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)
        [[ "$port" == "9999" ]] && score=$((score + 1))
    fi

    # Check command file
    [[ -f "/opt/course/p2/sunny_status_command.sh" ]] && score=$((score + 1))

    if [[ $score -eq $w ]]; then
        pass "PQ2" $w "Deployment, Service, and command file correct"
    elif [[ $score -gt 0 ]]; then
        partial "PQ2" $score $w "Some requirements met"
    else
        fail "PQ2" "Deployment sunny not found in sun"
    fi
}

# ============================================================================
# Preview Q3: Service fix (3 pts)
# ============================================================================
evaluate_pq3() {
    local w=3; MAX_SCORE=$((MAX_SCORE + w))
    local score=0

    # Check earth-3cc-web readinessProbe is fixed (port 80 instead of 82)
    if kubectl get deployment earth-3cc-web -n earth &>/dev/null; then
        local probe_port
        probe_port=$(kubectl get deployment earth-3cc-web -n earth -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.port}' 2>/dev/null)

        if [[ "$probe_port" == "80" ]]; then
            score=$((score + 2))
        fi

        # Check pods are ready
        local ready
        ready=$(kubectl get deployment earth-3cc-web -n earth -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
        [[ "$ready" -ge 1 ]] && score=$((score + 1))
    fi

    # Check ticket file
    [[ -f "/opt/course/p3/ticket-654.txt" ]] && score=$((score + 0))  # bonus

    if [[ $score -eq $w ]]; then
        pass "PQ3" $w "ReadinessProbe fixed (port 80) and pods running"
    elif [[ $score -gt 0 ]]; then
        partial "PQ3" $score $w "Some fixes applied"
    else
        fail "PQ3" "ReadinessProbe still broken"
    fi
}

# ============================================================================
# Run all evaluations
# ============================================================================
echo -e "${DIM}Evaluating answers...${NC}"
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
evaluate_pq1
evaluate_pq2
evaluate_pq3

# ============================================================================
# Results
# ============================================================================
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗"
echo "║                    EVALUATION RESULTS                         ║"
echo "╚══════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Display per-question results
printf "  ${BOLD}%-8s %-10s %s${NC}\n" "Question" "Status" "Details"
echo "  ──────── ────────── ──────────────────────────────────"

ALL_QUESTIONS=("Q1" "Q2" "Q3" "Q4" "Q5" "Q6" "Q7" "Q8" "Q9" "Q10" "Q11" "Q12" "Q13" "Q14" "Q15" "Q16" "Q17" "Q18" "Q19" "Q20" "Q21" "Q22" "PQ1" "PQ2" "PQ3")

for q in "${ALL_QUESTIONS[@]}"; do
    status="${Q_RESULT[$q]:-SKIP}"
    detail="${Q_DETAIL[$q]:-Not evaluated}"
    color=""

    case "$status" in
        PASS)    color="${GREEN}" ;;
        FAIL)    color="${RED}" ;;
        PARTIAL) color="${YELLOW}" ;;
        SKIP)    color="${DIM}" ;;
    esac

    printf "  ${color}%-8s %-10s %s${NC}\n" "$q" "$status" "$detail"
done

echo ""
echo "  ──────── ────────── ──────────────────────────────────"
echo ""

# Calculate percentage
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
    echo "║          CONGRATULATIONS! You passed the CKAD exam!          ║"
    echo "╚══════════════════════════════════════════════════════════════════╝${NC}"
else
    echo -e "${YELLOW}Keep practicing! Focus on the failed questions and try again.${NC}"
    echo -e "${YELLOW}Tip: Run ./cleanup-ckad-env.sh && ./setup-ckad-env.sh to reset.${NC}"
fi
echo ""
