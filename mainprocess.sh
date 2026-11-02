#!/bin/bash

#VARIABLES
num=10

usage () {
    cat << EOF
# Si se ejecuta sin opciones muestre el número de aperturas de archivo (lsof) de cada uno de los 10 procesos que más memoria consumen en el sistema según la opción %mem de ps.
# La tabla debe mostrar para cada proceso su pid, el número de aperturas de archivo y el comando que lanzó el proceso.
# El script debe comprobar la existencia del programa lsof con which. Si no existe debe salir con estado de salida
# diferente de (error) y un mensaje apropiado.
# El script se puede llamar con las opciones:
#mainprocs.sh [-h | --help] [ -n num ]
# -h o --help muestra la ayuda del comando y termina con estado de salida 0
# -n num: la información que se muestra es la de los num procesos que más memoria consumen (en lugar de los 10 que por defecto
# se muestran si no se introduce esta opción)
# Si el usuario introduce una opción incorrecta ha que terminar con estado de salida diferente de 0
#
# Ayuda: Recuerden que ps tiene la opción --sort que permite ordenar por alguna propiedad como %mem. #ps también tiene la opción -o para elegir los campos a mostrar.
# En lsof tiene la opción -p que permite mostrar las aperturas de un proceso usando su pid.
EOF
}

error_exit () {
    echo "$1" >&2
    exit 0
}

lsof_is_installed () {
    which lsof > /dev/null 2> /dev/null
}

if ! lsof_is_installed; then
    error_exit "Lsof no esta instalado. Pruebe a ejecutar apt install lsof"
fi

#PROCESAR LA LINEA DE COMANDOS

while [[ "$1" != "" ]]; do
    case "$1" in 
        -h | --help ) 
            usage 
            exit 1
            ;;
        -n | -num ) 
            shift 
            if [[ "$1" == "" || "$1" == -* ]]; then
                error_exit "Error falta el argumento de $1 para la opcion n"
            fi
            num=$1
            shift
            ;;
        -* ) 
            error_exit "Falta indiciar la opcion"
            ;;
        *  )
            error_exit "Argumento invalido"
            ;;

    esac 
done

#ps -Ao pid,%mem | sort -k2 -nr | head)
#LOGICA DEL PROGRAMA
echo "PID NºARCHIVOS COMANDO"
for pid in $(ps -Ao pid,%mem | sort -nr -k2 | awk -v n="$num" 'NR<=n {print $1}'); do
    echo "$pid $(lsof -p "$pid" | wc -l) $(ps -o comm= -p "$pid")"
done




