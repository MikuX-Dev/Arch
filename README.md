# ArchFiery

## Personal archlinux installer script :)

Just a simple bash script to install Arch Linux after you have booted on the official Arch Linux install media.

With this script, you can install Arch Linux with two simple terminal commands.

This wizard is made to install packages (Base, bootloader, optionally [ArchFiery](https://github.com/MikuX-Dev/ArchFiery) and [Blackarch-tools](https://blackarch.org/tools) "minimum-tools" or "full-tools").

## How to use

First fork this repo and edit the packages and tools by finding this --> "# Install needed pkgs and tools by PACMAN.." and "# Install needed pkgs and tools by AUR.." 

Then, boot with the [last Arch Linux image](https://www.archlinux.org/download/) with a [bootable device](https://wiki.archlinux.org/index.php/USB_flash_installation_media).

Then make sure you have Internet connection on the Arch iso. If you have a wireless connection the [`iwctl`](https://wiki.archlinux.org/index.php/Iwd#iwctl) command might be useful to you. You can also read the [Network configuration](https://wiki.archlinux.org/index.php/Network_configuration) from the Arch Linux guide for more detailed instructions.

Then download the script with from the command line:

clone your repo:

    git clone https://github.com/[`$USERNAME`]/ArchFiery.git

use this instead:

    git clone https://github.com/MikuX-Dev/ArchFiery.git

Change dir to ArchFiery
    
    cd ArchFiery

Finally, launch the script:

    ./ArchFiery

Then follow the on-screen instructions to completion.

## TODOs
- [x] change drive to support duel boot. 
- [ ] add pkgs and tools needed.
- [ ] add my own custom repo,pkgs and tools.

## Usage

check for help:

    ./ArchFiery -h 

or 

    ./ArchFiery --help

## License
This project is licensed under the GNU General Public License v3.0,
See the [LICENSE](https://github.com/MikuX-Dev/ArchFiery/blob/master/LICENSE) file for details.

