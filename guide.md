# My Tablet Server & Second Display – Comprehensive User Guide 📖

This guide is a complete user and architecture document for turning old Android tablets (such as the Samsung Galaxy Tab 3 and Vestel V Tab) into **24/7 GNU/Linux servers**, **low-latency second displays for a PC**, **ad-free anime and media players**, and **smart audio stations**.

---

## 📑 Table of Contents
1. [Project Vision and Architecture](#1-project-vision-and-architecture)
2. [Supported Hardware and Benchmark Comparison](#2-supported-hardware-and-benchmark-comparison)
3. [One-Click Installation (Linux & Windows)](#3-one-click-installation-linux--windows)
4. [Three Core Operating Modes (Linux, Android, Hybrid)](#4-three-core-operating-modes-linux-android-hybrid)
5. [PC Second Display Mode](#5-pc-second-display-mode)
6. [Ad-Free Anime & Video Playback System](#6-ad-free-anime--video-playback-system)
7. [Smart Audio Station & Dalvik AudioBridge](#7-smart-audio-station--dalvik-audiobridge)
8. [Frutiger Aero Screensavers & Nostalgic Wallpapers](#8-frutiger-aero-screensavers--nostalgic-wallpapers)
9. [Nostalgic Retro Games & Security Isolation](#9-nostalgic-retro-games--security-isolation)
10. [Universal Tablet Debloater](#10-universal-tablet-debloater)
11. [Integration with AI Agents](#11-integration-with-ai-agents)
12. [Frequently Asked Questions & Troubleshooting](#12-frequently-asked-questions--troubleshooting)

---

## 1. Project Vision and Architecture

Old Android tablets—especially those from the Android 4.4 KitKat era—often sit unused in drawers. However, their **low power consumption (2–3 W)**, **built-in battery (providing an uninterrupted UPS-like function)**, and **integrated display/touch panels** make them excellent home servers and peripherals.

### Core Engineering Principles

1. **Don't kill the drivers—make use of them:**  
   Many chroot projects kill Android services and try to write directly to the Linux framebuffer or ALSA. On Samsung and Allwinner chipsets, this can cause hardware lockups and unbearable audio crackling. Our project keeps Android's graphics and audio drivers running in the background to provide **zero crackling** and **100% stability**.
2. **Watchdog protection:**  
   If critical services such as `systemui` or `settings` are completely removed on Android 4.4, the kernel watchdog restarts the system every 60 seconds. Our project only freezes safe bloatware.
3. **Thermal control:**  
   On devices such as the Samsung SM-T210, cellular modem services that run on Wi-Fi models are prevented from entering an infinite loop, keeping the processor at a cool **36°C while idle**.

---

## 2. Supported Hardware and Benchmark Comparison

Two different tablet classes have been extensively tested and their roles optimized:

| Criterion | Samsung Galaxy Tab 3 7.0 (SM-T210) | Vestel V Tab 7 Lite II | Why choose it? |
| :--- | :--- | :--- | :--- |
| **Recommended role** | **24/7 uninterrupted Linux server** | **PC second display & portable media player** | Samsung is suitable as a server thanks to its eMMC endurance and root support. |
| **Processor (SoC)** | Marvell PXA986 (2× Cortex-A9 @ 1.2 GHz) | Allwinner A33 (4× Cortex-A7 @ 1.2 GHz) | Cortex-A9 is faster per core for server workloads thanks to its **out-of-order (OoO) execution** architecture. |
| **Storage** | **High-endurance Samsung eMMC (121 MB/s)** | **Raw consumer NAND flash** | Raw NAND wears out faster under continuous 24/7 log and database writes; Samsung eMMC supports wear leveling. |
| **Privilege level** | **Full root (`su`)** | Stock manufacturer firmware without root | Samsung can run low-numbered ports (such as 22) and a chroot environment without issues. |
| **Display** | 1024 × 600 TFT | 1024 × 600 glossy TFT | Both tablets work perfectly as 1024 × 600 virtual monitors. |

---

## 3. One-Click Installation (Linux & Windows)

### Preparation
On the tablet, open **Settings → Developer options** and enable **USB debugging**. Then connect the tablet to your computer with a USB cable.

### A) On Linux / macOS
```bash
cd "tablet sunucu"
chmod +x install.sh
./install.sh
```

### B) On Windows
1. Double-click `install.bat` (or run it in PowerShell):
```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

The installation wizard automatically:
- Checks the device and its permissions.
- Sets up and installs an Alpine Linux ARMv7 environment on the tablet.
- Installs all required APKs (`animedlr`, `skytube`, `vlc`, `lightning`, `bvnc`, and retro games).
- Applies thermal runaway patches.
- Registers an automatic Wi-Fi pairing background service on your PC.

---

## 4. Three Core Operating Modes (Linux, Android, Hybrid)

You can switch the tablet's resource allocation on demand:

```bash
# Check status: active mode, screen brightness, and RAM usage
my-tablet-server status

# 1. Pure Linux server mode (headless):
# Turns off the display backlight and freezes the Android interface.
# Allocates 700+ MB of RAM to the Linux server (SSH, databases, bots).
my-tablet-server linux

# 2. Pure Android tablet mode:
# Turns on the display and launches the regular tablet interface and games.
# Stops resource-intensive Linux services to give Android maximum performance.
my-tablet-server android

# 3. Hybrid (dual) mode:
# Keeps the tablet interface, clock, and notifications active,
# while Linux schedulers (Hermes, cron) continue running in the background.
my-tablet-server hybrid
```

---

## 5. PC Second Display Mode

Turn your tablet into a hardware-accelerated **1024 × 600 @ 60 FPS** second monitor for your computer (KDE Plasma Wayland)!

```bash
# Place the second display to the RIGHT of your laptop:
second-screen start right
# (Shortcut: ekran2)

# Place the second display to the LEFT of your laptop:
second-screen start left

# Start in USB-only mode (zero latency; no internet required):
second-screen usb

# Start in Wi-Fi-only mode (wireless use):
second-screen wifi

# Check second-display status:
second-screen status

# Turn off the second display and return to normal:
second-screen stop
```

Move your mouse cursor in the selected direction (for example, to the right) and it will move directly onto the tablet's screen. You can also drag windows onto the tablet display!

---

## 6. Ad-Free Anime & Video Playback System

The same experience as our **SkyTube Extra** setup for YouTube is also available for anime:

```bash
# 1. Launch AnimeDLR on the tablet (10,000+ anime series, including AnimePahe, etc.):
anime
# or: anime app

# 2. Open the ad-free anime portal Animecix in the Lightning Browser:
anime web https://animecix.net

# 3. Open the open-source anime portal Miruro:
anime miruro

# 4. Play a video/stream directly with VLC hardware acceleration:
anime play "Naruto 1. bolum"

# 5. Close the players and anime apps:
anime stop
```

---

## 7. Smart Audio Station & Dalvik AudioBridge

Audio from `mpv`, `ffmpeg`, and radio streams running on the Linux side is played through a lightweight bridge connected to Android's native audio framework.

```bash
# Play a music/podcast stream from YouTube:
yt "Lofi hip hop radio"
yt stop

# Start internet radio stations:
radio lofi
radio jazz
radio rock
radio stop

# Play a local audio file through the speaker:
play-sound /path/to/sound.mp3

# Set hardware volume (0–15):
set-volume 12

# Set a smart alarm:
alarm set "07:30"
```

### 7.1 Dual-Tablet External PC Stereo Speaker Mode & CAVA Live Equalizer 🔊

Place two tablets on the left and right sides of your desk to turn them into a **hardware-synchronized, true stereo (left/right) external speaker system** for your computer!

```text
+-------------------------------------------------------------------------+
|                              HOST PC (Linux / Win)                      |
|                     PipeWire Master Audio -> Snapserver                 |
|                   Web Control Panel: http://localhost:1780             |
+-------------------+---------------------------------+-------------------+
                    |                                 |
         Left channel|                                 |Right channel
       (Wi-Fi / SSH) v                                 v (USB ADB / Wi-Fi)
+-----------------------+                         +-----------------------+
|  Samsung Tab 3 (LEFT) |                         |  Vestel Tab 7 (RIGHT) |
|   Dalvik AudioBridge  |                         |  Snapcast Android App |
|  CAVA Frequency Scan  |                         |  Hardware AudioTrack  |
+-----------------------+                         +-----------------------+
```

#### One-Click Startup and Management
```bash
# 1. Start stereo speaker mode (left: Samsung, right: Vestel):
my-tablet-server speakers
# or: stereo-speakers start

# 2. Launch the live Frutiger Aero music-frequency visualizer:
my-tablet-server cava
# or: stereo-speakers cava

# 3. View speaker status and connected tablets:
my-tablet-server speakers status

# 4. Stop the mode and release the tablets:
my-tablet-server speakers stop
```

#### Customization Guide

- **Buffer / latency:**  
  In `config/snapserver.conf`, change `buffer = 150` to:
  - *For movies and games:* `buffer = 50` (ultra-low latency of 50 milliseconds).
  - *For stable home Wi-Fi music streaming:* `buffer = 150` (default, designed to avoid dropouts).
- **Left/right balance and live audio mixer:**  
  Open `http://localhost:1780` in your browser. You can view each tablet separately, raise or lower its volume, or swap the channels.
- **Audio quality and codec:**  
  In `config/snapserver.conf`, choose `codec = flac` (lossless / original studio quality) or `codec = opus` for weaker networks.
- **CAVA visualizer theme:**  
  Edit `config/cava.conf` to customize the color gradients (`gradient_color`), number of bars, and wave behavior.
- **Firewall tip (UFW):**  
  The Samsung tablet is unaffected by the firewall because it uses an SSH tunnel. The PC may need to allow a port for the Vestel tablet to connect over Wi-Fi:
  `sudo ufw allow 1704/tcp && sudo ufw allow 1780/tcp`

---

## 8. Frutiger Aero Screensavers & Nostalgic Wallpapers

When idle, the tablet can turn into a nostalgic digital picture frame or aquarium:

```bash
# Start a screensaver:
screensaver start aquarium   # Live aquarium
screensaver start aero       # Frutiger Aero landscape
screensaver start fireplace  # Fireplace
screensaver start matrix     # Matrix code

# Stop the screensaver:
screensaver stop
```

Four high-resolution Frutiger Aero wallpapers have also been installed in `/sdcard/Screensavers/Wallpapers/`.

---

## 9. Nostalgic Retro Games & Security Isolation

Nostalgic games installed on the tablets:
- **Hill Climb Racing** (modded version with unlimited money)
- **Minecraft PE** (lightweight classic version)
- **Subway Surfers**
- **Angry Birds Classic & Angry Birds Go**
- **Flappy Bird**

> [!NOTE]
> **Security assurance:** None of the installed games or apps can access the Linux server layer. Thanks to Android's Linux-kernel-level user isolation (UID/GID sandboxing), they have no access to `/data/local/linux` and do not open any background ports.

---

## 10. Universal Tablet Debloater

Freeze unnecessary carrier, OEM, and obsolete services on any connected tablet (rooted or unrooted):

```bash
my-tablet-server debloat
# or directly:
debloat-tablet
```

This operation:
- Freezes more than 60 unnecessary apps, including Facebook, Turkcell, Türk Telekom, and Fitwell.
- Immediately saves **300 MB+ of RAM** on the tablet.
- Speeds up touch animations (`0.5x`).
- Disables the Wi-Fi sleep policy to prevent the connection from dropping.

---

## 11. Integration with AI Agents

This repository is designed to be easily managed by autonomous AI agents (such as Antigravity Agent, Nous Hermes, Claude, AutoGPT, etc.).

- Agent skill definition: `skills/tablet-server/SKILL.md`
- Agents can run `my-tablet-server` commands directly through the terminal.
- They can monitor live output by attaching to the tablet's tmux session:
```bash
console
# or
ssh my-tablet-server "console"
```

---

## 12. Frequently Asked Questions & Troubleshooting

**Q: My computer can't detect the tablet. What should I do?**  
A: Make sure **USB debugging** is enabled on the tablet. If necessary, unplug and reconnect the cable, then run `adb devices` in the terminal.

**Q: What happens if the Wi-Fi password changes?**  
A: When your computer connects to the new Wi-Fi network while the tablet is connected, the `sync-wifi` command automatically transfers the new password to the tablet and connects it to the same network.

**Q: Does SSH ask for a password?**  
A: During installation, your PC's SSH key is installed on the tablet, so you can connect without a password. If a password is required, the default is `hermes` or `root`.
