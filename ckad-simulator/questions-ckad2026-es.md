# CKAD 2026 Preguntas de Práctica del Examen Real

> **25 preguntas** basadas en temas confirmados por la comunidad (Reddit r/ckad) como presentes
> en el examen real CKAD 2026. Alineado con Kubernetes v1.35.
>
> Fuentes: aravind4799/CKAD-Practice-Questions, vloidcloudtech/ckad-labs,
> TiPunchLabs/ckad-dojo, manik-singhal/CKAD-2025, dgkanatsios/CKAD-exercises,
> experiencias de la comunidad Reddit r/ckad (u/jorotg 90%, u/Last_Tomato_2818 74%).
>
> **Total: 127 puntos | Aprobación: 66% (84 puntos) | Tiempo: 2 horas**

---

## Pregunta 1 | Crear Secret desde Variables Hardcodeadas (6 pts)

En el namespace `ckad-secrets`, el Deployment `api-server` existe con variables de entorno hardcodeadas:

- `DB_USER=admin`
- `DB_PASS=S3cretP@ss!`

Tu tarea:

1. Crear un Secret llamado `db-credentials` en el namespace `ckad-secrets` con estas credenciales
2. Actualizar el Deployment `api-server` para usar el Secret via `valueFrom.secretKeyRef` en lugar de los valores hardcodeados
3. **No** cambiar el nombre del Deployment, namespace, o número de réplicas
4. Verificar que el Deployment se despliega correctamente con `kubectl rollout status`

> **Docs:** https://kubernetes.io/docs/concepts/configuration/secret/

---

## Pregunta 2 | Crear CronJob con Horario y Límites (5 pts)

Crear un CronJob llamado `log-cleaner` en el namespace `ckad-cronjob` con las siguientes especificaciones:

- **Horario:** Cada 30 minutos
- **Imagen:** `busybox:1.36`
- **Nombre del contenedor:** `cleaner`
- **Comando:** `echo "Log cleanup completed at $(date)"`
- **completions:** `2`
- **backoffLimit:** `3`
- **activeDeadlineSeconds:** `30`
- **restartPolicy:** `Never`

Verificar la ejecución creando un Job manualmente desde el CronJob:

    kubectl create job log-cleaner-test --from=cronjob/log-cleaner -n ckad-cronjob

> **Docs:** https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/

---

## Pregunta 3 | ServiceAccount, Role y RoleBinding (7 pts)

En el namespace `ckad-rbac`, el Pod `log-collector` existe pero está fallando con errores de autorización.

Revisa los logs del Pod para entender el problema:

    kubectl logs -n ckad-rbac log-collector

Los logs muestran: `User "system:serviceaccount:ckad-rbac:default" cannot list resource "pods" in namespace "ckad-rbac"`

Tu tarea:

1. Crear un ServiceAccount llamado `log-sa` en namespace `ckad-rbac`
2. Crear un Role llamado `log-role` en namespace `ckad-rbac` que otorgue `get`, `list` y `watch` sobre el recurso `pods`
3. Crear un RoleBinding llamado `log-rb` en namespace `ckad-rbac` vinculando `log-role` a `log-sa`
4. Actualizar el Pod `log-collector` para usar el ServiceAccount `log-sa` (eliminar y recrear si es necesario)

> **Docs:** https://kubernetes.io/docs/reference/access-authn-authz/rbac/

---

## Pregunta 4 | Canary Deployment (6 pts)

En el namespace `ckad-canary`, existen los siguientes recursos:

- Deployment `webapp-stable` con 4 réplicas, labels `app=webapp, version=v1`, imagen `nginx:1.24`
- Service `webapp-svc` con selector `app=webapp`

Tu tarea:

1. Crear un nuevo Deployment llamado `webapp-canary` en namespace `ckad-canary` con:
   - **1 réplica**
   - Labels en los pods: `app=webapp, version=v2`
   - Imagen: `nginx:1.25`
2. Ambos Deployments deben ser seleccionados por el Service `webapp-svc` (split de tráfico ~80/20)
3. Verificar que ambas versiones aparecen en los endpoints del Service

> **Nota:** Este es un patrón manual de canary donde el tráfico se divide basado en la cantidad de réplicas. NO uses Ingress, Service Mesh, o load balancers externos.

> **Docs:** https://kubernetes.io/docs/concepts/workloads/controllers/deployment/

---

## Pregunta 5 | Corregir NetworkPolicy Actualizando Labels de Pods (5 pts)

En el namespace `ckad-netpol`, existen tres Pods:

- `frontend` con label `role=wrong-frontend`
- `backend` con label `role=wrong-backend`
- `database` con label `role=wrong-db`

También existen tres NetworkPolicies:

- `deny-all` (deniega todo el ingress por defecto)
- `allow-frontend-to-backend` (permite ingress a pods con `role=backend` desde pods con `role=frontend`)
- `allow-backend-to-db` (permite ingress a pods con `role=db` desde pods con `role=backend`)

Tu tarea: Actualizar los labels de los Pods (NO modifiques las NetworkPolicies) para habilitar la cadena de comunicación:
`frontend` → `backend` → `database`

> **Tip para ahorrar tiempo:** Usa `kubectl label pod <nombre> role=<valor> --overwrite -n ckad-netpol`

> **Docs:** https://kubernetes.io/docs/concepts/services-networking/network-policies/

---

## Pregunta 6 | Corregir YAML Roto de Deployment (4 pts)

El archivo `/opt/course/e6/broken-deploy.yaml` contiene un manifiesto de Deployment que falla al aplicar.

El archivo tiene los siguientes problemas:

1. Usa la versión de API deprecada `extensions/v1beta1`
2. Falta el campo requerido `selector`
3. No tiene namespace configurado

Tu tarea:

1. Corregir el archivo YAML:
   - Usar `apiVersion: apps/v1`
   - Agregar un `spec.selector.matchLabels` que coincida con los labels del template
   - Establecer namespace a `default`
2. Aplicar el manifiesto corregido
3. Verificar que el Deployment está corriendo con `kubectl rollout status`

> **Docs:** https://kubernetes.io/docs/concepts/workloads/controllers/deployment/

---

## Pregunta 7 | Rolling Update con Estrategia + Rollback (5 pts)

En el namespace `ckad-rollout`, el Deployment `web-app` existe con imagen `nginx:1.24` y 4 réplicas.

Tu tarea:

1. Actualizar la estrategia del Deployment a:
   - `maxSurge: 1`
   - `maxUnavailable: 0`
2. Realizar un rolling update cambiando la imagen a `nginx:1.25`
3. Registrar la causa del cambio: `"update to nginx 1.25"`
4. Verificar que el rollout se completa exitosamente
5. Luego hacer rollback a la revisión anterior
6. Verificar el rollback comprobando que la imagen es `nginx:1.24` de nuevo

> **Docs:** https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#rolling-update-deployment

---

## Pregunta 8 | Agregar Readiness Probe al Deployment (4 pts)

En el namespace `ckad-probes`, el Deployment `api-deploy` existe con un contenedor llamado `api` escuchando en el puerto `80`.

Tu tarea: Agregar un **readinessProbe** al Deployment con:

- **Tipo de probe:** HTTP GET
- **Path:** `/ready`
- **Puerto:** `80`
- **initialDelaySeconds:** `5`
- **periodSeconds:** `10`

No modifiques ningún otro setting. Asegúrate que el Deployment se despliega exitosamente.

> **Docs:** https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/

---

## Pregunta 9 | SecurityContext: runAsUser + Capabilities (5 pts)

En el namespace `ckad-security`, el Deployment `secure-app` existe sin ningún security context.

El archivo del manifiesto está disponible en `/opt/course/e9/secure-app.yaml`.

Tu tarea:

1. Establecer `runAsUser: 30000` a nivel de Pod
2. Establecer `allowPrivilegeEscalation: false` a nivel de contenedor
3. Agregar la capability `NET_ADMIN` a nivel de contenedor
4. Aplicar el manifiesto actualizado
5. Guardar el YAML actualizado en `/opt/course/e9/secure-app-updated.yaml`

> **Nota:** Las capabilities y `allowPrivilegeEscalation` se configuran a nivel de contenedor, no a nivel de Pod.

> **Docs:** https://kubernetes.io/docs/tasks/configure-pod-container/security-context/

---

## Pregunta 10 | Crear Recurso Ingress (5 pts)

En el namespace `ckad-ingress`, existen los siguientes recursos:

- Deployment `web-deploy` con Pods etiquetados `app=web`
- Service `web-svc` con selector `app=web` en puerto `8080`

Tu tarea: Crear un Ingress llamado `web-ingress` en namespace `ckad-ingress` que:

- Enrute el host `web.example.com`
- Path `/` con `pathType: Prefix`
- Backend Service `web-svc` en puerto `8080`
- Use la API version `networking.k8s.io/v1`

> **Docs:** https://kubernetes.io/docs/concepts/services-networking/ingress/

---

## Pregunta 11 | Corregir PathType de Ingress (3 pts)

El archivo `/opt/course/e11/fix-ingress.yaml` contiene un manifiesto de Ingress que falla al aplicar debido a un valor inválido de `pathType`.

Tu tarea:

1. Intentar aplicar el archivo y observar el error
2. Corregir el `pathType` a un valor válido (opciones válidas: `Prefix`, `Exact`, o `ImplementationSpecific`)
3. Asegurar que el Ingress enruta el path `/api` al Service `api-svc` en puerto `8080`
4. Aplicar el manifiesto corregido en namespace `ckad-ingress`

> **Docs:** https://kubernetes.io/docs/concepts/services-networking/ingress/#path-types

---

## Pregunta 12 | ResourceQuota - Crear Pod con Limits (5 pts)

En el namespace `ckad-quota`, existe un ResourceQuota llamado `compute-quota` que establece límites de recursos para el namespace.

Tu tarea:

1. Revisar el ResourceQuota para ver los límites establecidos: `kubectl describe quota compute-quota -n ckad-quota`
2. Crear un Pod llamado `resource-pod` en namespace `ckad-quota` con:
   - **Imagen:** `nginx:1.25`
   - **Nombre del contenedor:** `web`
   - Establecer los **limits** de CPU y memoria a exactamente **la mitad** de los limits del quota
   - Establecer request de CPU a `100m` y request de memoria a `128Mi`

> **Docs:** https://kubernetes.io/docs/concepts/policy/resource-quotas/

---

## Pregunta 13 | Escalar Deployment + Agregar Label + NodePort Service (6 pts)

En el namespace `ckad-scale`, el Deployment `frontend-deploy` ya existe con 2 réplicas.

Tu tarea:

1. Agregar el label `func=webFrontEnd` al template de Pod del Deployment
2. Escalar el Deployment a **4 réplicas**
3. Crear un Service NodePort llamado `frontend-svc` en namespace `ckad-scale` que:
   - Tipo: `NodePort`
   - Exponga el servicio en TCP port `8080`
   - Se mapee a los Pods de `frontend-deploy`

> **Docs:** https://kubernetes.io/docs/concepts/services-networking/service/#nodeport

---

## Pregunta 14 | Logs de Pod + Troubleshooting de Métricas (4 pts)

**Tarea 1:**

Despliega el Pod usando el archivo spec en `/opt/course/e14/logger-pod.yaml` en namespace `ckad-logs`.

Obtén todos los logs disponibles del Pod en ejecución y guárdalos en el archivo `/opt/course/e14/pod-logs.txt`.

**Tarea 2:**

En el namespace `ckad-logs`, varios Pods están corriendo. Encuentra el Pod que consume **más CPU** usando `kubectl top` y escribe **solo el nombre del Pod** en `/opt/course/e14/top-pod.txt`.

> **Docs:** https://kubernetes.io/docs/reference/kubectl/generated/kubectl_logs/

---

## Pregunta 15 | API Deprecation - Corregir Manifiesto HPA (4 pts)

Un equipo intenta aplicar el manifiesto HPA en `/opt/course/e15/ckad-hpa.yaml`, que fue originalmente creado en un cluster de Kubernetes más antiguo.

Tu tarea:

1. Identificar la versión correcta de API que debe usarse para HorizontalPodAutoscaler en Kubernetes v1.35
2. Actualizar el manifiesto para usar el `apiVersion` correcto
3. Aplicar el manifiesto corregido en namespace `ckad-api`
4. Verificar que el HPA fue creado exitosamente

> **Pista:** Usa `kubectl api-resources | grep -i horizontalpodautoscaler` para encontrar el grupo y versión correctos de la API.

> **Docs:** https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/

---

## Pregunta 16 | Reanudar Rollout de Deployment Pausado (4 pts)

En el namespace `ckad-resume`, el Deployment `web-paused` está actualmente **pausado** y tiene la imagen `nginx:1.24`.

Tu tarea:

1. Actualizar la imagen del Deployment a `nginx:1.25`
2. Observar que `kubectl rollout status` no muestra progreso (el Deployment está pausado)
3. Reanudar el rollout del Deployment usando `kubectl rollout resume`
4. Verificar que el rollout se completa y la nueva imagen está corriendo

> **Docs:** https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#pausing-and-resuming-a-rollout

---

## Pregunta 17 | Construir Imagen de Contenedor y Guardar como Tarball (6 pts)

> **Fuente:** aravind4799 Q05, vloidcloudtech Q05, TiPunchLabs Dojo Amaterasu Q1.
> Este tipo de pregunta apareció **DOS VECES** en el examen real (Reddit u/Last_Tomato_2818).

En el nodo, el directorio `/opt/course/e17/image/` contiene un `Dockerfile` válido y un archivo `index.html`.

Tu tarea:

1. Construir una imagen de contenedor usando Docker (o Podman) con el nombre **`web-app:1.0`** usando `/opt/course/e17/image/` como contexto de build
2. Guardar la imagen como tarball en **`/opt/course/e17/web-app.tar`**

**Referencia de comandos:**
```bash
# Build
docker build -t web-app:1.0 /opt/course/e17/image/
# Save
docker save -o /opt/course/e17/web-app.tar web-app:1.0
```

> **Nota:** El examen real puede usar Podman en lugar de Docker. Los comandos son casi idénticos.

> **Docs:** https://docs.docker.com/reference/cli/docker/image/build/

---

## Pregunta 18 | Construir Segunda Imagen y Guardar como Archivo OCI (5 pts)

> **Fuente:** Reddit u/Last_Tomato_2818: "Docker/Podman apareció dos veces. Te dan el nombre y versión de la imagen."

En el nodo, el directorio `/opt/course/e18/image/` contiene un `Dockerfile` para una aplicación API.

Tu tarea:

1. Construir una imagen con nombre **`api-service`** y tag **`2.5`** usando `/opt/course/e18/image/` como contexto
2. Guardar la imagen como tarball en formato **OCI** en **`/opt/course/e18/api-service.tar`**

**Comando de Podman para OCI (referencia):**
```bash
podman save --format oci-archive -o /opt/course/e18/api-service.tar api-service:2.5
```

> **Docs:** https://docs.docker.com/reference/cli/docker/image/save/

---

## Pregunta 19 | Corregir Pod con ServiceAccount Incorrecto (5 pts)

> **Fuente:** aravind4799 Q04, vloidcloudtech Q04. Reddit confirma que RBAC apareció dos veces.

En el namespace `ckad-sa-fix`, el Pod `metrics-pod` usa el ServiceAccount `wrong-sa` y recibe errores de autorización.

Existen múltiples ServiceAccounts, Roles y RoleBindings en el namespace:

- **ServiceAccounts:** `monitor-sa`, `wrong-sa`, `admin-sa`
- **Roles:** `metrics-reader`, `full-access`, `view-only`
- **RoleBindings:** `monitor-binding`, `admin-binding`

Tu tarea:

1. Investigar los Roles y RoleBindings existentes para encontrar qué ServiceAccount tiene los permisos correctos para leer pods
2. Actualizar el Pod `metrics-pod` para usar el ServiceAccount correcto (eliminar y recrear)
3. Verificar que el Pod deja de mostrar errores de autorización

**Pista:** Usa `kubectl describe rolebinding -n ckad-sa-fix` para ver qué SA está vinculada a qué Role.

> **Docs:** https://kubernetes.io/docs/concepts/security/service-accounts/

---

## Pregunta 20 | Corregir Selector de Service Incorrecto (4 pts)

> **Fuente:** aravind4799 Q12, vloidcloudtech Q12, TiPunchLabs Dojo Oni Q9.

En el namespace `ckad-svc-fix`, el Deployment `web-app` existe con Pods etiquetados `app=webapp, tier=frontend`.

El Service `web-svc` existe pero tiene un selector incorrecto `app=wrongapp`. El tráfico no llega a los Pods.

Tu tarea:

1. Identificar el desajuste: `kubectl get endpoints web-svc -n ckad-svc-fix` (muestra `<none>`)
2. Corregir el selector del Service para que coincida con las labels de los Pods
3. Verificar con `kubectl get endpoints web-svc -n ckad-svc-fix` (debe mostrar IPs de los Pods)

> **Docs:** https://kubernetes.io/docs/concepts/services-networking/service/

---

## Pregunta 21 | CronJob con Límites de Historial (5 pts)

> **Fuente:** vloidcloudtech Q02, Reddit u/Last_Tomato_2818: "Usa .spec.successfulJobsHistoryLimit y .spec.failedJobsHistoryLimit"
> **Nota:** Esta es la versión que coincide con el examen real. Nuestra Q2 usa completions/backoffLimit — esta usa historyLimits.

Crear un CronJob llamado `backup-job` en el namespace `ckad-cronjob2` con las siguientes especificaciones:

- **Schedule:** Cada 30 minutos (`*/30 * * * *`)
- **Imagen:** `busybox:1.36`
- **Nombre del contenedor:** `backup`
- **Comando:** `echo "Backup completed at $(date)"`
- **successfulJobsHistoryLimit:** `3`
- **failedJobsHistoryLimit:** `2`
- **activeDeadlineSeconds:** `300`
- **restartPolicy:** `Never`

> **Tip:** Usa `kubectl explain cronjob.spec` para encontrar las ubicaciones correctas de los campos.

> **Docs:** https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/

---

## Pregunta 22 | Requests y Limits de Recursos desde el Máximo del Namespace (5 pts)

> **Fuente:** Reddit u/Last_Tomato_2818: "Te dan el memory request. Para limits, dicen la mitad del máximo del namespace. Ejecuta kubectl describe namespace dev para obtener el MAX, luego calcula la mitad."

En el namespace `ckad-resources`, existe un LimitRange llamado `resource-limits` que establece valores predeterminados y máximos de recursos.

Tu tarea:

1. Inspeccionar los límites del namespace: `kubectl describe limitrange resource-limits -n ckad-resources`
2. Crear un Pod llamado `resource-pod` en el namespace `ckad-resources` con:
   - **Imagen:** `nginx:1.25`
   - **Nombre del contenedor:** `web`
   - **Memory request:** `128Mi`
   - **CPU request:** `100m`
   - **Memory limit:** exactamente la **mitad** del límite máximo de memoria
   - **CPU limit:** exactamente la **mitad** del límite máximo de CPU

> **Docs:** https://kubernetes.io/docs/concepts/policy/limit-range/

---

## Pregunta 23 | Crear NetworkPolicy con Ingress Y Egress (6 pts)

> **Fuente:** Reddit u/Last_Tomato_2818: "Pregunta simple: podSelector con ingress y egress para dos pods."

En el namespace `ckad-netpol2`, existen dos Pods:

- `api-pod` con label `app=api`
- `db-pod` con label `app=database`

Crear una NetworkPolicy llamada `api-netpol` en el namespace `ckad-netpol2` que:

1. **Se aplique a** pods con label `app=api` (podSelector)
2. **Permita ingress** en el puerto `80` (TCP) **solo desde** pods con label `app=frontend`
3. **Permita egress** en el puerto `5432` (TCP) **solo hacia** pods con label `app=database`

> **Importante:** La política debe restringir tanto ingress como egress. Los pods que no coincidan con los selectores deben ser denegados.

> **Docs:** https://kubernetes.io/docs/concepts/services-networking/network-policies/

---

## Pregunta 24 | Job con Completions y Parallelism (5 pts)

> **Fuente:** TiPunchLabs Dojo Oni Q18. Los Jobs aparecen regularmente en el examen CKAD.

Crear un Job llamado `batch-processor` en el namespace `ckad-jobs` con:

- **Imagen:** `busybox:1.36`
- **Nombre del contenedor:** `processor`
- **Comando:** `echo "Processing batch item"`
- **completions:** `6` (6 items totales a procesar)
- **parallelism:** `2` (2 items procesados a la vez)
- **restartPolicy:** `Never`
- **backoffLimit:** `4`

Esperar a que el Job se complete y verificar que los 6 pods se ejecutaron correctamente.

> **Docs:** https://kubernetes.io/docs/concepts/workloads/controllers/job/

---

## Pregunta 25 | Corregir Deployment que Excede ResourceQuota del Namespace (5 pts)

> **Fuente:** TiPunchLabs Dojo Oni Q6, Reddit: "Los recursos del deployment deben coincidir con los recursos del namespace."

En el namespace `ckad-quota-fix`, existe un ResourceQuota llamado `compute-quota` y un Deployment llamado `quota-app` tiene los Pods en estado **Pending** porque sus requests de recursos exceden la quota del namespace.

Tu tarea:

1. Inspeccionar el ResourceQuota: `kubectl describe quota compute-quota -n ckad-quota-fix`
2. Inspeccionar los recursos actuales del Deployment: `kubectl get deploy quota-app -n ckad-quota-fix -o yaml`
3. Reducir los **requests** de recursos del Deployment para que los Pods puedan ser programados dentro de la quota
4. Mantener los **limits** al **doble** de los requests
5. Asegurar que el Deployment tenga Pods corriendo después de la corrección

> **Pista:** La quota permite `requests.cpu: 500m`, `requests.memory: 512Mi`. Ajusta el Deployment en consecuencia.

> **Docs:** https://kubernetes.io/docs/concepts/policy/resource-quotas/

---

## Tips para el Examen Real de CKAD

> Estos tips provienen directamente de usuarios de Reddit que aprobaron el examen CKAD (u/jorotg 90%, u/Last_Tomato_2818 74%).

- **Usa comandos imperativos** siempre que sea posible: `kubectl create`, `kubectl expose`, `kubectl run`, `kubectl set image`
- **Usa `--dry-run=client -o yaml`** para generar YAML y luego modificarlo
- **Siempre verifica el rollout status** después de modificar Deployments: `kubectl rollout status deploy/<nombre>`
- **Si rollout status muestra "Waiting..."** y estás seguro de que tu trabajo es correcto: intenta `kubectl rollout resume deployment <name>` — ¡esto les ahorró a varios usuarios de Reddit más de 10 minutos!
- **Usa `kubectl apply`**, NO `kubectl replace --force` para preguntas de rollout (replace causa problemas con el historial de rollback)
- **Usa `kubectl label`** para agregar/cambiar labels rápidamente en lugar de editar YAML
- **Atajos de vim**: `:set nu` (números de línea), `dd` (borrar línea), `yy` (copiar), `p` (pegar), `shift+v` (seleccionar líneas)
- **Usa `#`** antes de un comando para guardarlo en historial sin ejecutarlo
- **Cambiar namespace**: `kubectl config set-context --current --namespace=<ns>` o usa `-n <ns>`
- **Siempre agrega el namespace** — olvidar `-n <namespace>` es una pérdida común de puntos
- **Comandos Docker/Podman son casi idénticos**: `docker build` = `podman build`, `docker save` = `podman save`
- **Lee TODA la pregunta** — a veces detalles críticos están en la última oración
- **Marca preguntas difíciles** y regresa después cuando estés menos estresado
- **Después de editar un Deployment**, verifica: ¿Pods corriendo? ¿Service tiene endpoints? ¿rollout status exitoso?
- **Saber buscar en docs de k8s**: Ingress, NetworkPolicy, CronJob, RBAC, SecurityContext, ResourceQuota
- **Lo que NO viene en el examen** (según Reddit 2026): Helm, PV/PVC, ConfigMaps, Init Containers, Sidecar Containers, CRDs, Kustomize
