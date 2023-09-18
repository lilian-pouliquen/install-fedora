#!/bin/bash
set -e

red="\e[0;91m"
reset="\e[0m"

printHelp() {
    echo "UTILISATION"
    echo "  $0 <input-file> <output-file>"
    echo ""
    echo "OPTIONS"
    echo "    -h, --help    : Affiche l'aide de la commande"
    echo ""
}

###
### BEGIN
###

if [ $# -eq 1 ] && ([ $1 = "--help" ] || [ $1 = "-h" ])
then
    printHelp
    exit 0
fi

if [ $# -ne 2 ]
then
    echo -e "${red}La commande requiert exactement 2 argument : $# trouvé(s)${reset}" >&2
    printHelp
    exit 1
fi

for arg in "$@"
do
    if [ $arg = "--help" ] || [ $arg = "-h" ]
    then
        printHelp
        exit 0
    fi
done

input_file=$1
output_file=$2

if ! [ -f $PWD/$input_file ]
then
    echo -e "${red}Le fichier ${input_file} n'existe pas.${reset}" >&2
    exit 1
fi

mkdir --parents $PWD/pdf
docker run -it --rm -v $PWD/:/data/ docker.home-pouliquen.local/pandoc:3.1.1-alpine \
    -s \
    -V mainfont="Liberation Sans" \
    -V monofont="Liberation Mono" \
    -V titlepage=true \
    -V titlepage-rule-color="000080" \
    -V toc-title="Table des matières" \
    -V toc-own-page=true \
    -V listings-no-page-break=true \
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
