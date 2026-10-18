<#
==============================================================================
MY TABLET SERVER - Windows Application & Suite Auto-Downloader
==============================================================================
Installs pre-configured and hardware-optimized packages on top of the minimal
Alpine Linux server on Android 4.4 KitKat from Windows via ADB.
==============================================================================
#>

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir

function Write-Color([string]$text, [ConsoleColor]$color) {
    $orig = [Console]::ForegroundColor
    [Console]::ForegroundColor = $color
    Write-Host $text
    [Console]::ForegroundColor = $orig
}

function Run-Chroot([string]$cmd) {
    adb shell "su -c '/data/local/linux/lib/ld-musl-armhf.so.1 /data/local/linux/bin/busybox chroot /data/local/linux /bin/sh -c \""export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin; $cmd\""'"
}

function Install-Apk([string]$url, [string]$localPath) {
    $apkName = Split-Path -Leaf $localPath
    if (-not (Test-Path $localPath)) {
        Write-Color "[INFO] Downloading $apkName..." Blue
        $dir = Split-Path -Parent $localPath
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
        Invoke-WebRequest -Uri $url -OutFile $localPath
    }
    Write-Color "[INFO] Installing $apkName via ADB..." Blue
    adb install -r $localPath 2>$null | Out-Null
}

function Install-AudioSuite {
    Write-Color "`n--> [1/4] Installing Audio & YouTube Player Suite..." Yellow
    Write-Color "[INFO] Installing mpv, ffmpeg, alsa-utils, quickjs, snapcast-client in Linux..." Blue
    Run-Chroot "apk add --no-cache mpv ffmpeg alsa-utils quickjs snapcast-client 2>/dev/null || true"

    Write-Color "[INFO] Installing and optimizing yt-dlp..." Blue
    Run-Chroot "pip3 install --break-system-packages --upgrade yt-dlp 2>/dev/null || apk add --no-cache yt-dlp || true"

    Write-Color "[INFO] Deploying Dalvik AudioBridge server..." Blue
    adb push "$RootDir\packages\audio_bridge.jar" /sdcard/audio_bridge.jar > $null 2>&1
    adb shell "su -c 'cp /sdcard/audio_bridge.jar /data/local/audio_bridge.jar && cp /sdcard/audio_bridge.jar /data/local/linux/audio_bridge.jar && rm -f /sdcard/audio_bridge.jar'" 2>$null

    adb push "$RootDir\bin\yt" /sdcard/yt > $null 2>&1
    adb push "$RootDir\bin\radio" /sdcard/radio > $null 2>&1
    adb push "$RootDir\bin\play-sound" /sdcard/play-sound > $null 2>&1
    adb shell "su -c 'cp /sdcard/yt /sdcard/radio /sdcard/play-sound /data/local/linux/usr/local/bin/ && chmod 755 /data/local/linux/usr/local/bin/* && rm -f /sdcard/yt /sdcard/radio /sdcard/play-sound'" 2>$null

    Write-Color "✓ Audio & YouTube suite successfully installed!" Green
}

function Install-VideoSuite {
    Write-Color "`n--> [2/4] Installing Video Streaming Bridge (VLC & watch CLI)..." Yellow
    $vlcUrl = "https://archive.videolan.org/vlc-android/2.0.6/VLC-Android-2.0.6-ARMv7.apk"
    $vlcApk = Join-Path $RootDir "packages\browsers\vlc.apk"
    Install-Apk $vlcUrl $vlcApk

    Write-Color "[INFO] Deploying 'watch' CLI script..." Blue
    adb push "$RootDir\bin\watch" /sdcard/watch > $null 2>&1
    adb shell "su -c 'cp /sdcard/watch /data/local/linux/usr/local/bin/watch && chmod 755 /data/local/linux/usr/local/bin/watch && rm -f /sdcard/watch'" 2>$null
    adb shell "su -c 'mount -o bind /system /data/local/linux/system 2>/dev/null || true'"

    Write-Color "✓ Video streaming bridge and VLC hardware player installed!" Green
}

function Install-Browsers {
    Write-Color "`n--> [3/4] Installing Lightweight Web Browsers, Anime & YouTube (Lightning, AnimeDLR, SkyTube Extra)..." Yellow
    $lightningUrl = "https://f-droid.org/archive/acr.browser.lightning_90.apk"
    $lightningApk = Join-Path $RootDir "packages\browsers\lightning.apk"
    $skytubeUrl = "https://github.com/SkyTubeTeam/SkyTube/releases/download/v2.999/SkyTube-Extra-2.999.apk"
    $skytubeApk = Join-Path $RootDir "packages\browsers\skytube.apk"
    $animedlrUrl = "https://github.com/cylonu87/AnimeDLR/releases/download/145/AnimeDLR-7.0.0-full-release.apk"
    $animedlrApk = Join-Path $RootDir "packages\browsers\animedlr.apk"

    Install-Apk $lightningUrl $lightningApk
    Install-Apk $skytubeUrl $skytubeApk
    Install-Apk $animedlrUrl $animedlrApk

    Write-Color "✓ Lightning Browser, AnimeDLR & SkyTube Extra YouTube installed!" Green
}

function Install-AiAgents {
    Write-Color "`n--> [4/4] Installing AI Agents (Nous Hermes & Google Antigravity CLI)..." Yellow
    Write-Color "[INFO] Installing build dependencies in Linux..." Blue
    Run-Chroot "apk add --no-cache build-base python3-dev libffi-dev py3-cffi py3-cryptography 2>/dev/null || true"

    $wheelsDir = Join-Path $RootDir "packages\wheels"
    if (Test-Path $wheelsDir) {
        adb push "$wheelsDir\." /data/local/tmp/packages/wheels/ > $null 2>&1
        Run-Chroot "pip3 install --break-system-packages /data/local/tmp/packages/wheels/*.whl 2>/dev/null || true"
    }

    Write-Color "[INFO] Installing Nous Hermes Agent..." Blue
    Run-Chroot "pip3 install --break-system-packages hermes-agent 2>/dev/null || true"

    Write-Color "[INFO] Deploying Antigravity CLI smart bridge ('agy' and 'antigravity')..." Blue
    adb push "$RootDir\bin\agy" /sdcard/agy > $null 2>&1
    adb shell "su -c 'cp /sdcard/agy /data/local/linux/usr/local/bin/agy && /data/local/linux/lib/ld-musl-armhf.so.1 /data/local/linux/bin/busybox ln -sf agy /data/local/linux/usr/local/bin/antigravity && chmod 755 /data/local/linux/usr/local/bin/agy && rm -f /sdcard/agy'" 2>$null

    Write-Color "✓ AI Agents (Hermes + Antigravity CLI) installed!" Green
}

function Install-Cctv {
    Write-Color "`n--> [5/6] Installing CCTV Security Camera System (V4L2 H.264 Encoder)..." Yellow
    Write-Color "[INFO] Ensuring ffmpeg is installed in Linux..." Blue
    Run-Chroot "apk add --no-cache ffmpeg 2>/dev/null || true"

    Write-Color "[INFO] Deploying 'cctv' and 'security-camera' CLI tools..." Blue
    adb push "$RootDir\bin\cctv" /sdcard/cctv > $null 2>&1
    adb shell "su -c 'cp /sdcard/cctv /data/local/linux/usr/local/bin/cctv && /data/local/linux/lib/ld-musl-armhf.so.1 /data/local/linux/bin/busybox ln -sf /usr/local/bin/cctv /data/local/linux/usr/local/bin/security-camera && chmod 755 /data/local/linux/usr/local/bin/cctv && rm -f /sdcard/cctv'" 2>$null

    Write-Color "✓ CCTV Security Camera tool ('cctv' / 'security-camera') successfully installed!" Green
}

function Install-RetroStore {
    Write-Color "`n--> [6/6] Setting up Retro & Nostalgia Classic Games Store..." Yellow
    Write-Color "[INFO] Deploying 'retro-store' CLI script to tablet..." Blue
    adb push "$RootDir\bin\retro-store" /sdcard/retro-store > $null 2>&1
    adb shell "su -c 'cp /sdcard/retro-store /data/local/linux/usr/local/bin/retro-store && chmod 755 /data/local/linux/usr/local/bin/retro-store && rm -f /sdcard/retro-store'" 2>$null

    Write-Color "✓ Retro Games Store script ('retro-store') ready!" Green
    Write-Color "You can install classic games (Flappy Bird, Angry Birds, GBA/SNES) anytime by running: retro-store" Yellow
}

function Show-Menu {
    Clear-Host
    Write-Color @"
======================================================================
         MY TABLET SERVER - APPLICATION AUTO-DOWNLOADER (Windows)     
======================================================================
Running from Windows Host: ADB Remote Mode

Choose an option to install pre-configured and optimized packages:

  1) Install FULL Suite (Recommended)
     -> Audio/YT + VLC + Browsers + CCTV Camera + Retro Games + AI Suite

  2) Audio & YouTube Player Suite (yt, radio, dalvik audio bridge, quickjs)
  3) Video Streaming Bridge ('watch' CLI + VLC Hardware Player)
  4) Lightweight Web Browsers (Lightning Browser & SkyTube Extra YouTube)
  5) CCTV Security Camera System ('cctv' / 'security-camera' recording)
  6) Retro Games & Nostalgia Store ('retro-store' classic game installer)
  7) AI Agents (Nous Hermes Agent + Google Antigravity CLI)

  0) Exit / Keep Pure Minimal Server (No extra packages)
======================================================================
"@ Cyan
}

# Main entry
$devices = adb devices | Select-String -Pattern "device$"
if (-not $devices) {
    Write-Color "[ERROR] No ADB device detected! Connect tablet via USB." Red
    exit 1
}

$choice = $args[0]
if (-not $choice) {
    Show-Menu
    $choice = Read-Host "Enter choice [0-7, default: 1]"
    if (-not $choice) { $choice = "1" }
}

switch ($choice) {
    "1" {
        Write-Color "`nStarting Full Suite Installation..." Green
        Install-AudioSuite
        Install-VideoSuite
        Install-Browsers
        Install-Cctv
        Install-RetroStore
        Install-AiAgents
    }
    "2" { Install-AudioSuite }
    "3" { Install-VideoSuite }
    "4" { Install-Browsers }
    "5" { Install-Cctv }
    "6" { Install-RetroStore }
    "7" { Install-AiAgents }
    "0" {
        Write-Color "`nKeeping tablet as a Pure Minimal Server. Done!" Green
        exit 0
    }
    default {
        Write-Color "[ERROR] Invalid selection: $choice" Red
        exit 1
    }
}

Write-Color @"
`n======================================================================
   AUTO-DOWNLOADER COMPLETED SUCCESSFULLY!                           
======================================================================
All selected packages have been deployed and optimized.
You can run auto-downloader again at any time to add more tools.
======================================================================
"@ Green
