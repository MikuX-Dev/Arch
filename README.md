# ArchFiery:

## Introduction:
[ArchFiery](https://github.com/MikuX-Dev/ArchFiery) is a bash script that streamlines the installation process of [ArchLinux](https://archlinux.org). By executing only two terminal commands, users can effortlessly install [ArchLinux](https://archlinux.org). This script is specifically designed to install essential packages like the base system and bootloader. Additionally, it provides the option to install [ArchFiery](https://github.com/MikuX-Dev/ArchFiery) pkgs and [Blackarch-tools](https://blackarch.org/tools.html), which include a selection of tools from the [BlackArch](https://blackarch.org) Linux project.

> [!NOTE]
> ArchFiery is a personal archlinux installer script. It is not a part of the official Arch Linux project.

## installation:

To install ArchFiery, follow these steps:

- Boot using the [last Arch Linux image](https://www.archlinux.org/download/) and a [bootable device](https://wiki.archlinux.org/index.php/USB_flash_installation_media).

Ensure that you have an internet connection on the Arch ISO. If you have a wireless connection, you can use the [`iwctl`](https://wiki.archlinux.org/index.php/Iwd#iwctl) command. For detailed instructions, refer to the [Network configuration](https://wiki.archlinux.org/index.php/Network_configuration) guide in the [ArchLinux](https://wiki.archlinux.org/) documentation.

- Just exec the [ArchFiery](https://github.com/MikuX-Dev/ArchFiery) using the following command:
    ```
    curl -L https://mikux-dev.github.io/ArchFiery/archlinux-installer/ArchFiery.sh -o ArchFiery.sh; chmod +x ArchFiery.sh; ./ArchFiery.sh
    ```

Follow the on-screen instructions to complete the installation.

## Configuration:

To configure [ArchFiery](https://github.com/MikuX-Dev/ArchFiery), you'll need to clone the repository and edit the packages directory. And make the necessary changes according to your requirements.

## License:

This project is licensed under the GNU General Public License v3.0. For more details, please refer to the [LICENSE](https://github.com/MikuX-Dev/ArchFiery/blob/master/LICENSE) file.