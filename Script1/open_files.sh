#!/bin/bash
#Universidad de La Laguna
#Escuela Superior de Ingeniería y Tecnología
#Grado en Ingeniería Informática
#Asignatura: Sistemas Operativos 
#Curso: 2º
#Autor: Miguel Rodríguez Reyes
#Correo: alu0101794976@ull.edu.es
#Fecha: 02/11/2026
#Archivo open_files.sh
export LC_ALL=C

#ESTRUCTURA
#VARIABLES Y CONSNTANES
#FUNCIONES
#PROCESAR LA LINEA DE COMANDOS
#COMPROBACIONES DEL ENTORNO (lsof instalado etc etc)
#LOGICA Y SALIDA
# open_files [-h] [-f regexp] [-o] [-u usuario ...] [-s]

#Procesar la linea de comandos

SORT=0
USERS=""
REGEXP=""
OFFLINE=0




error_exit() {
	echo "$1" >&2
    usage >&2
	exit 1
}

usage() {
    cat << EOF
Uso: open_files [-h | --help] [-f regexp] [-o | --offline] [-u usuario ...] [-s | --sort]

Muestra, para cada usuario, su UID, el PID de su proceso más antiguo
y el número de archivos regulares que tiene abiertos.
Por defecto se muestran los usuarios conectados (los que salen en who).

Opciones:
  -u usuario ...   Muestra solo los usuarios indicados (si existen y cumplen
                   la condición de conectado / no conectado)
  -f regexp        Cuenta solo los archivos cuya ruta encaja con la expresión regular
  -o, --offline    Muestra los usuarios no conectados en lugar de los conectados
  -s, --sort       Ordena por número de archivos, de mayor a menor
  -h, --help       Muestra esta ayuda

Variable de entorno:
  OPEN_FILES_FOLDER   Si se define, solo se cuentan los archivos dentro de ese
                      directorio y sus subdirectorios

Ejemplo:
  open_files -s -u dabreu jttoledo -f '\.log$'
EOF
}

user_exists() {
    id "$1" 2> /dev/null > /dev/null
}


while [[ "$1" != "" ]]; do
    case "$1" in
        -h | --help) 
            usage
            exit 0
        ;;
        -s | --sort) 
            SORT=1
            shift
        ;;
        -f | --file)
            shift
            if [[ "$1" == "" || "$1" == -* ]]; then
                error_exit "Falta el argumento de -f"
            fi
            REGEXP=$1
            shift
        ;;
        -u | --users)
            shift
            if [[ "$1" == "" || "$1" == -* ]]; then
                error_exit "Falta el argumento de -u"
            fi
            while [[ "$1" != "" && "$1" != -* ]]; do
                USERS="$USERS $1"
                shift
            done
        ;;
        -o | --offline)
            OFFLINE=1
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


# Comprobaciones:

# - lsof instalado
# - los usuarios existen
# - archivo existe
# - opciones combatibles

directory_exist() {
	[[ -d "$1" ]]
}

get_all_users() {
    awk -F: '{print $1}' /etc/passwd | sort | uniq
}

get_offline_users() {
    comm -2 -3 <(get_all_users)  <(get_connected_users)
}



if [[ -n "$OPEN_FILES_FOLDER" ]] && ! directory_exist "$OPEN_FILES_FOLDER"; then
    error_exit "OPEN_FILES_FOLDER no es un directorio válido: $OPEN_FILES_FOLDER"
fi

lsof_is_installed() {
    type lsof > /dev/null 2> /dev/null
}


if ! lsof_is_installed; then
    error_exit "Error lsof no esta instalado. Usar apt install lsof"
fi




get_user_id() {
	id -u "$1" 2> /dev/null
}

get_oldest_process() {
    local pid
	pid=$(ps -u "$1" -o pid= --sort=-etimes 2> /dev/null | awk 'NR==1 {print $1}')
    echo "${pid:-NA}"
}

get_open_files() {
	local salida
	if [[ -n "$OPEN_FILES_FOLDER" ]]; then
		salida=$(lsof -a -u "$1" +D "$OPEN_FILES_FOLDER" 2> /dev/null)
	else
		salida=$(lsof -u "$1" 2> /dev/null)
	fi
	echo "$salida" | awk -v re="$REGEXP" '$5 == "REG" && $NF ~ re' | wc -l
}

get_connected_users() {
    w -h | awk '{print $1}' | sort | uniq
}


if [[ -z "$USERS" ]]; then
    if [[ $OFFLINE = 1 ]]; then
        USERS=$(get_offline_users)
    else 
        USERS=$(get_connected_users)
    fi
else 
    for user in $USERS; do
	    if ! user_exists "$user"; then
		    error_exit "El usuario $user no existe"
	    fi
    done

    if [[ $OFFLINE = 1 ]]; then
        REFERENCIA=$(get_offline_users)
    else
        REFERENCIA=$(get_connected_users)
    fi

    USERS=$(comm -1 -2 <(printf '%s\n' $USERS | sort) <(echo "$REFERENCIA"))

fi




# 2: Lógica del programa

SORT_CMD="sort -k1,1"
if [[ $SORT = 1 ]]; then
	SORT_CMD="sort -k4,4nr -k1,1"
fi

FORMATO="%-12s %10s %s %s\n"
printf "$FORMATO" USUARIO UID PID_ANTIGUO N_ARCHIVOS
for user in $USERS; do
	printf "$FORMATO" "$user" "$(get_user_id $user)" "$(get_oldest_process $user)" "$(get_open_files $user)"
done | $SORT_CMD