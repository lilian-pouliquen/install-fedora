#!/bin/bash

red="\e[0;91m"
reset="\e[0m"

if [ $# -gt 1 ]
then
    echo -e "${red}La commande requiert exactement 0 ou 1 argument : $# donné(s).${reset}" >&2
    echo "UTILISATION"
    echo "  $0 [version]"
    exit 1
fi

docker_compose_url="https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64"

if [ $# -eq 1 ]
then
    docker_compose_version=$1
    docker_compose_url="https://github.com/docker/compose/releases/download/v${docker_compose_version}/docker-compose-linux-x86_64"
fi

if ! wget --quiet --output-document "/usr/local/sbin/docker-compose" "${docker_compose_url}"
then
    echo -e "${red}Une erreur s'est produite lors de la récupération de Docker compose. Avez-vous donné une version valide ?${reset}" >&2
    exit 1
fi

chown root:docker "/usr/local/sbin/docker-compose"
chmod 754 "/usr/local/sbin/docker-compose"

exit 0

