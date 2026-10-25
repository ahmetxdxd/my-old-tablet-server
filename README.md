# My Old Tablet Server 🚀

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Linux: Alpine ARMv7](https://img.shields.io/badge/Linux-Alpine%20ARMv7-2489ca.svg)](https://alpinelinux.org/)
[![Android: 4.4+ KitKat](https://img.shields.io/badge/Android-4.4%2B-green.svg)](https://source.android.com/)
[![Display: Wayland & X11](https://img.shields.io/badge/Display-Wayland%20%7C%20X11-purple.svg)](https://wayland.freedesktop.org/)
[![Shell: Bash & PowerShell](https://img.shields.io/badge/Shell-Bash%20%7C%20PowerShell-4EAA25.svg)](https://github.com/)
[![AI-Agent: Skill Ready](https://img.shields.io/badge/AI--Agent-Skill%20Ready-ff69b4.svg)](skills/tablet-server/SKILL.md)

Transform any legacy Android tablet (Android 4.4+ ARMv7) into:
- ⚡ **A 24/7 Low-Power Linux Microserver** (~2W consumption with built-in battery UPS).
- 🖥️ **An Ultra-Low Latency PC Second Monitor** (Linux Wayland / KWin & X11 via USB or Wi-Fi).
- 📻 **Hardware-Synchronized PC Stereo Speakers & CAVA Visualizer** (Left/Right desktop audio split over Wi-Fi/USB with live audio spectrum).
- 🎌 **An Ad-Free Media Hub** (Anime streaming, ad-free YouTube, and hardware-accelerated VLC).
- 🌸 **An Aesthetic Desk Display** (Frutiger Aero artwork, live aquarium, fireplace, matrix rain, and desk clock).
- 🤖 **An Autonomous AI-Agent Workstation** (Pre-built `SKILL.md` for AI coding assistants).
- 🧹 **A Deeply Debloated Device** (Recovers up to 70% of available RAM safely without bootloops).

> 📖 **Detailed Technical Blueprint:** For in-depth low-level architecture notes and troubleshooting, see [guide.md](guide.md).

---

## 📱 Tested Devices

Tested and confirmed working out-of-the-box on:
* **Samsung Galaxy Tab 3 7.0 (`SM-T210`)** — Dual-core ARMv7, 1 GB RAM (Rooted)
* **Vestel V Tab 7 Lite II** — Allwinner Quad-core ARMv7, 1 GB RAM (Stock / Non-rooted)

*Compatible with virtually any ARMv7 Android tablet running Android 4.4 (KitKat) through Android 7.x (Nougat).*

---

## 📦 System Architecture

```
                       +---------------------------------------+
                       |       Host PC (Linux / Windows)       |
                       |  - Wayland / X11 Virtual Display      |
                       |  - Snapserver & CAVA Spectrum Audio   |
                       |  - Auto-Sync Wi-Fi & SSH Management   |
                       +-------------------+-------------------+
                                           | Wi-Fi (LAN) or USB Cable (ADB)
                                           v
+-----------------------------------------------------------------------------------+
|                            TABLET SUBSYSTEM ENVIRONMENT                           |
|                                                                                   |
|  +-------------------------------------+  +------------------------------------+  |
|  |     Alpine Linux ARMv7 (Chroot)     |  |       Android Driver Stack         |  |
|  |                                     |  |                                    |  |
|  |  * OpenSSH Server (Port 22 & 2222)  |  |  * SurfaceFlinger (Hardware Display)| |
|  |  * Shared Tmux ("console" session)  |  |  * MediaServer / AudioFlinger      |  |
|  |  * Python 3 / Cron / Daemons        |  |  * bVNC (Second Monitor Client)    |  |
|  |  * mpv / ffmpeg / yt-dlp            |  |  * Snapclient (Sync Audio Output)  |  |
|  |  * AI Agent Skills Hook             |  |  * Video Screensaver (Frutiger)    |  |
|  |  * Thermal & Low-Power Management   |  |  * Hardware Video Decoder (VLC)    |  |
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
2. Enable **Developer Options** -> **USB Debugging** on the tablet.
3. Connect the tablet to your PC via USB.

### Installation

#### 🐧 On Linux & macOS:
```bash
git clone https://github.com/ahmetxdxd/my-old-tablet-server.git
cd my-old-tablet-server
chmod +x install.sh
./install.sh
```

#### 🪟 On Windows:
Make sure ADB is installed (e.g. `winget install Google.PlatformTools`). Then run:
```powershell
cd my-old-tablet-server
powershell -ExecutionPolicy Bypass -File .\install.ps1
```
*(Or simply double-click `install.bat`)*

The installer automatically:
1. Detects your tablet model and checks root/ADB access.
2. Auto-syncs your PC's active Wi-Fi credentials to the tablet.
3. Deploys an Alpine Linux ARMv7 environment with OpenSSH, Python 3, and audio tools.
4. Installs the zero-latency Dalvik AudioBridge and safe debloat configs.
5. Deploys media tools and screensavers.
6. Sets up auto-boot on tablet restart (`/system/etc/install-recovery.sh`).

---

## 🎮 Quick Access & PC Remote Control (No SSH Hassle)

You don't need to struggle with complex SSH commands, IP addresses, ports, or credentials! You can control your tablet directly from your PC terminal without ever entering the tablet:

### ⚡ 1. Fast Tablet Terminal (One-Click / One-Command)
Instantly jump into the tablet's live Linux console without remembering SSH flags:

```bash
# On Linux & macOS:
tablet-terminal
# (or: tablet terminal)
```

```cmd
:: On Windows:
:: Simply double-click 'shortcuts\windows\21-tablet-terminal.bat' or run:
.\shortcuts\windows\21-tablet-terminal.bat
```
* **Auto-Discovery:** Automatically detects connected USB cable (port forward 2222) or Wi-Fi LAN IP.
* **Failsafe:** Seamlessly falls back to direct ADB chroot console if SSH server is temporarily offline.

### 🎛️ 2. Interactive Quick Menu (Run README Commands Without Entering Tablet)
Run any project feature from an interactive, numbered terminal dashboard:

```bash
# On Linux & macOS:
tablet-menu
# (or simply: tablet)
```

```cmd
:: On Windows:
:: Simply double-click 'shortcuts\windows\20-tablet-menu.bat' or run:
.\shortcuts\windows\20-tablet-menu.bat
```
* **One-Click Execution:** Second monitor, stereo speakers, screensavers (Frutiger Aero, Aquarium, Fireplace), debloater, modes, and media tools without touching tablet screen.

### ⌨️ 3. Direct PC Remote Command Runner
Execute any tablet command directly from your PC terminal in a single line:

```bash
# Check tablet metrics, temperatures, battery & RAM
tablet status

# Launch ambient screensavers
tablet screensaver art
tablet screensaver aquarium

# Second display & speakers
tablet second-screen usb
tablet stereo-speakers start

# Media & maintenance
tablet anime app
tablet debloat
tablet screen off        # Turn off LCD backlight for power saving
tablet <any-command>     # Executes directly inside tablet Linux
```
### 🖱️ 4. One-Click Desktop Shortcuts (Zero Terminal Window)
To trigger actions without opening or seeing any terminal window, use the **[`shortcuts/`](shortcuts)** folder:

* **🐧 On Linux & macOS:** Double-click any `.desktop` or `.sh` file inside the [`shortcuts/linux/`](shortcuts/linux) folder. No terminal window will appear; the task starts silently in the background and pops up a desktop notification (`notify-send`) (e.g. `01-second-screen-usb.desktop`).
* **🪟 On Windows:** Double-click any `.bat` file in [`shortcuts/windows/`](shortcuts/windows). It runs silently in the background without opening a command prompt window (`-WindowStyle Hidden`).

| Shortcut | Action on Double-Click |
| :--- | :--- |
| `01-second-screen-usb` | **Instantly turns tablet into PC second monitor via USB (no terminal window!)** |
| `02-second-screen-wifi` | Turns tablet into wireless second monitor over home Wi-Fi |
| `03-second-screen-stop` | Closes second monitor and restores tablet home launcher |
| `04-stereo-speakers-start` | Streams PC stereo audio (Left & Right channel split) to tablet speakers |
| `05-stereo-speakers-stop` | Stops tablet stereo speaker stream |
| `06-cava-audio-visualizer` | Opens live CAVA audio frequency spectrum in a clean terminal |
| `07-screensaver-frutiger-aero` | Starts glossy nostalgic Frutiger Aero dynamic art slideshow |
| `08-screensaver-aquarium` | Starts tropical coral reef live aquarium video loop |
| `09-screensaver-fireplace` | Starts cozy burning fireplace video loop |
| `10-screensaver-matrix` | Starts cyber green Matrix digital rain |
| `23-screensaver-dvd` | Starts classic bouncing DVD logo screensaver (with color changes & corner hits) |
| `12-anime-app` | Opens AnimeDLR ad-free anime streaming app |
| `13-lofi-radio` | Streams 24/7 chill lofi hip hop beats |
| `14-safe-debloat` | Safely freezes 60+ bloatware packages and recovers up to 70% RAM |
| `15-screen-light-on` / `16-off` | Turns tablet LCD backlight on or off |
| `20-tablet-menu` | **Opens the full interactive Quick Control Menu (tablet-menu)** |
| `21-tablet-terminal` | **Connects directly to live tablet Linux console (tablet-terminal)** |

---

## ⚙️ Operating Modes

Switch between use cases on the fly without rebooting:

```bash
# Check status, temperatures, battery and active mode
my-tablet-server status
```

| Mode | Command | Description |
| :--- | :--- | :--- |
| **[1] Pure Linux Server** | `my-tablet-server linux` | Screen turns OFF, Android UI launcher suspended. Maximum RAM dedicated to Linux background services. |
| **[2] Pure Android Tablet** | `my-tablet-server android` | Screen turns ON, Android launcher restored. Linux daemons sleep. |
| **[3] Hybrid Dual Mode** | `my-tablet-server hybrid` | Android UI stays visible on screen with clock/widgets while background Linux services run concurrently. |

---

## 🖥️ PC Second Monitor (Second Screen)

Turn your tablet into a low-latency secondary display for Linux (KDE Plasma Wayland / KWin & X11):

```bash
# Launch wired over USB (lowest latency, zero network jitter)
second-screen usb

# Launch wireless over home Wi-Fi (portable desk placement)
second-screen wifi

# Position secondary screen: right (default), left, above, below, or mirror
second-screen usb right
second-screen wifi left

# Turn off second screen and restore normal tablet launcher
second-screen stop
```

---

## 📻 Dual Tablet PC Stereo Speakers & CAVA Visualizer

Transform two tablets placed on the left and right sides of your desk into **hardware-synchronized stereo external PC speakers** with a live frequency spectrum visualizer!

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
|    Tablet 1 (LEFT)    |                         |    Tablet 2 (RIGHT)   |
|   Dalvik AudioBridge  |                         |  Snapcast Android App |
|  CAVA Spectrum Display|                         |  Hardware AudioTrack  |
+-----------------------+                         +-----------------------+
```

### Commands:
```bash
# 1. Start stereo speakers mode (Left & Right channel split):
stereo-speakers start

# 2. Launch CAVA live audio spectrum visualizer:
stereo-speakers cava

# 3. View status and active audio streams:
stereo-speakers status

# 4. Stop speakers and release tablets:
stereo-speakers stop
```

* **Live Mixer:** Open `http://localhost:1780` in your PC browser to adjust Left/Right volume, latency, or swap channels.
* **Low Latency:** Adjust buffer in [`config/snapserver.conf`](config/snapserver.conf) (50ms for gaming/movies, 150ms for stable Wi-Fi).

---

## 🎌 Ad-Free Media Hub

Stream video and music without popups, banners, or ads:

```bash
# Launch AnimeDLR (ad-free anime streaming with built-in hardware player)
anime app

# Open ad-free web player in lightweight browser
anime miruro

# Play video stream directly via hardware-accelerated VLC
watch "https://stream-url.mp4"

# Internet Radio streams
radio lofi
radio jazz
radio classic
```

---

## 🌸 Aesthetic Screensavers & Desk Display

Transform your tablet into an ambient retro-futuristic desk display:

```bash
# Frutiger Aero dynamic art slideshow
screensaver art

# Tropical coral reef aquarium loop
screensaver aquarium

# Cozy glowing fireplace loop
screensaver fireplace

# Cyber Matrix digital rain
screensaver matrix

# Interactive theme menu
sus
```

---

## 🧹 Safe Debloater

Clean out carrier and OEM junk without breaking Android 4.4 framework dependencies:

```bash
debloat-tablet
```

- **60+ Bloatware Packages Frozen:** Freezes carrier bloat, discontinued services, and OEM telemetry via `pm block`.
- **Anti-Bootloop Protection:** Preserves critical Android Watchdog dependencies (`systemui`, `providers.media`, `settings`, `providers.downloads`).
- **Results:** Recovers over **60% to 70% of available RAM**.

---

## 🤖 AI Agent Integration

This project includes a standardized skill definition for autonomous AI coding agents:
- File: [`skills/tablet-server/SKILL.md`](skills/tablet-server/SKILL.md)
- Compatible with: **Google Antigravity**, **Claude Code**, **Cursor**, **OpenDevin**, and custom LLM tool-calling agents.

AI agents can directly:
- Discover connected tablets and query system metrics (`my-tablet-server status`).
- Toggle between server, android, and hybrid modes.
- Activate secondary screen mirroring or stereo speakers.
- Schedule background automations and cron jobs.

---

## 📋 CLI Command Cheat-Sheet

| Command | Action |
| :--- | :--- |
| `tablet-terminal` | Instant live tablet terminal access from PC (No SSH flags needed) |
| `tablet-menu` | Interactive Quick Control Menu (run commands without entering tablet) |
| `tablet <command>` | Run any tablet command directly from PC terminal (e.g. `tablet status`) |
| `my-tablet-server status` | Show CPU temp, frequency, RAM, battery %, and IP |
| `my-tablet-server linux` | Switch to Pure Linux Server Mode |
| `my-tablet-server android` | Switch to Pure Android Tablet Mode |
| `my-tablet-server hybrid` | Switch to Hybrid Dual Mode |
| `second-screen usb [pos]` | Turn tablet into PC second monitor via USB |
| `second-screen wifi [pos]` | Turn tablet into PC second monitor via Wi-Fi |
| `second-screen stop` | Detach second monitor and restore tablet |
| `stereo-speakers start` | Dual Tablet PC Stereo Speakers (Left & Right) |
| `stereo-speakers cava` | Launch live audio frequency spectrum visualizer |
| `stereo-speakers stop` | Stop stereo audio streaming |
| `anime app` | Open AnimeDLR ad-free anime app |
| `screensaver <theme>` | Start screensaver (`art`, `aquarium`, `fireplace`, `matrix`, `dvd`) |
| `screensaver stop` | Stop screensaver |
| `debloat-tablet` | Safely freeze 60+ bloatware packages |
| `screen on / off` | Turn LCD backlight on or off |
| `play-sound <file>` | Play audio file through tablet speakers |
| `set-volume <0-100>` | Change media speaker volume |
| `alarm play / stop` | Morning wake-up alarm chime |
| `radio <lofi/jazz/url>` | Play live internet radio stream |
| `console` | Mirror PC terminal to tablet screen in real-time |

---

## ❓ Troubleshooting

### Q: `PTY allocation request failed on channel 0` when connecting via SSH
**Fix:** Run `mount -t devpts devpts /dev/pts` inside the chroot or run `./install.sh` to update mount configurations.

### Q: `INSTALL_FAILED_INVALID_URI` when installing APKs via ADB
**Fix:** On older Android versions, APKs must reside in `/data/local/tmp/` with `chmod 777` permissions before calling `pm install`.

### Q: ADB sees my smartphone instead of the tablet
**Fix:** The scripts automatically filter out phone model prefixes to protect your primary device.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
