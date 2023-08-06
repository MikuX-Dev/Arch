#!/usr/bin/env bash

clear

#Main Start
echo -ne "
╭─────── ArchFiery ───────╮
│  Installation starting  │
│      so sit back        │
│         relax           │
│       and enjoy         │
╰─────────────────────────╯
"
echo "Arch Linux Fast Install (ArchFiery) - Version: 2023.08.1 (GPL-3.0)"
sleep 1s 
clear

echo "Installation guide starts now.."
sleep 2s
clear

#Enabling multilib repo.
echo "Enabling multilib repo"
# Check if multilib repository exists in pacman.conf
if grep -q "\[multilib\]" /etc/pacman.conf; then
    # Multilib repository exists, remove comment if it is commented out
  sudo sed -i '/^\[multilib\]/,/Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf
else
    # Multilib repository does not exist, add it to pacman.conf
  echo -e "[multilib]\nInclude = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf
for
sleep 1s
clear

#Enabling Community repo.
echo "Enabling community repo"
# Check if community repository exists in pacman.conf
if grep -q "\[community\]" /etc/pacman.conf; then
    # Community repository exists, remove comment if it is commented out
  sudo sed -i '/^\[community\]/,/Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf
else
    # Community repository does not exist, add it to pacman.conf
  echo -e "[community]\nInclude = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf
for
sleep 1s
clear

#curl blackarch strap.sh 
curl -O https://blackarch.org/strap.sh
echo 5ea40d49ecd14c2e024deecf90605426db97ea0c strap.sh | sha1sum -c
chmod +x strap.sh
./strap.sh
pacman -Syy --needed --noconfirm pacman-contrib
rm -rf strap.sh 
sleep 1s
clear

#Installing fastest mirrors
echo "Installing fastest mirrorlists"
  
  #backup mirrorlist
  echo "backingup mirrorlists"
  mv -v /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
  mv -v /etc/pacman.d/blackarch-mirrorlist /etc/pacman.d/blackarch-mirrorlist.backup

  #blackarch-mirrorlist
  echo "blackarch-mirrorlist setup"
  cp -r /etc/pacman.d/blackarch-mirrorlist.backup /etc/pacman.d/blackarch-mirrorlist
  sed 's/^#Server = https:/Server = https:/g' > /etc/pacman.d/blackarch-mirrorlist  

  #archlinux mirrorlists
  echo "archlinux-mirrorlist setup"
  curl -LsS https://archlinux.org/mirrorlist/all/https/ -o /etc/pacman.d/mirrorlist 
  sed -i 's/#S/S/g' > /etc/pacman.d/mirrorlist
  rankmirrors -n 10 > /etc/pacman.d/mirrorlist
sleep 1s
clear

#Updating Keyrings
echo "Internet Connection is a must to begin."
echo "Updating Keyrings.."
pacman -Syy --needed --noconfirm archlinux-keyring blackarch-keyring 
pacman-key --init
pacman-key --populate
pacman -Syy
sleep 1s
clear

#Setting up system clock
echo "Ensuring if the system clock is accurate."
timedatectl set-ntp true
sleep 1s
clear

#Setting up drive
echo "Setting Up drive"
lsblk
echo "Enter the drive to install arch linux on it. (/dev/...)"
echo "Enter Drive (eg. /dev/sda or /dev/vda or /dev/nvme0n1 or something similar)"
read drive
sleep 2s
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
sleep 2s
clear

echo "Getting ready for formatting partitions!"
sleep 2s
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
sleep 2s
clear

echo "Getting ready for formatting drives."
sleep 2s
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
read -p "Enter the boot partition. (eg. /dev/sda4): " bootpartition
mkfs.fat -F 32 "$bootpartition"
mount $bootpartition /mnt/boot
clear

lsblk
sleep 3s
clear

# Installing base system with lts-kernel, intel-ucode and duel boot system too
echo "Installing Base system with lts kernel!!!"
sleep 1s
pacstrap /mnt base base-devel linux-lts linux-lts-headers linux-firmware intel-ucode 

#Gen fstab
echo "generating fstab file"
genfstab -U /mnt >> /mnt/etc/fstab
cat /etc/fstab
sleep 2s
clear 

#Setup for post-installation
sed '1,/^#part2$/d' ArchFiery.sh > /mnt/post_install.sh
chmod +x /mnt/post_install.sh
arch-chroot /mnt ./post_install.sh
clear
sleep 1s

#Unmount drives
echo "unmounting all the drives"
umount -R /mnt
sleep 1s
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
  sudo sed -i '/^\[multilib\]/,/Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf
else
    # Multilib repository does not exist, add it to pacman.conf
  echo -e "[multilib]\nInclude = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf
for
clear

#Enabling Community repo.
echo "Enabling community repo"
# Check if community repository exists in pacman.conf
if grep -q "\[community\]" /etc/pacman.conf; then
    # Community repository exists, remove comment if it is commented out
  sudo sed -i '/^\[community\]/,/Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf
else
    # Community repository does not exist, add it to pacman.conf
  echo -e "[community]\nInclude = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf
for
pacman -Syy --noconfirm pacman-contrib
clear

#Installing fastest mirrors
echo "Installing fastest mirrorlists"  
  #backup mirrorlist
  echo "backingup mirrorlists"
  mv -v /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
  mv -v /etc/pacman.d/blackarch-mirrorlist /etc/pacman.d/blackarch-mirrorlist.backup

  #blackarch-mirrorlist
  echo "blackarch-mirrorlist setup"
  cp -r /etc/pacman.d/blackarch-mirrorlist.backup /etc/pacman.d/blackarch-mirrorlist
  sed -i 's/^#Server = https:/Server = https:/g' /etc/pacman.d/blackarch-mirrorlist  
  rankmirrors -n 10 > /etc/pacman.d/blackarch-mirrorlist
  #archlinux mirrorlists
  echo "archlinux-mirrorlist setup"
  curl -LsS https://archlinux.org/mirrorlist/all/https/ -o /etc/pacman.d/mirrorlist 
  sed -i 's/#S/S/g' /etc/pacman.d/mirrorlist
  rankmirrors -n 10 > /etc/pacman.d/mirrorlist
pacman -S --noconfirm archlinux-keyring blackarch-keyring 
pacman-key --init
pacman-key --populate
pacman -Fyy 
pacman-db-upgrade
sync
pacman -Syy
sleep 1s
clear

#Replace Asia/kolkata with your timezone
echo "setting timezone"
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
sleep 1s
clear

#Gen locale
echo "generating locale"
sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen
sleep 1s
clear

#Setting lang
echo "setting LANG variable"
echo "LANG=en_US.UTF-8" > /etc/locale.conf
sleep 1s
clear

#Setting console keyboard
echo "setting console keyboard layout"
sed -i 's/^#KEYMAP=us/KEYMAP=us/g' /etc/vconsole.conf
sleep 1s
clear

#Setup hostname
echo "Set up your hostname!"
echo "Enter your computer name: "
read hostname
echo $hostname > /etc/hostname
echo "Checking hostname (/etc/hostname)"
cat /etc/hostname
sleep 1s
clear

#Setting up hosts
echo "setting up hosts file"
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $hostname" >> /etc/hosts
cat /etc/hosts
sleep 1s
clear

# Install needed pkgs and tools by PACMAN..
echo "Installing needed pkgs and tools by PACMAN.."
install_packages() {
  local packages=''

  #networkmanager etc..
  packages+='network-manager-applet networkmanager network-manager-applet networkmanager-openconnect networkmanager-openvpn networkmanager-pptp networkmanager-vpnc modemmanager dhclient dhcpcd'

  #bluetooth etc..
  packages+='bluez bluez-utils bluez-tools bluez-libs blueman pulseaudio pulseaudio-bluetooth pulseaudio-alsa pavucontrol alsa-utils
mesa alsa-firmware alsa-lib'

  #video drive etc..
  packages+='xf86-video-intel xf86-video-fbdev vulkan-intel vulkan-icd-loader xf86-video-openchrome xf86-video-vesa xf86-input-void xf86-input-libinput libinput xf86-input-evdev xf86-input-elographics'

  #print service
  packages+='cups system-config-printer'

  #text editor
  packages+='vim neovim nano'

  #terminal
  packages+='tmux'

  #git
  packages+='git git-lfs'

  #archive tools
  packages+='ack xarchiver p7zip zip unzip gzip tar bzip3 unrar xz zstd'

  #Document Viewer
  packages+='libreoffice-still'

  #dev tools
  packages+='archiso f2fs-tools automake gawk gammu gnome-keyring ntfs-3g mtools dosfstools devtools multilib-devel npm qemu-tools qemu-emulators-full qemu-system-x86-firmware cargo make go lua perl ruby rust rustup cmake gcc gcc-libs gdb ppp rp-pppoe pptpclient reiserfsprogs  clang llvm ccache curl wget sed'

  #lightdm lockscreen
  packages+='lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings'

  #shell
  packages+='zsh zsh-autosuggestions zsh-history-substring-search zsh-syntax-highlighting zsh-completions bash-completion'

  #xdg
  packages+='xdg-user-dirs-gtk xdg-desktop-portal-gtk'

  #other
  packages+='arch-wiki-docs linux-lts-docs linux-hardened-docs gvfs-mtp gvfs apache udisks2 cronie grub-customizer irqbalance plocate arch-install-scripts arch-install-scripts bind brltty broadcom-wl clonezilla darkhttpd diffutils dmraid dnsmasq edk2-shell profile-sync-daemon pacman-contrib grub efibootmgr os-prober'

  #application
  packages+='hexchat htop galculator fwupd ufw redshift ddrescue'

  #ssh and gnupg
  packages+='openssh gnupg'

  #fonts
  packages+='noto-fonts fontconfig ttf-bitstream-vera ttf-dejavu ttf-droid ttf-inconsolata ttf-indic-otf ttf-liberation ttf-jetbrains-mono-nerd ttf-hack-nerd ttf-firacode-nerd'

  #xorg
  packages+='xorg xorg-server xorg-xinit xcompmgr'

  #System 
  packages+='xfce4 xfce4-goodies plank ranger trash-cli ncdu mkinitcpio-archiso mkinitcpio-nfs-utils nfs-utils nilfs-utils nvme-cli nbd ndisc6 obsidian feh menumaker openconnect partclone gparted '

  #privacy
  packages+='tor'

  #blackarch
  packages+='blackarch-menus blackarch-config-cursor blackarch-config-icons blackarch-config-xfce'

  #blackarch-slim-tools
  packages+='aircrack-ng amass arp-scan aquatone binwalk bulk-extractor bully burpsuite cewl chaos-client chntpw commix crackmapexec creddump crunch davtest dbd dirb dirbuster dmitry dns2tcp dnschef dnsenum dnsrecon dnsx enum4linux exiv2 exploitdb faradaysec fern-wifi-cracker ffuf fierce findomain fping gobuster guymager hashcat hashcat-utils hashdeep hashid hash-identifier hping hotpatch httpx hydra ike-scan inetsim iodine john kismet laudanum lbd legion lulzbuster macchanger magicrescue maltego maskprocessor massdns masscan metasploit msfdb mimikatz mitmproxy multimac nbtscan ncrack netdiscover netmask netsed netsniff-ng ngrep nikto nmap nuclei nuclei-templates onesixtyone openbsd-netcat ophcrack patator pdfid pdf-parser pipal pixiewps powersploit proxychains-ng proxytunnel proxify pth-toolkit ptunnel pwnat radare2 reaver rebind recon-ng redsocks responder rsmangler sakis3g samdump2 sbd scalpel scrounge-ntfs seclists set skipfish sleuthkit smbmap snmpcheck socat sploitctl spiderfoot spooftooph sqlmap ssldump sslscan sslsplit sslyze statsprocessor stunnel subfinder swaks tcpdump tcpick tcpreplay thc-ipv6 thc-pptp-bruter tor theharvester udptunnel unix-privesc-check voiphopper wafw00f wce webshells weevely wfuzz whatweb whois wifite windows-binaries winexe wireshark-qt wordlistctl wpscan zaproxy zdns zgrab2 zmap'

}
pacman -S --needed --noconfirm $packages 
sleep 1s 
clear

# Install needed pkgs and tools by AUR..
echo "Installing needed pkgs and tools by AUR"
  # pikaur: AUR helper
  git clone https://aur.archlinux.org/pikaur.git
  cd pikaur
  makepkg -fsri
  cd ..
  
  # yay-bin: AUR helper
  git clone https://aur.archlinux.org/yay-bin.git
  cd yay-bin
  makepkg -fsri
  cd ..
  
  # remove dir 
  rm -rf yay-bin
  rm -rf pikaur
  clear
# Install pkgs and tools by AUR..
install_packages() {
  
  #Browser
  aurpkgs+='barve-bin librewolf-bin tor-browser' 

  #libreoffice 
  aurpkgs+='libreoffice-extension-languagetool'

  #other
  packages+='mkinitcpio-firmware mkinitcpio-openswap mkinitcpio-numlock i2p'

  #password manager
  aurpkgs+='bitwarden-rofi bitwarden-cli-bin' 

  #code-editor
  aurpkgs+='vscodium-bin todotxt' 

  #Sync 
  aurpkgs+='megasync-bin syncthing-bin'

}

pikaur -S --needed --noconfirm $aurpkgs
sleep 1s 
clear

#Setting boot partition "EFI"
lsblk
echo "Enter the boot partition to install bootloader. (eg: /dev/sda4): "
read efipartition
efidirectory="/boot/efi/"
if [ ! -d "$efidirectory" ]; then
  mkdir -p "$efidirectory"
fi
mount "$efipartition" "$efidirectory"
sleep 1s 
clear

#Install grub
lsblk
sleep 2s 
echo "Installing grub bootloader in /boot/efi parttiton"
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
sed -i "s/^#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/g" 
grub-mkconfig -o /boot/grub/grub.cfg
sleep 1s
clear

#Gen fstab
echo "generating fstab file"
genfstab -U /mnt >> /mnt/etc/fstab
cat /etc/fstab
sleep 3s
clear 

#edit sudo 
echo 'Defaults env_keep += "HOME"' | sudo tee -a /etc/sudoers

#Personal user config Setup
git clone https://github.com/MikuX-Dev/dotfiles.git
#shell
cp -r dotfiles/shell/bash/* /etc/skel/
cp -r dotfiles/shell/zsh/* /etc/skel/
#themes
cp -r dotfiles/themes/* /usr/share/themes/
cp -r dotfiles/icons/* /usr/share/icons/
#config
#cp -r dotfiles/config/* /etc/
#wallpaper
cp -r dotfiles/wallpaper/* /usr/share/backgrounds/
#grub-theme
cp -r dotfiles/themes/grub/src/* /usr/share/grub/themes/
grub-mkconfig -o /boot/grub/grub.cfg

#Setting root user
echo "Enter password for root user:"
passwd
clear

#Setting regular user
echo "Adding regular user!"
echo "Enter username to add a regular user: "
read username
useradd -m -G wheel -s /bin/bash $username
echo "Enter password for "$username": "
passwd $username
clear

#Adding sudo previliages to the user you created
echo "NOTE: ALWAYS REMEMBER THIS USERNAME AND PASSWORD YOU PUT JUST NOW."
sleep 1s
echo "Giving sudo access to "$username"!"
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /etc/sudoers
#echo "$username ALL=(ALL) ALL" >> /etc/sudoers.d/$username
clear
sleep 1s

#Enable services
echo "Enabling services.."
enable_services=('irqbalance.service' 'udisks2.service' 'httpd.service' 'cronie.service' 'sshd.service' 'cups.service' 'org.cups.cupsd.service' 'lightdm.service' 'NetworkManager.service' 'bluetooth.service')
systemctl enable ${enable_services[@]}
sleep 1s
clear

