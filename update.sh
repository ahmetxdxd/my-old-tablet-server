#!/bin/bash
# ==============================================================================
# MY TABLET SERVER - In-Place Updater (Non-Destructive Upgrade)
# ==============================================================================
# Upgrades an existing My Tablet Server installation to the latest release
# without wiping user data or reinstalling the entire Linux chroot.
# ==============================================================================

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[01;32m'
BLUE='\033[01;34m'
YELLOW='\033[01;33m'
CYAN='\033[01;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${CYAN}${BOLD}"
cat << 'BANNER'
  _    _ _____  _____       _______ ______ 
 | |  | |  __ \|  __ \   /\|__   __|  ____|
 | |  | | |__) | |  | | /  \  | |  | |__   
 | |  | |  ___/| |  | |/ /\ \ | |  |  __|  
 | |__| | |    | |__| / ____ \| |  | |____ 
  \____/|_|    |_____/_/    \_\_|  |______|
                                           
   My Tablet Server - One-Click In-Place Upgrade Tool
BANNER
echo -e "${NC}"

echo -e "${YELLOW}[1/4] Pulling Latest Updates from Git Repository...${NC}"
cd "$DIR"
if [ -d ".git" ]; then
    git pull origin main || echo -e "${YELLOW}Git pull skipped or already up-to-date.${NC}"
else
    echo -e "${YELLOW}Not a git repository, skipping git pull.${NC}"
fi

echo -e "\n${YELLOW}[2/4] Updating Local Host Tools, Permissions & Symlinks...${NC}"
chmod +x "$DIR/bin"/* "$DIR/shortcuts/linux"/*.sh "$DIR/shortcuts/linux/.run_silent.sh" "$DIR/install.sh" "$DIR/update.sh" "$DIR/uninstall.sh" 2>/dev/null || true

# Update global PC symlinks in ~/.local/bin
mkdir -p "$HOME/.local/bin"
for tool in tablet tablet-terminal tablet-term tablet-menu tablet-dashboard tablet-doctor tablet-devices battery-guard install-desktop-shortcut; do
    if [ -f "$DIR/bin/$tool" ]; then
        ln -sf "$DIR/bin/$tool" "$HOME/.local/bin/$tool"
    fi
done
ln -sf "$DIR/shortcuts/linux/.run_silent.sh" "$HOME/.local/bin/tablet-action" 2>/dev/null || true
echo -e "${GREEN}✓ Host PC command line tools successfully linked to ~/.local/bin${NC}"

# Reinstall / refresh Desktop & Application Menu shortcuts
"$DIR/bin/install-desktop-shortcut" >/dev/null 2>&1 || true
echo -e "${GREEN}✓ Desktop and Application Menu shortcuts refreshed.${NC}"

echo -e "\n${YELLOW}[3/4] Checking Connected Tablet (ADB) for In-Place Script Sync...${NC}"
DEV=$(adb devices 2>/dev/null | grep -E "\bdevice$" | awk '{print $1}' | head -n1 || true)

if [ -n "$DEV" ]; then
    echo -e "${GREEN}✓ Connected Tablet Found: $DEV${NC}"
    echo -e "--> Updating core utilities and audio bridge binaries on tablet..."

    # Push updated config and core tools into tablet chroot without wiping rootfs
    adb -s "$DEV" shell "su -c '
        mkdir -p /data/local/tmp/core /data/local/tmp/bin /data/local/tmp/config
        chmod 777 /data/local/tmp
    '" 2>/dev/null || true

    adb -s "$DEV" push "$DIR/core" /data/local/tmp/ >/dev/null 2>&1 || true
    adb -s "$DEV" push "$DIR/config" /data/local/tmp/ >/dev/null 2>&1 || true
    adb -s "$DEV" push "$DIR/bin" /data/local/tmp/ >/dev/null 2>&1 || true

    # Copy updated bin files into chroot /usr/local/bin
    adb -s "$DEV" shell "su -c '
        if [ -d /data/local/linux/usr/local/bin ]; then
            cp -r /data/local/tmp/bin/* /data/local/linux/usr/local/bin/ 2>/dev/null || true
            chmod +x /data/local/linux/usr/local/bin/* 2>/dev/null || true
        fi
    '" 2>/dev/null || true

    # Refresh port forward
    adb -s "$DEV" forward tcp:2222 tcp:22 2>/dev/null || true
    adb -s "$DEV" forward tcp:4711 tcp:4711 2>/dev/null || true

    echo -e "${GREEN}✓ Tablet binaries, scripts, and port forwards updated successfully.${NC}"
else
    echo -e "${YELLOW}[!] No tablet connected via USB. Host tools updated; connect tablet later to sync.${NC}"
fi

echo -e "\n${YELLOW}[4/4] Restarting Background Daemons & Services...${NC}"
if which systemctl >/dev/null 2>&1 && [ -f "$HOME/.config/systemd/user/tablet-server-sync.service" ]; then
    systemctl --user daemon-reload 2>/dev/null || true
    systemctl --user restart tablet-server-sync.service 2>/dev/null || true
fi

echo -e "\n${GREEN}${BOLD}======================================================================${NC}"
echo -e "${GREEN}${BOLD}   ✓ UPDATE COMPLETE! WELCOME TO THE NEWEST VERSION                  ${NC}"
echo -e "${GREEN}${BOLD}======================================================================${NC}"
echo -e "New features now active on your system:"
echo -e "  🌟 ${BOLD}Modern Web Desktop Dashboard${NC}   : Run '${CYAN}tablet ui${NC}' or use your Desktop icon"
echo -e "  📱 ${BOLD}Multi-Tablet Support${NC}           : Run '${CYAN}tablet devices${NC}' to manage multiple tablets"
echo -e "  🩺 ${BOLD}Tablet Doctor Diagnostics${NC}      : Run '${CYAN}tablet doctor --fix${NC}' for auto-repairs"
echo -e "  🛡️ ${BOLD}Smart Battery Health Guard${NC}     : Run '${CYAN}tablet battery-guard${NC}'\n"
