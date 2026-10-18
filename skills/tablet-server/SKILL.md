---
name: tablet-server
description: >-
  Manage, orchestrate, and control legacy Android tablets converted into 24/7 Linux servers,
  hardware-accelerated PC second displays, ad-free anime/media streamers, and smart audio devices.
  Use when asked to switch tablet operation modes (linux/android/hybrid), launch PC second screen,
  play ad-free anime or YouTube, set alarms/audio, debloat devices, or query tablet status.
---

# Tablet Server & Second Display Orchestration Skill

This skill guides AI agents on how to interact with, manage, and automate legacy Android tablets transformed into Linux servers, smart audio nodes, and PC secondary monitors.

---

## 1. Quick Environment & Hardware Discovery

Before executing actions, identify which devices are available:

### A. Check Attached USB Devices (ADB)
```bash
adb devices
```
> [!NOTE]
> Always check `ro.product.model` to distinguish between client tablets, server tablets, and user smartphones:
> ```bash
> for DEV in $(adb devices | grep -E "\bdevice$" | awk '{print $1}'); do
>     echo "$DEV: $(adb -s "$DEV" shell getprop ro.product.model 2>/dev/null)"
> done
> ```

### B. Device Profiles in this Setup
1. **Samsung Galaxy Tab 3 7.0 (SM-T210)** - Primary 24/7 Linux Server
   - **Access:** `ssh my-tablet-server` (or `ssh -p 22 root@192.168.1.109`)
   - **OS:** Alpine Linux ARMv7 in chroot on Android 4.4.2 KitKat (Rooted).
   - **Features:** Headless Linux daemon, OpenSSH, Tmux console, Nous Hermes AI, Crond, Dalvik AudioBridge (`127.0.0.1:4711`).
2. **Vestel V Tab 7 Lite II (`V_TAB_7_LITE_II`)** - Dedicated Second Screen & Media Tablet
   - **Access:** ADB via USB (`0582436374445700707`) or Wi-Fi (`192.168.1.111`).
   - **OS:** Stock Android 4.4.2 KitKat (63 bloatware packages safely frozen via `pm block`).
   - **Features:** 1024x600 @ 60 FPS Wayland virtual monitor client (`bVNC`), AnimeDLR, SkyTube Extra, VLC.

---

## 2. Core CLI Commands Reference

All project actions are unified under `bin/my-tablet-server` (or standalone binaries in `bin/`):

### A. Operation Modes
```bash
# 1. Check current status, active mode, screen brightness, and free RAM
my-tablet-server status

# 2. Pure Linux Server Mode: Screen OFF, TouchWiz Launcher stopped, ~700 MB RAM free
my-tablet-server linux

# 3. Pure Android Mode: Screen ON, normal tablet launcher, heavy Linux services stopped
my-tablet-server android

# 4. Hybrid Mode: Android UI visible (clock, calendar, wallpaper) + Linux daemons (Hermes, cron) running
my-tablet-server hybrid
```

### B. PC Second Display (Wayland Native / 1024x600 @ 60 FPS)
```bash
# Start second monitor to the right of PC display (auto-detects USB or Wi-Fi)
second-screen start right
# (Available positions: right, left, top, bottom)

# Force USB Cable mode (Lowest latency / Zero network overhead)
second-screen usb

# Force Wi-Fi LAN mode (Wireless freedom)
second-screen wifi

# Check virtual display status
second-screen status

# Close virtual monitor and return PC desktop to normal
second-screen stop
```

### C. Ad-Free Anime & Video Streaming
```bash
# Open AnimeDLR on tablet screen (10,000+ series, AnimePahe, 9Anime)
anime app

# Open Lightning Browser with built-in AdBlock to local anime portal (Animecix)
anime web https://animecix.net

# Open Miruro ad-free portal
anime miruro

# Stream direct video URL via hardware-accelerated VLC player
anime play "<video-url or search query>"

# Stop all video players and anime apps
anime stop
```

### D. Audio & Smart Speaker Commands
```bash
# Stream YouTube audio directly to tablet speakers (ad-free via yt-dlp & AudioBridge)
yt "Lofi hip hop beats"
yt stop

# Stream live internet radio stations (lofi, jazz, classic, rock)
radio lofi
radio stop

# Play local audio or sound effects through hardware AudioBridge
play-sound /path/to/sound.mp3

# Set hardware volume (0 to 15)
set-volume 12
```

### E. Dual Tablet PC Stereo Speakers & CAVA Visualizer
```bash
# Start dual stereo speakers (Left: Samsung, Right: Vestel)
my-tablet-server speakers
# or: stereo-speakers start

# Launch live CAVA audio frequency spectrum visualizer
my-tablet-server cava
# or: stereo-speakers cava

# Check speaker status and connected tablets
my-tablet-server speakers status

# Stop speakers and release tablets
my-tablet-server speakers stop
```

### F. Maintenance, Debloat & Screensavers
```bash
# Run universal debloater on all connected tablets (frees 300MB+ RAM safely)
debloat-tablet

# Launch ambient screensaver (options: aero, aquarium, fireplace, matrix)
screensaver start aquarium
screensaver stop

# Sync host PC Wi-Fi credentials to tablet automatically
sync-wifi
```

---

## 3. Best Practices for AI Agents

1. **Avoid the Watchdog Trap:**
   Never disable or force-stop `com.android.systemui`, `com.android.providers.downloads`, `com.android.providers.media`, or `com.android.settings` on KitKat. Doing so triggers a kernel watchdog panic and reboots the tablet after 60 seconds.
2. **Audio Calibration Preservation:**
   Never write directly to raw ALSA nodes on the tablet. Always pipe PCM audio into Dalvik AudioBridge on `127.0.0.1:4711` or use `play-sound` / `yt` / `radio` commands to maintain PDM clock sync and prevent audio crackling.
3. **Handling Long-Running Tasks:**
   Installing large APKs (e.g. 50MB games) over ADB on low-spec ARMv7 tablets takes 30-60 seconds due to `dexopt` verification. Always launch such tasks asynchronously or expect a delay without repeatedly polling.
4. **Display Geometry Awareness:**
   The virtual tablet monitor (`Virtual-TabletEkran`) is strictly 1024x600. When positioning with `kscreen-doctor`, ensure coordinate offsets match the host resolution (e.g. host 1600x900 means right display starts at `1600,0`).
