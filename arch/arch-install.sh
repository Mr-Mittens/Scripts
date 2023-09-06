#!/bin/bash

# Install script for Arch Linux with Hyprland
clear
echo "Ramen is cooking, sit tight!"
sleep 1

# Increase the number of parallel downloads in pacman.conf
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 10/" /etc/pacman.conf

# Use reflector to generate a mirrorlist
reflector --country "Australia,Germany,India,Taiwan,Singapore,Thailand,China" --save /etc/pacman.d/mirrorlist

# Update the archlinux-keyring
pacman --noconfirm -Sy archlinux-keyring

# Set the keyboard layout to US
loadkeys us

# Enable NTP time synchronization
timedatectl set-ntp true

# List available block devices
lsblk
echo "Enter the drive: "
read drive

# Partition the selected drive
cfdisk $drive
echo "Enter the Linux partition: "
read partition

# Format the Linux partition
mkfs.ext4 $partition

# Ask if a new EFI partition has been created
read -p "Have you created a new EFI partition? [y/n]" answer
if [[ $answer = y ]]; then
    echo "Enter EFI partition: "
    read efipartition
    mkfs.vfat -F 32 $efipartition
fi

# Mount the Linux partition
mount $partition /mnt

# Install essential packages using pacstrap
pacstrap /mnt base base-devel linux linux-firmware

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Copy this script to the new system and make it executable
sed '1,/^# Part2$/d' $(basename $0) > /mnt/arch_ramen.sh
chmod +x /mnt/arch_ramen.sh

# Chroot into the new system and run Part2
arch-chroot /mnt ./arch_ramen.sh
exit

# Part2: Configuration after chroot
clear
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc

# Generate locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Set the keyboard layout
echo "KEYMAP=us" > /etc/vconsole.conf

# Set the hostname
echo "Hostname: "
read hostname
echo $hostname > /etc/hostname

# Configure /etc/hosts
echo "127.0.0.1  localhost" >> /etc/hosts
echo "::1        localhost ip6-localhost ip6-loopback" >> /etc/hosts
echo "ff02::1    ip6-allnodes" >> /etc/hosts
echo "ff02::2    ip6-allrouters" >> /etc/hosts
echo "127.0.1.1       $hostname.localdomain $hostname" >> /etc/hosts

# Generate initramfs
mkinitcpio -P

# Set the root password
passwd

# Increase parallel downloads in pacman.conf again
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 10/" /etc/pacman.conf

# Regenerate the mirrorlist
reflector --country "Australia,Germany,India,Taiwan,Singapore,Thailand,China" --save /etc/pacman.d/mirrorlist

# Install GRUB and related packages
pacman --noconfirm -Sy grub efibootmgr os-prober

# List block devices
lsblk
echo "Enter EFI partition: "
read efipartition

# Create the EFI directory and mount the EFI partition
mkdir /boot/efi
mount $efipartition /boot/efi

# Install GRUB
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ArchLinux

# Configure GRUB options
sed -i 's/quiet/pci=noaer/g' /etc/default/grub
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=1/g' /etc/default/grub
sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/g' /etc/default/grub

# Update GRUB configuration
grub-mkconfig -o /boot/grub/grub.cfg

# Install additional packages
pacman -Sy --noconfirm networkmanager wpa_supplicant rsync zip unzip unrar fzf git vim

# Enable NetworkManager service
systemctl enable NetworkManager.service

# Add the user to the sudoers file
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
echo "Enter Username: "
read username

# Create a new user and set the password
useradd -m -G wheel -s /bin/sh $username
passwd $username

echo "Pre-Installation Finish. Reboot now !! also decide whether you want hyprland or Kde"

# Clone a my repo for the next step!
git clone https://github.com/Mr-Mittens/Scripts /home/$username/Scripts

# Change directory to Scripts/hyprland
cd /home/$username/Scripts/hyprland

# Make post-install.sh executable
chmod +x post-install.sh
