#!/system/bin/sh
# ==============================================================================
# My Tablet Server - Alpine Linux RootFS Provisioning (/data/local/linux)
# ==============================================================================

TARGET="/data/local/linux"

echo "[RootFS-Setup] 1/6 - Remounting /data with suid, dev, rw..."
mount -o remount,rw,suid,dev /data 2>/dev/null

echo "[RootFS-Setup] 2/6 - Mounting virtual filesystems (proc, sys, dev, devpts, system, data)..."
mkdir -p "$TARGET/proc" "$TARGET/sys" "$TARGET/dev" "$TARGET/dev/pts" "$TARGET/system" "$TARGET/data" "$TARGET/android_data" "$TARGET/sdcard"
mkdir -p "$TARGET/run" "$TARGET/tmp" "$TARGET/var/empty"
chmod 755 "$TARGET/run" "$TARGET/var/empty" 2>/dev/null || true
chmod 1777 "$TARGET/tmp" 2>/dev/null || true

mount -t proc proc "$TARGET/proc" 2>/dev/null || true
mount -t sysfs sysfs "$TARGET/sys" 2>/dev/null || true
mount -o bind /dev "$TARGET/dev" 2>/dev/null || true
mount -o bind /dev/pts "$TARGET/dev/pts" 2>/dev/null || mount -t devpts devpts "$TARGET/dev/pts" 2>/dev/null || true
chmod 666 "$TARGET/dev/ptmx" 2>/dev/null || true
mount -o bind /system "$TARGET/system" 2>/dev/null || true
mount -o bind /data "$TARGET/data" 2>/dev/null || true
mount -o bind /data/data "$TARGET/android_data" 2>/dev/null || true
mount -o bind /data/media/0 "$TARGET/sdcard" 2>/dev/null || true

echo "[RootFS-Setup] 3/6 - Configuring DNS, Hostname and Android Network Groups..."
cat > "$TARGET/etc/resolv.conf" << 'EOF'
nameserver 1.1.1.1
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

cat > "$TARGET/etc/hosts" << 'EOF'
127.0.0.1       localhost my-tablet-server
::1             localhost my-tablet-server
192.168.1.110   host-pc pc
EOF

echo "my-tablet-server" > "$TARGET/etc/hostname"

# Android Paranoid Network permissions (AID_INET 3003, AID_NET_RAW 3004)
grep -q "^aid_inet:" "$TARGET/etc/group" 2>/dev/null || echo "aid_inet:x:3003:root,sshd" >> "$TARGET/etc/group"
grep -q "^aid_net_raw:" "$TARGET/etc/group" 2>/dev/null || echo "aid_net_raw:x:3004:root,sshd" >> "$TARGET/etc/group"

sed -i 's|^root:x:0:0:root:/root:/bin/sh|root:x:0:0:root:/root:/bin/bash|' "$TARGET/etc/passwd" 2>/dev/null || true
sed -i 's|^root:x:0:0:root:/root:/bin/ash|root:x:0:0:root:/root:/bin/bash|' "$TARGET/etc/passwd" 2>/dev/null || true

echo "[RootFS-Setup] 4/6 - Installing Server Packages inside Chroot..."

L="$TARGET/lib/ld-musl-armhf.so.1"
B="$TARGET/bin/busybox"

cat > "$TARGET/tmp/chroot_install.sh" << 'CHROOT_EOF'
#!/bin/sh
set -e
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

sed -i 's/^#//g' /etc/apk/repositories 2>/dev/null || true
grep -q "community" /etc/apk/repositories 2>/dev/null || echo "http://dl-cdn.alpinelinux.org/alpine/v3.24/community" >> /etc/apk/repositories

echo "[Chroot] Updating APK repositories..."
apk update

echo "[Chroot] Installing Minimal Server Packages (OpenSSH, Tmux, btop, htop, Python3, curl, git)..."
apk add --no-cache \
    bash \
    openssh \
    openssh-sftp-server \
    tmux \
    btop \
    htop \
    python3 \
    py3-pip \
    git \
    curl \
    wget \
    ca-certificates \
    nano \
    net-tools \
    iproute2 \
    snapcast-client \
    tzdata

cp /usr/share/zoneinfo/Europe/Istanbul /etc/localtime 2>/dev/null || true
echo "Europe/Istanbul" > /etc/timezone 2>/dev/null || true

echo "root:hermes" | chpasswd

mkdir -p /var/run /var/empty /root/.ssh
ssh-keygen -A

CHROOT_EOF

chmod +x "$TARGET/tmp/chroot_install.sh"
$L $B chroot "$TARGET" /bin/sh /tmp/chroot_install.sh
rm -f "$TARGET/tmp/chroot_install.sh"

echo "[RootFS-Setup] 5/6 - Deploying Configurations (sshd, authorized_keys, motd, bashrc)..."
cp /data/local/tmp/config/sshd_config "$TARGET/etc/ssh/sshd_config" 2>/dev/null || true
cp /data/local/tmp/config/authorized_keys "$TARGET/root/.ssh/authorized_keys" 2>/dev/null || true
chmod 700 "$TARGET/root/.ssh" 2>/dev/null || true
chmod 600 "$TARGET/root/.ssh/authorized_keys" 2>/dev/null || true

cp /data/local/tmp/config/motd "$TARGET/etc/motd" 2>/dev/null || true
cp /data/local/tmp/config/bashrc "$TARGET/root/.bashrc" 2>/dev/null || true
cp /data/local/tmp/config/bashrc "$TARGET/etc/bash.bashrc" 2>/dev/null || true

echo "[RootFS-Setup] 6/6 - Installing Utility Commands into /usr/local/bin..."
mkdir -p "$TARGET/usr/local/bin"
cp -r /data/local/tmp/bin/* "$TARGET/usr/local/bin/" 2>/dev/null || true
chmod +x "$TARGET/usr/local/bin"/* 2>/dev/null || true

echo "[RootFS-Setup] Completed successfully! Alpine Linux environment is ready."
