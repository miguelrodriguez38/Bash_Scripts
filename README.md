# Scripts de Bash

Scripts sencillos en Bash hechos para la asignatura de Sistemas Operativos.

## open_files1.sh

Muestra cuántos archivos regulares tiene abiertos cada usuario conectado, usando `lsof`.

```
./open_files1.sh [-h] [-f regexp] [-o] [-u usuario ...] [-s]
```

- `-h`: ayuda
- `-f regexp`: cuenta solo las rutas que encajan con la expresión
- `-o`: usuarios no conectados
- `-u usuario ...`: solo esos usuarios
- `-s`: ordenar por número de archivos

Requiere `lsof`.
