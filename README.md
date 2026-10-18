# My Tablet Server & Second Display 🚀

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Linux: Alpine ARMv7](https://img.shields.io/badge/Linux-Alpine%20ARMv7-2489ca.svg)](https://alpinelinux.org/)
[![Android: 4.4+ KitKat](https://img.shields.io/badge/Android-4.4%2B%20KitKat-green.svg)](https://source.android.com/)
[![Display: Wayland & X11](https://img.shields.io/badge/Display-Wayland%20%7C%20X11-purple.svg)](https://wayland.freedesktop.org/)
[![Arch: ARMv7 Dual/Quad](https://img.shields.io/badge/Arch-ARMv7%20Dual%2FQuad--Core-orange.svg)](https://arm.com)
[![Shell: Bash & PowerShell](https://img.shields.io/badge/Shell-Bash%20%7C%20PowerShell-4EAA25.svg)](https://github.com/)
[![AI-Agent: Skill Ready](https://img.shields.io/badge/AI--Agent-Skill%20Ready-ff69b4.svg)](skills/tablet-server/SKILL.md)

Transform any legacy Android tablet (e.g. **Samsung Galaxy Tab 3 7.0 / SM-T210**, **Vestel V Tab 7 Lite II**, or any KitKat/Lollipop ARMv7 device) into:
- ⚡ **A 24/7 Low-Power GNU/Linux Microserver** (~2W consumption, built-in battery UPS).
- 🖥️ **An Ultra-Low Latency PC Second Monitor** (KDE Plasma Wayland / KWin & X11, wired USB or wireless Wi-Fi).
- 📻 **Hardware-Synchronized PC Stereo Speakers & CAVA Visualizer** (Left/Right desktop audio split over Wi-Fi/USB with live audio spectrum).
- 🎌 **An Ad-Free Anime & Video Streaming Hub** (AnimeDLR with 10,000+ series, SkyTube ad-free YouTube, hardware VLC).
- 🌸 **An Aesthetic Frutiger Aero Desk Ornament** (Aquarium, cozy fireplace, cyber rain, and dynamic Frutiger Aero artwork with clock).
- 🤖 **An Autonomous AI-Agent Workstation** (Standardized `SKILL.md` for Google Antigravity & Nous Hermes agents).
- 🧹 **A Deeply Debloated Device** (Recovers >70% of 1 GB RAM safely via `pm block` without bootloops).

> 📖 **Comprehensive Manual:** For full A-Z architectural blueprints, detailed benchmarking notes, and debugging tips, see the [Comprehensive Guide (guide.md)](guide.md).

---

## 📑 Table of Contents
1. [Engineering Philosophy & The Traps We Solved](#-engineering-philosophy--the-traps-we-solved)
2. [Hardware Benchmark: Samsung vs. Vestel](#-hardware-benchmark-samsung-vs-vestel)
3. [System Architecture](#-system-architecture)
4. [Quick Start (One-Click Setup)](#-quick-start-one-click-setup)
5. [The 3 Operating Modes](#-the-3-operating-modes)
6. [PC Second Monitor (Second Screen)](#-pc-second-monitor-second-screen)
7. [Ad-Free Anime & Media Hub](#-ad-free-anime--media-hub)
8. [Aesthetic Frutiger Aero Screensavers](#-aesthetic-frutiger-aero-screensavers)
9. [Safe Debloater (63+ Bloatware Packages Blocked)](#-safe-debloater)
10. [Zero-Crackling Dalvik AudioBridge](#-zero-crackling-dalvik-audiobridge)
11. [Dual Tablet PC Stereo Speakers & CAVA Visualizer](#-dual-tablet-pc-stereo-speakers--cava-visualizer)
12. [Live Terminal Console (Screen Mirroring)](#-live-terminal-console)
13. [Security & Sandbox Guarantee](#-security--sandbox-guarantee)
14. [AI Agent Orchestration (SKILL.md)](#-ai-agent-orchestration)
15. [CLI Command Cheat-Sheet](#-cli-command-cheat-sheet)
16. [Troubleshooting & FAQ](#-troubleshooting--faq)
17. [Contributing & License](#-contributing--license)

---

## 🌟 Engineering Philosophy & The Traps We Solved

Most attempts to turn old Android devices into Linux servers fail because they try to kill Android services or treat the tablet like a Raspberry Pi. Here is why our architecture succeeds where others fail:

### 1. Don't Kill Android Drivers — Leverage Them!
* **The Framebuffer Trap:** On many legacy chips (e.g. Marvell `pxa168fb`), the display controller uses proprietary triple-buffering. Killing Android graphics (`surfaceflinger`/`zygote`) and driving `/dev/graphics/fb0` directly cuts the LVDS clock during blanks and permanently locks the LCD into a black screen.
* **The Raw ALSA Trap:** Integrated sound chips (e.g. Marvell `88pm805` / Allwinner AC100) require proprietary Android HAL calibration (`libacm.so` / `audio.primary.*.so`). Bypassing the Android framework and outputting directly to ALSA breaks PDM clock synchronization, producing intolerable distortion and buzzing.
* **Our Solution:** Keep Android's core driver stack (`surfaceflinger`, `mediaserver`, `wpa_supplicant`) alive. Linux routes sound through our lightweight Dalvik **AudioBridge** (`127.0.0.1:4711`) at native hardware speed with **zero crackling**.

### 2. The KitKat Watchdog Trap (~250 MB - 600 MB RAM Saved Safely)
* Disabling `systemui`, `providers.downloads`, `providers.media`, or `settings` in Android 4.4 triggers `system_server`'s Watchdog thread to initiate a kernel reboot every 60 seconds (bootloop).
* Our **Deep Debloat Engine** preserves those 4 mandatory framework anchors, while cleanly freezing 63+ non-essential OEM, carrier, and Google Play telemetry services via `pm block`, instantly freeing over **60% to 70% of available RAM**.

### 3. Thermal Runaway Mitigation
* Samsung Wi-Fi tablets run background factory cellular daemons (`atcmdsrv`, `simal`, `diag`, `nvm`) that enter infinite loops when no cellular baseband modem is present, pegging the CPU at 100% (1.2 GHz) and overheating the battery.
* Our boot hooks freeze these rogue daemons, scaling CPU frequencies down to **312 MHz idle**, keeping the tablet cool (~36°C) 24/7 without active fans.

---

## 🔬 Hardware Benchmark: Samsung vs. Vestel

We benchmarked two prevalent classes of budget legacy tablets to determine their ideal roles:

| Spec / Capability | Samsung Galaxy Tab 3 7.0 (`SM-T210`) | Vestel V Tab 7 Lite II (`A33`) | Verdict & Recommendation |
| :--- | :--- | :--- | :--- |
| **Recommended Role** | **🏆 24/7 Headless Linux Server** | **🖥️ PC Second Screen & Media Hub** | Samsung for reliable servers; Vestel for display. |
| **Processor (SoC)** | Marvell PXA986 (Dual-Core Cortex-A9 @ 1.2 GHz) | Allwinner A33 (Quad-Core Cortex-A7 @ 1.2 GHz) | Cortex-A9 has **Out-of-Order (OoO)** execution, giving 25% higher single-thread throughput for daemons. Allwinner's 4 cores excel at multi-threaded video decode. |
| **GPU / Acceleration** | Vivante GC1000 | Mali-400 MP2 (OpenGL ES 2.0) | Mali-400 delivers silky smooth 60 FPS VNC screen mirroring. |
| **Internal Storage** | **High-Endurance Samsung eMMC (121 MB/s)** | **Raw Consumer NAND Flash** | Samsung eMMC handles continuous database/log writes for years without wearout. |
| **RAM Utilization** | 1 GB (~650 MB Available after debloat) | 1 GB (~620 MB Available after debloat) | Both run smooth; Vestel boots cleanly with 63 bloatware packages blocked. |
| **Privileges** | **Full Root Access (`su`)** | Stock Firmware (Unrooted) | Samsung can bind privileged ports (Port 22 SSH) and manage chroots; Vestel uses userland VNC seamlessly. |
| **Display Panel** | 1024 x 600 7.0" TFT | 1024 x 600 7.0" Bright TFT | Both make crisp 16:9 secondary desktop monitors. |

---

## 📦 System Architecture

```
                       +---------------------------------------+
                       |       Host PC (Linux / Windows)       |
                       |  - Wayland / X11 Virtual Display      |
                       |  - Wi-Fi Auto-Sync Daemon             |
                       |  - SSH Client: ssh my-tablet-server   |
                       +-------------------+-------------------+
                                           | Wi-Fi (LAN) or USB Cable (ADB)
                                           v
+-----------------------------------------------------------------------------------+
|                            TABLET SUBSYSTEM ENVIRONMENT                           |
|                                                                                   |
|  +-------------------------------------+  +------------------------------------+  |
|  |     Alpine Linux ARMv7 (Chroot)     |  |       Android 4.4.2 Framework      |  |
|  |                                     |  |                                    |  |
|  |  * OpenSSH Server (Port 22 & 2222)  |  |  * SurfaceFlinger (Hardware Display)| |
|  |  * Shared Tmux ("console" session)  |  |  * MediaServer / AudioFlinger      |  |
|  |  * Python 3 / Node.js / Cron Daemons|  |  * bVNC Free (Second Monitor)      |  |
|  |  * mpv / ffmpeg / yt-dlp            |  |  * AnimeDLR (10,000+ Ad-Free Anime)|  |
|  |  * AI Agent Hooks (Antigravity/Nous)|  |  * SkyTube Extra & Hardware VLC   |  |
|  |  * Safe Debloat & Thermal Mitigation|  |  * Video Screensaver (Frutiger)    |  |
|  +------------------+------------------+  +------------------+-----------------+  |
|                     |                                        ^                    |
|                     +------> 127.0.0.1:4711 (Raw PCM) -------+                    |
|                              127.0.0.1:4712 (Audio Playback)                      |
+-----------------------------------------------------------------------------------+
```

---

## 🚀 Quick Start (One-Click Setup)

### Prerequisites
1. Any Android 4.4+ ARMv7 tablet.
2. Enable **Developer Options** -> **USB Debugging**.
3. Connect the tablet to your PC via USB.

### Installation

#### 🐧 On Linux & macOS:
```bash
git clone https://github.com/your-username/my-tablet-server.git
cd my-tablet-server
chmod +x install.sh
./install.sh
```

#### 🪟 On Windows:
Make sure ADB is installed (e.g. `winget install Google.PlatformTools`). Then run:
```powershell
cd my-tablet-server
powershell -ExecutionPolicy Bypass -File .\install.ps1
```
*(Or simply double-click `install.bat`)*

The installer automatically:
1. Detects your tablet model and verifies ADB/root connectivity.
2. Auto-syncs your PC's active Wi-Fi credentials to the tablet.
3. Deploys Alpine Linux ARMv7 rootfs with OpenSSH, Python 3, tmux, and audio tools.
4. Installs the zero-latency Dalvik AudioBridge and watchdog-safe debloat configs.
5. Deploys ad-free anime, video players, and Frutiger Aero screensavers.
6. Sets up persistent auto-boot on tablet restart (`/system/etc/install-recovery.sh`).

---

## ⚙️ The 3 Operating Modes

Switch effortlessly between tasks without rebooting:

```bash
# Check current status, active mode, screen brightness, and free RAM
my-tablet-server status
```

| Mode | Command | What Happens | Ideal Use Case |
| :--- | :--- | :--- | :--- |
| **[1] Pure Linux Server** | `my-tablet-server linux` | Screen turns OFF, Android UI launcher suspended. ~700 MB RAM dedicated to Linux daemons. | 24/7 background home server, Node/Python web apps, automation. |
| **[2] Pure Android Tablet** | `my-tablet-server android` | Screen turns ON, Android launcher activated. Linux daemons sleep. | Retro gaming, touchscreen apps, YouTube, offline reading. |
| **[3] Hybrid Dual Mode** | `my-tablet-server hybrid` | Android UI stays visible on screen with widgets/clock while background Linux daemons (**Hermes AI, Cron, SSH**) run concurrently! | Smart desk clock, AI companion, active monitoring dashboard. |

---

## 🖥️ PC Second Monitor (Second Screen)

Turn your tablet into a low-latency secondary display for Linux (KDE Plasma Wayland / KWin & X11):

```bash
# Launch wired over USB cable (lowest latency, zero network jitter)
second-screen usb

# Launch wireless over home Wi-Fi (portable desk placement)
second-screen wifi

# Position secondary screen: right (default), left, above, below, or mirror
second-screen usb right
second-screen wifi left

# Turn off second screen and restore normal tablet launcher
second-screen stop
```

**Key Features:**
- **Automatic Resolution Matching:** Creates a virtual 1024x600 display matching the tablet's physical panel.
- **Hardware Acceleration:** Uses `bVNC` on Android with RFB tight-encoding for snappy mouse tracking.
- **Wi-Fi Auto-Sync:** Before connecting, pairs the tablet to the PC's current Wi-Fi network automatically.

---

## 🎌 Ad-Free Anime & Media Hub

Enjoy seamless media streaming without popups, banners, or ads:

```bash
# Launch AnimeDLR (10,000+ series from AnimePahe, 9Anime, AnimeDao with built-in hardware player)
anime app

# Open ad-free Miruro modern web player in lightweight browser
anime miruro

# Play anime or video directly via hardware-accelerated VLC
anime play "Attack on Titan"
watch "https://stream-url.mp4"

# Stop media playback
anime stop
```

Also includes:
- **SkyTube Extra:** Open-source YouTube player with sponsorblock and zero video ads.
- **VLC for Android:** Plays all local and streamed video formats.
- **Internet Radio:** `radio lofi`, `radio jazz`, `radio classic`, `radio rock`.

---

## 🌸 Aesthetic Frutiger Aero Screensavers

Transform your tablet into an ambient retro-futuristic desk ornament:

```bash
# Frutiger Aero dynamic slideshow (glass spheres, green rolling hills, cyan aurora, eco-utopia)
screensaver art

# Tropical coral reef aquarium loop with Nemo & tropical fish
screensaver aquarium

# Cozy glowing crackling fireplace loop
screensaver fireplace

# Cyber Matrix digital rain
screensaver matrix

# Toggle 24-hour live clock overlay
screensaver clock on
screensaver clock off

# Interactive theme picker menu (Alias: sus)
sus
```

---

## 🧹 Safe Debloater

Clean out carrier and OEM junk without breaking Android 4.4 framework dependencies:

```bash
debloat-tablet
# or
my-tablet-server debloat
```

- **63+ Bloatware Packages Frozen:** Removes Facebook, carrier bloat (Turkcell, Vodafone, Avea), dead Google services (Google+, Hangouts, Play Music/Movies/Newsstand), and vendor diagnostic tools.
- **Safety First:** Preserves critical Android Watchdog dependencies to prevent 60-second reboot loops.
- **Results:** Recovers **~620 MB usable RAM** (>70% of total memory available).

---

## 🔊 Zero-Crackling Dalvik AudioBridge

Linux applications communicate with Android's audio system through a local loopback bridge:

```bash
# Play audio file through tablet speakers
play-sound /path/to/music.mp3

# Adjust volume (0 - 100%)
set-volume 85

# Stream YouTube audio directly
yt "Daft Punk Random Access Memories"

# Morning wake-up alarm
alarm play
alarm stop
```

---

## 📻 Dual Tablet PC Stereo Speakers & CAVA Visualizer

Transform two tablets placed on the left and right sides of your desk into **hardware-synchronized, true stereo external PC speakers** with a live Frutiger Aero frequency spectrum visualizer!

```
+-------------------------------------------------------------------------+
|                              HOST PC (Linux / Windows)                  |
|                     PipeWire Master Audio -> Snapserver                 |
|                   Web Control Dashboard: http://localhost:1780          |
+-------------------+---------------------------------+-------------------+
                    |                                 |
         Left Channel |                               | Right Channel
      (Wi-Fi / SSH) v                                 v (USB ADB / Wi-Fi)
+-----------------------+                         +-----------------------+
|  Samsung Tab 3 (LEFT) |                         |  Vestel Tab 7 (RIGHT) |
|   Dalvik AudioBridge  |                         |  Snapcast Android App |
|  CAVA Spectrum Display|                         |  Hardware AudioTrack  |
+-----------------------+                         +-----------------------+
```

### Commands:
```bash
# 1. Start stereo speakers mode (Left: Samsung, Right: Vestel):
my-tablet-server speakers
# or: stereo-speakers start

# 2. Launch CAVA live Frutiger Aero audio spectrum visualizer:
my-tablet-server cava
# or: stereo-speakers cava

# 3. View status, connected tablets, and active stream:
my-tablet-server speakers status

# 4. Stop speakers and release tablets:
my-tablet-server speakers stop
```

### Configuration & Fine-Tuning:
* **Latency & Buffering:** Edit [`config/snapserver.conf`](config/snapserver.conf):
  - For movies & gaming: `buffer = 50` (50ms low latency).
  - For stable Wi-Fi streaming: `buffer = 150` (Default, zero dropouts).
* **Live Volume & Channel Mixer:** Open `http://localhost:1780` in your web browser to independently control Left/Right volume, mute, or swap channels.
* **Audio Codec:** Choose `codec = flac` (Lossless studio quality) or `codec = opus` (Ultra lightweight for congested Wi-Fi).
* **CAVA Visualizer Theme:** Customize gradient colors, bar count, and physics in [`config/cava.conf`](config/cava.conf).
* **Firewall Note (UFW):** Samsung uses an SSH tunnel to bypass firewalls automatically. For direct Wi-Fi streaming on Vestel:
  `sudo ufw allow 1704/tcp && sudo ufw allow 1780/tcp`

---

## 💻 Live Terminal Console

The tablet's screen can mirror your PC terminal in real-time using a shared Tmux session:

```bash
console
# or
tmux attach -t console
```
Anything typed on your PC displays immediately on the tablet LCD, and vice-versa. Perfect for monitoring system resources, logs, and compiling code.

---

## 🤖 AI Agent Orchestration

This project includes a standardized skill file for autonomous AI coding agents:
- Path: [`skills/tablet-server/SKILL.md`](skills/tablet-server/SKILL.md)
- Compatible with: **Google Antigravity**, **Nous Hermes**, **AutoGPT**, **Claude Code**.

AI agents can automatically:
- Discover connected tablets and query system metrics (`my-tablet-server status`).
- Toggle between server, android, and hybrid modes.
- Trigger secondary screen mirroring for pair-programming.
- Set alarms, stream audio, and schedule cron routines.

---

## 📋 CLI Command Cheat-Sheet

| Command | Action |
| :--- | :--- |
| `my-tablet-server status` | Show CPU temp, frequency, RAM, battery %, and IP |
| `my-tablet-server linux` | Switch to Pure Linux Server Mode |
| `my-tablet-server android` | Switch to Pure Android Tablet Mode |
| `my-tablet-server hybrid` | Switch to Hybrid Dual Mode |
| `second-screen usb [pos]` | Turn tablet into PC second monitor via USB cable |
| `second-screen wifi [pos]` | Turn tablet into PC second monitor via Wi-Fi |
| `second-screen stop` | Detach second monitor and restore tablet |
| `my-tablet-server speakers` | Dual Tablet PC Stereo Speakers (Left: Samsung, Right: Vestel) |
| `my-tablet-server cava` | Launch Frutiger Aero live audio frequency visualizer |
| `anime app` | Open AnimeDLR ad-free anime streaming app |
| `anime miruro` | Open Miruro streaming web interface |
| `anime play "<query>"` | Stream video directly with hardware acceleration |
| `screensaver <theme>` | Start screensaver (`art`, `aquarium`, `fireplace`, `matrix`) |
| `screensaver stop` | Stop screensaver |
| `debloat-tablet` | Safely freeze 63+ bloatware packages |
| `screen on / off` | Turn LCD backlight on or off |
| `play-sound <file>` | Play audio via Dalvik AudioBridge |
| `set-volume <0-100>` | Change media speaker volume |
| `alarm play / stop` | Morning wake-up alarm chime |
| `radio <lofi/jazz/url>` | Play live internet radio stream |
| `console` | Mirror PC terminal to tablet screen in real-time |

---

## ❓ Troubleshooting & FAQ

### Q: `PTY allocation request failed on channel 0` when connecting via SSH
**Fix:** Run `mount -t devpts devpts /dev/pts` inside the chroot or run `./install.sh` to update mount configurations.

### Q: `INSTALL_FAILED_INVALID_URI` when installing APKs via ADB
**Fix:** On Android 4.4, APKs must reside in `/data/local/tmp/` with `chmod 777` permissions before calling `pm install`.

### Q: ADB sees my smartphone instead of the tablet
**Fix:** All scripts (`second-screen`, `sync-wifi`, `debloat-tablet`) automatically filter out smartphone prefixes (`SM-G`, `SM-S`, `SM-A`, `iPhone`) to protect your personal phone.

### Q: How do I change the default SSH password?
**Fix:** Log in via SSH and run `passwd root`. Enter your new password.

---
