# CKAD Simulator Practice Environment

Este directorio contiene scripts y recursos para practicar las preguntas del simulador CKAD de Killer.sh.

## 📋 Contenido

```
ckad-simulator/
├── setup-ckad-env.sh      # Script principal para configurar el entorno
├── cleanup-ckad-env.sh    # Script para limpiar el entorno
├── README.md              # Este archivo
└── resources/             # Archivos YAML con los recursos de K8s
    ├── serviceaccounts.yaml
    ├── secrets.yaml
    ├── saturn-pods.yaml
    ├── pluto-pods.yaml
    ├── pluto-deployments.yaml
    ├── earth-resources.yaml
    ├── neptune-resources.yaml
    ├── sun-resources.yaml
    ├── mercury-resources.yaml
    ├── mars-resources.yaml
    ├── jupiter-resources.yaml
    └── project-23-api.yaml
```

## 🚀 Uso Rápido

### 1. Iniciar Minikube (si no está corriendo)
```bash
minikube start
```

### 2. Configurar el entorno de práctica
```bash
chmod +x setup-ckad-env.sh cleanup-ckad-env.sh
./setup-ckad-env.sh
```

### 3. Cargar alias del examen
```bash
source ~/.ckad-env
```

### 4. Practicar las preguntas
Abre el archivo `Killer Shell - Exam Simulators.html` en tu navegador y resuelve las preguntas.

### 5. Limpiar y empezar de nuevo
```bash
./cleanup-ckad-env.sh
./setup-ckad-env.sh
```

## 🌍 Namespaces Creados

El script crea los siguientes namespaces que se usan en las preguntas:

| Namespace | Descripción |
|-----------|-------------|
| `earth` | Deployments con readinessProbe, services |
| `jupiter` | Jobs y CronJobs |
| `mars` | NetworkPolicies |
| `mercury` | Helm releases |
| `neptune` | ServiceAccounts, Secrets, Rollouts |
| `pluto` | Pods multi-container, Deployments |
| `saturn` | Pods webserver con annotations |
| `sun` | Pods y Deployments con ServiceAccounts |
| `shell-intern` | Namespace para ejercicios de shell |

## 📝 Recursos Pre-existentes

El script crea los siguientes recursos que ya existen en las preguntas del simulador:

### Saturn
- 6 pods `webserver-sat-001` a `webserver-sat-006`
- Uno de ellos tiene la anotación `description: "my-happy-shop"`

### Neptune
- ServiceAccount `neptune-sa-v2`
- Secret `neptune-secret-1`
- Deployment `api-new-c32` con historial de revisiones

### Earth
- Deployment `earth-3cc-web` con **readinessProbe ROTA** (puerto 82 en vez de 80)
- Deployment `earth-2x3-api`
- Services correspondientes

### Pluto
- Pod `holy-api` con 2 containers
- Deployment `project-23-api`

### Sun
- Pods `sun-pod-0023` y `sun-pod-0024`
- Deployment `sun-deploy` con ServiceAccount específico

### Mars
- Pods `mars-web` y `mars-api` para practicar NetworkPolicies

## 🔧 Alias Disponibles

Después de ejecutar `source ~/.ckad-env`:

| Alias/Variable | Valor | Uso |
|----------------|-------|-----|
| `k` | `kubectl` | Atajo para kubectl |
| `kn <namespace>` | Cambiar namespace | `kn neptune` |
| `$do` | `--dry-run=client -o yaml` | `k run pod --image=nginx $do > pod.yaml` |
| `$now` | `--force --grace-period 0` | `k delete pod mypod $now` |

## 📁 Estructura de Directorios

El script crea los siguientes directorios para guardar tus respuestas:
- `/opt/course/1` a `/opt/course/22` - Para las 22 preguntas regulares
- `/opt/course/p1` y `/opt/course/p2` - Para las Preview Questions

## ⚠️ Notas Importantes

1. **Helm**: Algunas preguntas requieren Helm. Asegúrate de tenerlo instalado:
   ```bash
   curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
   ```

2. **NetworkPolicy**: Para que las NetworkPolicies funcionen, necesitas un CNI que las soporte. En Minikube:
   ```bash
   minikube start --cni=calico
   ```

3. **Permisos**: Es posible que necesites `sudo` para crear directorios en `/opt/course/`.

## 🎯 Tips para el Examen

1. **Usa los alias**: `k` es mucho más rápido que `kubectl`
2. **Usa `$do`**: Genera YAML rápidamente y luego edítalo
3. **Usa `$now`**: Borra pods rápidamente sin esperar
4. **Practica `vim`**: El editor del examen es vim/nano
5. **Conoce la documentación**: kubernetes.io/docs está permitido en el examen

¡Buena suerte en tu CKAD! 🚀
