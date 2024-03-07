#!/bin/bash
set -e

#
# VARIABLES
#
red="\e[0;91m"
reset="\e[0m"
config_dir="${XDG_CONFIG_HOME:-"${HOME}/.config"}"

#
# FUNCTIONS
#
printHelp() {
    echo "UTILISATION"
    echo "  $0 start|stop"
    echo ""
    echo "OPTIONS"
    echo "    -h, --help    : Affiche l'aide de la commande"
    echo ""
}

syncStart() {
    # Checking if process is not already running
    if [ "$(pgrep --count --full "sync-obsidian start")" -gt 1 ]
    then
        echo "[sync-obsidian] La synchronisation est déjà démarrée."
        return
    fi

    # Getting config file path
    config_file="${config_dir}/sync-obsidian/directories.conf"

    # Check if config file exists and is not empty
    if [ -f "${config_file}" ] && [ -s "${config_file}" ]
    then
        # Start the process
        echo "[sync-obsidian] Démarrage du processus de synchronisation du coffre Obsidian"
        while true;
        do
            echo "[sync-obsidian] Synchronisation des dossiers du coffre Obsidian"
            while read -r line
            do
                # Check if line is a comment
                if echo "${line}" | grep --quiet --regexp "#.*" || [ -z "${line}" ]
                then
                    continue
                fi

                # Get directories paths from the current line
                readarray -d ':' -t paths <<< "${line}" 
                obsidian_dir="${HOME}/$(echo "${paths[0]}" | tr --delete '\n')"
                original_dir="${HOME}/$(echo "${paths[1]}" | tr --delete '\n')"

                # Check if dirs exist
                if [ -d "${obsidian_dir}" ] && [ -d "${original_dir}" ]
                then
                    rsync --recursive --times --update --verbose "${original_dir}/"* "${obsidian_dir}"
                    rsync --recursive --times --update --verbose "${obsidian_dir}/"* "${original_dir}"
                else
                    echo "[sync-obsidian] L'un des dossiers suivants, si ce n'est les deux, n'existe pas :"
                    echo "    * Dossier d'origine  ; ${original_dir}"
                    echo "    * Dossier Obsidienne : ${obsidian_dir}"
                fi
            done < "${config_file}"
            sleep 1m
        done
    else
        # Create configuration
        mkdir --parents "${config_dir}/sync-obsidian/"
        echo -e "# Liste des répertoires à synchroniser avec le coffre Obsidian. Les chemins sont relatifs depuis le \$HOME.\n# Syntaxe :\n# chemin/vers/le/repertoire/obsidian:chemin/vers/le/repertoire/original" > "${config_file}"
        echo "Rien à faire, le fichier de configuration est vide."
        echo "Configurez votre environnement dans le fichier suivant : ${config_file}"
    fi
}

syncStop() {
    # Stop the process if it exists
    echo "[sync-obsidian] Arrêt de la synchronisation."
    pkill --full "sync-obsidian start"
}

###
### BEGIN
###

if [ $# -ne 1 ]
then
    echo -e "${red}La commande requiert exactement 1 argument : $# trouvé(s)${reset}" >&2
    printHelp
    exit 1
fi

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    printHelp
    exit 0
fi

case "$1" in
    "start")
        syncStart
        exit_code=0
        ;;
    "stop")
        syncStop
        exit_code=0
        ;;
    *)
        echo -e "${red}l'argument donné n'est pas accepté.${reset}" >&2
        printHelp
        exit_code=1
        ;;
esac

exit ${exit_code}

###
### END
###

