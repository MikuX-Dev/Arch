# ArchFiery

## Introduction:

### Personal archlinux installer script :)

ArchFiery is a simple bash script designed to facilitate the installation of Arch Linux after booting from the official Arch Linux installationmedia. With just two terminal commands, you can easily install Arch Linux. This script is specifically created to install packages such as the base system, bootloader, and optionally [ArchFiery](https://github.com/MikuX-Dev/ArchFiery) and [Blackarch-tools](https://blackarch.org/tools) ("minimum-tools" or "full-tools").

## installation:

To install ArchFiery, follow these steps:

- Boot using the [last Arch Linux image](https://www.archlinux.org/download/) and a [bootable device](https://wiki.archlinux.org/index.php/USB_flash_installation_media).

Ensure that you have an internet connection on the Arch ISO. If you have a wireless connection, you can use the [`iwctl`](https://wiki.archlinux.org/index.php/Iwd#iwctl) command. For detailed instructions, refer to the [Network configuration](https://wiki.archlinux.org/index.php/Network_configuration) guide in the Arch Linux documentation.  

- Clone the [ArchFiery](https://github.com/MikuX-Dev/ArchFiery) repository using the following command:

    git clone https://github.com/MikuX-Dev/ArchFiery.git

- Change to the [ArchFiery](https://github.com/MikuX-Dev/ArchFiery) directory:    
    
    cd ArchFiery

- Make sure the script is executable by running the following command:
    
    ```
    chmod +x ArchFiery

    ```
- Finally, launch the script:
    
    ./ArchFiery

Follow the on-screen instructions to complete the installation.

## Configuration:

To configure [ArchFiery](https://github.com/MikuX-Dev/ArchFiery), you'll need to fork the repository and edit the packages and tools. Locate the following lines in the script:

- `# Install needed pkgs and tools by PACMAN..`
- `# Install needed pkgs and tools by AUR..`

Make the necessary changes according to your requirements.

## TODOs

- [ ] Interactive User Interface: Create a user-friendly and interactive interface for [ArchFiery](https://github.com/MikuX-Dev/ArchFiery), similar to [MatMoul](https://github.com/MatMoul/archfi). This can include menus, prompts, and clear instructions to guide the user through the installation process.

- [ ] Language Selection: Create a language selection menu at the beginning of the installation process. This menu should display a list of available languages for the user to choose from.

- [ ] Automatic Detection and Configuration: Develop a mechanism to automatically detect hardware components and configure the system accordingly. This can involve identifying network adapters, graphics cards, and other hardware to ensure proper drivers and settings are installed.

- [ ] Partitioning and Disk Formatting: Enhance [ArchFiery](https://github.com/MikuX-Dev/ArchFiery) to provide a partitioning tool that allows users to create, resize, and format partitions easily. This can include support for various partitioning schemes like MBR and GPT, as well as file systems such as ext4 and btrfs.

- [ ] Package Selection and Installation: Improve the package selection process by providing a comprehensive list of packages categorized into groups (e.g., base, desktop environments, utilities). Allow users to customize their package selection easily by enabling checkboxes or similar interactive elements.

- [ ] Kernel Selection: Implement a mechanism for users to choose the kernel version during the installation process. This can include providing a list of available kernel options with brief descriptions so that users can make an informed decision.

- [ ] Desktop Environment Selection: Offer a selection of popular desktop environments during the installation process. Allow users to choose their preferred desktop environment and install it automatically, including the necessary display managers and additional packages.

- [ ] Localization and Language Support: Enhance [ArchFiery](https://github.com/MikuX-Dev/ArchFiery) to support multiple languages during the installation process. Provide language selection options and ensure that the system locale is properly configured based on the user's choice.

- [ ] Post-Installation Configuration: Include options for post-installation tasks, such as setting up user accounts, configuring network settings, installing additional software, and enabling essential services like Bluetooth or printers.

- [ ] Theming and Customization: Allow users to customize the appearance and behavior of their Arch Linux system by providing theming options, wallpapers, and pre-configured settings for popular desktop environments.

- [ ] Comprehensive Documentation: Create detailed documentation or a user guide that explains how to use [ArchFiery](https://github.com/MikuX-Dev/ArchFiery), including step-by-step instructions and explanations of each option. This will help users understand the installation process and troubleshoot any issues they may encounter.

Remember that [ArchFiery](https://github.com/MikuX-Dev/ArchFiery) should respect the Arch Linux principles of simplicity, minimalism, and user choice while incorporating features inspired by [MatMoul](https://github.com/MatMoul/archfi).

## License:

This project is licensed under the GNU General Public License v3.0. For more details, please refer to the [LICENSE](https://github.com/MikuX-Dev/ArchFiery/blob/master/LICENSE) file.

## Credits:

Special thanks to the following individuals for their contributions:

- [Bugswriter](https://github.com/Bugswriter/arch-linux-magic) for arch-linux-magic,
- [MatMoul](https://github.com/MatMoul/archfi) for archfi.

