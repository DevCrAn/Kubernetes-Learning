# CKAD Tips - Kubernetes 1.35

En esta sección proporcionaremos algunos consejos sobre cómo manejar el examen CKAD y la terminal del navegador.

---

## Conocimiento

- Estudia todos los temas propuestos en el currículum hasta que te sientas cómodo con todos
- Aprende y estudia los escenarios en el navegador en https://killercoda.com/killer-shell-ckad
- Lee esto y haz todos los ejemplos: https://kubernetes.io/docs/concepts/cluster-administration/logging
- Comprende el Rolling Update Deployment incluyendo `maxSurge` y `maxUnavailable`
- Realiza 1 o 2 sesiones de prueba con este CKAD Simulator. Comprende las soluciones y tal vez prueba otras formas de lograr lo mismo
- Sé rápido y respira kubectl

---

## Preparación CKAD

**Lee el Currículum**  
https://github.com/cncf/curriculum

**Lee el Manual**  
https://docs.linuxfoundation.org/tc-docs/certification/lf-handbook2

**Lee los consejos importantes**  
https://docs.linuxfoundation.org/tc-docs/certification/tips-cka-and-ckad

**Lee el FAQ**  
https://docs.linuxfoundation.org/tc-docs/certification/faq-cka-ckad

---

## Documentación de Kubernetes

Familiarízate con la documentación de Kubernetes y sé capaz de usar la búsqueda. Los recursos permitidos son:

- https://kubernetes.io/docs
- https://kubernetes.io/blog
- https://helm.sh/docs

> ℹ️ Verifica la lista [aquí](https://docs.linuxfoundation.org/tc-docs/certification/certification-resources-allowed)

---

## La Interfaz del Examen / Escritorio Remoto

El examen real, así como el simulador, proporciona un Escritorio Remoto (XFCE) en Ubuntu/Debian. Viniendo de OSX/Windows habrá cambios en copiar y pegar por ejemplo.

**Información Oficial**  
ExamUI: [Exámenes Basados en Rendimiento](https://docs.linuxfoundation.org/tc-docs/certification/lf-handbook2/exam-user-interface)

### Retraso (Lagging)

Podría haber algo de retraso, definitivamente asegúrate de estar usando una buena conexión a internet porque tu cámara web y pantalla están transfiriendo todo el tiempo.

### Autocompletado de Kubectl y comandos

Los siguientes están instalados o preconfigurados, [verifica la lista aquí](https://docs.linuxfoundation.org/tc-docs/certification/tips-cka-and-ckad):

- `kubectl` con alias `k` y autocompletado de Bash
- `yq` para procesamiento de YAML
- `curl` y `wget` para probar servicios web
- `man` y páginas man para documentación adicional

> ℹ️ Se te permite instalar herramientas, como `tmux` para multiplexación de terminal o `jq` para procesamiento de JSON

### Copiar y Pegar

Copiar y pegar funcionará como normal en un Entorno Linux:

- **Lo que siempre funciona:** copiar+pegar usando el menú contextual del botón derecho del mouse
- **Lo que funciona en Terminal:** `Ctrl+Shift+c` y `Ctrl+Shift+v`
- **Lo que funciona en otras aplicaciones como Firefox:** `Ctrl+c` y `Ctrl+v`

### Puntuación

Hay 15-20 preguntas en el examen. Tus resultados serán verificados automáticamente según el manual. Si no estás de acuerdo con los resultados puedes solicitar una revisión contactando al Soporte de Linux Foundation.

### Bloc de Notas y Marcar Preguntas

Puedes marcar preguntas para volver más tarde. Esto es solo un marcador para ti mismo y no afectará la puntuación. También tienes acceso a un bloc de notas simple en el navegador que puede usarse para almacenar cualquier tipo de texto plano. Podría tener sentido usar esto y escribir información adicional sobre las preguntas marcadas. En lugar de usar el bloc de notas también podrías abrir Mousepad (aplicación XFCE dentro del Escritorio Remoto) o crear un archivo con Vim.

### VSCodium

Puedes usar VSCodium para editar archivos y también puedes usar su terminal para ejecutar comandos. No se te permite instalar ninguna extensión de VSCodium.

### Servidores

Cada pregunta debe resolverse en una instancia específica diferente a tu terminal principal. Necesitarás conectarte a la instancia correcta vía ssh, el comando se proporciona antes de cada pregunta.

---

## PSI Bridge

Empezando con PSI Bridge:

- El examen ahora se tomará usando el PSI Secure Browser, que puede descargarse usando las versiones más nuevas de Microsoft Edge, Safari, Chrome o Firefox
- Ya no se permitirán múltiples monitores
- Ya no se permitirá el uso de marcadores personales

La nueva ExamUI incluye características mejoradas tales como:

- Un escritorio remoto configurado con las herramientas y software necesarios para completar las tareas
- Un temporizador que muestra el tiempo real restante (en minutos) y proporciona una alerta con 30, 15 o 5 minutos restantes
- El panel de contenido permanece igual (presentado en el Lado Izquierdo de ExamUI)

[Lee más aquí](https://docs.linuxfoundation.org/tc-docs/certification/lf-handbook2/exam-user-interface/psi-bridge-proctoring-platform).

---

## Manejo de Terminal

### Alias de Bash

En el examen real, cada pregunta tiene que resolverse en una instancia diferente a la que te conectas vía ssh. Esto significa que no se recomienda configurar alias de bash porque no estarían disponibles en las instancias accedidas por ssh.

### Sé rápido

Usa el comando `history` para reutilizar comandos ya ingresados o usa la búsqueda de historial aún más rápida a través de `Ctrl+r`.

Si un comando toma algo de tiempo en ejecutarse, como a veces `kubectl delete pod x`. Puedes poner una tarea en segundo plano usando `Ctrl+z` y traerla de vuelta al primer plano ejecutando el comando `fg`.

Puedes eliminar pods rápidamente con:

```bash
k delete pod x --grace-period 0 --force
```

---

## Vim

Sé genial con vim.

### Configuración

En caso de que enfrentes una situación donde vim no está configurado correctamente y enfrentes por ejemplo problemas al pegar contenido copiado, deberías poder configurar vía `~/.vimrc` o ingresando manualmente en el modo de configuración de vim:

```vim
set tabstop=2
set expandtab
set shiftwidth=2
```

La opción `expandtab` asegura usar espacios para tabulaciones.

Nota que los cambios en `~/.vimrc` no se transferirán al conectarse a otras instancias vía ssh.

### Alternar números de línea en vim

Cuando estés en vim puedes presionar `Esc` y escribir `:set number` o `:set nonumber` seguido de `Enter` para alternar los números de línea. Esto puede ser útil cuando encuentras errores de sintaxis basados en línea - pero puede ser malo cuando quieres marcar y copiar con el mouse. También puedes simplemente saltar a un número de línea con `Esc :22 + Enter`.

### Copiar y Pegar

Acostúmbrate a copiar/pegar/cortar con vim:

- **Marcar líneas:** `Esc+V` (luego teclas de flecha)
- **Copiar líneas marcadas:** `y`
- **Cortar líneas marcadas:** `d`
- **Pegar líneas:** `p` o `P`

### Indentar múltiples líneas

Para indentar múltiples líneas presiona `Esc` y escribe `:set shiftwidth=2`. Primero marca múltiples líneas usando `Shift+v` y las teclas arriba/abajo. Luego para indentar las líneas marcadas presiona `>` o `<`. Puedes luego presionar `.` para repetir la acción.
