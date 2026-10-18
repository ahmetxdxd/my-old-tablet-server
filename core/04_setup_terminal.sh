#!/system/bin/sh
# ==============================================================================
# My Tablet Server - Fullscreen Terminal & Live Tmux Console Integration
# ==============================================================================

TARGET="/data/local/linux"

echo "[Terminal-Setup] 1/3 - Configuring Fullscreen Preferences..."
PREFS_DIR="/data/data/jackpal.androidterm/shared_prefs"
mkdir -p "$PREFS_DIR" 2>/dev/null || true

cat > "$PREFS_DIR/jackpal.androidterm_preferences.xml" << 'EOF'
<?xml version='1.0' encoding='utf-8' standalone='yes' ?>
<map>
    <string name="statusbar">0</string>
    <string name="actionbar">0</string>
    <string name="fontsize">16</string>
    <string name="color">4</string>
    <string name="orientation">1</string>
    <boolean name="utf8_by_default">true</boolean>
    <string name="shell">/system/xbin/su</string>
    <string name="initialcommand">sh /data/local/linux/enter.sh&#10;</string>
</map>
EOF

chown -R $(stat -c %u /data/data/jackpal.androidterm 2>/dev/null || echo 10000):$(stat -c %g /data/data/jackpal.androidterm 2>/dev/null || echo 10000) "$PREFS_DIR" 2>/dev/null || true
chmod 660 "$PREFS_DIR/jackpal.androidterm_preferences.xml" 2>/dev/null || true

echo "[Terminal-Setup] 2/3 - Creating Chroot Console Bridge (enter.sh)..."
cat > "$TARGET/enter.sh" << 'EOF'
#!/system/bin/sh
R=/data/local/linux
L=$R/lib/ld-musl-armhf.so.1
B=$R/bin/busybox

# Ensure vital virtual filesystems are mounted
[ -e $R/dev/urandom ] || mount -o bind /dev $R/dev 2>/dev/null
[ -e $R/proc/uptime ] || mount -t proc proc $R/proc 2>/dev/null
[ -e $R/sys/class ] || mount -t sysfs sysfs $R/sys 2>/dev/null
[ -e $R/system/bin/sh ] || mount -o bind /system $R/system 2>/dev/null
[ -e $R/data/local ] || mount -o bind /data $R/data 2>/dev/null

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export TERM=xterm-256color
export HOME=/root
export USER=root

$L $B chroot $R /bin/bash -c "
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export TERM=xterm-256color
export HOME=/root
export USER=root
tmux attach -t console 2>/dev/null || tmux new-session -s console
"
EOF
chmod 755 "$TARGET/enter.sh" 2>/dev/null || true

echo "[Terminal-Setup] 3/3 - Launching Terminal..."
am start -n jackpal.androidterm/.Term 2>/dev/null || true

echo "[Terminal-Setup] Completed. Terminal is now attached to the shared tmux console."
