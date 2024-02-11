#!/bin/bash
set -e

#
# VARIABLES
#
green="\e[0;92m"
red="\e[0;91m"
reset="\e[0m"

#
# FUNCTIONS
#
defaultInstall() {
    ## Adding Flathub to user dependencies
    flatpak remote-add --user --if-not-exists flathub "https://flathub.org/repo/flathub.flatpakrepo"

    ## Configurations
    echo -e "${green}[ CONFIGURATIONS DIVERSES ]${reset}"
    mkdir --parents "${HOME}/bin/"
    cp "./files/home/user/.config/mimeapps.list" "${HOME}/.config/mimeapps.list"

    ## Preparing apps dir and app icon dirs
    mkdir --parents \
        "${HOME}/applications/" \
        "${HOME}/.local/share/icons/hicolor/128x128/apps/" \
        "${HOME}/.local/share/icons/hicolor/512x512/apps/" \
        "${HOME}/.local/share/icons/hicolor/scalable/apps/"
}

systemInstall() {
    ## Installing last driver packages
    echo -e "${green}[ INSTALLATION DES DERNIERS PILOTES ]${reset}"
    sudo dnf install --assumeyes \
        akmod-nvidia \
        steam-devices

    ## Keeping only Flathub flatpak remote
    unset flatpak_remotes
    readarray -t flatpak_remotes <<< "$(flatpak remote-list --show-disabled --columns=name)"
    for remote_name in "${flatpak_remotes[@]}"; do
        if [ "${remote_name}" != 'flathub' ]; then
            sudo flatpak remote-delete "${remote_name}"
        fi
    done

    ## Disabling systemd-resolved for OpenVPN to work well with custom DNS
    sudo systemctl disable --now systemd-resolved
    sudo rm "/etc/resolv.conf"
    sudo systemctl restart NetworkManager

    ## Creating Docker certificate directory
    echo -e "${green}[ CRÉATION DU RÉPERTOIRE DE CERTIFICATS SSL DOCKER ]${reset}"
    sudo mkdir --parents "/etc/docker/certs.d/"

    ## Installing SSH autocompletion
    sudo cp "./files/etc/bash_completion.d/ssh_completion" "/etc/bash_completion.d/ssh"
    sudo chown root:root "/etc/bash_completion.d/ssh"
    sudo chmod 644 "/etc/bash_completion.d/ssh"

    ## Installing custom commands
    echo -e "${green}[ INSTALLATION DES COMMANDES PERSONNALISÉES ]${reset}"
    ### BTOP++ update
    sudo cp "./files/usr/local/sbin/update-btop.sh" "/usr/local/sbin/update-btop"
    sudo chown root:root "/usr/local/sbin/update-btop"
    sudo chmod 744 "/usr/local/sbin/update-btop"
    ### Docker compose update
    sudo cp "./files/usr/local/sbin/update-docker-compose.sh" "/usr/local/sbin/update-docker-compose"
    sudo chown root:root "/usr/local/sbin/update-docker-compose"
    sudo chmod 744 "/usr/local/sbin/update-docker-compose"
    ### Open VM
    sudo cp "./files/usr/local/bin/openvm.sh" "/usr/local/bin/openvm"
    sudo chown root:root "/usr/local/bin/openvm"
    sudo chmod 755 "/usr/local/bin/openvm"
    ### Pandock
    sudo cp "./files/usr/local/bin/pandock.sh" "/usr/local/bin/pandock"
    sudo chown root:root "/usr/local/bin/pandock"
    sudo chmod 755 "/usr/local/bin/pandock"
    ### Sync Obsidian
    sudo cp "./files/usr/local/bin/sync-obsidian.sh" "/usr/local/bin/sync-obsidian"
    sudo chown root:root "/usr/local/bin/sync-obsidian"
    sudo chmod 755 "/usr/local/bin/sync-obsidian"

    ## Using custom commands to install apps
    echo -e "${green}[ INSTALLATION AVEC LES COMMANDES PERSONNALISÉES ]${reset}"
    ## BTOP++
    sudo update-btop

    ## App icons
    echo -e "${green}[ CRÉATION DES ICONES DE BUREAU ]${reset}"
    ### Creating required directories
    sudo mkdir --parents \
        "/usr/local/share/icons/hicolor/512x512/apps/" \
        "/usr/local/share/icons/hicolor/scalable/apps/" \
        "/usr/local/share/applications/"
    ### tmux
    sudo cp "./files/usr/local/share/icons/hicolor/512x512/apps/tmux.png" "/usr/local/share/icons/hicolor/512x512/apps/tmux.png"
    sudo cp "./files/usr/local/share/icons/hicolor/scalable/apps/tmux.svg" "/usr/local/share/icons/hicolor/scalable/apps/tmux.svg"
    sudo cp "./files/usr/local/share/applications/tmux.desktop" "/usr/local/share/applications/tmux.desktop"

    ## Backgrounds
    echo -e "${green}[ AJOUT DU SET DE FONDS D'ÉCRANS FEDORA ]${reset}"
    ### Creating required directories
    sudo mkdir --parents \
        "/usr/share/backgrounds/custom/f35/"
    ### Installing backgrounds
    sudo cp "./files/usr/share/backgrounds/custom/f35/f35-day.png" "/usr/share/backgrounds/custom/f35/f35-day.png"
    sudo cp "./files/usr/share/backgrounds/custom/f35/f35-night.png" "/usr/share/backgrounds/custom/f35/f35-night.png"
    ### Installing background set configurations
    sudo cp "./files/usr/share/gnome-background-properties/f35.xml" "/usr/share/gnome-background-properties/f35.xml"
    sudo cp "./files/usr/share/backgrounds/custom/f35/f35.xml" "/usr/share/backgrounds/custom/f35/f35.xml"
}

miscellaneousInstall() {
    ## Installing miscellaneous apps
    ### Ledger live
    echo -e "${green}[ INSTALLATION DE LEDGER-LIVE ]${reset}"
    mkdir --parents "${HOME}/applications/ledger/"
    wget --quiet --output-document "${HOME}/applications/ledger/ledger-live" "https://download.live.ledger.com/latest/linux"
    chmod 755 "${HOME}/applications/ledger/ledger-live"
    wget --quiet --output-document - "https://raw.githubusercontent.com/LedgerHQ/udev-rules/master/add_udev_rules.sh" | sudo bash

    cp "./files/home/user/.local/share/icons/hicolor/512x512/apps/ledger_live.png" "${HOME}/.local/share/icons/hicolor/512x512/apps/ledger_live.png"
    cp "./files/home/user/.local/share/icons/hicolor/scalable/apps/ledger_live.svg" "${HOME}/.local/share/icons/hicolor/scalable/apps/ledger_live.svg"
    cp "./files/home/user/.local/share/applications/ledger_live.desktop" "${HOME}/.local/share/applications/ledger_live.desktop"
}

devInstall() {
    ## Creating git directories
    echo -e "${green}[ CRÉATION DES RÉPERTOIRES GIT ]${reset}"
    mkdir --parents \
      "${HOME}/git/" \
      "${HOME}/.git-certs/"

    ## Installing Flatpak development apps for user
    echo -e "${green}[ INSTALLATION DES APPLICATIONS FLATPAK POUR LE DÉVELOPPEMENT ]${reset}"
    flatpak install --user --assumeyes flathub \
        com.vscodium.codium

    ## Installing Webstorm
    unset webstorm_folder_name
    wget --quiet --output-document "/tmp/webstorm.tar.gz" "https://download.jetbrains.com/webstorm/WebStorm-2023.3.2.tar.gz"
    webstorm_folder_name=$(tar --exclude='*/*' --list --file "/tmp/webstorm.tar.gz" | uniq)
    tar --directory "${HOME}/applications/" --extract --overwrite --file="/tmp/webstorm.tar.gz"
    mv "${HOME}/applications/${webstorm_folder_name}" "${HOME}/applications/webstorm/"

    ## Adding Webstorm desktop icon
    cp "${HOME}/applications/webstorm/bin/webstorm.png" "${HOME}/.local/share/icons/hicolor/128x128/apps/webstorm.png"
    cp "${HOME}/applications/webstorm/bin/webstorm.svg" "${HOME}/.local/share/icons/hicolor/scalable/apps/webstorm.svg"
    cp "./files/home/user/.local/share/applications/webstorm.desktop" "${HOME}/.local/share/applications/webstorm.desktop"

    ## Installing NVChad vor NeoVim
    git clone "https://github.com/NvChad/starter" "${HOME}/.config/nvim"

}

gamingInstall() {
    ## Creating user games directory
    mkdir --parents "${HOME}/Games/"

    ## Installing Flatpak gaming apps for user
    echo -e "${green}[ INSTALLATION DES APPLICATIONS FLATPAK POUR LES JEUX ]${reset}"
    flatpak install --user --assumeyes flathub \
        com.heroicgameslauncher.hgl \
        com.usebottles.bottles \
        com.valvesoftware.Steam \
        io.github.hmlendea.geforcenow-electron

    ## Minecraft
    echo -e "${green}[ INSTALLATION DE MINECRAFT ]${reset}"
    wget --quiet --output-document "${HOME}/Games/minecraft-launcher.tar.gz" "https://launcher.mojang.com/download/Minecraft.tar.gz"
    tar --directory "${HOME}/Games/" -zxf "${HOME}/Games/minecraft-launcher.tar.gz"
    chmod 755 "${HOME}/Games/minecraft-launcher/minecraft-launcher"
    rm "${HOME}/Games/minecraft-launcher.tar.gz"
    cp "./files/home/user/.local/share/icons/hicolor/512x512/apps/minecraft.png" "${HOME}/.local/share/icons/hicolor/512x512/apps/minecraft.png"
    cp "./files/home/user/.local/share/icons/hicolor/scalable/apps/minecraft.svg" "${HOME}/.local/share/icons/hicolor/scalable/apps/minecraft.svg"
    cp "./files/home/user/.local/share/applications/minecraft.desktop" "${HOME}/.local/share/applications/minecraft.desktop"
}

printNextSteps() {
    local system=$1
    local dev=$2
    local gaming=$3
    local misc=$4

    echo -e "${green}[ ÉTAPES SUIVANTES ]${reset}"
    echo ""
    echo "    Les étapes qui suivent sont à faire manuellement :"
    echo "    Si une carte Nvidia est utilisée :"
    echo "      - reboot"
    echo "      - flatpak update --assumeyes"

    if [ "${gaming}" -eq 1 ]; then
        echo "    Installer les jeux :"
        echo "      - FTB App                         : https://feed-the-beast.com/app"
        echo "      - Minecraft Dungeons (Bottles)    : https://launcher.mojang.com/download/MinecraftInstaller.msi"
        echo "      - Genshin Impact (Bottles)        : https://ys-api-os.mihoyo.com/event/download_porter/link/ys_global/genshinimpactpc/default"
        echo ""
    fi

    if [ "${dev}" -eq 1 ]; then
        echo "    Ajouter l'utilisateur au groupe docker :"
        echo "      - sudo usermod -aG docker,libvirt ${USER}"
        echo ""
        echo "    Restaurer :"
        echo "      - Clefs SSH"
        echo "      - Clef GPG"
        echo "      - Certificats VPN"
        echo "      - Certificats SSL privés"
        echo ""
        echo "    Configuration de Git :"
        echo "      - git config --global commit.gpgSign true"
        echo "      - git config --global init.defaultBranch master"
        echo "      - git config --global tag.gpgSign true"
        echo "      - git config --global user.email <email>"
        echo "      - git config --global user.name <name>"
        echo "      - git config --global user.signingKey <gpg-key-id>"
        echo "      - git config --global http.sslCAInfo ${HOME}/.git-certs/<certificats>"
        echo ""
    fi
}

printHelp() {
    echo ""
    echo -e "${green}[ UTILISATION ]${reset}"
    echo "    $0 [options]"
    echo ""
    echo -e "${green}[ OPTIONS DISPONIBLES ]${reset}"
    echo "    --help         : Affiche la documentation de la commande."
    echo "    --system       : Met à jour et installe des paquets avec dnf et configure le système. (requiert les privilèges d'administrateur)"
    echo "    --misc         : Installe Ledger live. (requiert les privilèges d'administrateur)"
    echo "    --dev          : Prépare le compte pour le développement."
    echo "    --gaming       : Prépare le compte pour jouer aux jeux vidéos."
    echo "    --all          : Équivaut à --system --misc --dev --gaming"
    echo ""
}

#
# BEGIN
#

# Requirements verifications
if ! [ -f "${PWD}/postinstall-fedora.sh" ]; then
    echo -e "${red}Vous devez exécuter ce script depuis le dossier contenant ce dernier.${reset}"
    exit 1
fi

# Args variables
system=0
dev=0
gaming=0
misc=0

# Arguments handling
for opt in "$@"; do
    case "$opt" in
    "--help")
        printHelp
        exit 0
        ;;
    "--all")
        system=1
        dev=1
        gaming=1
        misc=1
        ;;
    "--system")
        system=1
        ;;
    "--dev")
        dev=1
        ;;
    "--gaming")
        gaming=1
        ;;
    "--misc")
        misc=1
        ;;
    *)
        echo "Argument invalide : $opt" >&2
        exit 1
        ;;
    esac
done

# Default installation
defaultInstall

# Specific installations
if [ $system -eq 1 ]; then
    systemInstall
fi

if [ $misc -eq 1 ]; then
    miscellaneousInstall
fi

if [ $dev -eq 1 ]; then
    devInstall
fi

if [ $gaming -eq 1 ]; then
    gamingInstall
fi

printNextSteps $system $dev $gaming $misc

echo ""
echo -e "${green}[ POST-INSTALLATION TERMINÉE ]${reset}"
echo ""

#
# End
#
exit 0
