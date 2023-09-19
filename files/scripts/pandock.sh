#!/bin/bash
set -e

red="\e[0;91m"
reset="\e[0m"

printHelp() {
    echo "UTILISATION"
    echo "  $0 [<option>]... <input-file> <output-file>"
    echo ""
    echo "OPTIONS"
    echo "    -h, --help                  : Affiche l'aide de la commande"
    echo ""
    echo "    -d, --directory <chemin>    : Exécute la commande dans le dossier dont le chemin est <chemin>"
    echo ""
}

###
### BEGIN
###

# Default values
directory=$PWD

# Parse options
while :
do
    case $1 in
        -h|--help|-\?)
            printHelp
            exit 0
            ;;
        -d|--directory)
            # Assign value to directory if value is given
            if [ "$2" ]; then
                directory=$2
                shift
            else
                echo -e "${red}--file requiert un argument non vide.${reset}" >&2
            fi
            ;;
        --directory=?*)
            # Delete everything up to "=" and assign what remains to directory
            directory=${1#*=}
            ;;
        --directory=)
            echo -e "${red}--file requiert un argument non vide.${reset}" >&2
            ;;
        --)
            # End of all options
            shift
            break
            ;;
        -?*)
            # Unknown option
            echo -e "${red}Option non prise en charge (ignorée): $1.${reset}" >&2
            ;;
        *)
            # Default case: No more options, so break out of the loop
            break
    esac
    shift
done

if [ $# -ne 2  ]
then
    echo -e "${red}Mauvais nombre d'arguments : $# trouvé(s), 2 attendus.${reset}" >&2
    printHelp
    exit 1
fi

input_file=$1
output_file=$2

if ! [ -d $directory ]
then
    echo -e "${red}$directory n'existe pas.${reset}" >&2
    exit 1
fi

directory=$(readlink -f $directory)
if ! [ -f $directory/$input_file ]
then
    echo -e "${red}Le fichier '${input_file}' n'existe pas dans '${directory}'.${reset}" >&2
    exit 1
fi

mkdir --parents $directory/pdf
docker run -it --rm -v $directory/:/data/ docker.home-pouliquen.local/pandoc:3.1.1-alpine \
    -s \
    -V mainfont="Liberation Sans" \
    -V monofont="Liberation Mono" \
    -V linkcolor=blue \
    -V titlepage=true \
    -V titlepage-rule-color="000080" \
    -V colorlinks=true \
    -V toc-title="Table des matières" \
    -V toc-own-page=true \
    --template=eisvogel \
    --pdf-engine=xelatex \
    --toc \
    --number-sections \
    $input_file \
    --output=pdf/$output_file

exit 0

###
### END
###
