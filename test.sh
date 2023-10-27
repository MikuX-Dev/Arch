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
echo "Arch Linux Fast Install (ArchFiery) - Version: 2023.11.8 (GPL-3.0)"
sleep 5s

echo "Installation guide starts now..."
sleep 3s
# Clean up the Pacman cache
pacman -Scc --noconfirm --quiet && rm -rf /var/cache/pacman/pkg/*
sleep 2s
# Update
echo "updateing first"
pacman -Syy reflector rsync curl --noconfirm
sleep 3s
clear


# Enabling multilib repo.
echo "Enabling multilib repo"
# Check if multilib repository exists in pacman.conf
if grep -q "\[multilib\]" /etc/pacman.conf; then
    # Multilib repository exists, remove comment if it is commented out
  sed -i '/^\[multilib\]/,/Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf
else
    # Multilib repository does not exist, add it to pacman.conf
  echo -e "[multilib]\nInclude = /etc/pacman.d/mirrorlist" | tee -a /etc/pacman.conf
fi
sleep 3s
clear

# Enabling Community repo.
echo "Enabling community repo"
# Check if community repository exists in pacman.conf
if grep -q "\[community\]" /etc/pacman.conf; then
    # Community repository exists, remove comment if it is commented out
  sed -i '/^\[community\]/,/Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf
else
    # Community repository does not exist, add it to pacman.conf
  echo -e "[community]\nInclude = /etc/pacman.d/mirrorlist" | tee -a /etc/pacman.conf
fi
sleep 3s
clear

# Installing fastest mirrors
echo "Installing fastest mirrorlists"

  # Backup mirrorlist
  echo "Backingup mirrorlists"
  cp -r /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup

  # Archlinux mirrorlists
  echo "Archlinux-mirrorlist setup"
  curl -LsS https://archlinux.org/mirrorlist/all/https/ -o /etc/pacman.d/mirrorlist
  sed -i 's/#S/S/g' > /etc/pacman.d/mirrorlist
  pacman -Syy --noconfirm
  reflector --verbose -l 200 -n 20 --sort rate --download-timeout 15 --save /etc/pacman.d/mirrorlist
sleep 3s
clear

# Updating Keyrings
echo "Internet Connection is a must to begin."
echo "Updating Keyrings.."
pacman -Syy --needed --noconfirm archlinux-keyring && pacman-key --init --noconfirm && pacman-key --populate --noconfirm && sync --noconfirm && pacman -Syy --noconfirm
sleep 3s
clear

# Setting up system clock
echo "Ensuring if the system clock is accurate."
timedatectl set-ntp true
sleep 3s
clear

# Setting up drive
echo "Setting Up drive"
lsblk
echo "Enter the drive to install arch linux on it. (/dev/...)"
echo "Enter Drive (eg. /dev/sda or /dev/vda or /dev/nvme0n1 or something similar)"
read drive
sleep 3s
clear

echo "Getting ready for creating partitions!"
echo "root and boot partitions are mandatory."
echo "home and swap partitions are optional but recommended!"
echo "Also, you can create a separate partition for timeshift backup (optional)!"
echo "Getting ready in 5 seconds"
sleep 5s
clear

lsblk
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

lsblk
echo "choose your linux file system type for formatting drives"
echo " 1. ext4"
echo " 2. xfs"
echo " 3. btrfs"
echo " 4. f2fs"
echo " Boot partition will be formatted in fat32 file system type."
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
sleep 3s
clear

echo "Getting ready for formatting drives."
sleep 3s
lsblk
echo "Enter the root partition (eg: /dev/sda1): "
read rootpartition
mkfs."$filesystemtype" "$rootpartition"
mount "$rootpartition" /mnt
clear

lsblk
read -p "Did you also create separate home partition? [y/n]: " answerhome
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
lsblk
read -p "Did you also create swap partition? [y/n]: " answerswap
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

lsblk
read -p "Do you want to use a separate boot partition or use the EFI partition of windows? (boot/efi): " setbootpartition
if [[ $setbootpartition == "boot" ]]; then
  echo "Setting up a separate boot partition..."
  read -p "Enter the boot partition (e.g., /dev/sda4): " bootpartition
  mkfs.fat -F 32 "$bootpartition"
  mount "$bootpartition" /mnt/boot
else
  echo "Using the EFI partition for boot..."
fi
sleep 3s
clear

lsblk
sync
sleep 5s
clear

# Installing base system with lts-kernel, intel-ucode and duel boot system too
echo "Installing Base system with lts kernel!!!"
sleep 3s
pacstrap /mnt base base-devel linux linux-headers linux-firmware intel-ucode ntfs-3g nvme-cli

#Gen fstab
echo "Generating fstab file"
genfstab -U /mnt >> /mnt/etc/fstab
cat /etc/fstab
sleep 3s
clear

#Setup for post-installation
sed '1,/^#part2$/d' ArchFiery.sh > /mnt/post_install.sh
chmod +x /mnt/post_install.sh
arch-chroot /mnt ./post_install.sh
clear
sleep 3s

#Unmount drives
echo "unmounting all the drives"
umount -R /mnt
sleep 3s
clear

echo -ne "
╭─────── ArchFiery ───────╮
│      Installation       │
│        completed        │
│    rebooting in 5s      │
╰─────────────────────────╯
"
echo "Installation Finished. REBOOTING IN 5 SECONDS!!!"
sleep 5s
reboot

#part2
#starting post_install
echo -ne "
╭─────── ArchFiery ───────╮
│      post_install       │
│     starting in 5s      │
╰─────────────────────────╯
"
sleep 5s
clear

#Enabling multilib repo.
echo "Enabling multilib repo"
# Check if multilib repository exists in pacman.conf
if grep -q "\[multilib\]" /etc/pacman.conf; then
    # Multilib repository exists, remove comment if it is commented out
  sed -i '/^\[multilib\]/,/Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf
else
    # Multilib repository does not exist, add it to pacman.conf
  echo -e "[multilib]\nInclude = /etc/pacman.d/mirrorlist" | tee -a /etc/pacman.conf
for
sleep 3s
clear

#Enabling Community repo.
echo "Enabling community repo"
# Check if community repository exists in pacman.conf
if grep -q "\[community\]" /etc/pacman.conf; then
    # Community repository exists, remove comment if it is commented out
  sed -i '/^\[community\]/,/Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf
else
    # Community repository does not exist, add it to pacman.conf
  echo -e "[community]\nInclude = /etc/pacman.d/mirrorlist" | tee -a /etc/pacman.conf
for
sleep 3s
clear

#Installing fastest mirrors
echo "Installing fastest mirrorlists"
  #backup mirrorlist
  echo "Backingup mirrorlists"
  cp -r /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup

  #archlinux mirrorlists
  echo "Archlinux-mirrorlist setup"
  reflector --verbose -l 200 -n 20 --sort rate --save /etc/pacman.d/mirrorlist
  pacman -Syy --noconfirm && pacman-key --init --noconfirm && pacman-key --populate --noconfirm && pacman -Fyy --noconfirm && pacman-db-upgrade --noconfirm && sync --noconfirm 
sleep 3s
clear

#Replace Asia/kolkata with your timezone
echo "Setting timezone"
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
sleep 3s
clear

#Gen locale
echo "Generating locale"
sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen
locale-gen
sleep 3s
clear

#Setting lang
echo "Setting LANG variable"
echo "LANG=en_US.UTF-8" > /etc/locale.conf
sleep 3s
clear

#Setting console keyboard
echo "Setting console keyboard layout"
echo 'KEYMAP=us' > /etc/vconsole.conf
sleep 3s
clear

#Setup hostname
echo "Set up your hostname!"
echo "Enter your computer name: "
read hostname
echo $hostname > /etc/hostname
echo "Checking hostname (/etc/hostname)"
cat /etc/hostname
sleep 3s
clear

#Setting up hosts
echo "Setting up hosts file"
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $hostname" >> /etc/hosts
cat /etc/hosts
sleep 3s
clear

# Install needed pkgs and tools by PACMAN..
echo "Installing needed pkgs and tools by PACMAN.."
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

  packages+='virtualbox-host-modules-arch virtualbox-guest-utils virtualbox-guest-utils-nox'
},
pacman -S --needed --noconfirm $packages
sleep 3s
clear

# Install needed pkgs and tools by AUR..
echo "Installing needed pkgs and tools by AUR"
  # yay-bin: AUR helper
  git clone https://aur.archlinux.org/yay-bin.git
  cd yay-bin
  makepkg -fsri
  cd ..
# remove dir
rm -rf yay-bin

# Install pkgs and tools by AUR..
install_packages() {
  local aurpkgs=''
  
  #other
  aurpkgs+='mkinitcpio-firmware mkinitcpio-openswap mkinitcpio-numlock'
},

yay -S --needed --noconfirm $aurpkgs
sleep 3s
clear

# Setting boot partition "EFI"
lsblk
echo "Enter the EFI partition to install bootloader. (eg: /dev/sda4): "
read efipartition
efidirectory="/boot/efi/"
if [ ! -d "$efidirectory" ]; then
  mkdir -p "$efidirectory"
fi
mount "$efipartition" "$efidirectory"
sleep 3s
clear

# Install grub
lsblk
sleep 2s
echo "Installing grub bootloader in /boot/efi parttiton"
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --recheck
grub-mkconfig -o /boot/grub/grub.cfg
sleep 3s

# os-prober
read -p "Are you duelbooting? (y/n): " use_os_prober
if [[ $use_os_prober =~ ^[Yy]$ ]]; then
  echo "Enabling os-prober..."
  sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/g' /etc/default/grub
  os-prober
  sleep 2s
  grub-mkconfig -o /boot/grub/grub.cfg
else
  echo "Os-prober not enabled. Generating fstab..."
fi
sleep 3s
clear

# Gen fstab
echo "Generating fstab file"
genfstab -U /mnt >> /mnt/etc/fstab
cat /etc/fstab
sleep 5s
clear

#edit sudo
#echo 'Defaults env_keep += "HOME"' | tee -a /etc/sudoers

# Personal dotfiles
#echo "Setting up Personal dotfiles"
#git clone https://github.com/MikuX-Dev/dotfiles.git
#sleep 3s
# bash
#echo "Installing shell"
#cp -r dotfiles/shell/bash/* /etc/skel/
#sleep 2s
#cp -r dotfiles/shell/zsh/* /etc/skel/
# theme
#echo "Installing themes"
#cp -r dotfiles/themes/* /usr/share/themes/
#cp -r dotfiles/icons/* /usr/share/icons/
#sleep 2s
# config
#echo "Installing configs"
#cp -r dotfiles/config/* /etc/
#sleep 2s
#wallpaper
#echo "Installing wallpaper"
#cp -r dotfiles/wallpaper/* /usr/share/backgrounds/
#sleep 2s

# grub-theme
echo "Installing grub-theme"
git clone https://github.com/MikuX-Dev/ArchFiery.git
cp -r ArchFiery/grub/src/* /usr/share/grub/themes/
sed -i 's/#GRUB_THEME="/path/to/gfxtheme"/GRUB_THEME="/usr/share/grub/themes/nexsecuros/theme.txt"/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
sleep 3s
#remove folder
rm -rf ArchFiery/
sleep 2s
clear

# Setting root user
echo "Enter password for root user:"
passwd
sleep 3s
clear

#Setting regular user
echo "Adding regular user!"
echo "Enter username to add a regular user: "
read username
useradd -m -G wheel -s /bin/zsh $username
echo "Enter password for "$username": "
passwd $username
sleep 3s
clear

# Adding sudo previliages to the user you created
echo "NOTE: ALWAYS REMEMBER THIS USERNAME AND PASSWORD YOU PUT JUST NOW."
sleep 2s
echo "Giving sudo access to "$username"!"
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /etc/sudoers
clear
sleep 3s

# Enable services
echo "Enabling services.."
enable_services=('irqbalance.service' 'udisks2.service' 'httpd.service' 'cronie.service' 'sshd.service'')
systemctl enable ${enable_services[@]}
sleep 3s
clear
