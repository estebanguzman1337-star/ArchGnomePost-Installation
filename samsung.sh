#!/usr/bin/env bash
# KDE Arch Linux Post‑Installation Script (Samsung i3‑3110M + Intel HD 4000)
# Fully merged and performance‑tuned for 4GB RAM + 5400RPM HDD

set -e

### --- 1. SYSTEM UPDATE -------------------------------------------------------
echo "Updating system..."
sudo pacman -Syu --noconfirm

### --- 2. MICROCODE -----------------------------------------------------------
echo "Installing Intel microcode..."
sudo pacman -S --noconfirm intel-ucode

### --- 3. KDE PLASMA (LIGHT + FAST) ------------------------------------------
echo "Installing lightweight KDE Plasma..."
sudo pacman -S --noconfirm \
    plasma-desktop sddm sddm-kcm \
    dolphin konsole kate ark spectacle \
    plasma-nm partitionmanager filelight kcalc \
    kde-gtk-config

sudo systemctl enable sddm

### --- 4. NETWORKING ----------------------------------------------------------
echo "Installing networking tools..."
sudo pacman -S --noconfirm \
    networkmanager nm-connection-editor \
    openssh wget curl

sudo systemctl enable NetworkManager

### --- 5. AUDIO (PipeWire) ----------------------------------------------------
echo "Installing PipeWire audio stack..."
sudo pacman -S --noconfirm \
    pipewire pipewire-alsa pipewire-pulse pipewire-jack \
    wireplumber pavucontrol

### --- 6. FONTS ---------------------------------------------------------------
echo "Installing fonts..."
sudo pacman -S --noconfirm \
    ttf-dejavu ttf-liberation noto-fonts noto-fonts-cjk \
    noto-fonts-emoji ttf-jetbrains-mono ttf-fira-code

### --- 7. GPU DRIVERS (INTEL HD 4000) -----------------------------------------
echo "Installing Intel HD 4000 drivers..."
sudo pacman -S --noconfirm \
    mesa libva-intel-driver vulkan-intel \
    i965-va-driver

### --- 8. VA-API TEST ---------------------------------------------------------
echo "Testing VA-API..."
sudo pacman -S --noconfirm vainfo
vainfo || echo "VA-API test completed."

### --- 9. POWER MANAGEMENT (TLP + HDD TUNING) ---------------------------------
echo "Installing TLP power management..."
sudo pacman -S --noconfirm tlp tlp-rdw ethtool smartmontools hdparm
sudo systemctl enable tlp

echo "Applying HDD performance tuning..."
sudo hdparm -B 254 /dev/sda
sudo hdparm -S 0 /dev/sda
sudo hdparm -W 1 /dev/sda

### --- 10. ZRAM (CRITICAL FOR 4GB RAM) ---------------------------------------
echo "Configuring ZRAM..."
sudo pacman -S --noconfirm zram-generator

sudo tee /etc/systemd/zram-generator.conf >/dev/null <<EOF
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
EOF

### --- 11. HDD I/O SCHEDULER OPTIMIZATION ------------------------------------
echo "Optimizing I/O scheduler for HDD..."
sudo tee /etc/udev/rules.d/60-ioschedulers.rules >/dev/null <<EOF
ACTION=="add|change", KERNEL=="sda", ATTR{queue/scheduler}="bfq"
EOF

### --- 12. FLATPAK ------------------------------------------------------------
echo "Installing Flatpak..."
sudo pacman -S --noconfirm flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

### --- 13. UTILITIES ----------------------------------------------------------
echo "Installing utilities..."
sudo pacman -S --noconfirm \
    htop neofetch btop rsync unzip zip \
    firefox vlc mpv

### --- 14. MPV CONFIG FOR VA-API ---------------------------------------------
echo "Configuring MPV for VA-API..."
mkdir -p ~/.config/mpv
cat <<EOF > ~/.config/mpv/mpv.conf
hwdec=vaapi
vo=gpu
gpu-context=wayland
EOF

### --- 15. KDE PERFORMANCE TWEAKS ---------------------------------------------
echo "Applying KDE performance tweaks..."

mkdir -p ~/.config

cat <<EOF > ~/.config/kdeglobals
[General]
AnimationDurationFactor=0
EOF

cat <<EOF > ~/.config/kwinrc
[Compositing]
LatencyPolicy=LowLatency
EOF

### --- 16. FIREFOX VA-API CONFIGURATION ---------------------------------------
echo "Configuring Firefox for VA-API hardware acceleration..."

mkdir -p ~/.config/environment.d

cat <<EOF > ~/.config/environment.d/firefox-vaapi.conf
MOZ_X11_EGL=1
MOZ_ENABLE_WAYLAND=1
LIBVA_DRIVER_NAME=i965
EOF

echo "Firefox VA-API environment configured."

firefox_prefs="$HOME/.mozilla/firefox/*/prefs.js"

if ls $firefox_prefs 1> /dev/null 2>&1; then
    sed -i '/media.ffmpeg.vaapi.enabled/d' $firefox_prefs
    sed -i '/media.ffmpeg.vaapi.force-enabled/d' $firefox_prefs
    sed -i '/media.hardware-video-decoding.enabled/d' $firefox_prefs
    sed -i '/media.hardware-video-decoding.force-enabled/d' $firefox_prefs
    sed -i '/gfx.webrender.all/d' $firefox_prefs
    sed -i '/media.ffvpx.enabled/d' $firefox_prefs

    echo 'user_pref("media.ffmpeg.vaapi.enabled", true);' >> $firefox_prefs
    echo 'user_pref("media.ffmpeg.vaapi.force-enabled", true);' >> $firefox_prefs
    echo 'user_pref("media.hardware-video-decoding.enabled", true);' >> $firefox_prefs
    echo 'user_pref("media.hardware-video-decoding.force-enabled", true);' >> $firefox_prefs
    echo 'user_pref("gfx.webrender.all", true);' >> $firefox_prefs
    echo 'user_pref("media.ffvpx.enabled", false);' >> $firefox_prefs

    echo "Firefox VA-API flags applied."
else
    echo "Firefox profile not found. Launch Firefox once and re-run this section."
fi

### --- 17. SAMSUNG THERMAL TUNING ---------------------------------------------
echo "Applying Samsung laptop thermal tuning..."

sudo pacman -S --noconfirm thermald powertop lm_sensors
sudo systemctl enable thermald
sudo sensors-detect --auto

sudo sed -i 's/^CPU_SCALING_GOVERNOR_ON_AC=.*/CPU_SCALING_GOVERNOR_ON_AC=powersave/' /etc/tlp.conf
sudo sed -i 's/^CPU_SCALING_GOVERNOR_ON_BAT=.*/CPU_SCALING_GOVERNOR_ON_BAT=powersave/' /etc/tlp.conf
sudo sed -i 's/^CPU_ENERGY_PERF_POLICY_ON_AC=.*/CPU_ENERGY_PERF_POLICY_ON_AC=power/' /etc/tlp.conf
sudo sed -i 's/^CPU_ENERGY_PERF_POLICY_ON_BAT=.*/CPU_ENERGY_PERF_POLICY_ON_BAT=power/' /etc/tlp.conf
sudo sed -i 's/^CPU_MAX_PERF_ON_AC=.*/CPU_MAX_PERF_ON_AC=70/' /etc/tlp.conf
sudo sed -i 's/^CPU_MAX_PERF_ON_BAT=.*/CPU_MAX_PERF_ON_BAT=45/' /etc/tlp.conf
sudo sed -i 's/^CPU_BOOST_ON_AC=.*/CPU_BOOST_ON_AC=0/' /etc/tlp.conf
sudo sed -i 's/^CPU_BOOST_ON_BAT=.*/CPU_BOOST_ON_BAT=0/' /etc/tlp.conf

sudo hdparm -B 128 /dev/sda
sudo hdparm -M 254 /dev/sda

echo "Samsung thermal tuning applied."

### --- 18. THERMAL LOGGING SCRIPT --------------------------------------------
echo "Installing thermal logging script..."

mkdir -p ~/thermal_logs

sudo tee /usr/local/bin/thermal_log.sh >/dev/null <<'EOF'
#!/usr/bin/env bash
LOGDIR="$HOME/thermal_logs"
mkdir -p "$LOGDIR"
LOGFILE="$LOGDIR/thermal_$(date +%Y-%m-%d_%H-%M-%S).log"
echo "Thermal logging started. Output file:"
echo "$LOGFILE"
echo "Press CTRL+C to stop."
while true; do
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    CPU_TEMP=$(sensors | grep -E 'Package id 0:' | awk '{print $4}')
    CORE1_TEMP=$(sensors | grep -E 'Core 0:' | awk '{print $3}')
    CORE2_TEMP=$(sensors | grep -E 'Core 1:' | awk '{print $3}')
    FAN_SPEED=$(sensors | grep -E 'fan1:' | awk '{print $2}')
    CPU_FREQ=$(cat /proc/cpuinfo | grep "MHz" | awk '{print $4}' | head -n 1)
    POWER=$(sudo powertop --time=1 --html=/tmp/power.html >/dev/null 2>&1 && \
            grep "Total" /tmp/power.html | grep -o '[0-9.]* W')
    echo "$TIMESTAMP | CPU: $CPU_TEMP | Core0: $CORE1_TEMP | Core1: $CORE2_TEMP | Fan: ${FAN_SPEED}RPM | Freq: ${CPU_FREQ}MHz | Power: ${POWER}" \
        >> "$LOGFILE"
    sleep 2
done
EOF

sudo chmod +x /usr/local/bin/thermal_log.sh

echo "Thermal logging script installed. Run with: thermal_log.sh"

### --- 19. BLUETOOTH & PRINTING SUPPORT ---------------------------------------
echo "Installing Bluetooth and printing support..."

sudo pacman -S --noconfirm bluez bluez-utils bluez-obex
sudo systemctl enable bluetooth.service

sudo pacman -S --noconfirm pipewire-audio wireplumber

sudo pacman -S --noconfirm cups system-config-printer cups-pdf \
    gutenprint foomatic-db-engine foomatic-db

sudo systemctl enable cups.service

echo "Bluetooth and printing support installed."

### --- 20. CLEANUP ------------------------------------------------------------
echo "Cleaning package cache..."
sudo pacman -Sc --noconfirm

echo "All performance optimizations applied! Reboot recommended.”
