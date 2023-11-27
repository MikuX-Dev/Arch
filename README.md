# ArchFiery

> [!WARNING]
> ArchFiery is still in development. It is not recommended to use this script for now.

## Introduction:
ArchFiery is a simple bash script designed to facilitate the installation of Arch Linux after booting from the official Arch Linux installation media. With just two terminal commands, you can easily install Arch Linux. This script is specifically created to install packages such as the base system, bootloader, and optionally ArchFiery and Blackarch-tools ("minimum-tools" or "full-tools").

> [!NOTE]
> ArchFiery is a personal archlinux installer script. It is not a part of the official Arch Linux project.

## installation:

To install ArchFiery, follow these steps:

- Boot using the [last Arch Linux image](https://www.archlinux.org/download/) and a [bootable device](https://wiki.archlinux.org/index.php/USB_flash_installation_media).

Ensure that you have an internet connection on the Arch ISO. If you have a wireless connection, you can use the [`iwctl`](https://wiki.archlinux.org/index.php/Iwd#iwctl) command. For detailed instructions, refer to the [Network configuration](https://wiki.archlinux.org/index.php/Network_configuration) guide in the Arch Linux documentation.

- Just exec the [ArchFiery](https://github.com/MikuX-Dev/ArchFiery) using the following command:
    ```
    curl -L https://mikux-dev.github.io/ArchFiery/ArchFiery.sh -o ArchFiery.sh; chmod +x ArchFiery.sh; ./ArchFiery.sh
    ```

- For testing purposes, you can also use the following command:
    ```
    curl -L https://mikux-dev.github.io/ArchFiery/test.sh -o test.sh; chmod +x test.sh; ./test.sh
    ```

Follow the on-screen instructions to complete the installation.

## Configuration:

To configure [ArchFiery](https://github.com/MikuX-Dev/ArchFiery), you'll need to clone the repository and edit the packages directory. And make the necessary changes according to your requirements.

## License:

This project is licensed under the GNU General Public License v3.0. For more details, please refer to the [LICENSE](https://github.com/MikuX-Dev/ArchFiery/blob/master/LICENSE) file.
