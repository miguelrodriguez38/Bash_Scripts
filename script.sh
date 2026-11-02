#!/bin/bash

#VARIABLES
TIEMPO=0
FICHEROS=0


error_exit() {
    echo "$1" >&2
    exit 1
}


usage() {
    cat << EOF
    Uso del programa:
    Listado de procesos con el numero de ficheros abiertos ordenado por tiempo
    de ejecución del proceso
    Uso: ./script.sh -P N: muestra los procesos con al menos N segundos de ejecución
         ./script.sh -f N: muestra los procesos con al menos N ficheros abiertos

EOF
}


#COMPROBACIONES

ps_is_installed() {
    type ps > /dev/null 2> /dev/null
}

if ! ps_is_installed; then
    error_exit "Error ps no esta instalado. Usar apt install lsof"
fi

lsof_is_installed() {
    type lsof > /dev/null 2> /dev/null
}

if ! lsof_is_installed; then
    error_exit "Error lsof no esta instalado. Usar apt install lsof"
fi


while [[ "$1" != "" ]]; do
    case "$1" in
        -P )
            shift
            if [[ "$1" == "" || "$1" == -* ]]; then
                error_exit "Argumento de -P invalido"
            fi
            TIEMPO=$1
            shift
            ;;
        -h | --help ) 
            usage
            exit 0
            ;;
        -f ) 
            shift
            if [[ "$1" == "" || "$1" == -* ]]; then
                error_exit "Argumento de -f invalido"
            fi
            FICHEROS=$1
            shift
            ;;
        -*)
            error_exit "Opción $1 desconocida"
        ;;
        *)
            error_exit "Argumento inválido"
        ;;
    esac
done


for pid in $(ps -e -o pid=); do
	t=$(ps -o etimes= -p "$pid" 2>/dev/null | tr -d ' ')
	[[ -z "$t" ]] && continue
	n=$(lsof -p "$pid" 2>/dev/null | wc -l)
	(( t >= TIEMPO && n >= FICHEROS )) && echo "$pid $t $n"
done | sort -k2 -n -r

# Uso: ./script.sh -P N: muestra los procesos con al menos N segundos de ejecución
#      ./script.sh -f N: muestra los procesos con al menos N ficheros abiertos
