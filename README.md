# Arch Gnome Post-Installation

Arch Gnome post-installation script to allow users to enjoy a good experience out of the box.

## Overview

This repository provides a post-installation script for Arch Linux systems running the GNOME desktop. The script automates common tasks and tweaks to get a comfortable, polished GNOME desktop environment quickly after a fresh Arch install.

## Features

- Installs commonly used packages and GNOME extensions (as configured in the script)
- Applies GNOME settings and preferences for a better out-of-the-box experience
- Installs themes, icon sets, and fonts to improve visual polish
- Enables and configures essential services
- Applies useful tweaks and performance improvements

## Requirements

- Arch Linux
- GNOME desktop environment already installed
- Internet connection
- A user account with sudo privileges

## Installation

Clone the repository or create a README.md file in your local copy of the repo and save the contents of this file.

```
git clone https://github.com/estebanguzman1337-star/ArchGnomePost-Installation.git
cd ArchGnomePost-Installation
```

If the repository already exists on your system, add this README.md to the repo root.

## Usage

Review the script to understand which packages and settings will be changed. Adjust variables and lists in the script to suit your preferences.

To run the post-install script:

```
chmod +x post-install.sh
./post-install.sh
```

Follow any on-screen prompts. Reboot when the script recommends it.

## Safety and customization

- Always read and understand scripts before running them with elevated privileges.
- Backup important data and config files before making system changes.
- This script is intended as a starting point — customize package lists, tweaks, and settings to match your workflow.

## Files of interest

- post-install.sh — main script that performs the post-install tasks (review and edit before running).

## Contributing

Contributions, suggestions, and improvements are welcome. Open an issue to discuss changes or submit a pull request with your improvements.

## License

Add a license to this repository if you want others to reuse the code (for example, MIT). If you want, I can prepare a recommended LICENSE file for this project.

## Contact

For questions or suggestions, open an issue on the repository.
