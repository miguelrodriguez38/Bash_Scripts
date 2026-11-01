#!/bin/bash
export LC_ALL=C #Sort uniq y comm usen el mismo criterio de ordenacion

#VARIABLES
OFFLINE=0
SORT=0
ARCHIVO_OPCION_F=""
USERS=""
CONECTADOS=""



usage () {
    cat << _EOF_
Uso: open_files [-h | --help] [-f regexp] [-o | --offline] [-u usuario ...] [-s | --sort]

Muestra, por usuario, el número de archivos regulares abiertos (según lsof).

Opciones:
  -h, --help       Muestra esta ayuda y termina.
  -f regexp        Cuenta solo los archivos cuya ruta encaje con la expresión regular extendida.
  -o, --offline    Muestra los usuarios NO conectados en vez de los conectados.
  -u usuario ...   Muestra solo los usuarios indicados (lista separada por espacios).
  -s, --sort       Ordena por número de archivos, de mayor a menor.

Variable de entorno:
  OPEN_FILES_FOLDER  Si está definida, solo se cuentan archivos dentro de ese directorio.
_EOF_
}

exit_error () {
    echo "$1" >&2 
    exit 1  
}

lsof_is_installed () {
    type lsof > /dev/null 2> /dev/null
}

connected_user () {
    w | awk 'NR>2 {print $1}' | sort | uniq
}

count_files () {
    if [[ -n "$OPEN_FILES_FOLDER" ]]; then
        lsof -a -u "$1" +D "$OPEN_FILES_FOLDER" 2> /dev/null | awk -v R="$ARCHIVO_OPCION_F" '$5=="REG" && $NF ~ R'  | wc -l  #la opcion -a te da ambas condicones (AND) que cumpla que pertenecen al usuario y ademas que esten en la ruta especificada
    else
        lsof -u "$1" 2> /dev/null | awk -v R="$ARCHIVO_OPCION_F" '$5=="REG" && $NF ~ R' | wc -l
    fi
}




#PROCESAR LA LINEA DE COMANDOS
while [[ "$1" != "" ]]; do
    case "$1" in 
        -h | --help ) 
            usage
            exit 0
            ;;
        -o | --offline ) 
            OFFLINE=1
            shift
            ;;
        -s | --sort ) 
            SORT=1
            shift
            ;;
        -f )
            shift
            if [[ "$1" == ""  || "$1" == -* ]]; then
                exit_error "Falta el argumento de -f"
            fi
            ARCHIVO_OPCION_F=$1
            shift
            ;;
        -u )
            shift
            if [[ "$1" == ""  || "$1" == -* ]]; then
                exit_error "Error, introducida la opcion -u y no se ha proporcionado ningun usuario"
            fi
            while [[ "$1" != "" && "$1" != -* ]]; do
                USERS="$USERS$1"
                USERS="$USERS "
                shift
            done
            ;;
        -* )
            usage >&2
            exit_error "Opcion no soportada"
            ;;
        * ) 
            exit_error "Argumento suelto error"
            ;;
    esac
done

#COMPROBACIONES
if ! lsof_is_installed; then
    exit_error "Error lsof no esta instalado"
fi

if [[ ! -z "$OPEN_FILES_FOLDER" ]]; then
    if [[ ! -e "$OPEN_FILES_FOLDER" ]]; then
        exit_error "La ruta no existe"
    fi
    if [[ ! -d "$OPEN_FILES_FOLDER" ]]; then
        exit_error "No es un directorio"
    fi
fi
    
if [[ ! -z "$USERS" ]]; then
    for USUARIO in $USERS; do
        if ! id "$USUARIO" > /dev/null 2> /dev/null ; then
            exit_error "No existe $USUARIO "
        fi
    done
fi



imprimir_usuarios() {
    if [[ "$OFFLINE" == 0 ]]; then
        if [[ ! -z "$USERS" ]]; then 
            comm -12 <(echo "$CONECTADOS") <(echo $USERS | tr ' ' '\n' | sort | uniq)
        else  #si no se emplea la opcion -u
            echo "$CONECTADOS"
        fi
    else 
        if [[ -z "$USERS" ]]; then
            comm -23 <(cat /etc/passwd | cut -d: -f1 | sort | uniq) <(echo "$CONECTADOS")
        else #si se emplea la opcion u
            comm -12 <(comm -23 <(cat /etc/passwd | cut -d: -f1 | sort | uniq)  <(echo "$CONECTADOS")) <(echo $USERS | tr ' ' '\n' | sort | uniq)
        fi
    fi
}

Mostrar_Proceso() {
    if [[ $(ps -u "$1" -o pid,etimes | wc -l) -gt 1 ]]; then
        ps -u "$1" -o pid,etimes | sort -nr -k2 | awk 'NR==1 {print $1}'
    else 
        echo "NA"
    fi
}

CONECTADOS=$(connected_user)


printf "%-10s %5s %15s %10s\n" "USUARIO" "UID" "PID_ANTIGUO" "N_ARCHIVOS"


Imprimir_tabla() {
    for conectado in $(imprimir_usuarios); do
        printf "%-10s %5s %15s %10s\n" "$conectado" "$(id -u "$conectado")" "$(Mostrar_Proceso "$conectado")" "$(count_files "$conectado")"
    done
}

if [[ "$SORT" == 1 ]]; then
    Imprimir_tabla | sort -k4,4nr -k1,1 #Ordena por cuarta columna por numero y de mayor a menor y sino desempata comparando alfabteicamente la primera columna
else
    Imprimir_tabla
fi




