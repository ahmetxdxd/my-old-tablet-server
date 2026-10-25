# ⚡ My Tablet Server - One-Click Shortcuts

This folder contains double-clickable shortcuts to manage and trigger all tablet features **silently in the background without opening a terminal window**.

---

## 📁 Directory Structure

* **🐧 [`linux/`](linux)**: Contains all `.sh` shortcuts for Linux & macOS desktop environments (KDE Plasma, GNOME, XFCE, etc.).
* **🪟 [`windows/`](windows)**: Contains all `.bat` shortcuts for Windows (PowerShell hidden window style).

---

## 🖥️ How to Use

### 🐧 On Linux & macOS:
- Open [`shortcuts/linux/`](linux).
- Double-click any **`.sh`** file from your file manager (Dolphin, Nautilus, Thunar, etc.) or run it from terminal.
- The action will start **silently in the background** without cluttering your screen with terminal windows, and will display a native desktop notification (`notify-send`).

### 🪟 On Windows:
- Open [`shortcuts/windows/`](windows).
- Double-click any **`.bat`** file.
- The action runs invisibly in the background (`-WindowStyle Hidden`) without opening a persistent command prompt.

---

## 📂 Available Shortcuts

| File Name | Function |
| :--- | :--- |
| `01-second-screen-usb` | **Instantly turns tablet into PC second monitor via USB cable (no terminal window!)** |
| `02-second-screen-wifi` | Turns tablet into wireless second monitor over home Wi-Fi |
| `03-second-screen-stop` | Closes second monitor and restores tablet home launcher |
| `04-stereo-speakers-start` | Streams PC stereo audio to tablet speakers (Direct PipeWire PCM / Snapcast) |
| `05-stereo-speakers-stop` | Stops tablet stereo speaker stream |
| `06-cava-audio-visualizer` | Opens CAVA live audio frequency visualizer in a clean terminal window |
| `07-screensaver-frutiger-aero` | Starts glossy nostalgic Frutiger Aero dynamic art slideshow |
| `08-screensaver-aquarium` | Starts tropical coral reef live aquarium video loop |
| `09-screensaver-fireplace` | Starts cozy burning fireplace video loop |
| `10-screensaver-matrix` | Starts cyber green Matrix digital rain |
| `11-screensaver-stop` | Stops any active screensaver and returns to desktop |
| `12-anime-app` | Opens AnimeDLR ad-free anime streaming app |
| `13-lofi-radio` | Streams 24/7 chill lofi hip hop beats |
| `14-safe-debloat` | Safely freezes 60+ bloatware packages and recovers up to 70% RAM |
| `15-screen-light-on` | Turns on tablet LCD backlight |
| `16-screen-light-off` | Turns off tablet LCD backlight to save power |
| `17-mode-linux-server` | Switches to Pure Headless Linux Server Mode (Max RAM) |
| `18-mode-android-tablet` | Switches to Pure Android Tablet Mode |
| `19-mode-hybrid` | Switches to Hybrid Dual Mode |
| `20-tablet-menu` | **Opens the full interactive Quick Control Menu (tablet-menu)** |
| `21-tablet-terminal` | **Connects directly to live tablet Linux console (tablet-terminal)** |
| `22-auto-downloader` | Downloads and provisions media packages and Python wheels |
| `23-screensaver-dvd` | Starts classic bouncing DVD logo screensaver with color changes & corner hits |
