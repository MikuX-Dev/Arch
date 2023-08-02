clear
exit
ls
sudo pacman -Syyu
clear
exit
sudo vim /etc/pacman.conf 
curl -O https://blackarch.org/strap.sh
echo 5ea40d49ecd14c2e024deecf90605426db97ea0c strap.sh | sha1sum -c
chmod +x strap.sh
./strap.sh 
sudp ./strap.sh 
sudo ./strap.sh 
sudo pacman -Syyu
clear
git clone https://github.com/ctlos/ctlosiso.git
ls
git clone https://github.com/ctlos/ctlosiso.git ~/nexcrypt-iso
git clone https://github.com/ctlos/ctlosiso.git -b master ~/nexcrypt-iso 
cd nexcrypt-iso/
clear
ls
ll
clear
cd
sudo pacman -S zsh
sudo pacman -S archiso
clear
sudo pacman -S blackarch-config-vim
cp -a /usr/share/blackarch/config/vim/vim ~/.vim
cp -a /usr/share/blackarch/config/vim/vimrc ~/.vimrc
vim
sudo pacman -S blackarch-config-zsh
cp -a /usr/share/blackarch/config/zsh/zshrc ~/.zshrc
zsh
exit
sudo -i
exit
