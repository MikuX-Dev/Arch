#!/usr/bin/env bash

clear

# Start
echo -ne "
╭─────── ArchFiery ───────╮
│  Installation starting  │
│      so sit back        │
│         relax           │
│       and enjoy         │
╰─────────────────────────╯
"
echo "Arch Linux Fast Install (ArchFiery) - Version: 2023.27.10 (GPL-3.0)"
sleep 5s
echo -ne "\n"
echo "Installation guide starts now..."
pacman -Syy
sleep 5s
# Update
echo -ne "\n"
echo "updateing first"
pacman -Syy reflector rsync curl --noconfirm
sleep 5s
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
read -p "Do you want fastest mirrors? [Y/n] " fm
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

# Setting up system clock
echo "Ensuring if the system clock is accurate."
timedatectl set-ntp true
sleep 5s
clear

# Setting up drive
echo "Setting Up drive"
echo -ne "\n"
lsblk
echo -ne "\n"
echo "Enter the drive to install arch linux on it. (/dev/...)"
echo "Enter Drive (eg. /dev/sda or /dev/vda or /dev/nvme0n1 or something similar)"
read drive
sleep 5s
clear

echo "Getting ready for creating partitions!"
echo "root and boot partitions are mandatory."
echo "home and swap partitions are optional but recommended!"
echo "Also, you can create a separate partition for timeshift backup (optional)!"
echo "Getting ready in 9 seconds"
sleep 9s
clear

echo -ne "\n"
lsblk
echo -ne "\n"
echo "Choose a familier disk utility tool to partition your drive!"
echo " 1. fdisk"
echo " 2. cfdisk"
echo " 3. gdisk"
echo " 4. parted"
read partitionutility

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
echo ""$partitionutility" is the selected disk utility tool for partition."
sleep 5s
clear

echo "Getting ready for formatting partitions!"
sleep 5s
"$partitionutility" "$drive"
clear

echo -ne "\n"
lsblk
echo -ne "\n"
echo "choose your linux file system type for formatting drives"
echo " 1. ext4"
echo " 2. xfs"
echo " 3. btrfs"
echo " 4. f2fs"
echo -ne "\n"
echo "Note: Boot partition will be formatted in fat31 file system type."
read filesystemtype

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
echo ""$filesystemtype" is the selected file system type."
sleep 5s
clear

echo "Getting ready for formatting drives."
echo -ne "\n"
sleep 5s
lsblk
echo -ne "\n"
echo "Enter the root partition (eg: /dev/sda1): "
read rootpartition
mkfs."$filesystemtype" "$rootpartition"
mount "$rootpartition" /mnt
clear

lsblk\n
read -p "Did you also create separate home partition? [Y/n]: " answerhome
case "$answerhome" in
  y | Y | yes | Yes | YES)
  echo "Enter home partition (eg: /dev/sda2): "
  read homepartition
  mkfs."$filesystemtype" "$homepartition"
  mkdir /mnt/home
  mount "$homepartition" /mnt/home
  ;;
  *)
  echo "Skipping home partition!"
  ;;
esac
clear

echo -ne "\n"
lsblk
echo -ne "\n"
read -p "Did you also create swap partition? [Y/n]: " answerswap
case "$answerswap" in
  y | Y | yes | Yes | YES)
  echo "Enter swap partition (eg: /dev/sda3): "
  read swappartition
  mkswap "$swappartition"
  swapon "$swappartition"
  ;;
  *)
  echo "Skipping Swap partition!"
  ;;
esac
clear

echo -ne "\n"
lsblk
echo -ne "\n"
read -p "Do you want to use a separate boot partition or use the EFI partition of windows? (boot/efi): " setbootpartition
if [[ $setbootpartition == "boot" ]]; then
  echo "Setting up a separate boot partition..."
  read -p "Enter the boot partition (e.g., /dev/sda4): " bootpartition
  mkfs.fat -F 32 "$bootpartition"
  mount "$bootpartition" /mnt/boot
else
  echo "Using the EFI partition for boot..."
fi
sleep 5s
clear

echo -ne "\n"
lsblk
echo -ne "\n"
sync
sleep 5s
clear

# Installing base system with linux kernel and intel-ucode...
echo "Installing Base system with linux kernel!!!"
sleep 5s
pacstrap /mnt base base-devel linux linux-headers linux-firmware intel-ucode ntfs-3g nvme-cli

# Gen fstab
echo "Generating fstab file"
echo -ne "\n"
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
elif
  echo "Skipping the fastert mirrorlist"
fi
sleep 5s
clear

# Replace Asia/kolkata with your timezone
echo "Setting timezone"
echo -ne "\n"
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
sleep 5s
clear

# Gen locale
echo "Generating locale"
echo -ne "\n"
sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen
locale-gen
sleep 5s
clear

# Setting lang
echo "Setting LANG variable"
echo -ne "\n"
echo "LANG=en_US.UTF-8" > /etc/locale.conf
sleep 5s
clear

# Setting console keyboard
echo "Setting console keyboard layout"
echo -ne "\n"
echo 'KEYMAP=us' > /etc/vconsole.conf
sleep 5s
clear

# Setup hostname
echo "Set up your hostname!"
echo "Enter your computer name: "
echo -ne "\n"
read hostname
echo $hostname > /etc/hostname
echo "Checking hostname (/etc/hostname)"
cat /etc/hostname
sleep 5s
clear

# Setting up hosts
echo "Setting up hosts file"
echo -ne "\n"
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $hostname" >> /etc/hosts
cat /etc/hosts
sleep 5s
clear

# Install needed pkgs and tools by PACMAN..
echo "Installing needed pkgs and tools by PACMAN.."
echo -ne "\n"
install_packages() {
  local packages=''

  #networkmanager etc..
  packages+='network-manager-applet networkmanager network-manager-applet networkmanager-openconnect networkmanager-openvpn networkmanager-pptp networkmanager-vpnc modemmanager dhclient dhcpcd'

  #video drive etc..
  packages+='xf86-video-intel xf86-video-fbdev vulkan-intel vulkan-icd-loader xf86-video-openchrome xf86-video-vesa xf86-input-void xf86-input-libinput libinput xf86-input-evdev xf86-input-elographics'

  #text editor
  packages+='vim neovim nano'

  #git
  packages+='git git-lfs'

  #archive tools
  packages+='ack xarchiver p7zip zip unzip gzip tar bzip3 unrar xz zstd'

  #dev tools
  packages+='archiso f2fs-tools automake gawk gammu gnome-keyring mtools dosfstools devtools multilib-devel npm qemu-tools qemu-emulators-full qemu-system-x86-firmware cargo make go lua perl ruby rust rustup cmake gcc gcc-libs gdb ppp rp-pppoe pptpclient reiserfsprogs  clang llvm ccache curl wget sed'

  #shell
  packages+='zsh zsh-autosuggestions zsh-history-substring-search zsh-syntax-highlighting zsh-completions bash-completion'

  #xdg
  packages+='xdg-user-dirs-gtk xdg-desktop-portal-gtk'

  #other
  packages+='arch-wiki-docs linux-firmware pkgfile intel-ucode ntfs-3g base smartmontools base-devel gvfs-mtp gvfs apache udisks2 cronie grub-customizer irqbalance plocate arch-install-scripts bind brltty broadcom-wl clonezilla darkhttpd diffutils dmraid dnsmasq edk2-shell profile-sync-daemon pacman-contrib grub efibootmgr os-prober'

  #ssh and gnupg
  packages+='openssh gnupg'

  #System
  packages+='ncdu mkinitcpio-archiso mkinitcpio-nfs-utils nfs-utils nilfs-utils nvme-cli nbd ndisc6 obsidian feh menumaker openconnect partclone gparted '

  #privacy
  packages+='tor'

  packages+='arch-install-scripts pkgfile'

  packages+='cifs-utils dmraid dosfstools exfat-utils f2fs-tools
  gpart gptfdisk mtools nilfs-utils ntfs-3g partclone parted partimage'

  packages+='acpi alsa-utils b43-fwcutter bash-completion bc cmake ctags expac
  feh git gpm haveged hdparm htop inotify-tools ipython irssi
  lsof mercurial mesa mlocate moreutils mpv p7zip rsync
  rtorrent screen scrot smartmontools strace tmux udisks2 unace unrar
  unzip upower usb_modeswitch usbutils zip zsh'

  packages+='atftp bind-tools bridge-utils curl darkhttpd dhclient dhcpcd dialog
  dnscrypt-proxy dnsmasq dnsutils fwbuilder gnu-netcat ipw2100-fw ipw2200-fw iw
  iwd lftp nfs-utils ntp openconnect openssh openvpn ppp pptpclient rfkill
  rp-pppoe socat vpnc wget wireless_tools wpa_supplicant wvdial xl2tpd'

  packages+='virtualbox-host-modules-arch virtualbox-guest-utils'
},
pacman -S --needed --noconfirm $packages
sleep 5s
clear

# Install needed pkgs and tools by AUR..
echo "Installing needed pkgs and tools by AUR"
echo -ne "\n"
  # yay-bin: AUR helper
  git clone https://aur.archlinux.org/yay-bin.git
  cd yay-bin
  makepkg -fsri
  cd ..
# remove dir
rm -rf yay-bin

# Install pkgs and tools by AUR..
echo "Installing aur pkgs"
echo -ne "\n"
install_packages() {
  local aurpkgs=''

  # mkinitcpio
  aurpkgs+='mkinitcpio-firmware mkinitcpio-numlock'
}
yay -S --needed --noconfirm $aurpkgs
sleep 5s
clear

# Setting boot partition "EFI"
echo -ne "\n"
lsblk
echo -ne "\n"
echo "Enter the EFI partition to install bootloader. (eg: /dev/sda4): "
read efipartition
efidirectory="/boot/efi/"
if [ ! -d "$efidirectory" ]; then
  mkdir -p "$efidirectory"
fi
mount "$efipartition" "$efidirectory"
sleep 5s
clear

# Install grub
echo -ne "\n"
lsblk
echo -ne "\n"
sleep 5s
echo "Installing grub bootloader in /boot/efi parttiton"
echo -ne "\n"
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --recheck
grub-mkconfig -o /boot/grub/grub.cfg
sleep 5s

# os-prober
read -p "Are you duelbooting? (Y/n): " use_os_prober
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
echo -ne "\n"
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
  echo -ne "\n"
  cp -r dotfiles/shell/bash/* /etc/skel/
  cp -r dotfiles/shell/zsh/* /etc/skel/
sleep 5s
  # theme
  echo "Installing themes"
  echo -ne "\n"
  cp -r dotfiles/themes/* /usr/share/themes/
  cp -r dotfiles/icons/* /usr/share/icons/
  sleep 5s
  # config
  echo "Installing configs"
  echo -ne "\n"
  cp -r dotfiles/config/* /etc/
  sleep 5s
  # wallpaper
  echo "Installing wallpaper"
  echo -ne "\n"
  cp -r dotfiles/wallpaper/* /usr/share/backgrounds/
  sleep 5s
  # grub-theme
--TODO: Grub setup;

  echo "Installing grub-theme"
  echo -ne "\n"
  cp -r dotfiles/themes/grub/themes/* /usr/share/grub/themes/
  sed -i 's/#GRUB_THEME="/path/to/gfxtheme"/GRUB_THEME="/usr/share/grub/themes/archfiery/theme.txt"/g' /etc/default/grub
  grub-mkconfig -o /boot/grub/grub.cfg
  sleep 5s
  #remove folder
  echo "Removing dotfiles folder"
  echo -ne "\n"
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
echo "Enter username to add a regular user: "
read username
echo -ne "\n"
useradd -m -G wheel -s /bin/zsh $username
echo "Enter password for "$username": "
passwd $username
sleep 5s
clear

# Adding sudo previliages to the user you created
echo "NOTE: ALWAYS REMEMBER THIS USERNAME AND PASSWORD YOU PUT JUST NOW."
echo -ne "\n"
sleep 5s
echo "Giving sudo access to "$username"!"
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /etc/sudoers
clear
sleep 5s

# Enable services
echo "Enabling services.."
echo -ne "\n"
enable_services=('irqbalance.service' 'udisks2.service' 'httpd.service' 'cronie.service' 'sshd.service')
systemctl enable ${enable_services[@]}
sleep 5s
clear
