#!/bin/bash

# Stop script on any error to prevent broken installs
set -e

echo "-------------------------------------------------"
echo "      Arch Linux: Gnome + GRUB All-in-One        "
echo "-------------------------------------------------"

# -------------------------------------------------------
# 1. SYSTEM UPDATE & REPOS
# -------------------------------------------------------
echo "[1/8] Updating repositories..."
pacman -Syu --noconfirm

# -------------------------------------------------------
# 2. ESSENTIALS & GIT
# -------------------------------------------------------
echo "[2/8] Installing Base Utils, Git, and Networking..."
pacman -S --noconfirm --needed \
    base-devel \
    git \
    vim \
    nano \
    wget \
    curl \
    networkmanager \
    man-db \
    man-pages

# -------------------------------------------------------
# 3. FONTS (Readability + Asian Support)
# -------------------------------------------------------
echo "[3/8] Installing Fonts (Western & Asian CJK)..."
pacman -S --noconfirm --needed \
    gnu-free-fonts \
    ttf-liberation \
    ttf-dejavu \
    noto-fonts \
    noto-fonts-emoji \
    noto-fonts-cjk \
    adobe-source-han-sans-otc-fonts \
    adobe-source-han-serif-otc-fonts

# -------------------------------------------------------
# 4. HARDWARE SUPPORT (Pipewire, Bluez, CUPS)
# -------------------------------------------------------
echo "[4/8] Installing Audio, Bluetooth, and Printing..."
pacman -S --noconfirm --needed \
    pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber \
    bluez bluez-utils \
    cups cups-pdf print-manager system-config-printer

# -------------------------------------------------------
# 5. GNOME DESKTOP & DRIVERS
# -------------------------------------------------------
echo "[5/8] Installing Gnome and Graphics Drivers..."
# Gnome Desktop
pacman -S --noconfirm --needed gnome gdm gnome-tweaks

# Graphics (Mesa covers Intel/AMD. NVIDIA users might need nvidia-dkms manually later)
pacman -S --noconfirm --needed mesa lib32-mesa xf86-video-amdgpu xf86-video-ati xf86-video-nouveau xf86-video-vmware

# -------------------------------------------------------
# 6. SYSTEM CONFIGURATION (Services & Users)
# -------------------------------------------------------
echo "[6/8] Enabling Services..."
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable cups.service
systemctl enable gdm.service

echo "--- User Setup ---"
read -p "Enter your new username: " username

if id "$username" &>/dev/null; then
    echo "User $username already exists. Skipping creation."
else
    useradd -m -G wheel -s /bin/bash "$username"
    echo "Please set the password for $username:"
    passwd "$username"
fi

echo "Enabling sudo for wheel group..."
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# -------------------------------------------------------
# 7. GRUB BOOTLOADER (UEFI)
# -------------------------------------------------------
echo "[7/8] Setting up GRUB Bootloader..."

# Install packages
pacman -S --noconfirm grub efibootmgr

# Detect Microcode (Intel/AMD)
cpu_vendor=$(grep -m1 'vendor_id' /proc/cpuinfo | awk '{print $3}')
if [[ $cpu_vendor == "GenuineIntel" ]]; then
    echo "Intel CPU detected. Installing microcode..."
    pacman -S --noconfirm intel-ucode
elif [[ $cpu_vendor == "AuthenticAMD" ]]; then
    echo "AMD CPU detected. Installing microcode..."
    pacman -S --noconfirm amd-ucode
fi

# Install GRUB to EFI partition (Assuming mounted at /boot/efi)
echo "Installing GRUB to /boot/efi..."
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB

# Generate Config
echo "Generating grub.cfg..."
grub-mkconfig -o /boot/grub/grub.cfg

# -------------------------------------------------------
# 8. FINISH
# -------------------------------------------------------
echo "-------------------------------------------------"
echo "   Installation Complete! "
echo "   1. Type 'exit' to leave chroot."
echo "   2. Type 'umount -R /mnt' to unmount drives."
echo "   3. Type 'reboot'."
echo "-------------------------------------------------"
