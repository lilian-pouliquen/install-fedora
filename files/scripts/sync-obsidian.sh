#!/bin/bash
set -e

red="\e[0;91m"
reset="\e[0m"

printHelp() {
    echo "UTILISATION"
    echo "  $0 start|stop"
    echo ""
    echo "OPTIONS"
    echo "    -h, --help    : Affiche l'aide de la commande"
    echo ""
}

syncStart() {
    configFile="$HOME/.config/sync-obsidian/directories.conf"

    # Check if config file exists and is not empty
    if [ -f $configFile ] && [ -s $configFile ]
    then
        # Start the process
        echo "[sync-obsidian] Démarrage du processus de synchronisation du coffre Obsidian"
        while true;
        do
            echo "[sync-obsidian] Synchronisation des dossiers du coffre Obsidian"
            while read line
            do
                # Check if line is a comment
                if [[ $line == \#* ]] || [ -z $line ];then continue; fi

                # Get directories paths from the current line
                IFS=':' read -ra paths <<< "$line"
                obsidianDir="$HOME/${paths[0]}"
                originalDir="$HOME/${paths[1]}"

                # Check if dirs exist
                if [ -d $obsidianDir ] && [ -d $originalDir ]
                then
                    rsync -rtuv $originalDir/* $obsidianDir
                    rsync -rtuv $obsidianDir/* $originalDir
                fi
            done < $configFile
            sleep 1m
        done
    else
        # Create configuration
        mkdir --parents $HOME/.config/sync-obsidian/
        echo -e "# Liste des répertoires à synchroniser avec le coffre Obsidian. Les chemins sont relatifs depuis le \$HOME.\n# Syntaxe :\n# chemin/vers/le/repertoire/obsidian:chemin/vers/le/repertoire/original" > $configFile
        echo "Rien à faire, le fichier de configuration est vide."
        echo "Configurez votre environnement dans le fichier suivant : $configFile"
    fi
}

syncStop() {
    # Stop the process
    processId=$(ps -C sync-obsidian -o pid,cmd | grep "sync-obsidian start" | xargs | cut -d " " -f 1)
    if [ -n "$processId" ];
    then
        echo "Arrêt de la synchronisation."
	kill $processId
    else
	echo "sync-obsidian n'est pas démarré."
    fi
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

if [ $1 = "--help" ] || [ $1 = "-h" ]; then
    printHelp
    exit 0
fi

case $1 in
    "start")
        syncStart
        exitCode=0
        ;;
    "stop")
        syncStop
        exitCode=0
        ;;
    *)
        echo -e "${red}l'argument donné n'est pas accepté.${reset}" >&2
        printHelp
        exitCode=1
        ;;
esac

exit $exitCode

###
### END
###
