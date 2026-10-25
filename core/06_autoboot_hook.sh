#!/system/bin/sh
# ==============================================================================
# My Tablet Server - Persistent Auto-Boot Hook Installation
# ==============================================================================
# Executed by Android init on boot via /system/etc/install-recovery.sh:
# 1. Enforces permissive SELinux rules.
# 2. Acquires CPU wake lock and starts thermal mitigation.
# 3. Mounts chroot virtual filesystems.
# 4. Starts OpenSSH, Crond, and Android AudioBridgeServer.
# 5. Launches fullscreen terminal and attaches to shared tmux console.
# ==============================================================================

TARGET="/data/local/linux"

echo "[AutoBoot] 1/3 - Writing Boot Controller (/data/local/linux/boot.sh)..."

cat > "$TARGET/boot.sh" << 'BOOT_EOF'
#!/system/bin/sh
R=/data/local/linux
L=$R/lib/ld-musl-armhf.so.1
B=$R/bin/busybox

# 1. SELinux policy adjustments
setenforce 0 2>/dev/null
/system/xbin/supolicy --live \
    "allow init system_data_file dir *" \
    "allow init system_data_file file *" \
    "allow init system_data_file lnk_file *" \
    "allow init system_data_file sock_file *" \
    "allow init system_data_file fifo_file *" \
    "allow init shell_data_file file *" >/dev/null 2>&1

# 2. Prevent deep CPU sleep
echo "tablet_server_lock" > /sys/power/wake_lock 2>/dev/null

# 3. Apply thermal throttling & rogue diagnostics freeze
if [ -f "$R/thermal_fix.sh" ]; then
    sh "$R/thermal_fix.sh" >/dev/null 2>&1 &
fi

# 4. Remount /data with suid,dev,rw
mount -o remount,rw,suid,dev /data 2>/dev/null

# 5. Mount chroot filesystems
mkdir -p $R/proc $R/sys $R/dev $R/dev/pts $R/system $R/data $R/android_data $R/sdcard $R/tmp $R/run $R/var/empty
chmod 755 $R/run $R/var/empty 2>/dev/null || true
chmod 1777 $R/tmp 2>/dev/null || true

mount -t proc proc $R/proc 2>/dev/null || true
mount -o bind /sys $R/sys 2>/dev/null || mount -t sysfs sysfs $R/sys 2>/dev/null || true
mount -o bind /dev $R/dev 2>/dev/null || true
mount -o bind /dev/pts $R/dev/pts 2>/dev/null || mount -t devpts devpts $R/dev/pts 2>/dev/null || true
chmod 666 $R/dev/ptmx 2>/dev/null || true
mount -o bind /system $R/system 2>/dev/null || true
mount -o bind /data $R/data 2>/dev/null || true
mount -o bind /data/data $R/android_data 2>/dev/null || $B mount --bind /data/data $R/android_data 2>/dev/null || true
mount -o bind /data/media/0 $R/sdcard 2>/dev/null || $B mount --bind /data/media/0 $R/sdcard 2>/dev/null || true

# 6. Start Android Audio Bridge
if [ -f "/data/local/start_audio_bridge.sh" ]; then
    sh /data/local/start_audio_bridge.sh >/dev/null 2>&1 &
fi

# 7. Start SSH and Cron Daemons inside Chroot
$L $B chroot $R /bin/sh -c "
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
mkdir -p /var/run /var/empty /dev/net
[ -e /dev/net/tun ] || ln -s /dev/tun /dev/net/tun 2>/dev/null
pgrep -x sshd >/dev/null || /usr/sbin/sshd
pgrep -x crond >/dev/null || /usr/sbin/crond
"

# 8. Wi-Fi & Terminal Display Initialization
(
    sleep 15
    settings put global wifi_sleep_policy 2 2>/dev/null
    settings put system screen_brightness_mode 0 2>/dev/null
    settings put system screen_off_timeout 600000 2>/dev/null
    svc power stayon true 2>/dev/null
    svc wifi enable 2>/dev/null

    echo 180 > /sys/class/backlight/panel/brightness 2>/dev/null
    am start -n jackpal.androidterm/.Term 2>/dev/null || true
) &

BOOT_EOF

chmod 755 "$TARGET/boot.sh"

echo "[AutoBoot] 2/3 - Hooking into /system/etc/install-recovery.sh..."

mount -o remount,rw /system 2>/dev/null

HOOK_FILE="/system/etc/install-recovery.sh"
if [ ! -f "$HOOK_FILE" ]; then
    echo "#!/system/bin/sh" > "$HOOK_FILE"
fi

if ! grep -q "/data/local/linux/boot.sh" "$HOOK_FILE"; then
    cat >> "$HOOK_FILE" << 'HOOK_EOF'

# My Tablet Server Auto-Boot Hook
if [ -f /data/local/linux/boot.sh ]; then
    /system/bin/sh /data/local/linux/boot.sh >/dev/null 2>&1 &
fi
HOOK_EOF
fi

chmod 755 "$HOOK_FILE"
mount -o remount,ro /system 2>/dev/null

echo "[AutoBoot] 3/3 - Completed! All server daemons will launch automatically on boot."
