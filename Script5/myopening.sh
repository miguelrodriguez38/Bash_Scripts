#!/bin/bash
#Universidad de La Laguna
#Escuela Superior de Ingeniería y Tecnología
#Grado en Ingeniería Informática
#Asignatura: Sistemas Operativos 
#Curso: 2º
#Autor: Miguel Rodríguez Reyes
#Correo: alu0101794976@ull.edu.es
#Fecha: 02/11/2026
#Archivo myopening.sh

USERS=""
OPCION_P=0
OPCION_U=0


#FUNCIONES
error_exit() {
    echo "$1" >&2 
    exit 1
}

isvalidusuerarg() {
    if [ -z "$1" ]; then
        return 1;
    fi
    [[ ! $1 =~ ^-.* ]]
}

usage () {
    cat << 'EOF'
1.- Si se llama sin opciones mostrará una lista de las aperturas de archivo del usuario de la
sesión actual según salida del comando lsof con la opción -u nombre_de_usuario.
Recuerda que el nombre del usuario de la sesión actual lo puedes obtener de la variable
$USER. Se deben mostrar solo los campos correspondientes a las columnas COMMAND y
PID de lsof.

2.- SI se llama con la opción -p seguida de un número de PID, se mostrará lo siguiente:
procedente de lsof, el número de aperturas de archivo del proceso seleccionado por PID y
procedente del comando ps el tiempo transcurrido desde que fue iniciado (campo etime de
ps)
Nota: lsof -p número_de_pid: devuelve las aperturas de archivo de proceso
ps -p numero_de_pid -oetime: devuelve elapsed time del procesos

3.-Si se llama con la opción -u seguida de una lista de usuarios de tamaño definido y
separada por espacios se mostrará para cada usuario de aperturas de archivos. Pasta
implementar esta opción tendrás que usar está función:
EOF
}




#PROCESAR LINEA DE COMANDOS
while [[ "$1" != "" ]]; do
    case "$1" in 
        -u | --users ) 
            OPCION_U=1
            shift
            while isvalidusuerarg "$1"; do
                USERS="$USERS$1 "
                shift
            done
            ;;
        -p )
            shift
            if [[ "$1" == "" || "$1" == -* ]]; then
                error_exit "Argumento de -p inválido"
            fi
            OPCION_P=$1
            shift
            ;;
        -h | --help ) 
            usage
            exit 1
            ;;
        -*) 
            error_exit "Arguemento invalido"
            ;;
        *)
            error_exit "Error, pruebe a usar el comando --help"
            ;;
    esac
done


#NO SE PUEDEN USAR -p Y -u A LA VEZ
if [[ "$OPCION_P" -ne 0 && "$OPCION_U" -eq 1 ]]; then
    error_exit "No se puede usar la opcion -p y -u a la vez"
fi


#COMPROBACIÓN DE QUE EL USUARIO EXISTE
if [[ ! -z "$USERS" ]]; then
    for USUARIO in $USERS; do
        if ! id "$USUARIO" > /dev/null 2> /dev/null ; then
            error_exit "No existe $USUARIO "
        fi
    done
fi


#LOGICA
if [[ -z "$USERS" && "$OPCION_P" -eq 0 ]]; then 
    lsof -u $USER | awk '{print $1,$2}'
else 
    if [[ ! -z "$USERS" ]]; then
        for usuario in $USERS; do
            lsof -u "$usuario"
        done
    else
        printf "%-10s %10s\n" "NºAPERTURAS" "TIEMPO_TRANSUCRRIDO"
        printf "%-10s %10s\n" "$(lsof -p "$OPCION_P" | awk 'NR>1' | wc -l)" "$(ps -p "$OPCION_P" -o etime | awk 'NR==2')"
    fi
fi


