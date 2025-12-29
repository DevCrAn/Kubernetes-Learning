# CKAD Simulator - Preguntas de Práctica

## Pregunta 1 | Namespaces

**Instancia:** `ssh ckad5601`

El equipo de DevOps necesita obtener la lista de todos los Namespaces en el clúster.

La lista puede contener otras columnas como STATUS o AGE.

Guarda la lista en `/opt/course/1/namespaces` en `ckad5601`.

---

## Pregunta 2 | Pods

**Instancia:** `ssh ckad5601`

Crea un único Pod con la imagen `httpd:2.4.41-alpine` en el Namespace `default`. El Pod debe llamarse `pod1` y el contenedor debe llamarse `pod1-container`.

Tu manager quiere ejecutar un comando manualmente para obtener el estado de ese Pod exacto. Escribe un comando que haga esto en `/opt/course/2/pod1-status-command.sh` en `ckad5601`. El comando debe usar `kubectl`.

---

## Pregunta 3 | Job

**Instancia:** `ssh ckad7326`

El Team Neptune necesita una plantilla de Job ubicada en `/opt/course/3/job.yaml`. Este Job debe ejecutar la imagen `busybox:1.31.0` y ejecutar `sleep 2 && echo done`. Debe estar en el namespace `neptune`, ejecutarse un total de 3 veces y ejecutar 2 ejecuciones en paralelo.

Inicia el Job y verifica su historial. Cada pod creado por el Job debe tener la etiqueta `id: awesome-job`. El job debe llamarse `neb-new-job` y el contenedor `neb-new-job-container`.

---

## Pregunta 4 | Helm Management

**Instancia:** `ssh ckad7326`

El Team Mercury te pidió realizar algunas operaciones usando Helm, todas en el Namespace `mercury`:

- Elimina el release `internal-issue-report-apiv1`
- Actualiza el release `internal-issue-report-apiv2` a cualquier versión más nueva del chart `killershell/nginx` disponible
- Instala un nuevo release `internal-issue-report-apache` del chart `killershell/apache`. El Deployment debe tener dos réplicas, configúralas mediante Helm-values durante la instalación
- Parece haber un release roto, atascado en estado `pending-install`. Encuéntralo y elimínalo

---

## Pregunta 5 | ServiceAccount, Secret

**Instancia:** `ssh ckad7326`

El Team Neptune tiene su propia ServiceAccount llamada `neptune-sa-v2` en el Namespace `neptune`. Un compañero de trabajo necesita el token del Secret que pertenece a esa ServiceAccount. Escribe el token decodificado en base64 en el archivo `/opt/course/5/token` en `ckad7326`.

---

## Pregunta 6 | ReadinessProbe

**Instancia:** `ssh ckad5601`

Crea un único Pod llamado `pod6` en el Namespace `default` con la imagen `busybox:1.31.0`. El Pod debe tener un readiness-probe que ejecute `cat /tmp/ready`. Debe esperar inicialmente 5 segundos y periódicamente 10 segundos. Esto establecerá el contenedor como ready solo si el archivo `/tmp/ready` existe.

El Pod debe ejecutar el comando `touch /tmp/ready && sleep 1d`, que creará el archivo necesario para estar listo y luego permanecerá inactivo. Crea el Pod y confirma que inicia correctamente.

---

## Pregunta 7 | Pods, Namespaces

**Instancia:** `ssh ckad7326`

La junta del Team Neptune decidió tomar el control de un servidor web de e-commerce del Team Saturn. El administrador que configuró este servidor web ya no forma parte de la organización. Toda la información que pudiste obtener fue que el sistema de e-commerce se llama `my-happy-shop`.

Busca el Pod correcto en el Namespace `saturn` y muévelo al Namespace `neptune`. No importa si lo apagas y lo vuelves a iniciar, probablemente no tenga clientes de todos modos.

---

## Pregunta 8 | Deployment, Rollouts

**Instancia:** `ssh ckad7326`

Existe un Deployment llamado `api-new-c32` en el Namespace `neptune`. Un desarrollador hizo una actualización al Deployment pero la versión actualizada nunca se puso en línea. Verifica el historial del Deployment y encuentra una revisión que funcione, luego haz un rollback a ella. ¿Podrías decirle al Team Neptune cuál fue el error para que no vuelva a suceder?

---

## Pregunta 9 | Pod -> Deployment

**Instancia:** `ssh ckad9043`

En el Namespace `pluto` hay un único Pod llamado `holy-api`. Ha estado funcionando bien por un tiempo pero el Team Pluto necesita que sea más confiable.

Convierte el Pod en un Deployment llamado `holy-api` con 3 réplicas y elimina el Pod único una vez hecho. El archivo de plantilla del Pod raw está disponible en `/opt/course/9/holy-api-pod.yaml`.

Además, el nuevo Deployment debe establecer `allowPrivilegeEscalation: false` y `privileged: false` para el contexto de seguridad a nivel de contenedor.

Por favor crea el Deployment y guarda su yaml en `/opt/course/9/holy-api-deployment.yaml` en `ckad9043`.

---

## Pregunta 10 | Service, Logs

**Instancia:** `ssh ckad9043`

El Team Pluto necesita un nuevo Service interno del clúster. Crea un Service ClusterIP llamado `project-plt-6cc-svc` en el Namespace `pluto`. Este Service debe exponer un único Pod llamado `project-plt-6cc-api` con la imagen `nginx:1.17.3-alpine`, crea ese Pod también. El Pod debe identificarse con la etiqueta `project: plt-6cc-api`. El Service debe usar redirección de puerto tcp de `3333:80`.

Finalmente usa por ejemplo `curl` desde un Pod temporal `nginx:alpine` para obtener la respuesta del Service. Escribe la respuesta en `/opt/course/10/service_test.html` en `ckad9043`. También verifica si los logs del Pod `project-plt-6cc-api` muestran la solicitud y escríbelos en `/opt/course/10/service_test.log` en `ckad9043`.

---

## Pregunta 11 | Working with Containers

**Instancia:** `ssh ckad9043`

Hay archivos para construir una imagen de contenedor ubicados en `/opt/course/11/image` en `ckad9043`. El contenedor ejecutará una aplicación Golang que genera información en stdout. Se te pide realizar las siguientes tareas:

> ℹ️ Ejecuta todos los comandos Docker y Podman como usuario root. Usa `sudo docker` y `sudo podman` o conviértete en root con `sudo -i`

- Cambia el Dockerfile: establece la variable ENV `SUN_CIPHER_ID` al valor hardcoded `5b9c1065-e39d-4a43-a04a-e59bcea3e03f`
- Construye la imagen usando `sudo docker`, etiquétala como `registry.killer.sh:5000/sun-cipher:v1-docker` y envíala al registry
- Construye la imagen usando `sudo podman`, etiquétala como `registry.killer.sh:5000/sun-cipher:v1-podman` y envíala al registry
- Ejecuta un contenedor usando `sudo podman`, que se mantenga ejecutándose en segundo plano (detached), llamado `sun-cipher` usando la imagen `registry.killer.sh:5000/sun-cipher:v1-podman`
- Escribe los logs que produce tu contenedor `sun-cipher` en `/opt/course/11/logs` en `ckad9043`

---

## Pregunta 12 | Storage, PV, PVC, Pod volume

**Instancia:** `ssh ckad5601`

Crea un nuevo PersistentVolume llamado `earth-project-earthflower-pv`. Debe tener una capacidad de `2Gi`, accessMode `ReadWriteOnce`, hostPath `/Volumes/Data` y no debe tener storageClassName definido.

Luego crea un nuevo PersistentVolumeClaim en el Namespace `earth` llamado `earth-project-earthflower-pvc`. Debe solicitar `2Gi` de almacenamiento, accessMode `ReadWriteOnce` y no debe definir un storageClassName. El PVC debe vincularse correctamente al PV.

Finalmente crea un nuevo Deployment `project-earthflower` en el Namespace `earth` que monte ese volumen en `/tmp/project-data`. Los Pods de ese Deployment deben usar la imagen `httpd:2.4.41-alpine`.

---

## Pregunta 13 | Storage, StorageClass, PVC

**Instancia:** `ssh ckad9043`

El Team Moonpie, que tiene el Namespace `moon`, necesita más almacenamiento. Crea un nuevo PersistentVolumeClaim llamado `moon-pvc-126` en ese namespace. Este claim debe usar una nueva StorageClass `moon-retain` con el provisioner establecido en `moon-retainer` y la reclaimPolicy establecida en `Retain`. El claim debe solicitar almacenamiento de `3Gi`, un accessMode de `ReadWriteOnce` y debe usar la nueva StorageClass.

El provisioner `moon-retainer` será creado por otro equipo, por lo que se espera que el PVC aún no arranque. Confirma esto escribiendo el mensaje del evento del PVC en el archivo `/opt/course/13/pvc-126-reason` en `ckad9043`.

---

## Pregunta 14 | Secret, Secret-Volume, Secret-Env

**Instancia:** `ssh ckad9043`

Necesitas hacer cambios en un Pod existente en el Namespace `moon` llamado `secret-handler`. Crea un nuevo Secret `secret1` que contenga `user=test` y `pass=pwd`. El contenido del Secret debe estar disponible en el Pod `secret-handler` como variables de entorno `SECRET1_USER` y `SECRET1_PASS`. El yaml para el Pod `secret-handler` está disponible en `/opt/course/14/secret-handler.yaml`.

Hay un yaml existente para otro Secret en `/opt/course/14/secret2.yaml`, crea este Secret y móntalo dentro del mismo Pod en `/tmp/secret2`. Tus cambios deben guardarse en `/opt/course/14/secret-handler-new.yaml` en `ckad9043`. Ambos Secrets deben estar disponibles solo en el Namespace `moon`.

---

## Pregunta 15 | ConfigMap, Configmap-Volume

**Instancia:** `ssh ckad9043`

El Team Moonpie tiene un Deployment de servidor nginx llamado `web-moon` en el Namespace `moon`. Alguien comenzó a configurarlo pero nunca se completó. Para completarlo, crea un ConfigMap llamado `configmap-web-moon-html` que contenga el contenido del archivo `/opt/course/15/web-moon.html` bajo el nombre de clave de datos `index.html`.

El Deployment `web-moon` ya está configurado para trabajar con este ConfigMap y servir su contenido. Prueba la configuración de nginx por ejemplo usando `curl` desde un Pod temporal `nginx:alpine`.

---

## Pregunta 16 | Logging sidecar

**Instancia:** `ssh ckad7326`

El Tech Lead de Mercury2D decidió que es hora de tener más logging, para finalmente combatir todos estos incidentes de datos faltantes. Hay un contenedor existente llamado `cleaner-con` en el Deployment `cleaner` en el Namespace `mercury`. Este contenedor monta un volumen y escribe logs en un archivo llamado `cleaner.log`.

El yaml para el Deployment existente está disponible en `/opt/course/16/cleaner.yaml`. Persiste tus cambios en `/opt/course/16/cleaner-new.yaml` en `ckad7326` pero también asegúrate de que el Deployment esté ejecutándose.

Crea un contenedor sidecar llamado `logger-con`, imagen `busybox:1.31.0`, que monte el mismo volumen y escriba el contenido de `cleaner.log` en stdout, puedes usar el comando `tail -f` para esto. De esta manera puede ser capturado por `kubectl logs`.

Verifica si los logs del nuevo contenedor revelan algo sobre los incidentes de datos faltantes.

---

## Pregunta 17 | InitContainer

**Instancia:** `ssh ckad5601`

En el último almuerzo le contaste a tu compañero del departamento Mars Inc lo increíbles que son los InitContainers. Ahora le gustaría ver uno en acción. Hay un yaml de Deployment en `/opt/course/17/test-init-container.yaml`. Este Deployment crea un único Pod con la imagen `nginx:1.17.3-alpine` y sirve archivos desde un volumen montado, que está vacío ahora mismo.

Crea un InitContainer llamado `init-con` que también monte ese volumen y cree un archivo `index.html` con el contenido `check this out!` en la raíz del volumen montado. Para esta prueba ignoramos que no contiene html válido.

El InitContainer debe usar la imagen `busybox:1.31.0`. Prueba tu implementación por ejemplo usando `curl` desde un Pod temporal `nginx:alpine`.

---

## Pregunta 18 | Service misconfiguration

**Instancia:** `ssh ckad5601`

Parece haber un problema en el Namespace `mars` donde el service ClusterIP `manager-api-svc` debería hacer que los Pods del Deployment `manager-api-deployment` estén disponibles dentro del clúster.

Puedes probar esto con `curl manager-api-svc.mars:4444` desde un Pod temporal `nginx:alpine`. Verifica la configuración incorrecta y aplica una corrección.

---

## Pregunta 19 | Service ClusterIP->NodePort

**Instancia:** `ssh ckad5601`

En el Namespace `jupiter` encontrarás un Deployment de apache (con una réplica) llamado `jupiter-crew-deploy` y un Service ClusterIP llamado `jupiter-crew-svc` que lo expone. Cambia este servicio a uno NodePort para hacerlo disponible en todos los nodos en el puerto `30100`.

Prueba el Service NodePort usando la IP interna de todos los nodos disponibles y el puerto `30100` usando `curl`, puedes alcanzar las IPs internas de los nodos directamente desde tu terminal principal. ¿En qué nodos está accesible el Service? ¿En qué nodo se está ejecutando el Pod?

---

## Pregunta 20 | NetworkPolicy

**Instancia:** `ssh ckad7326`

En el Namespace `venus` encontrarás dos Deployments llamados `api` y `frontend`. Ambos Deployments están expuestos dentro del clúster usando Services. Crea una NetworkPolicy llamada `np1` que restrinja las conexiones tcp salientes desde el Deployment `frontend` y solo permita aquellas que van al Deployment `api`. Asegúrate de que la NetworkPolicy todavía permita tráfico saliente en puertos UDP/TCP 53 para resolución DNS.

Prueba usando: `wget www.google.com` y `wget api:2222` desde un Pod del Deployment `frontend`.

---

## Pregunta 21 | Requests and Limits, ServiceAccount

**Instancia:** `ssh ckad7326`

El Team Neptune necesita 3 Pods con la imagen `httpd:2.4-alpine`, crea un Deployment llamado `neptune-10ab` para esto. Los contenedores deben llamarse `neptune-pod-10ab`. Cada contenedor debe tener una solicitud de memoria de `20Mi` y un límite de memoria de `50Mi`.

El Team Neptune tiene su propia ServiceAccount `neptune-sa-v2` bajo la cual deben ejecutarse los Pods. El Deployment debe estar en el Namespace `neptune`.

---

## Pregunta 22 | Labels, Annotations

**Instancia:** `ssh ckad9043`

El Team Sunny necesita identificar algunos de sus Pods en el namespace `sun`. Te piden agregar una nueva etiqueta `protected: true` a todos los Pods con una etiqueta existente `type: worker` o `type: runner`. También agrega una anotación `protected: do not delete this pod` a todos los Pods que tienen la nueva etiqueta `protected: true`.

---

## Pregunta de Vista Previa 1

**Instancia:** `ssh ckad9043`

En el Namespace `pluto` hay un Deployment llamado `project-23-api`. Ha estado funcionando bien por un tiempo pero el Team Pluto necesita que sea más confiable. Implementa un liveness-probe que verifique que el contenedor sea accesible en el puerto `80`. Inicialmente la sonda debe esperar 10, periódicamente 15 segundos.

El yaml del Deployment original está disponible en `/opt/course/p1/project-23-api.yaml`. Guarda tus cambios en `/opt/course/p1/project-23-api-new.yaml` y aplica los cambios.

---

## Pregunta de Vista Previa 2

**Instancia:** `ssh ckad9043`

El Team Sun necesita un nuevo Deployment llamado `sunny` con 4 réplicas de la imagen `nginx:1.17.3-alpine` en el Namespace `sun`. El Deployment y sus Pods deben usar la ServiceAccount existente `sa-sun-deploy`.

Expone el Deployment internamente usando un Service ClusterIP llamado `sun-srv` en el puerto `9999`. Los contenedores nginx deben ejecutarse por defecto en el puerto `80`. La gerencia del Team Sun quisiera ejecutar un comando para verificar que todos los Pods estén ejecutándose ocasionalmente. Escribe ese comando en el archivo `/opt/course/p2/sunny_status_command.sh`. El comando debe usar `kubectl`.

---

## Pregunta de Vista Previa 3

**Instancia:** `ssh ckad5601`

La gerencia de EarthAG registró que uno de sus Services dejó de funcionar. Dirk, el administrador, ya se fue para el fin de semana largo. Toda la información que pudieron darte es que estaba ubicado en el Namespace `earth` y que dejó de funcionar después del último rollout. Todos los Services de EarthAG deben ser accesibles desde dentro del clúster.

Encuentra el Service, corrige cualquier problema y confirma que funciona nuevamente. Escribe la razón del error en el archivo `/opt/course/p3/ticket-654.txt` para que Dirk sepa cuál fue el problema.
