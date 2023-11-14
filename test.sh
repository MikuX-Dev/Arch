#!/usr/bin/env bash

clear

# RED=$(tput setaf 1)         # Red
# GREEN=$(tput setaf 2)       # Green
# YELLOW=$(tput setaf 3)      # Yellow
# BLUE=$(tput setaf 4)        # Blue
# MAGENTA=$(tput setaf 5)     # Magenta
# CYAN=$(tput setaf 6)        # Cyan
# WHITE=$(tput setaf 7)       # White
# RESET=$(tput sgr0)          # Text reset

# Start
echo -ne "
╭─────── ArchFiery ───────╮
│  Installation starting  │
│       so sit back       │
│         relax           │
│       and enjoy         │
╰─────────────────────────╯
"
echo "Arch Linux Fast Install (ArchFiery) - Version: 2023.11.06 (GPL-3.0)"
sleep 5s
printf "\n"
echo "Installation guide starts now..."
pacman -Syy
sleep 5s
clear

# install package
echo "Installing needed packages..."
pacman -S reflector rsync curl --noconfirm
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
  echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist\n\n[community]\nInclude = /etc/pacman.d/mirrorlist" >>/etc/pacman.conf
fi
sleep 5s
clear

# Installing fastest mirrors
read -p "Do you want fastest mirrors? [Y/n] " fm
if [[ $fm =~ ^[Yy]$ ]]; then
  echo "Installing fastest mirrorlists"
  printf "\n"
  # Backup mirrorlist
  echo "Backingup mirrorlists"
  cp -r /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
  # Archlinux mirrorlists
  printf "\n"
  echo "Archlinux-mirrorlist setup"
  reflector --verbose -l 22 -f 22 -p https --download-timeout 55 --sort rate --save /etc/pacman.d/mirrorlist
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
read -p "Enter Drive (eg. /dev/sda or /dev/vda or /dev/nvme0n1 or something similar): " drive
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
read -p partitionutility

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
printf "\n"
"$partitionutility" "$drive"
sleep 5s
clear

printf "\n"
lsblk
printf "\n"
echo "Note: Boot partition will be formatted in fat31 file system type."
echo "choose your linux file system type for formatting drives"
echo " 1. ext4"
echo " 2. xfs"
echo " 3. btrfs"
echo " 4. f2fs"
printf "\n"
read -p filesystemtype

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
sleep 5s
printf "\n"
lsblk
printf "\n"
read -p "Enter the root partition (eg: /dev/sda1): " rootpartition
mkfs."$filesystemtype" "$rootpartition"
mount "$rootpartition" /mnt
clear

printf "\n"
lsblk
printf "\n"
read -p "Did you also create separate home partition? [Y/n]: " answerhome
case "$answerhome" in
y | Y | yes | Yes | YES)
  read -p "Enter home partition (eg: /dev/sda2): " homepartition
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
read -p "Did you also create swap partition? [Y/n]: " answerswap
case "$answerswap" in
y | Y | yes | Yes | YES)
  read -p "Enter swap partition (eg: /dev/sda3): " swappartition
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
read -p "Do you want to use a separate boot partition or use the EFI partition ? (boot/efi): " setbootpartition
if [[ $setbootpartition == "boot" ]]; then
  echo "Setting up a separate boot partition..."
  read -p "Enter the boot partition (e.g., /dev/sda4): " bootpartition
  mkfs.fat -F 32 "$bootpartition"
  mount "$bootpartition" /mnt/boot
else
  echo "Using the EFI partition..."
fi
sleep 5s
clear

printf "\n"
sync
printf "\n"
lsblk
sleep 5s
clear

# Installing base system...
echo "Installing Base system..."
printf "\n"
sleep 5s

# Determine processor type and install microcode
proc_type=$(lscpu)
printf "\n"
if grep -E "GenuineIntel" <<<"${proc_type}"; then
  echo "Installing Intel microcode"
  proc_ucode=intel-ucode
elif grep -E "AuthenticAMD" <<<"${proc_type}"; then
  echo "Installing AMD microcode"
  proc_ucode=amd-ucode
fi

# Determine graphics card type and build package list
gpu_type=$(lspci)
printf "\n"
if grep -E "NVIDIA|GeForce" <<<"${gpu_type}"; then
  echo "Installing NVIDIA drivers..."
  packages+=" nvidia nvidia-utils"
elif lspci | grep 'VGA' | grep -E "Radeon|AMD"; then
  echo "Installing AMD drivers..."
  packages+=" xf86-video-amdgpu"
elif grep -E "Integrated Graphics Controller" <<<"${gpu_type}"; then
  echo "Installing integrated Graphics Controller"
  packages+=" libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils libva-mesa-driver mesa lib32-mesa mesa-amber lib32-mesa-amber intel-media-driver"
elif grep -E "Intel Corporation UHD" <<<"${gpu_type}"; then
  echo "Installing Intel UHD Graphics"
  packages+=" libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils libva-mesa-driver mesa lib32-mesa mesa-amber lib32-mesa-amber intel-media-driver"
else
  echo "Installing generic drivers..."
  packages+="virtualbox-host-modules-arch xf86-input-vmmouse open-vm-tools xf86-video-vmware virtualbox-guest-utils qemu qemu-arch-extra libvirt virt-manager"
fi

packages="base base-devel linux linux-headers linux-firmware ntfs-3g nvme-cli ${proc_ucode} ${gpu_type}"

# Install the determined packages
pacstrap /mnt "${packages}"

# Gen fstab
echo "Generating fstab file"
printf "\n"
genfstab -U /mnt >>/mnt/etc/fstab
cat /etc/fstab
sleep 5s
clear

# Setup for post-installation
sed '1,/^#part2$/d' ArchFiery.sh >/mnt/post_install.sh
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
  echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist\n\n[community]\nInclude = /etc/pacman.d/mirrorlist" >>/etc/pacman.conf
fi
sleep 5s
clear

# Installing fastest mirrors
read -p "Do you want fastest mirrors? [Y/n] " fm
if [[ $fm =~ ^[Yy]$ ]]; then
  echo "Installing fastest mirrorlists"
  # Backup mirrorlist
  echo "Backingup mirrorlists"
  cp -r /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
  # Archlinux mirrorlists
  echo "Archlinux-mirrorlist setup"
  reflector --verbose -l 22 -f 22 -p https --download-timeout 55 --sort rate --save /etc/pacman.d/mirrorlist
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
echo "LANG=en_US.UTF-8" >/etc/locale.conf
sleep 5s
clear

# Setting console keyboard
echo "Setting console keyboard layout"
printf "\n"
echo 'KEYMAP=us' >/etc/vconsole.conf
sleep 5s
clear

# Setup hostname
echo "Set up your hostname!"
read -p "Enter your computer name: " hostname
echo "$hostname" >/etc/hostname
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
} >>/etc/hosts
cat /etc/hosts
sleep 5s
clear

# Install pkgs and tools by PACMAN..
echo "Installing pkgs and tools by PACMAN.."
printf "\n"
pacman -S --noconfirm --needed ack acpi alacritty alsa-utils apache arch-install-scripts arch-wiki-docs archiso atftp automake b43-fwcutter base base-devel bash-completion bc bind bind-tools bridge-utils brltty broadcom-wl bzip3 cargo ccache cifs-utils clang clonezilla cmake conky cronie ctags curl darkhttpd devtools dhclient dhcpcd dialog diffutils dmraid dnscrypt-proxy dnsmasq dnsutils dosfstools edk2-shell efibootmgr exfat-utils expac f2fs-tools feh fwbuilder gammu gawk gcc gcc-libs gdb git git-lfs gnome-keyring gnu-netcat gnupg go gpart gparted gpm gptfdisk grub grub-customizer gvfs gvfs gvfs-mtp gzip haveged hdparm helix htop inotify-tools intel-ucode ipw2100-fw ipw2200-fw ipython irqbalance irssi iw iwd kvantum lftp libx11 libxext lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings lightdm-webkit2-greeter lightdm-webkit2-theme-glorious llvm lsof lua make menumaker mercurial mesa mlocate modemmanager moreutils mpv mtools multilib-devel nano nbd ncdu ndisc6 neovim network-manager-applet networkmanager networkmanager-openconnect networkmanager-openvpn networkmanager-pptp networkmanager-vpnc nfs-utils nilfs-utils npm ntfs-3g ntp nvme-cli obsidian openconnect openssh openvpn os-prober p7zip pacman-contrib partclone parted partimage pavucontrol perl pkgfile plocate plymouth ppp pptpclient profile-sync-daemon qemu-emulators-full qemu-system-x86-firmware qemu-tools qt5-tools qt5ct reiserfsprogs rfkill rofi rp-pppoe rsync rtorrent ruby rustup screen scrot sed smartmontools socat strace tar tmux tor udisks2 unace unrar unzip upower usb_modeswitch usbutils vim vpnc wget wireless_tools wpa_supplicant wvdial xarchiver xarchiver xdg-desktop-portal-gtk xdg-user-dirs-gtk xfce4 xfce4-goodies xl2tpd xz zip zsh zsh-autosuggestions zsh-completions zsh-history-substring-search zsh-syntax-highlighting zstd
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
yay -S --noconfirm --needed appmenu-gtk-module-git appmenu-qt4 brave-bin libdbusmenu-glib libdbusmenu-gtk2 libdbusmenu-gtk3 mkinitcpio-firmware mkinitcpio-numlock mugshot visual-studio-code-bin zsh-theme-powerlevel10k-git
sleep 5s
clear

# Setting boot partition "EFI"
printf "\n"
lsblk
printf "\n"
read -p "Enter the EFI partition to install bootloader. (eg: /dev/sda4): " efipartition
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
read -p "Are you duelbooting? [Y/n]: " use_os_prober
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

#edit sudo
echo 'Defaults env_keep += "HOME"' | tee -a /etc/sudoers
sleep 5s
clear

# Personal dotfiles
echo "Setting up Personal dotfiles"
git clone https://github.com/MikuX-Dev/dotfiles.git
sleep 5s

# Creating folder first
mkdir -p /etc/skel/.config/
mkdir -p /etc/skel/bin/
mkdir -p /usr/share/lightdm-webkit/themes/glorious

# shell
echo "Installing shell"
printf "\n"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
cp -r dotfiles/shell/bash/* /etc/skel/
cp -r dotfiles/shell/zsh/* /etc/skel/
cp -r dotfiles/shell/p-script/* /etc/skel/bin/
printf "\n"
sleep 5s

# theme
echo "Installing themes and fonts"
printf "\n"
cp -r dotfiles/themes/themes/* /usr/share/themes/
cp -r dotfiles/themes/icons/* /usr/share/icons/
cp -r dotfiles/themes/plymouth/* /etc/plymouth/
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf /usr/share/fonts/
printf "\n"
sleep 5s

# config
echo "Installing configs"
printf "\n"
cp -r dotfiles/config/* /etc/skel/.config/
printf "\n"
sleep 5s

# plymouth config
echo "Configuring plymouth"
printf "\n"
sed -i 's/^HOOKS=.*/HOOKS=(base udev plymouth autodetect modconf kms keyboard keymap consolefont block filesystems fsck)/' /etc/mkinitcpio.conf
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet splash udev.log_level=3 vt.global_cursor_default=0"/g' /etc/default/grub
mkinitcpio -p linux
grub-mkconfig -o /boot/grub/grub.cfg
plymouth-set-default-theme -R archfiery
sleep 5s
clear

# wallpaper
echo "Installing wallpaper"
printf "\n"
cp -r dotfiles/wallpaper/* /usr/share/backgrounds/
printf "\n"
sleep 5s
clear

# lightdm
echo "Setting up Desktop environment"
printf "\n"

echo "Setting up lightdm"
latest_release_url=$(curl -s https://api.github.com/repos/eromatiya/lightdm-webkit2-theme-glorious/releases/latest | grep "browser_download_url" | cut -d '"' -f 4)
curl -L -o glorious-latest.tar.gz "$latest_release_url"
tar -zxvf glorious-latest.tar.gz -C /usr/share/lightdm-webkit/themes/glorious --strip-components=1
sed -i 's/^\(#?greeter\)-session\s*=\s*\(.*\)/greeter-session = lightdm-webkit2-greeter #\1/ #\2g' /etc/lightdm/lightdm.conf
sed -i 's/^webkit_theme\s*=\s*\(.*\)/webkit_theme = glorious #\1/g' /etc/lightdm/lightdm-webkit2-greeter.conf
sed -i 's/^debug_mode\s*=\s*\(.*\)/debug_mode = true #\1/g' /etc/lightdm/lightdm-webkit2-greeter.conf
printf "\n"
sleep 5s
clear

echo "Setting up EWW"
git clone https://github.com/elkowar/eww
(
  cd eww || exit
  cargo build --release --no-default-features --features x11
  cd target/release || exit
  chmod +x ./eww
  cp -r ./eww /usr/bin/
)
printf "\n"
sleep 5s
clear

echo "Setting up vala-pannel-appmenu"
xfconf-query -c xsettings -p /Gtk/ShellShowsMenubar -n -t bool -s true
xfconf-query -c xsettings -p /Gtk/ShellShowsAppmenu -n -t bool -s true
printf "\n"
sleep 5s
clear

# grub-theme
echo "Installing grub-theme"
printf "\n"
cp -r dotfiles/themes/grub/themes/* /usr/share/grub/themes/
sed -i 's/#GRUB_THEME="/path/to/gfxtheme"/GRUB_THEME="/usr/share/grub/themes/archfiery/theme.txt"/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
sleep 5s
clear

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
read -p "Enter username to add a regular user: " username
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
enable_services=('irqbalance.service' 'udisks2.service' 'httpd.service' 'cronie.service' 'sshd.service' 'lightdm-plymouth.service' 'NetworkManager.service')
systemctl enable "${enable_services[@]}"
sleep 5s
clear

# Clearcache
echo "Clearing cache..."
yay -Scc --noconfirm
sleep 5s
clear
