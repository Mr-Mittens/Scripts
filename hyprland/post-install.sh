#!/bin/bash

# Function to read yes/no responses
function __read_yn {
    echo -en "$1"
    read yn
    yn=$(echo "$yn" | tr A-Z a-z)

    if [[ $yn =~ [yY] ]]; then
        return 0
    elif [[ $yn =~ [nN] ]]; then
        return -1
    elif [[ -z $yn ]]; then
        return $2
    fi

    return -1
}

# Install essential packages using pacman
sudo pacman -S --needed --noconfirm \
    base-devel git zsh acpi acpid wget \
    networkmanager dhcpcd bluez bluez-utils blueman alacritty \
    pipewire pipewire-alsa pipewire-audio pipewire-jack pipewire-pulse wireplumber \
    python python-pybluez python-dotenv python-pip \
    qt5ct qt5-imageformats qt5-wayland qt6-wayland  \
    wofi dunst xdg-desktop-portal \
    brightnessctl playerctl pamixer tlp swayidle \
    grim slurp \
    swayimg thunar vim

# Install yay (AUR helper) if not already installed
if ! command -v yay &> /dev/null; then
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    cd ..
    rm -rf yay
fi

# Install additional packages using yay
yay -S --needed --noconfirm \
    swaylock-effects swww auto-cpufreq \
    hyprpaper sway-audio-idle-inhibit-git \
    ttf-jetbrains-mono-nerd otf-font-awesome nwg-look \
    oh-my-zsh-git zsh-autosuggestions

# Install Nvidia drivers if desired
if __read_yn "Install Nvidia drivers? [y/N] " -1; then
    sudo pacman -S --needed --noconfirm \
        nvidia nvidia-utils
    if __read_yn "Install envycontrol? (for optimus laptops) [y/N] "; then
        yay -S envycontrol
    fi
fi

# Install optional packages if desired
if __read_yn "Install optional packages? [Y/n] "; then
    sudo pacman -S --needed --noconfirm \
        firefox obs-studio \
        gimp mpv \
        pavucontrol-qt neofetch btop

    yay -S --needed --noconfirm \
         vscodium-bin 
fi

# Install Wine if desired
if __read_yn "Install Wine? [Y/n] "; then
    sudo pacman -S --needed --noconfirm \
        lutris wine-staging wine-mono
fi
