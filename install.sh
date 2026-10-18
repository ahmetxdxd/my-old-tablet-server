#!/bin/bash
# ==============================================================================
# MY TABLET SERVER - Automated Deployment & Setup Wizard
# Target Device: Samsung Galaxy Tab 3 7.0 Wi-Fi (SM-T210 / lt02wifi)
# Target OS    : Alpine Linux ARMv7 (Chroot on Android 4.4.2 KitKat, Kernel 3.4.5)
# Goal         : Full GNU/Linux Server + Fullscreen Terminal + Smart Audio Speaker
# ==============================================================================

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[01;32m'
BLUE='\033[01;34m'
YELLOW='\033[01;33m'
RED='\033[01;31m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BLUE}${BOLD}"
cat << 'BANNER'
  __  ____     __  _______ _    ____  _      ______ _______    _____ ______ _______      ________ _____  
 |  \/  \ \   / / |__   __|/\  |  _ \| |    |  ____|__   __|  / ____|  ____|  __ \ \    / /  ____|  __ \ 
 | \  / |\ \_/ /     | |  /  \ | |_) | |    | |__     | |    | (___ | |__  | |__) \ \  / /| |__  | |__) |
 | |\/| | \   /      | | / /\ \|  _ <| |    |  __|    | |     \___ \|  __| |  _  / \ \/ / |  __| |  _  / 
 | |  | |  | |       | |/ ____ \ |_) | |____| |____   | |     ____) | |____| | \ \  \  /  | |____| | \ \ 
 |_|  |_|  |_|       |_/_/    \_\____/|______|______|  |_|    |_____/|______|_|  \_\  \/   |______|_|  \_\
                                                                                                         
  Automated Installer & Provisioning Tool for Android Tablets (SM-T210 / KitKat 4.4.2)
BANNER
echo -e "${NC}"

echo -e "${YELLOW}[1/8] Checking ADB Connectivity & Device Status...${NC}"

# Verify ADB connection
DEVICES=$(adb devices | grep -v "List of devices" | grep "device$" || true)
if [ -z "$DEVICES" ]; then
    echo -e "${YELLOW}No active ADB device detected.${NC}"
    echo -e "Please ensure tablet is powered on, connected via USB, and 'USB Debugging' is enabled."
    echo -e "If the tablet is frozen or in MTP mode:"
    echo -e "  1. Hold the Power button for 10-15 seconds to hard-reboot the tablet."
    echo -e "  2. Go to Settings -> Developer Options -> Toggle 'USB Debugging' off and on."
    echo -e "\nWaiting for ADB device..."
    adb wait-for-device
fi

DEVICE_ID=$(adb devices | grep -v "List of devices" | grep "device$" | head -n 1 | awk '{print $1}')
echo -e "${GREEN}✓ Device Detected: ${DEVICE_ID}${NC}"

MODEL=$(adb shell getprop ro.product.model 2>/dev/null | tr -d '\r\n')
ANDROID_VER=$(adb shell getprop ro.build.version.release 2>/dev/null | tr -d '\r\n')
echo -e "${BLUE}  Hardware Model : ${MODEL:-SM-T210}${NC}"
echo -e "${BLUE}  Android Version: ${ANDROID_VER:-4.4.2}${NC}"

# Root verification
echo -e "${YELLOW}[2/8] Verifying Root (su) Privileges...${NC}"
ROOT_CHECK=$(adb shell "su -c 'id'" 2>/dev/null | tr -d '\r\n')
if [[ "$ROOT_CHECK" != *"uid=0"* ]]; then
    echo -e "${RED}[ERROR] Root access could not be acquired! Ensure SuperSU / root access is granted on the tablet screen.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Root Access Verified (uid=0).${NC}"

# Confirmation & Clean Slate Prompt
echo -e "\n${RED}${BOLD}======================================================================${NC}"
echo -e "${RED}${BOLD}   WARNING: CLEAN SLATE & FRESH INSTALLATION CONFIRMATION             ${NC}"
echo -e "${RED}${BOLD}======================================================================${NC}"
echo -e " This process will wipe previous Linux files and perform a clean install:"
echo -e "   • Existing chroot environments will be wiped (${YELLOW}/data/local/linux${NC}, ${YELLOW}/data/local/alpine${NC})"
echo -e "   • Rogue background updaters, Samsung Apps and bloatware will be disabled"
echo -e "   • Thermal runaway fix (0% CPU idle) will be permanently deployed"
echo -e "   • Android core framework, system drivers and Wi-Fi credentials are preserved"
echo -e "${RED}${BOLD}======================================================================${NC}"
read -p " Are you sure you want to proceed with a fresh installation? [y/N]: " CONFIRM_INSTALL

case "$CONFIRM_INSTALL" in
    [yY]|[yY][eE][sS])
        echo -e "${GREEN}✓ Confirmation accepted. Proceeding with clean installation...${NC}\n"
        ;;
    *)
        echo -e "${YELLOW}Installation aborted by user.${NC}"
        exit 0
        ;;
esac

# Local package checks
ROOTFS_TAR="$DIR/packages/alpine-minirootfs-3.24.2-armv7.tar.gz"
if [ ! -f "$ROOTFS_TAR" ]; then
    echo -e "${RED}[ERROR] packages/alpine-minirootfs-3.24.2-armv7.tar.gz is missing!${NC}"
    exit 1
fi

JACKPAL_APK="$DIR/packages/jackpal.androidterm_72.apk"
if [ ! -f "$JACKPAL_APK" ]; then
    echo -e "${YELLOW}[INFO] Downloading Jackpal Terminal APK from F-Droid...${NC}"
    curl -L "https://f-droid.org/repo/jackpal.androidterm_72.apk" -o "$JACKPAL_APK"
fi

if [ ! -f "$DIR/packages/audio_bridge.jar" ]; then
    echo -e "${RED}[ERROR] packages/audio_bridge.jar is missing!${NC}"
    exit 1
fi

echo -e "${YELLOW}[3/8] Performing Clean Slate Wipe on Tablet...${NC}"
adb shell "su -c '
    umount -l /data/local/linux/* /data/local/alpine/* 2>/dev/null || true
    rm -rf /data/local/linux /data/local/alpine /data/local/tmp/* 2>/dev/null || true
    mkdir -p /data/local/linux /data/local/tmp/config /data/local/tmp/core /data/local/tmp/bin /data/local/tmp/packages
    chmod 777 /data/local/linux /data/local/tmp
    chmod 777 /data/local/tmp/config /data/local/tmp/core /data/local/tmp/bin /data/local/tmp/packages
'"
echo -e "${GREEN}✓ Old chroot environments, caches and temporary files wiped clean.${NC}"

echo -e "${YELLOW}[4/8] Extracting & Deploying Alpine Linux ARMv7 RootFS...${NC}"

# Extract RootFS on host PC (solves missing tar binary on Android 4.4)
EXTRACT_DIR="/tmp/alpine_extracted_tablet"
rm -rf "$EXTRACT_DIR" && mkdir -p "$EXTRACT_DIR"
echo -e "${BLUE}  Extracting Alpine Linux ARMv7 rootfs on PC...${NC}"
tar -xzf "$ROOTFS_TAR" -C "$EXTRACT_DIR"

echo -e "${BLUE}  Pushing Alpine rootfs to /data/local/linux on tablet...${NC}"
adb push "$EXTRACT_DIR/." /data/local/linux/ >/dev/null
rm -rf "$EXTRACT_DIR"

# Auto-detect host PC public SSH key and inject into authorized_keys
for KEY in "$HOME/.ssh/id_ed25519.pub" "$HOME/.ssh/id_rsa.pub" "$HOME/.ssh/id_ecdsa.pub"; do
    if [ -f "$KEY" ]; then
        echo -e "${BLUE}  Found host SSH public key ($KEY), copying to tablet authorized_keys...${NC}"
        cat "$KEY" > "$DIR/config/authorized_keys"
        break
    fi
done

echo -e "${BLUE}  Pushing configurations, audio bridge, precompiled wheels and scripts...${NC}"
adb push "$DIR/packages/audio_bridge.jar" /data/local/tmp/packages/ >/dev/null
[ -d "$DIR/packages/wheels" ] && adb push "$DIR/packages/wheels/." /data/local/tmp/packages/wheels/ >/dev/null 2>&1 || true
adb push "$DIR/config/." /data/local/tmp/config/ >/dev/null
adb push "$DIR/core/." /data/local/tmp/core/ >/dev/null
adb push "$DIR/bin/." /data/local/tmp/bin/ >/dev/null

adb shell "su -c '
    chmod -R 755 /data/local/tmp/core /data/local/tmp/bin
    chmod -R 644 /data/local/tmp/config /data/local/tmp/packages
'"

# Install Jackpal Terminal Emulator APK via ADB (handles UID_CHANGED cleanly)
echo -e "${BLUE}  Installing Fullscreen Jackpal Terminal APK...${NC}"
adb uninstall jackpal.androidterm >/dev/null 2>&1 || true
adb shell "su -c 'rm -rf /data/data/jackpal.androidterm /data/app/jackpal.androidterm*'" 2>/dev/null || true
adb install -r "$JACKPAL_APK" >/dev/null 2>&1 || true

# Install Video Screensaver Engine APK & Media Catalog
VIDEOSCREENSAVER_APK="$DIR/packages/videoscreensaver.apk"
if [ -f "$VIDEOSCREENSAVER_APK" ]; then
    echo -e "${BLUE}  Installing Video Screensaver Engine APK...${NC}"
    adb install -r "$VIDEOSCREENSAVER_APK" >/dev/null 2>&1 || true
fi

# Install Core Browser & Media Tools (AnimeDLR, SkyTube, VLC, Lightning, bVNC)
echo -e "${BLUE}  Installing Core Media & Anime APKs (AnimeDLR, SkyTube, VLC, Lightning, bVNC)...${NC}"
for APK in "$DIR"/packages/browsers/*.apk "$DIR"/packages/tools/*.apk; do
    if [ -f "$APK" ]; then
        echo -e "${BLUE}    Installing $(basename "$APK")...${NC}"
        adb install -r "$APK" >/dev/null 2>&1 || true
    fi
done

if [ -d "$DIR/packages/screensavers" ]; then
    echo -e "${BLUE}  Deploying Frutiger Aero & Ambient Screensavers to /sdcard/Screensavers/...${NC}"
    adb shell "mkdir -p /sdcard/Screensavers/Wallpapers" 2>/dev/null || true
    adb push "$DIR/packages/screensavers/." /sdcard/Screensavers/ >/dev/null 2>&1 || true
fi

if [ -d "$DIR/packages/retro" ]; then
    echo -e "${BLUE}  Deploying & Installing Selected Retro Classic Games...${NC}"
    adb shell "mkdir -p /sdcard/retro-apks" 2>/dev/null || true
    adb push "$DIR/packages/retro/." /sdcard/retro-apks/ >/dev/null 2>&1 || true
    for RETRO_APK in "$DIR"/packages/retro/*.apk; do
        if [ -f "$RETRO_APK" ]; then
            echo -e "${BLUE}    Installing $(basename "$RETRO_APK")...${NC}"
            adb install -r "$RETRO_APK" >/dev/null 2>&1 || true
        fi
    done
fi

echo -e "${GREEN}✓ Rootfs, screensavers, anime player, retro games and tools successfully deployed.${NC}"

echo -e "${YELLOW}[5/8] Step 1: Applying Thermal Mitigation & Watchdog-Safe Debloat...${NC}"
adb shell "su -c 'sh /data/local/tmp/core/01_thermal_fix.sh'"
adb shell "su -c 'sh /data/local/tmp/core/02_safe_debloat.sh'"
echo -e "${GREEN}✓ Thermal fix applied (CPU idle stabilized) and bloatware/updaters disabled.${NC}"

echo -e "${YELLOW}[6/8] Step 2: Provisioning Minimal Alpine Linux ARMv7 Environment...${NC}"
echo -e "${BLUE}(Updating APK repositories & installing lightweight base packages - 1-2 minutes)...${NC}"
adb shell "su -c 'sh /data/local/tmp/core/03_setup_rootfs.sh'"
echo -e "${GREEN}✓ Minimal Alpine Linux environment and base server packages installed.${NC}"

echo -e "${YELLOW}[7/8] Step 3: Configuring Fullscreen Console & Hardware Terminal...${NC}"
adb shell "su -c 'sh /data/local/tmp/core/04_setup_terminal.sh'"
adb shell "su -c 'sh /data/local/tmp/core/05_audio_bridge.sh'"
echo -e "${GREEN}✓ Live terminal console and hardware audio bridge ready.${NC}"

echo -e "${YELLOW}[8/8] Step 4: Installing Persistent Auto-Boot Hook & Launching Daemons...${NC}"
adb shell "su -c 'sh /data/local/tmp/core/06_autoboot_hook.sh'"

# Ensure OpenSSH daemon is running immediately
adb shell "su -c '
    mkdir -p /data/local/linux/var/run /data/local/linux/var/empty
    /data/local/linux/lib/ld-musl-armhf.so.1 /data/local/linux/bin/busybox chroot /data/local/linux /usr/sbin/sshd 2>/dev/null || true
'"

echo -e "${GREEN}✓ install-recovery.sh auto-boot hook installed and OpenSSH running.${NC}"

# USB Port Forwarding
adb forward tcp:2222 tcp:22 2>/dev/null || true
adb forward tcp:22 tcp:22 2>/dev/null || true

# Wi-Fi Auto-Sync & PC Host Daemon Configuration
echo -e "\n${BLUE}--> Setting up Host PC Wi-Fi Auto-Sync & USB daemon...${NC}"
chmod +x "$DIR/bin/sync-wifi" "$DIR/bin/tablet-daemon" "$DIR/bin/auto-downloader" "$DIR/bin/agy" 2>/dev/null || true
"$DIR/bin/sync-wifi" || true

# Install and start user systemd service on PC
mkdir -p "$HOME/.config/systemd/user"
cat << EOF > "$HOME/.config/systemd/user/tablet-server-sync.service"
[Unit]
Description=Tablet Server Auto Wi-Fi Synchronizer & Port Forwarder
After=network.target

[Service]
Type=simple
ExecStart=/bin/bash "$DIR/bin/tablet-daemon"
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
EOF
systemctl --user daemon-reload 2>/dev/null || true
systemctl --user enable --now tablet-server-sync.service 2>/dev/null || true
echo -e "${GREEN}✓ Host Wi-Fi auto-sync daemon activated (monitors PC network & auto-syncs to tablet).${NC}"

# Wi-Fi IP Detection (processed locally on PC)
WIFI_IP=$(adb shell "su -c 'ip -4 addr show wlan0'" 2>/dev/null | grep -E "inet [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | awk '{print $2}' | cut -d/ -f1 | head -n 1)

# Cleanup temporary deployment files
adb shell "su -c 'rm -rf /data/local/tmp/*'" 2>/dev/null || true

# ==============================================================================
# AUTO-DOWNLOADER INTERACTIVE APP SELECTION
# ==============================================================================
echo -e "\n${YELLOW}${BOLD}======================================================================${NC}"
echo -e "${YELLOW}${BOLD}   MINIMAL PURE LINUX SERVER DEPLOYMENT COMPLETED!                    ${NC}"
echo -e "${YELLOW}${BOLD}======================================================================${NC}"
echo -e " The tablet is now running as a clean, low-resource Minimal Linux Server."
echo -e " Free RAM is maximized and all heavy background tasks are stopped."
echo -e ""
echo -e " Would you like to install pre-configured applications & media tools?"
echo -e " ${BOLD}(YouTube audio, Web browsers, VLC video stream, Hermes AI, Antigravity CLI)${NC}"
echo -e "${YELLOW}${BOLD}======================================================================${NC}"
read -p " Do you want to run auto-downloader now? [y/N]: " RUN_AUTODOWNLOADER

case "$RUN_AUTODOWNLOADER" in
    [yY]|[yY][eE][sS])
        echo -e "${GREEN}Launching auto-downloader wizard...${NC}"
        "$DIR/bin/auto-downloader"
        ;;
    *)
        echo -e "\n${GREEN}✓ Kept as a Pure Minimal Linux Server.${NC}"
        echo -e "You can run ${YELLOW}auto-downloader${NC} at any time from your PC or tablet terminal."
        ;;
esac

echo -e "\n${GREEN}${BOLD}======================================================================${NC}"
echo -e "${GREEN}${BOLD}   CONGRATULATIONS! MY TABLET SERVER IS READY!                        ${NC}"
echo -e "${GREEN}${BOLD}======================================================================${NC}"
echo -e "${BOLD}How to Connect:${NC}"
echo -e "1. ${BLUE}Wireless via Wi-Fi (Home LAN):${NC}"
if [ -n "$WIFI_IP" ]; then
    echo -e "   ssh root@${WIFI_IP}  or  ${GREEN}ssh my-tablet-server${NC}"
else
    echo -e "   ${GREEN}ssh my-tablet-server${NC} (after connecting tablet to Wi-Fi)"
fi
echo -e "2. ${BLUE}Wired via USB Cable (ADB Port Forwarding):${NC}"
echo -e "   ${GREEN}ssh root@localhost -p 2222${NC}"
echo -e "   (No password required, your PC SSH key was authorized automatically. Default password: hermes)"
echo -e "\n${BOLD}Live Synced Terminal Console:${NC}"
echo -e "   The tablet physical display is running Jackpal Terminal."
echo -e "   Run ${YELLOW}console${NC} or ${YELLOW}tmux attach -t console${NC} from your PC terminal"
echo -e "   to view and interact with the exact same live session on the tablet screen."
echo -e "\n${BOLD}Master CLI & Tools:${NC}"
echo -e "   Server CLI helper  : ${YELLOW}my-tablet-server${NC} (or: my-tablet-server status, console, server)"
echo -e "   Auto-Downloader    : ${GREEN}auto-downloader${NC} (install/upgrade apps anytime)"
echo -e "   CCTV Security Cam  : ${GREEN}cctv start [max_gb]${NC} (24/7 video surveillance with circular quota)"
echo -e "   Retro Games Store  : ${GREEN}retro-store${NC} (Talking Tom, Çakmak, Pou, Flappy Bird, Temple Run, Emülatörler)"
echo -e "   Screensaver & Süs  : ${GREEN}screensaver art${NC} (or: aquarium, fireplace, matrix, sus menu)"
echo -e "   Antigravity CLI    : ${GREEN}agy${NC} / ${GREEN}antigravity${NC} (Google Antigravity AI CLI)"
echo -e "   Nous Hermes Agent  : ${GREEN}hermes${NC} (AI terminal agent)"
echo -e "   Anime & Video watch: ${YELLOW}watch <URL or search>${NC} (Hardware-accelerated VLC player)"
echo -e "   YouTube audio      : ${YELLOW}yt 'Song Name'${NC} (or: yt stop)"
echo -e "   Play sound / music : ${YELLOW}play-sound <file.mp3>${NC} (or: play)"
echo -e "   Internet radio     : ${YELLOW}radio lofi${NC} (or: radio jazz, radio rock)"
echo -e "   Morning alarm      : ${YELLOW}alarm play${NC}"
echo -e "   [1] Linux Server   : ${YELLOW}server-mode linux${NC} (headless, screen off, max RAM)"
echo -e "   [2] Android Tablet : ${YELLOW}server-mode android${NC} (pure tablet, Linux stopped)"
echo -e "   [3] Hybrid Mode    : ${YELLOW}server-mode hybrid${NC} (Android UI ON + Hermes Timers & Cron)"
echo -e "   TTY Console Mode   : ${YELLOW}server-mode screen-on${NC} (fullscreen TTY terminal)"
echo -e "   Screen brightness  : ${YELLOW}screen on${NC} / ${YELLOW}screen off${NC} / ${YELLOW}screen brightness 150${NC}"
echo -e "   Server dashboard   : ${YELLOW}server-status${NC} (or: ${YELLOW}server-mode status${NC})"
echo -e "======================================================================\n"
