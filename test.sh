#!/usr/bin/env bash

clear

# Start
echo -ne "
╭─────── ArchFiery ───────╮
│  Installation starting  │
│       so sit back       │
│         relax           │
│       and enjoy         │
╰─────────────────────────╯
"
printf "\n"
echo "Arch Linux Fast Install (ArchFiery) - Version: 2023.11.06 (GPL-3.0)"
sleep 5s
printf "\n"
echo "Installation guide starts now..."
pacman -Syy
sleep 5s
# Update
printf "\n"
echo "updateing first"
pacman -Syy reflector rsync curl --noconfirm
sleep 5s
clear

# Check if multilib and community repositories are enabled
echo "Enabling multilib and community repositories"
printf "\n"
if grep -E '^\[multilib\]|^\[community\]' /etc/pacman.conf; then
    # Repositories are already enabled, remove any commented-out lines
    sed -i '/^\[multilib\]/,/^\[/ s/^#//' /etc/pacman.conf
    sed -i '/^\[community\]/,/^\[/ s/^#//' /etc/pacman.conf
else
    # Repositories are not enabled, add them
    echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist\n\n[community]\nInclude = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf
fi
sleep 5s
clear

# Installing fastest mirrors
read -pr "Do you want fastest mirrors? [Y/n] " fm
if [ "$fm" = "Y" ] || [ "$fm" = "y" ]; then
echo "Installing fastest mirrorlists"
printf "\n"
  # Backup mirrorlist
  echo "Backingup mirrorlists"
  cp -r /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
  # Archlinux mirrorlists
  printf "\n"
  echo "Archlinux-mirrorlist setup"
  reflector --verbose -l 10 -f 10 --sort rate --download-timeout 55 --save /etc/pacman.d/mirrorlist
  pacman -Syy
else
  echo "Skipping the fastert mirrorlist"
fi
sleep 5s
clear

# Setting up system clock
echo "Ensuring if the system clock is accurate."
printf "\n"
timedatectl set-ntp true
sleep 5s
clear

# Setting up drive
echo "Setting Up drive"
printf "\n"
lsblk
printf "\n"
echo "Enter the drive to install arch linux on it. (/dev/...)"
echo "Enter Drive (eg. /dev/sda or /dev/vda or /dev/nvme0n1 or something similar)"
read -pr drive
sleep 5s
clear

echo "Getting ready for creating partitions!"
echo "root and boot partitions are mandatory."
echo "home and swap partitions are optional but recommended!"
echo "Also, you can create a separate partition for timeshift backup (optional)!"
echo "Getting ready in 9 seconds"
sleep 9s
clear

printf "\n"
lsblk
printf "\n"
echo "Choose a familier disk utility tool to partition your drive!"
echo " 1. fdisk"
echo " 2. cfdisk"
echo " 3. gdisk"
echo " 4. parted"
read -pr partitionutility

case "$partitionutility" in
  1 | fdisk | Fdisk | FDISK)
  partitionutility="fdisk"
  ;;
  2 | cfdisk | Cfdisk | CFDISK)
  partitionutility="cfdisk"
  ;;
  3 | gdisk | Gdisk | GDISK)
  partitionutility="gdisk"
  ;;
  4 | parted | Parted | PARTED)
  partitionutility="parted"
  ;;
  *)
  echo "Unknown or unsupported disk utility! Default = cfdisk."
  partitionutility="cfdisk"
  ;;
esac
echo "'$partitionutility' is the selected disk utility tool for partition."
sleep 5s
clear

echo "Getting ready for formatting partitions!"
sleep 5s
"$partitionutility" "$drive"
clear

printf "\n"
lsblk
printf "\n"
echo "choose your linux file system type for formatting drives"
echo " 1. ext4"
echo " 2. xfs"
echo " 3. btrfs"
echo " 4. f2fs"
printf "\n"
echo "Note: Boot partition will be formatted in fat31 file system type."
read -pr filesystemtype

case "$filesystemtype" in
  1 | ext4 | Ext4 | EXT4)
  filesystemtype="ext4"
  ;;
  2 | xfs | Xfs | XFS)
  filesystemtype="xfs"
  ;;
  3 | btrfs | Btrfs | BTRFS)
  filesystemtype="btrfs"
  ;;
  4 | f2fs | F2fs | F2FS)
  filesystemtype="f2fs"
  ;;
  *)
  echo "Unknown or unsupported Filesystem. Default = ext4."
  filesystemtype="ext4"
  ;;
esac
echo "'$filesystemtype' is the selected file system type."
sleep 5s
clear

echo "Getting ready for formatting drives."
sleep 5s
printf "\n"
lsblk
printf "\n"
echo "Enter the root partition (eg: /dev/sda1): "
read -pr rootpartition
mkfs."$filesystemtype" "$rootpartition"
mount "$rootpartition" /mnt
clear

printf "\n"
lsblk
printf "\n"
read -pr "Did you also create separate home partition? [Y/n]: " answerhome
case "$answerhome" in
  y | Y | yes | Yes | YES)
  echo "Enter home partition (eg: /dev/sda2): "
  read -pr homepartition
  mkfs."$filesystemtype" "$homepartition"
  mkdir /mnt/home
  mount "$homepartition" /mnt/home
  ;;
  *)
  echo "Skipping home partition!"
  ;;
esac
clear

printf "\n"
lsblk
printf "\n"
read -pr "Did you also create swap partition? [Y/n]: " answerswap
case "$answerswap" in
  y | Y | yes | Yes | YES)
  echo "Enter swap partition (eg: /dev/sda3): "
  read -pr swappartition
  mkswap "$swappartition"
  swapon "$swappartition"
  ;;
  *)
  echo "Skipping Swap partition!"
  ;;
esac
clear

printf "\n"
lsblk
printf "\n"
read -pr "Do you want to use a separate boot partition or use the EFI partition ? (boot/efi): " setbootpartition
if [[ $setbootpartition == "boot" ]]; then
  echo "Setting up a separate boot partition..."
  read -pr "Enter the boot partition (e.g., /dev/sda4): " bootpartition
  mkfs.fat -F 32 "$bootpartition"
  mount "$bootpartition" /mnt/boot
else
  echo "Using the EFI partition..."
fi
sleep 5s
clear

printf "\n"
lsblk
printf "\n"
sync
sleep 5s
clear

# Installing base system...
echo "Installing Base system..."
printf "\n"
sleep 5s

# Determine processor type and install microcode
proc_type=$(lscpu)
printf "\n"
if grep -E "GenuineIntel" <<< "${proc_type}"; then
    echo "Installing Intel microcode"
    proc_ucode=intel-ucode
elif grep -E "AuthenticAMD" <<< "${proc_type}"; then
    echo "Installing AMD microcode"
    proc_ucode=amd-ucode
fi

# Determine graphics card type and build package list
gpu_type=$(lspci)
printf "\n"
packages="base base-devel linux linux-headers linux-firmware ntfs-3g nvme-cli ${proc_ucode}"

if grep -E "NVIDIA|GeForce" <<< "${gpu_type}"; then
    echo "Installing NVIDIA drivers..."
    packages+=" nvidia nvidia-utils"
elif lspci | grep 'VGA' | grep -E "Radeon|AMD"; then
    echo "Installing AMD drivers..."
    packages+=" xf86-video-amdgpu"
elif grep -E "Integrated Graphics Controller" <<< "${gpu_type}"; then
    echo "Installing integrated Graphics Controller"
    packages+=" libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils lib32-mesa"
elif grep -E "Intel Corporation UHD" <<< "${gpu_type}"; then
    echo "Installing Intel UHD Graphics"
    packages+=" libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils lib32-mesa"
else
    echo "Installing generic drivers..."
    packages+="virtualbox-host-modules-arch xf86-input-vmmouse open-vm-tools xf86-video-vmware virtualbox-guest-utils qemu qemu-arch-extra libvirt virt-manager"
fi

# Install the determined packages
pacstrap /mnt "${packages}"

# Gen fstab
echo "Generating fstab file"
printf "\n"
genfstab -U /mnt >> /mnt/etc/fstab
cat /etc/fstab
sleep 5s
clear

# Setup for post-installation
sed '1,/^#part2$/d' ArchFiery.sh > /mnt/post_install.sh
chmod +x /mnt/post_install.sh
arch-chroot /mnt ./post_install.sh
clear
sleep 5s

# Unmount drives
echo "unmounting all the drives"
printf "\n"
umount -R /mnt
sleep 5s
clear

echo -ne "
╭─────── ArchFiery ───────╮
│      Installation       │
│        completed        │
│    rebooting in 9s      │
╰─────────────────────────╯
"
printf "\n"
echo "Installation Finished. REBOOTING IN 9 SECONDS!!!"
sleep 9s
reboot

#part2
#starting post_install
echo -ne "
╭─────── ArchFiery ───────╮
│      post_install       │
│     starting in 9s      │
╰─────────────────────────╯
"
sleep 9s
clear

# Check if multilib and community repositories are enabled
echo "Enabling multilib and community repositories"
if grep -E '^\[multilib\]|^\[community\]' /etc/pacman.conf; then
    # Repositories are already enabled, remove any commented-out lines
    sed -i '/^\[multilib\]/,/^\[/ s/^#//' /etc/pacman.conf
    sed -i '/^\[community\]/,/^\[/ s/^#//' /etc/pacman.conf
else
    # Repositories are not enabled, add them
    echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist\n\n[community]\nInclude = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf
fi
sleep 5s
clear

# Installing fastest mirrors
reap -p "Do you want fastest mirrors? [Y/n] " fm
if [ "$fm" = "Y" ] || [ "$fm" = "y" ]; then
echo "Installing fastest mirrorlists"
  # Backup mirrorlist
  echo "Backingup mirrorlists"
  cp -r /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
  # Archlinux mirrorlists
  echo "Archlinux-mirrorlist setup"
  reflector --verbose -l 10 -f 10 --sort rate --download-timeout 55 --save /etc/pacman.d/mirrorlist
  pacman -Syy
else
  echo "Skipping the fastert mirrorlist"
fi
sleep 5s
clear

# Replace Asia/kolkata with your timezone
echo "Setting timezone"
printf "\n"
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
sleep 5s
clear

# Gen locale
echo "Generating locale"
printf "\n"
sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen
locale-gen
sleep 5s
clear

# Setting lang
echo "Setting LANG variable"
printf "\n"
echo "LANG=en_US.UTF-8" > /etc/locale.conf
sleep 5s
clear

# Setting console keyboard
echo "Setting console keyboard layout"
printf "\n"
echo 'KEYMAP=us' > /etc/vconsole.conf
sleep 5s
clear

# Setup hostname
echo "Set up your hostname!"
echo "Enter your computer name: "
printf "\n"
read -pr hostname
echo "$hostname" > /etc/hostname
echo "Checking hostname (/etc/hostname)"
cat /etc/hostname
sleep 5s
clear

# Setting up hosts
echo "Setting up hosts file"
printf "\n"
{
echo "127.0.0.1       localhost"
echo "::1             localhost"
echo "127.0.1.1       $hostname"
} >> /etc/hosts
cat /etc/hosts
sleep 5s
clear

# Install pkgs and tools by PACMAN..
echo "Installing pkgs and tools by PACMAN.."
printf "\n"
# Define the function to install AUR packages
install_pman_pkgs(){
  local pmanpkgs=''
  # Download the list of AUR packages from the specified URL
  wget -O pman-pkg.txt https://raw.githubusercontent.com/MikuX-Dev/ArchFiery/master/packages/pman-pkg.txt
  # Read the package names from the file
  while IFS= read -r line; do
    pmanpkgs+="$line"
  done < pman-pkg.txt
  # Install AUR packages using yay
  pacman -S --needed --noconfirm "$pmanpkgs"
}
# Execute the function
install_pman_pkgs
rm -rf pman-pkg.txt
sleep 5s
clear

# Install pkgs and tools by AUR..
echo "Installing pkgs and tools by AUR"
printf "\n"
  # yay-bin: AUR helper
  git clone https://aur.archlinux.org/yay-bin.git
  (
    cd yay-bin || exit
    makepkg -sic --noconfirm
  )
# remove dir
rm -rf yay-bin

# Install pkgs from yay-bin
echo "Installing pkgs from yay-bin"
printf "\n"
install_aur_pkgs(){
  local aurpkgs=''
  # Download the list of AUR packages from the specified URL
  wget -O aur.txt https://raw.githubusercontent.com/MikuX-Dev/ArchFiery/master/packages/aur.txt
  # Read the package names from the file
  while IFS= read -r line; do
    aurpkgs+="$line"
  done < aur.txt
  # Install AUR packages using yay
  yay -S --needed --noconfirm "$aurpkgs"
}
# Execute the function
install_aur_pkgs
rm -rf aur.txt
sleep 5s
clear

# Setting boot partition "EFI"
printf "\n"
lsblk
printf "\n"
echo "Enter the EFI partition to install bootloader. (eg: /dev/sda4): "
read -pr efipartition
efidirectory="/boot/efi/"
if [ ! -d "$efidirectory" ]; then
  mkdir -p "$efidirectory"
fi
mount "$efipartition" "$efidirectory"
sleep 5s
clear

# Install grub
printf "\n"
lsblk
printf "\n"
sleep 5s
echo "Installing grub bootloader in /boot/efi parttiton"
printf "\n"
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --recheck
grub-mkconfig -o /boot/grub/grub.cfg
sleep 5s

# os-prober
read -pr "Are you duelbooting? (Y/n): " use_os_prober
if [[ $use_os_prober =~ ^[Yy]$ ]]; then
  echo "Enabling os-prober..."
  sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/g' /etc/default/grub
  os-prober
  sleep 5s
  grub-mkconfig -o /boot/grub/grub.cfg
else
  echo "Os-prober not enabled. Generating fstab..."
fi
sleep 5s
clear

# Gen fstab
echo "Generating fstab file"
printf "\n"
genfstab -U /mnt >> /mnt/etc/fstab
cat /etc/fstab
sleep 5s
clear

#edit sudo
echo 'Defaults env_keep += "HOME"' | tee -a /etc/sudoers
sleep 5s
clear

# Personal dotfiles
echo "Setting up Personal dotfiles"
git clone https://github.com/MikuX-Dev/dotfiles.git
sleep 5s

  # shell
  echo "Installing shell"
  printf "\n"
  cp -r dotfiles/shell/bash/* /etc/skel/
  cp -r dotfiles/shell/zsh/* /etc/skel/
  cp -r dotfiles/shell/p-script/* /etc/skel/
  printf "\n"
  sleep 5s

  # theme
  echo "Installing themes"
  printf "\n"
  cp -r dotfiles/themes/themes/* /usr/share/themes/
  cp -r dotfiles/themes/icons/* /usr/share/icons/
  printf "\n"
  sleep 5s

  # config
  echo "Installing configs"
  printf "\n"
  mkdir -p /etc/skel/.config/
  cp -r dotfiles/config/* /etc/skel/.config/
  printf "\n"
  sleep 5s

  # wallpaper
  echo "Installing wallpaper"
  printf "\n"
  cp -r dotfiles/wallpaper/* /usr/share/backgrounds/
  printf "\n"
  sleep 5s

  # grub-theme
  #TODO: Grub setup;
  echo "Installing grub-theme"
  printf "\n"
  cp -r dotfiles/themes/grub/themes/* /usr/share/grub/themes/
  sed -i 's/#GRUB_THEME="/path/to/gfxtheme"/GRUB_THEME="/usr/share/grub/themes/archfiery/theme.txt"/g' /etc/default/grub
  grub-mkconfig -o /boot/grub/grub.cfg
  printf "\n"
  sleep 5s

  #remove folder
  echo "Removing dotfiles folder"
  printf "\n"
  rm -rf dotfiles/
sleep 5s
clear

# Setting root user
echo "Enter password for root user: "
passwd
sleep 5s
clear

# Setting regular user
echo "Adding regular user!"
printf "\n"
echo "Enter username to add a regular user: "
read -pr username
printf "\n"
useradd -m -G wheel -s /bin/zsh "$username"
echo "Enter password for '$username': "
passwd "$username"
sleep 5s
clear

# Adding sudo previliages to the user you created
echo "NOTE: ALWAYS REMEMBER THIS USERNAME AND PASSWORD YOU PUT JUST NOW."
printf "\n"
sleep 5s
echo "Giving sudo access to '$username'!"
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /etc/sudoers
clear
sleep 5s

# Enable services
echo "Enabling services.."
printf "\n"
#TODO: add lightdm and other services
enable_services=('irqbalance.service' 'udisks2.service' 'httpd.service' 'cronie.service' 'sshd.service')
systemctl enable "${enable_services[@]}"
sleep 5s
clear

# Clearcache
echo "Clearing cache..."
yay -Scc --noconfirm
sleep 5s
clear
