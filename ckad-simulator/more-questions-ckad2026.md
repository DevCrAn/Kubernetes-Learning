# 🎯 CKAD — Temario Completo + Preguntas Estilo Examen Real (Kubernetes v1.35)

> **Deep research compilado de:** Reddit r/ckad, foros chinos (CSDN, Zhihu, 腾讯云), Medium, GitHub repos de candidatos que pasaron el examen (2025–2026), blog.ljh.cool (preguntas compartidas por comunidad china), GitHub `theplatformlab/CKAD-Certified-Kubernetes-Application-Developer` (aprobado con 91%, marzo 2026).

---

## ⚠️ INFORMACIÓN CRÍTICA — Versión actual

| Detalle | Valor |
|---|---|
| **Versión Kubernetes en el examen** | **v1.35** (confirmado por Linux Foundation, vigente desde 2026) |
| **Duración** | 2 horas |
| **Puntaje para pasar** | 66% |
| **Número de preguntas** | ~15–20 tareas de performance |
| **Entorno** | PSI Secure Browser — terminal remota Linux |
| **Documentación permitida** | kubernetes.io/docs, kubernetes.io/blog, github.com/kubernetes |
| **Formato** | 100% hands-on en terminal. Sin opción múltiple. |
| **Intentos incluidos** | 2 (incluye 1 retake gratis) |
| **Simuladores incluidos** | 2 sesiones de killer.sh (cada una válida 36h) |

> **Si lo hiciste en v1.33, los cambios clave en v1.35 son:**
> - Sidecar containers ahora GA (usan `restartPolicy: Always` en `initContainers`)
> - In-Place Pod Vertical Scaling (GA) — resize CPU/memory sin reiniciar pod
> - Ingress NGINX **retirado** (archivado marzo 2026) → Gateway API es el estándar
> - `HTTPRoute` es el recurso principal en Gateway API v1.4+
> - cgroup v1 eliminado; se requiere cgroup v2

---

## 📊 Pesos del Examen (v1.35)

| Dominio | Peso |
|---|---|
| Application Environment, Configuration & Security | **25%** |
| Application Design and Build | **20%** |
| Application Deployment | **20%** |
| Services and Networking | **20%** |
| Application Observability and Maintenance | **15%** |

> **Estrategia:** App Environment + cualquiera de los dominios de 20% = 45% del examen. Prioriza esos.

---e

## 🔑 Primeros 60 segundos del examen (memorizar)

```bash
# Ejecutar ANTES de tocar la pregunta 1
alias k=kubectl
export do='--dry-run=client -o yaml'
export now='--force --grace-period=0'
source <(kubectl completion bash)
complete -F __start_kubectl k

# Configurar vim para YAML (crítico)
cat << 'EOF' >> ~/.vimrc
set expandtab
set tabstop=2
set shiftwidth=2
set number
EOF
```

> **SIEMPRE** ejecutar el comando de cambio de contexto al inicio de CADA pregunta:
> ```bash
> kubectl config use-context <nombre-contexto>
> ```

---

## 📝 PREGUNTAS ESTILO EXAMEN REAL

> Las preguntas del CKAD inician con un bloque de contexto (`Quick Reference`) y describen el escenario sin decirte exactamente qué comandos ejecutar. El formato a continuación replica exactamente eso.

---

### DOMINIO 1 — Application Design and Build (20%)

---

#### Pregunta 1 — CronJob con historial y límite de tiempo
```
╔══════════════════════════════════════════════════════════════════╗
║  Quick Reference                                                 ║
║  Cluster/Contexto: k8s                                           ║
║  Namespace:        default                                        ║
╚══════════════════════════════════════════════════════════════════╝

Contexto:
Debes configurar una tarea periódica de cómputo matemático que se
ejecute de forma regular y tenga límites de tiempo bien definidos.

Tarea:
1. Crea un CronJob llamado ppi que ejecute un único contenedor con
   las siguientes especificaciones:
   - Nombre del contenedor: pi
   - Imagen: perl:5
   - Comando: ["perl", "-Mbignum=bpi", "-wle", "print bpi(2000)"]
   
   Configura el CronJob para que:
   • Se ejecute cada 5 minutos
   • Conserve 2 Jobs completados exitosamente
   • Conserve 4 Jobs fallidos
   • Nunca reinicie el Pod
   • Termine el Pod después de 8 segundos

2. Para propósitos de prueba, crea y ejecuta manualmente un Job
   llamado ppi-test a partir del CronJob ppi.

[Fuente: Blog comunidad china ljh.cool — pregunta real del examen]
```

---

#### Pregunta 2 — CronJob con manifiesto en archivo
```
╔══════════════════════════════════════════════════════════════════╗
║  Quick Reference                                                ║
║  Cluster/Contexto: k8s                                         ║
║  Namespace:        default                                      ║
╚══════════════════════════════════════════════════════════════════╝

Contexto:
El equipo de plataforma necesita que una tarea programada quede
definida en un manifiesto para control de versiones.

Tarea:
1. Define el Pod en el archivo de manifiesto 
   /ckad/CKAD00016/periodic.yaml

2. En un contenedor busybox:stable ejecuta el comando date.
   El comando debe ejecutarse cada minuto y debe completarse
   dentro de 10 segundos, o Kubernetes lo terminará.
   
   Nota: Tanto el nombre del CronJob como el del contenedor deben
   ser hello.

3. Crea el recurso a partir del manifiesto anterior y verifica que
   el Job haya sido ejecutado exitosamente al menos una vez.

[Fuente: ljh.cool — pregunta compartida por comunidad china]
```

---

#### Pregunta 3 — Dockerfile: construir y exportar imagen OCI
```
╔══════════════════════════════════════════════════════════════════╗
║  Quick Reference                                                ║
║  (Sin restricción de namespace — tarea de contenedor)          ║
╚══════════════════════════════════════════════════════════════════╝

Contexto:
El equipo de infraestructura ya creó un Dockerfile. Debes construir
la imagen y exportarla en formato OCI para distribución.

Tarea:
Un Dockerfile ya existe en /ckad/DF/Dockerfile.

1. Usando el Dockerfile existente, construye una imagen de contenedor
   con nombre centos y tag 8.2. Puedes usar la herramienta de tu
   elección (docker, podman).

2. Usando tu herramienta preferida, exporta la imagen construida en
   formato OCI y guárdala en /ckad/DF/centos-8.2.tar

[Fuente: ljh.cool — pregunta real del examen]
```

---

#### Pregunta 4 — Pod con múltiples contenedores y patrón sidecar
```
╔══════════════════════════════════════════════════════════════════╗
║  Quick Reference                                                ║
║  Cluster/Contexto: k8s                                         ║
║  Namespace:        default                                      ║
╚══════════════════════════════════════════════════════════════════╝

Contexto:
Tu equipo de observabilidad necesita que los logs de un servidor web
sean procesados en tiempo real por un contenedor auxiliar usando el
patrón sidecar.

Tarea:
Crea un Deployment llamado deploymenb-web en el namespace default
con las siguientes especificaciones:

• Contenedor principal:
  - Nombre: logger-123
  - Imagen: lfccncf/busybox:1
  - Ejecuta el siguiente loop infinito que escribe en un log compartido:
    while true; do echo "i luv cncf" >> /ckad/log/input.log; sleep 10; done

• Contenedor sidecar:
  - Nombre: adaptor-dev  
  - Imagen: lfccncf/fluentd:v0.12
  - Lee /ckad/log/input.log y escribe en /ckad/log/output.* en formato JSON

• Ambos contenedores deben compartir un volumen montado en /ckad/log
• Cuando el Pod sea eliminado, el volumen no debe persistir

Nota: No necesitas conocer Fluentd en detalle. La especificación
necesaria se encuentra en /ckad/KDMC00102/fluentd-configmap.yaml.
Crea el ConfigMap desde ese archivo y móntalo en adaptor-dev en
/fluentd/etc

[Fuente: ljh.cool — pregunta real del examen, también en premiumdumps.com]
```

---

#### Pregunta 5 — Multi-container Pod con init container
```
╔══════════════════════════════════════════════════════════════════╗
║  Quick Reference                                                ║
║  Cluster/Contexto: k8s-cluster2                                ║
║  Namespace:        frontend                                     ║
╚══════════════════════════════════════════════════════════════════╝

Contexto:
El equipo de frontend necesita que el servidor web sirva contenido
personalizado que es preparado por un proceso de inicialización
antes de que el servidor arranque.

Tarea:
Crea un Pod llamado web-app en el namespace frontend con:

• Un init container llamado init-config que:
  - Use imagen busybox
  - Cree el archivo /work-dir/index.html con el contenido:
    <h1>Hello CKAD</h1>

• Un contenedor principal llamado nginx que:
  - Use imagen nginx
  - Monte el mismo volumen en /usr/share/nginx/html

• Usa un volumen emptyDir llamado html compartido entre ambos
  contenedores

[Fuente: theplatformlab/CKAD-Certified-Kubernetes-Application-Developer]
```

---

#### Pregunta 6 — PV, PVC y Pod con almacenamiento persistente
```
╔══════════════════════════════════════════════════════════════════╗
║  Quick Reference                                                ║
║  Cluster/Contexto: k8s                                         ║
║  Namespace:        default                                      ║
╚══════════════════════════════════════════════════════════════════╝

Contexto:
El equipo de almacenamiento necesita aprovisionar volúmenes
persistentes para la aplicación de logging.

Tarea:
1. En el nodo node02, crea el archivo:
   /opt/KDSP00101/data/index.html
   Con el contenido: WEPKEY=7789

2. Crea un PersistentVolume llamado task-pv-volume con:
   - Capacidad: 2Gi
   - hostPath: /opt/KDSP00101/data
   - Modo de acceso: ReadWriteOnce
   - StorageClass: keys

3. Crea un PersistentVolumeClaim llamado task-pv-claim que:
   - Solicite 200Mi de capacidad
   - Use modo de acceso ReadWriteOnce
   - Use StorageClass: keys

4. Crea un Pod que:
   - Use el PVC como volumen
   - Tenga el label app: my-storage-app
   - Monte el volumen en /usr/share/nginx/html

[Fuente: ljh.cool — pregunta real del examen]
```

---

### DOMINIO 2 — Application Deployment (20%)

---

#### Pregunta 7 — Canary Deployment (Despliegue Canario)
```
╔══════════════════════════════════════════════════════════════════╗
║  Quick Reference                                                ║
║  Cluster/Contexto: k8s                                         ║
║  Namespace:        goshawk                                      ║
╚══════════════════════════════════════════════════════════════════╝

Contexto:
Para probar una nueva versión de la aplicación, el equipo de
plataforma necesita implementar un despliegue canario.

Tarea:
En el namespace goshawk, el Service llamado chipmunk-service
apunta al Deployment current-chipmunk-deployment que actualmente
tiene 5 Pods activos.

El manifiesto de current-chipmunk-deployment se encuentra en
/ckad/goshawk/.

1. En el mismo namespace, crea un Deployment idéntico llamado
   canary-chipmunk-deployment

2. Modifica ambos Deployments de modo que:
   • El número máximo total de Pods en ejecución en el namespace
     goshawk sea 10
   • El 40% del tráfico del Service chipmunk-service vaya hacia
     los Pods del canary-chipmunk-deployment

[Fuente: ljh.cool — pregunta compartida por comunidad china — muy frecuente en examen]
```

---

#### Pregunta 8 — Deployment: actualizar imagen y hacer rollback
```
╔══════════════════════════════════════════════════════════════════╗
║  Quick Reference                                                ║
║  Cluster/Contexto: k8s                                         ║
║  Namespace:        ckad00015                                    ║
╚══════════════════════════════════════════════════════════════════╝

Contexto:
El equipo de operaciones necesita actualizar la aplicación y luego
revertirla a su estado anterior para validar el proceso de rollback.

Tarea:
1. Actualiza la configuración de escalado proporcional del Deployment
   webapp en el namespace ckad00015:
   - maxSurge: 10%
   - maxUnavailable: 4

2. Actualiza el Deployment webapp para que el contenedor use la
   imagen lfccncf/nginx con el tag 1.13.7

3. Realiza un rollback del Deployment webapp a la versión anterior

[Fuente: ljh.cool — pregunta real del examen]
```

---

#### Pregunta 9 — Helm: instalar y actualizar un chart
```
╔══════════════════════════════════════════════════════════════════╗
║  Quick Reference                                                ║
║  Cluster/Contexto: k8s-cluster1                                ║
║  Namespace:        data                                         ║
╚══════════════════════════════════════════════════════════════════╝

Contexto:
El equipo de datos necesita desplegar Redis usando el gestor de
paquetes de Kubernetes.

Tarea:
1. Agrega el repositorio de Helm de Bitnami:
   https://charts.bitnami.com/bitnami

2. Instala una release llamada cache usando el chart bitnami/redis
   en el namespace data (créalo si no existe)

3. Actualiza la release para que replica.replicaCount sea 3

[Fuente: theplatformlab repo — patrón frecuente reportado en Reddit r/ckad]
```

---

#### Pregunta 10 — Arreglar API deprecated en manifiesto
```
╔══════════════════════════════════════════════════════════════════╗
║  Quick Reference                                                ║
║  Cluster/Contexto: k8s                                         ║
║  Namespace:        garfish                                      ║
╚══════════════════════════════════════════════════════════════════╝

Contexto:
Un manifiesto existente fue creado para una versión antigua de
Kubernetes y necesita ser actualizado para ser compatible con el
cluster actual.

Tarea:
1. Arregla cualquier problema de APIs deprecadas en el archivo de
   manifiesto /ckad/credible-mite/www.yaml para que la aplicación
   pueda ser desplegada en el cluster k8s.
   
   Nota: La aplicación fue desarrollada para Kubernetes v1.15.
   El cluster k8s ejecuta Kubernetes v1.24+.

2. Despliega la aplicación actualizada del manifiesto
   /ckad/credible-mite/www.yaml en el namespace garfish.

[Fuente: ljh.cool — pregunta real del examen, API Deprecation muy frecuente]
```

---

### DOMINIO 3 — Application Observability and Maintenance (15%)

---

#### Pregunta 11 — Liveness Probe: identificar y corregir fallo
```
╔══════════════════════════════════════════════════════════════════╗
║  Quick Reference                                                ║
║  Cluster/Contexto: dk8s                                        ║
║  Namespace:        (puede ser cualquiera)                       ║
╚══════════════════════════════════════════════════════════════════╝

Contexto:
Un equipo reporta que no puede acceder a su aplicación. Sospechan
que el problema está relacionado con la configuración de la sonda
de salud del Pod.

Tarea:
1. Identifica el Pod que tiene problemas con su Liveness Probe
   (puede estar en cualquier namespace). Escribe el nombre del Pod
   y su namespace en el archivo /ckad/CKAD00011/broken.txt
   usando el formato: <namespace>/<nombre-pod>

2. Obtén los eventos de error usando kubectl get events y guárdalos
   en /ckad/CKAD00011/error.txt usando el formato de salida wide.

3. Corrige el problema de la Liveness Probe del Pod afectado.

[Fuente: ljh.cool — pregunta real del examen]
```

---

#### Pregunta 12 — Readiness Probe: agregar a deployment existente
```
╔══════════════════════════════════════════════════════════════════╗
║  Quick Reference                                                ║
║  Cluster/Contexto: dk8s                                        ║
║  Namespace:        (el del deployment probe-http)               ║
╚══════════════════════════════════════════════════════════════════╝

Contexto:
El equipo de confiabilidad necesita agregar una sonda de disponibilidad
al deployment existente para que el sistema de balanceo de carga sepa
cuándo el Pod está listo para recibir tráfico.

Tarea:
Modifica el Deployment existente probe-http para agregar una
readinessProbe con las siguientes especificaciones:
• Método de comprobación: httpGet
• Ruta de exploración: /healthz/return200
• Puerto: 80
• Tiempo de espera antes de la primera comprobación: 15 segundos
• Intervalo entre comprobaciones: 20 segundos

[Fuente: ljh.cool — pregunta real del examen]
```

---

#### Pregunta 13 — Logs: extraer y guardar en archivo
```
╔══════════════════════════════════════════════════════════════════╗
║  Quick Reference                                                ║
║  Cluster/Contexto: k8s                                         ║
║  Namespace:        (el del pod foobar)                          ║
╚══════════════════════════════════════════════════════════════════╝

Contexto:
El equipo de soporte necesita recolectar logs del sistema para
análisis forense. Un pod está generando errores que deben ser
documentados.

Tarea:
• Despliega el Pod counter en el cluster usando el archivo YAML
  que se encuentra en /opt/KDOB00201/counter.yaml

• Recupera todos los logs de aplicación actualmente disponibles del
  Pod en ejecución y guárdalos en el archivo
  /opt/KDOB00201/log_Output.txt (el archivo ya existe)

[Fuente: premiumdumps.com — basado en patrones del examen real]
```

---

#### Pregunta 14 — Top Pod: identificar el que consume más CPU
```
╔══════════════════════════════════════════════════════════════════╗
║  Quick Reference                                                ║
║  Cluster/Contexto: k8s                                         ║
║  Namespace:        cpu-stress                                   ║
╚══════════════════════════════════════════════════════════════════╝

Contexto:
El equipo de operaciones necesita identificar el Pod que está
consumiendo más recursos de CPU para diagnosticar un problema
de rendimiento.

Tarea:
• Monitorea los Pods que se ejecutan en el namespace cpu-stress
• Escribe el nombre del Pod que consume la mayor cantidad de CPU
  en el archivo /ckad/CKAD00010/pod.txt

Nota: El archivo /ckad/CKAD00010/pod.txt ya existe.

[Fuente: ljh.cool — pregunta real del examen]
```

---

### DOMINIO 4 — Application Environment, Configuration & Security (25%)

---

#### Pregunta 15 — Límites de CPU y Memoria (básico)
```
╔══════════════════════════════════════════════════════════════════╗
║  Quick Reference                                                ║
║  Cluster/Contexto: k8s                                         ║
║  Namespace:        pod-resources                                ║
╚══════════════════════════════════════════════════════════════════╝

Contexto:
El equipo de plataforma necesita garantizar que los Pods no consuman
más recursos de los necesarios para mantener la estabilidad del
cluster.

Tarea:
En el namespace existente pod-resources, crea un Pod llamado
nginx-resources con las siguientes especificaciones:
• Imagen: nginx:1.16
• Nombre del contenedor: nginx-resources
• Resource request de CPU: 40m
• Resource request de memoria: 50Mi

[Fuente: ljh.cool — pregunta real del examen]
```

---

#### Pregunta 16 — Límites de CPU y Memoria (con LimitRange)
```
╔══════════════════════════════════════════════════════════════════╗
║  Quick Reference                                                ║
║  Cluster/Contexto: k8s                                         ║
║  Namespace:        haddock                                      ║
╚══════════════════════════════════════════════════════════════════╝

Contexto:
El Deployment de una base de datos NoSQL no puede iniciar porque
su contenedor ha agotado los recursos asignados.

Tarea:
El Deployment llamado nosql en el namespace haddock no puede iniciar
porque sus Pods han excedido los recursos disponibles.

Actualiza el Deployment nosql para que sus Pods:
• Soliciten 15Mi de memoria para su contenedor
• Tengan un límite de memoria equivalente a la mitad de la capacidad
  máxima de memoria configurada en el namespace haddock

Puedes encontrar el manifiesto en /ckad/chief-cardinal/nosql.yaml

Pista: Examina el LimitRange del namespace haddock para determinar
el límite máximo de memoria.

[Fuente: ljh.cool — pregunta real del examen]
```

---

#### Pregunta 17 — ConfigMap: crear y montar como volumen
```
╔══════════════════════════════════════════════════════════════════╗
║  Quick Reference                                                ║
║  Cluster/Contexto: k8s                                         ║
║  Namespace:        default                                      ║
╚══════════════════════════════════════════════════════════════════╝

Contexto:
El equipo de configuración necesita externalizar los parámetros de
la aplicación usando mecanismos nativos de Kubernetes.

Tarea:
1. En el namespace default, crea un ConfigMap llamado some-config
   que almacene el siguiente par clave/valor:
   key3: value4

2. En el namespace default, crea un Pod llamado nginx-configmap
   con las siguientes especificaciones:
   • Imagen: nginx:stable
   • El ConfigMap some-config debe ser montado como volumen en la
     ruta /some/path dentro del contenedor

[Fuente: ljh.cool — pregunta real del examen]
```

---

#### Pregunta 18 — Secret: crear y consumir como variable de entorno
```
╔══════════════════════════════════════════════════════════════════╗
║  Quick Reference                                                ║
║  Cluster/Contexto: k8s                                         ║
║  Namespace:        default                                      ║
╚══════════════════════════════════════════════════════════════════╝

Contexto:
La aplicación necesita acceder a credenciales de forma segura sin
exponerlas en el código o en los manifiestos de configuración.

Tarea:
1. En el namespace default, crea un Secret llamado another-secret
   que contenga el siguiente par clave/valor:
   key1: value12

2. En el namespace default, crea un Pod llamado nginx-secret con:
   • Imagen: nginx:1.16
   • Una variable de entorno llamada COOL_VARIABLE cuyo valor
     provenga de la clave key1 del Secret another-secret

[Fuente: ljh.cool — pregunta real del examen]
```

---

#### Pregunta 19 — SecurityContext: runAsUser y allowPrivilegeEscalation
```
╔══════════════════════════════════════════════════════════════════╗
║  Quick Reference                                                ║
║  Cluster/Contexto: k8s                                         ║
║  Namespace:        quetzal                                      ║
╚══════════════════════════════════════════════════════════════════╝

Contexto:
El equipo de seguridad requiere que los contenedores de producción
corran con un usuario no-root y sin capacidades de escalación de
privilegios.

Tarea:
Modifica el Deployment existente llamado broker-deployment en el
namespace quetzal para que su contenedor:
• Se ejecute como el usuario con ID 30000
• No permita la escalación de privilegios

Puedes encontrar el manifiesto en
/ckad/daring-moccasin/broker-deployment.yaml

[Fuente: ljh.cool — pregunta real del examen]
```

---

#### Pregunta 20 — SecurityContext avanzado: capabilities y filesystem
```
╔══════════════════════════════════════════════════════════════════╗
║  Quick Reference                                                ║
║  Cluster/Contexto: k8s-cluster2                                ║
║  Namespace:        restricted                                   ║
╚══════════════════════════════════════════════════════════════════╝

Contexto:
El equipo de seguridad necesita reforzar la postura de seguridad
de los Pods en el namespace de producción restringida.

Tarea:
Crea un Pod llamado secure-app en el namespace restricted con
imagen nginx. Configura el Pod para que:
• Corra como usuario 1000
• Corra con grupo 3000
• El sistema de archivos (fsGroup) use el grupo 2000
• El contenedor no permita escalación de privilegios
• El sistema de archivos raíz del contenedor sea de solo lectura
• El contenedor elimine todas las Linux capabilities

[Fuente: theplatformlab repo — patrón frecuente en killer.sh y examen real]
```

---

#### Pregunta 21 — RBAC: identificar el ServiceAccount correcto
```
╔══════════════════════════════════════════════════════════════════╗
║  Quick Reference                                                ║
║  Cluster/Contexto: k8s                                         ║
║  Namespace:        gorilla                                      ║
╚══════════════════════════════════════════════════════════════════╝

Contexto:
Un Deployment está generando errores de autorización porque el
Pod no tiene los permisos adecuados para interactuar con la API
de Kubernetes.

Tarea:
El Deployment llamado honeybee-deployment y un Pod en el namespace
gorilla están registrando errores. El log muestra el siguiente error:
User "system:serviceaccount:gorilla:default" cannot list resource
"serviceaccounts" [...] in the namespace "gorilla"

1. Examina los logs para identificar el error de autorización

2. Actualiza el Deployment honeybee-deployment para resolver el
   error encontrado en los logs de los Pods.

El manifiesto se encuentra en
/ckad/prompt-escargot/honeybee-deployment.yaml

[Fuente: ljh.cool — pregunta real del examen — patrón RBAC muy frecuente]
```

---

#### Pregunta 22 — RBAC: crear Role y RoleBinding desde cero
```
╔══════════════════════════════════════════════════════════════════╗
║  Quick Reference                                                ║
║  Cluster/Contexto: k8s-cluster1                                ║
║  Namespace:        monitoring                                   ║
╚══════════════════════════════════════════════════════════════════╝

Contexto:
El equipo de monitoreo necesita que su aplicación pueda leer
información de los Pods del cluster sin tener acceso de escritura.

Tarea:
1. Crea un ServiceAccount llamado monitoring-sa en el namespace
   monitoring

2. Crea un Role llamado pod-metrics-reader que otorgue permisos
   de get, list y watch sobre los recursos pods y pods/log

3. Vincula el Role al ServiceAccount usando un RoleBinding llamado
   monitoring-binding

[Fuente: theplatformlab repo — patrón frecuente en examen real]
```

---

#### Pregunta 23 — Deployment con variable de entorno
```
╔══════════════════════════════════════════════════════════════════╗
║  Quick Reference                                                ║
║  Cluster/Contexto: k8s                                         ║
║  Namespace:        ckad00014                                    ║
╚══════════════════════════════════════════════════════════════════╝

Contexto:
El equipo de desarrollo necesita desplegar una API que requiere
configuración a través de variables de entorno.

Tarea:
En el namespace existente ckad00014, crea un Deployment llamado api
con las siguientes especificaciones:
• 6 réplicas de Pods
• Imagen: nginx:1.16
• Agrega una variable de entorno llamada NGINX_PORT con valor 8000
• Expone el puerto 80 del contenedor

[Fuente: ljh.cool — pregunta real del examen]
```

---

#### Pregunta 24 — Deployment: asignar ServiceAccount específico
```
╔══════════════════════════════════════════════════════════════════╗
║  Quick Reference                                                ║
║  Cluster/Contexto: k8s                                         ║
║  Namespace:        frontend                                     ║
╚══════════════════════════════════════════════════════════════════╝

Contexto:
La aplicación frontend necesita usar una identidad específica para
acceder a los recursos del cluster de forma controlada.

Tarea:
Actualiza el Deployment en el namespace frontend para que use el
ServiceAccount existente llamado app.

[Fuente: ljh.cool — pregunta real del examen]
```

---

### DOMINIO 5 — Services and Networking (20%)

---

#### Pregunta 25 — NetworkPolicy: modificar labels del Pod (no la policy)
```
╔══════════════════════════════════════════════════════════════════╗
║  Quick Reference                                                ║
║  Cluster/Contexto: nk8s                                        ║
║  Namespace:        ckad00018                                    ║
╚══════════════════════════════════════════════════════════════════╝

Contexto:
Por razones de seguridad, un Pod recién desplegado solo debe poder
comunicarse con dos Pods específicos y no con el resto.

Tarea:
Actualiza el Pod ckad00018-newpod en el namespace ckad00018 para
que use una NetworkPolicy que solo permita a este Pod enviar y
recibir tráfico hacia y desde los Pods front y db.

Nota importante: Ya existen NetworkPolicies en el namespace.
No debes crear nuevas NetworkPolicies. Debes analizar las políticas
existentes y hacer que el Pod cumpla con los requisitos.

[Fuente: ljh.cool + premiumdumps — pregunta real muy frecuente en el examen]
```

---

#### Pregunta 26 — NetworkPolicy: crear policy de acceso restringido
```
╔══════════════════════════════════════════════════════════════════╗
║  Quick Reference                                                ║
║  Cluster/Contexto: nk8s                                        ║
║  Namespace:        secure                                       ║
╚══════════════════════════════════════════════════════════════════╝

Contexto:
El equipo de seguridad de datos necesita asegurarse de que la base
de datos solo sea accesible desde la capa de API y no desde otros
servicios.

Tarea:
En el namespace secure, crea una NetworkPolicy que permita tráfico
de entrada (ingress) a los Pods con la etiqueta app=db, únicamente
desde Pods con la etiqueta app=api, en el puerto 3306.

La NetworkPolicy también debe permitir al Pod db resolver nombres
DNS (tráfico de salida hacia el puerto 53 UDP).

[Fuente: theplatformlab repo + comunidad Reddit r/ckad]
```

---

#### Pregunta 27 — Service NodePort + Deployment
```
╔══════════════════════════════════════════════════════════════════╗
║  Quick Reference                                                ║
║  Cluster/Contexto: k8s                                         ║
║  Namespace:        ckad00017                                    ║
╚══════════════════════════════════════════════════════════════════╝

Contexto:
El equipo de operaciones necesita escalar una aplicación existente
y exponerla para acceso externo dentro de la infraestructura.

Tarea:
1. Primero, actualiza el Deployment ckad00017-deployment en el
   namespace ckad00017 para que:
   • Ejecute 5 réplicas de Pods
   • Agregue el label tier: dmz a los Pods

2. Luego, en el namespace ckad00017, crea un Service de tipo
   NodePort llamado rover que exponga el Deployment
   ckad00017-deployment en el puerto TCP 81.

[Fuente: ljh.cool — pregunta real del examen]
```

---

#### Pregunta 28 — Ingress: troubleshooting (3 recursos con errores)
```
╔══════════════════════════════════════════════════════════════════╗
║  Quick Reference                                                ║
║  Cluster/Contexto: k8s                                         ║
║  Namespace:        ingress-ckad                                 ║
╚══════════════════════════════════════════════════════════════════╝

Contexto:
El equipo de plataforma reporta que el acceso a través del Ingress
no funciona. Los tres recursos (Deployment, Service e Ingress) ya
están desplegados pero tienen errores de configuración.

Tarea:
En el namespace ingress-ckad, hay un Deployment, un Service y un
Ingress ya desplegados con problemas de configuración que causan
que el acceso a través del Ingress no funcione.

Los manifiestos se encuentran en /ckad/CKAD202206/

Nota importante: El Deployment está correcto. No debes modificarlo.
Debes identificar y corregir los problemas en el Service y en el
Ingress, y luego recrearlos.

[Fuente: ljh.cool — pregunta real del examen — muy frecuente]
```

---

#### Pregunta 29 — Ingress: troubleshooting (Service faltante)
```
╔══════════════════════════════════════════════════════════════════╗
║  Quick Reference                                                ║
║  Cluster/Contexto: k8s                                         ║
║  Namespace:        ingress-kk                                   ║
╚══════════════════════════════════════════════════════════════════╝

Contexto:
El equipo de infraestructura reporta que el Ingress de la aplicación
no responde correctamente a las solicitudes externas.

Tarea:
En el namespace ingress-kk hay un Ingress que no puede ser accedido
correctamente. Identifica la causa raíz del problema y corrígela.

Nota: El Deployment está correcto. No debes modificarlo.

[Fuente: ljh.cool — pregunta real del examen]
```

---

#### Pregunta 30 — Service + ConfigMap + Ambassador Container (Sidecar avanzado)
```
╔══════════════════════════════════════════════════════════════════╗
║  Quick Reference                                                ║
║  Cluster/Contexto: k8s                                         ║
║  Namespace:        default                                      ║
╚══════════════════════════════════════════════════════════════════╝

Contexto:
Un contenedor en un Pod está codificado para conectarse a un puerto
específico de un Service. Necesitas agregar un contenedor ambassador
para que el puerto sea configurable.

Tarea:
1. Actualiza el Service nginxsvc en el namespace default para que
   exponga el puerto 9090.

2. En el namespace default, crea un ConfigMap llamado haproxy-config
   que almacene el contenido del archivo /ckad/ambassador/haproxy.cfg

3. Actualiza el Pod llamado poller en el namespace default:
   • Agrega un contenedor ambassador (patrón ambassador proxy) llamado
     ambassador-container usando la imagen haproxy:lts que exponga el
     puerto 80
   • Monta el ConfigMap haproxy-config en el contenedor
     ambassador-container en la ruta /usr/local/etc/haproxy/

[Fuente: ljh.cool — pregunta real del examen — patrón Ambassador muy específico de CKAD]
```

---

#### Pregunta 31 — Deployment mal configurado: arreglar imagen incorrecta
```
╔══════════════════════════════════════════════════════════════════╗
║  Quick Reference                                                ║
║  Cluster/Contexto: nk8s                                        ║
║  Namespace:        default                                      ║
╚══════════════════════════════════════════════════════════════════╝

Contexto:
El equipo de producción reporta que un Deployment no puede
iniciar sus Pods.

Tarea:
En el namespace default, hay un Deployment que está fallando porque
especifica una imagen de contenedor incorrecta.

Identifica dicho Deployment y corrige el problema.

[Fuente: ljh.cool — pregunta real del examen — troubleshooting básico]
```

---

## 🆕 PREGUNTAS NUEVAS — Cambios v1.35 (Gateway API, Sidecar GA, In-Place Scaling)

---

#### Pregunta 32 — Gateway API: HTTPRoute (nuevo en v1.35)
```
╔══════════════════════════════════════════════════════════════════╗
║  Quick Reference                                                ║
║  Cluster/Contexto: k8s-cluster1                                ║
║  Namespace:        default                                      ║
╚══════════════════════════════════════════════════════════════════╝

Contexto:
Con la depreciación de Ingress NGINX en el cluster, el equipo de
plataforma necesita migrar el enrutamiento de tráfico HTTP al
nuevo estándar de Kubernetes.

Tarea:
Crea los siguientes recursos en el namespace default:

1. Un GatewayClass llamado example-gc usando el controlador
   example.com/gateway-controller

2. Un Gateway llamado my-gateway que escuche en el puerto HTTP 80

3. Un HTTPRoute llamado app-route que:
   • Referencie el Gateway my-gateway
   • Use el hostname app.example.com
   • Enrute solicitudes con el path /api hacia el Service api-svc
     en el puerto 80
   • Enrute el resto del tráfico (/) hacia el Service frontend-svc
     en el puerto 80

[Fuente: theplatformlab repo — cambio crítico en v1.35]
```

---

#### Pregunta 33 — Native Sidecar Container (v1.35 GA)
```
╔══════════════════════════════════════════════════════════════════╗
║  Quick Reference                                                ║
║  Cluster/Contexto: k8s-cluster2                                ║
║  Namespace:        logging                                      ║
╚══════════════════════════════════════════════════════════════════╝

Contexto:
El equipo de observabilidad necesita que el agente de logging
arranque antes que el contenedor principal y persista durante todo
el ciclo de vida del Pod, usando el nuevo mecanismo nativo de Kubernetes.

Tarea:
Crea un Pod llamado native-sidecar-pod en el namespace logging con:

• Un contenedor sidecar nativo (usando initContainers con
  restartPolicy: Always) llamado log-collector con imagen fluentd:v1.16

• Un contenedor principal llamado app con imagen nginx

Ambos contenedores deben compartir un volumen emptyDir montado en
/var/log/app.

Nota: El contenedor sidecar debe usar la sintaxis de sidecar nativo
de Kubernetes v1.35 (no el patrón clásico de dos contenedores en
spec.containers).

[Fuente: theplatformlab repo — feature GA en v1.35, reportado en examen]
```

---

#### Pregunta 34 — In-Place Pod Vertical Scaling (nuevo en v1.35)
```
╔══════════════════════════════════════════════════════════════════╗
║  Quick Reference                                                ║
║  Cluster/Contexto: k8s-cluster1                                ║
║  Namespace:        production                                   ║
╚══════════════════════════════════════════════════════════════════╝

Contexto:
La aplicación de producción necesita más recursos sin tiempo de
inactividad. El equipo ha decidido usar la nueva capacidad de
escalado vertical in-place de Kubernetes.

Tarea:
El Pod llamado webapp-pod en el namespace production tiene actualmente
un request de CPU de 100m y un límite de CPU de 200m.

Actualiza el Pod (sin recrearlo) para que:
• El request de CPU sea 250m
• El límite de CPU sea 500m

Nota: Usa la funcionalidad de In-Place Pod Vertical Scaling disponible
en Kubernetes v1.35.

[Fuente: theplatformlab repo — feature GA en v1.35]
```

---

## 📋 Temas Confirmados por la Comunidad (frecuencia en el examen real)

Basado en análisis de Reddit r/ckad, Medium, blogs chinos (CSDN, Zhihu, 腾讯云, ljh.cool) y GitHub repos de candidatos que pasaron 2024–2026:

### Alta frecuencia (muy probable que aparezca)
- ✅ **NetworkPolicy** — especialmente modificar labels de Pods (no crear la policy)
- ✅ **Canary Deployment** — 40/60 o 20/80 con réplicas proporcionales
- ✅ **ConfigMap + Secret** — montados como volumen y como variables de entorno
- ✅ **Sidecar / Multi-container pods** — patrón ambassador, adapter, sidecar con volumen compartido
- ✅ **Ingress troubleshooting** — selector mismatch entre Service y Deployment
- ✅ **RBAC** — identificar ServiceAccount correcto por logs de error
- ✅ **CronJob** — historial, límites de tiempo, `restartPolicy: Never`
- ✅ **Liveness/Readiness Probe** — identificar Pod roto y corregir probe
- ✅ **Rolling update + Rollback** — `maxSurge`, `maxUnavailable`, `rollout undo`
- ✅ **Resource requests/limits** — incluyendo LimitRange del namespace

### Frecuencia media
- 🟡 **PV/PVC** — hostPath, storageClassName, accessModes
- 🟡 **Dockerfile** — build + export OCI tar
- 🟡 **Helm** — install, upgrade, set values
- 🟡 **API Deprecations** — cambiar `apps/v1beta1` a `apps/v1`
- 🟡 **SecurityContext** — runAsUser, allowPrivilegeEscalation, capabilities
- 🟡 **kubectl top** — identificar Pod con mayor CPU
- 🟡 **Deployment troubleshooting** — imagen incorrecta, CrashLoopBackOff

### Baja frecuencia (pero estudiar para v1.35)
- 🔵 **Gateway API (HTTPRoute)** — reemplaza Ingress NGINX en v1.35
- 🔵 **Native Sidecar Containers** — `restartPolicy: Always` en `initContainers`
- 🔵 **In-Place Pod Vertical Scaling** — resize sin recrear Pod
- 🔵 **StatefulSets** — storage persistente con identidad estable
- 🔵 **CRDs** — `kubectl get crds`, interactuar con custom resources

---

## ⚡ Comandos Imperativos Más Usados (memorizar)

```bash
# Pod
k run nginx --image=nginx $do > pod.yaml

# Deployment
k create deployment webapp --image=nginx --replicas=3 $do > deploy.yaml

# Service
k expose deployment webapp --port=80 --target-port=8080 --type=NodePort

# ConfigMap
k create configmap app-config --from-literal=KEY=VALUE

# Secret
k create secret generic db-secret --from-literal=password=s3cret

# ServiceAccount
k create serviceaccount my-sa -n namespace

# Role
k create role pod-reader --verb=get,list,watch --resource=pods -n namespace

# RoleBinding
k create rolebinding binding --role=pod-reader --serviceaccount=ns:my-sa -n namespace

# Verificar permisos
k auth can-i list pods --as=system:serviceaccount:ns:my-sa -n namespace

# CronJob
k create cronjob hello --image=busybox --schedule="*/5 * * * *" -- echo hello $do > cj.yaml

# Job desde CronJob
k create job ppi-test --from=cronjob/ppi

# Rollout
k rollout status deployment/webapp
k rollout undo deployment/webapp
k rollout history deployment/webapp

# Scale
k scale deployment webapp --replicas=5

# Set image
k set image deployment/webapp nginx=nginx:1.25

# Set serviceaccount
k set serviceaccount deployment webapp my-sa

# Top pods
k top pods --sort-by=cpu -n namespace

# Labels
k label pod mypod env=prod
k get pods --show-labels
k get pods -l app=web

# Delete rápido
k delete pod mypod $now
```

---

## 🐛 Errores más comunes que causan 0 puntos

Basado en testimonios de la comunidad (Reddit, Medium, blogs chinos):

1. **No cambiar el contexto** (`kubectl config use-context xxx`) antes de cada pregunta → 0 puntos automático
2. **Crear recursos en namespace incorrecto** → 0 puntos
3. **Indentación YAML incorrecta** → usar `set expandtab tabstop=2` en vim
4. **NetworkPolicy sin egress DNS** → pods no resuelven nombres de servicio
5. **Service selector que no coincide con labels del Pod** → endpoints vacíos
6. **Gastar +10 min en una pregunta de bajo peso** → no terminar el examen
7. **No verificar que el Pod esté Running** después de crear recursos
8. **Copy-paste con Ctrl+C en terminal** → mata el proceso (usar Ctrl+Shift+C)
9. **Olvidar `restartPolicy: Never/OnFailure`** en Jobs y CronJobs
10. **Modificar la NetworkPolicy cuando la pregunta pide modificar el Pod**

---

## 📚 Recursos de Práctica Recomendados por la Comunidad

| Recurso | Tipo | Costo |
|---|---|---|
| **killer.sh** | Simulador oficial (incluido con el examen) | Gratis (2 sesiones) |
| **killercoda.com** | Laboratorios en browser | Gratis |
| **KodeKloud — Mumshad Mannambeth** | Curso + labs | Pago |
| **theplatformlab/CKAD-Certified-Kubernetes-Application-Developer** | GitHub repo — pasaron con 91% | Gratis |
| **github.com/dgkanatsios/CKAD-exercises** | Ejercicios clásicos | Gratis |
| **github.com/jamesbuckett/ckad-questions** | Preguntas con soluciones | Gratis |
| **Sailor.sh CKAD Simulator** | 20+ scenarios CLI | Gratis |

---

*Compilado de: Reddit r/ckad, Medium (múltiples autores 2025), ljh.cool (blog comunidad china con preguntas reales), CSDN, Zhihu, 腾讯云, GitHub repos de candidatos que aprobaron (2025-2026), Linux Foundation official curriculum v1.35.*

*Última actualización: Mayo 2026 — Kubernetes v1.35*