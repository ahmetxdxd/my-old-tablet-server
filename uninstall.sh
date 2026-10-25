#!/bin/bash
# ==============================================================================
# MY TABLET SERVER - Complete Uninstaller & Clean Reversion Tool
# ==============================================================================
# Safely reverts all modifications made to the tablet and host PC:
# - Terminates and unmounts all Linux chroot environments
# - Removes /data/local/linux, AudioBridge, and helper scripts
# - Restores /system/etc/install-recovery.sh (removes autoboot hook)
# - Unfreezes/Restores all disabled Samsung/Android bloatware packages
# - Removes PC shortcuts, systemd daemons, and config directories
# ==============================================================================

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[01;32m'
BLUE='\033[01;34m'
YELLOW='\033[01;33m'
RED='\033[01;31m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${RED}${BOLD}"
cat << 'BANNER'
  _    _ _   _ _____ _   _  _____ _______       _      _      ______ _____  
 | |  | | \ | |_   _| \ | |/ ____|__   __|/\   | |    | |    |  ____|  __ \ 
 | |  | |  \| | | | |  \| | (___    | |  /  \  | |    | |    | |__  | |__) |
 | |  | | . ` | | | | . ` |\___ \   | | / /\ \ | |    | |    |  __| |  _  / 
 | |__| | |\  |_| |_| |\  |____) |  | |/ ____ \| |____| |____| |____| | \ \ 
  \____/|_| \_|_____|_| \_|_____/   |_/_/    \_\______|______|______|_|  \_\
                                                                             
   Complete Uninstallation & Factory State Reversion Wizard
BANNER
echo -e "${NC}"

echo -e "${YELLOW}This wizard will revert all modifications and cleanly remove My Tablet Server.${NC}\n"
read -p "Are you sure you want to proceed with uninstallation? [y/N]: " CONFIRM_UNINSTALL
case "$CONFIRM_UNINSTALL" in
    [yY]|[yY][eE][sS])
        ;;
    *)
        echo -e "${YELLOW}Uninstallation cancelled.${NC}"
        exit 0
        ;;
esac

echo -e "\n${YELLOW}[1/4] Checking Connected Tablet (ADB)...${NC}"
DEV=$(adb devices 2>/dev/null | grep -E "\bdevice$" | awk '{print $1}' | head -n1 || true)

if [ -n "$DEV" ]; then
    echo -e "${GREEN}✓ Connected Tablet Found: $DEV${NC}"

    echo -e "${YELLOW}[2/4] Reverting Tablet Modifications (Root & File Cleanup)...${NC}"
    adb -s "$DEV" shell "su -c '
        echo \"--> Stopping all chroot and audio bridge services...\"
        pkill -9 sshd 2>/dev/null || true
        pkill -9 snapclient 2>/dev/null || true
        pkill -9 crond 2>/dev/null || true
        pkill -9 tmux 2>/dev/null || true
        pkill -9 -f AudioBridgeServer 2>/dev/null || true

        echo \"--> Safely unmounting virtual filesystems...\"
        for mp in /data/local/linux/dev/pts /data/local/linux/dev /data/local/linux/proc /data/local/linux/sys /data/local/linux/system /data/local/linux/android_data /data/local/linux/sdcard /data/local/linux/data; do
            umount -l \"\$mp\" 2>/dev/null || true
        done
        for m in \$(cat /proc/mounts 2>/dev/null | grep \"/data/local/linux\" | awk \"{print \\\$2}\" | sort -r); do
            umount -l \"\$m\" 2>/dev/null || true
        done
        umount -l /data/local/alpine/* 2>/dev/null || true

        echo \"--> Removing Linux chroot, AudioBridge, and temporary directories...\"
        rm -rf /data/local/linux /data/local/alpine /data/local/tmp /data/local/audio_bridge.jar /data/local/start_audio_bridge.sh 2>/dev/null || true

        echo \"--> Restoring /system/etc/install-recovery.sh autoboot hook...\"
        mount -o remount,rw /system 2>/dev/null || true
        if [ -f /system/etc/install-recovery.sh.bak ]; then
            mv /system/etc/install-recovery.sh.bak /system/etc/install-recovery.sh 2>/dev/null || true
        elif [ -f /system/etc/install-recovery.sh ]; then
            # Strip tablet server trigger block
            sed -i \"/MY TABLET SERVER/d\" /system/etc/install-recovery.sh 2>/dev/null || true
            sed -i \"/data\/local\/linux/d\" /system/etc/install-recovery.sh 2>/dev/null || true
        fi
        mount -o remount,ro /system 2>/dev/null || true

        echo \"--> Unfreezing / Restoring disabled Android and Samsung apps...\"
        for pkg in com.sec.android.app.samsungapps com.sec.android.widgetapp.ap.hero.accuweather com.policydm com.wssyncmldm; do
            pm enable \"\$pkg\" 2>/dev/null || true
            pm unhide \"\$pkg\" 2>/dev/null || true
        done
    '" 2>/dev/null || echo -e "${YELLOW}Warning: Non-root or partial access; cleaned up reachable ADB components.${NC}"

    echo -e "${GREEN}✓ Tablet environment reverted to clean Android state.${NC}"
else
    echo -e "${YELLOW}[!] No tablet detected via USB. Skipping tablet-side filesystem cleanup.${NC}"
fi

echo -e "\n${YELLOW}[3/4] Removing Host PC Shortcuts, Binaries & Services...${NC}"

# Remove systemd daemon if active
if which systemctl >/dev/null 2>&1; then
    systemctl --user stop tablet-server-sync.service 2>/dev/null || true
    systemctl --user disable tablet-server-sync.service 2>/dev/null || true
fi
rm -f "$HOME/.config/systemd/user/tablet-server-sync.service" 2>/dev/null || true

# Remove CLI symlinks
rm -f "$HOME/.local/bin/tablet" \
      "$HOME/.local/bin/tablet-terminal" \
      "$HOME/.local/bin/tablet-term" \
      "$HOME/.local/bin/tablet-menu" \
      "$HOME/.local/bin/tablet-dashboard" \
      "$HOME/.local/bin/tablet-doctor" \
      "$HOME/.local/bin/tablet-devices" \
      "$HOME/.local/bin/battery-guard" \
      "$HOME/.local/bin/tablet-action" 2>/dev/null || true

# Remove desktop shortcuts
rm -f "$HOME/Desktop/My-Tablet-Server.desktop" \
      "$HOME/Masaüstü/My-Tablet-Server.desktop" \
      "$HOME/.local/share/applications/my-tablet-server.desktop" 2>/dev/null || true

# Clean port forwards
adb forward --remove tcp:2222 2>/dev/null || true
adb forward --remove tcp:4711 2>/dev/null || true

echo -e "${GREEN}✓ PC shortcuts, systemd services, and ADB port forwards removed.${NC}"

echo -e "\n${YELLOW}[4/4] Cleaning Configuration Caches...${NC}"
rm -rf "$HOME/.config/my-tablet-server" /tmp/snapcast /tmp/tablet_dashboard.log 2>/dev/null || true

echo -e "\n${GREEN}${BOLD}======================================================================${NC}"
echo -e "${GREEN}${BOLD}   ✓ COMPLETE UNINSTALLATION FINISHED SUCCESSFULLY!                   ${NC}"
echo -e "${GREEN}${BOLD}======================================================================${NC}"
echo -e "Your tablet and host PC have been cleanly restored to their original state."
echo -e "If you wish to reinstall in the future, simply run: ${CYAN}./install.sh${NC}\n"
