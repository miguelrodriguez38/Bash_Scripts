# Scripts de Bash

Scripts sencillos en Bash realizados para la asignatura de Sistemas Operativos. Todos están centrados en la monitorización de procesos, usuarios y archivos abiertos usando herramientas del sistema como `lsof`, `ps`, `w`, `who` e `id`.

## 1. Script 1: open_files.sh

Este script muestra, para cada usuario, el UID, el PID del proceso más antiguo y el número de archivos regulares que tiene abiertos.

```
./Script1/open_files.sh [-h | --help] [-f regexp] [-o | --offline] [-u usuario ...] [-s | --sort]
```

Funciones principales:
- Muestra los usuarios conectados por defecto.
- Con `-o` o `--offline`, muestra los usuarios no conectados.
- Con `-u usuario ...`, limita la salida a usuarios concretos.
- Con `-f regexp`, solo cuenta archivos cuya ruta coincida con una expresión regular.
- Con `-s` o `--sort`, ordena por número de archivos abiertos, de mayor a menor.
- Si se define la variable `OPEN_FILES_FOLDER`, solo cuenta archivos dentro de ese directorio y sus subdirectorios.

Se basa en `lsof` para comprobar qué archivos están abiertos por cada usuario y `ps` para obtener el proceso más antiguo.

## 2. Script 2: open_files1.sh

Este script es una versión muy similar a la anterior, pero centrada en mostrar, por usuario, el número total de archivos regulares abiertos.

```
./Script2/open_files1.sh [-h] [-f regexp] [-o] [-u usuario ...] [-s]
```

Características:
- `-h`: muestra la ayuda.
- `-f regexp`: cuenta solo rutas que coincidan con la expresión regular indicada.
- `-o`: muestra usuarios no conectados.
- `-u usuario ...`: restringe la búsqueda a usuarios concretos.
- `-s`: ordena la salida por número de archivos, de mayor a menor.
- `OPEN_FILES_FOLDER`: si está definida, limita la búsqueda a ese directorio.

También usa `lsof`, `ps`, `w` e `id` para obtener el usuario, su UID y el proceso más antiguo asociado.

## 3. Script 3: script.sh

Este script recorre todos los procesos del sistema y muestra aquellos que cumplen dos condiciones simultáneas:
- tiempo de ejecución mayor o igual que un valor dado con `-P`
- número de ficheros abiertos mayor o igual que un valor dado con `-f`

```
./Script3/script.sh [-h] [-P N] [-f N]
```

Parámetros:
- `-P N`: muestra procesos con al menos `N` segundos de ejecución.
- `-f N`: muestra procesos con al menos `N` ficheros abiertos.
- `-h`: muestra ayuda.

La salida incluye el PID, el tiempo de ejecución y el número de ficheros abiertos y se ordena por tiempo de ejecución de mayor a menor. El script comprueba que `ps` y `lsof` estén instalados antes de ejecutarse.

## 4. Script 4: mainprocess.sh

Este script muestra los procesos que más memoria consumen y, para cada uno, el número de archivos abiertos que tiene.

```
./Script4/mainprocess.sh [-h | --help] [-n num]
```

Funcionalidad:
- Por defecto, muestra los 10 procesos que más memoria consumen.
- `-n num`: cambia el número de procesos a mostrar.
- `-h`: muestra la ayuda.
- Si se introduce una opción inválida, termina con error.

La salida tiene este formato:
- PID
- NºARCHIVOS
- COMANDO

Se ordena por porcentaje de memoria y usa `lsof -p PID` para contar las aperturas de archivo del proceso.

## 5. Script 5: myopening.sh

Este script está pensado para consultar la información de aperturas de archivos relacionadas con usuarios y procesos.

```
./Script5/myopening.sh [-h] [-p PID] [-u usuario1 usuario2 ...]
```

Comportamiento:
- Si se ejecuta sin opciones, muestra las aperturas de archivo del usuario actual usando `lsof -u $USER`, mostrando únicamente las columnas `COMMAND` y `PID`.
- Con `-p PID`, muestra el número de aperturas del proceso indicado junto con el tiempo transcurrido desde su inicio, usando `ps -p PID -o etime`.
- Con `-u usuario ...`, itera sobre varios usuarios y muestra la información de aperturas de cada uno.
- Si se usan `-p` y `-u` a la vez, el script genera un error.

Además, valida que los usuarios introducidos existan y que `lsof` esté disponible.

## Resumen general

Estos scripts forman una pequeña colección de herramientas de monitorización del sistema en bash. Su finalidad es observar:
- cuántos archivos están abiertos por cada usuario,
- qué procesos tienen más ficheros abiertos,
- qué procesos consumen más memoria,
- y qué procesos o usuarios presentan más actividad de ficheros abiertos.

En conjunto, son ejercicios prácticos para entender el uso de `lsof`, `ps`, `id`, `w` y filtros con Bash.
