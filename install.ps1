<#
==============================================================================
MY TABLET SERVER - Windows Automated Deployment & Setup Wizard
Target Device: Samsung Galaxy Tab 3 7.0 Wi-Fi (SM-T210 / lt02wifi)
Target OS    : Alpine Linux ARMv7 (Chroot on Android 4.4.2 KitKat, Kernel 3.4.5)
Goal         : Full GNU/Linux Server + Fullscreen Terminal + Smart Audio Speaker
==============================================================================
#>

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Colors
function Write-Color([string]$text, [ConsoleColor]$color) {
    $orig = [Console]::ForegroundColor
    [Console]::ForegroundColor = $color
    Write-Host $text
    [Console]::ForegroundColor = $orig
}

Write-Color @"
  __  ____     __  _______ _    ____  _      ______ _______    _____ ______ _______      ________ _____  
 |  \/  \ \   / / |__   __|/\  |  _ \| |    |  ____|__   __|  / ____|  ____|  __ \ \    / /  ____|  __ \ 
 | \  / |\ \_/ /     | |  /  \ | |_) | |    | |__     | |    | (___ | |__  | |__) \ \  / /| |__  | |__) |
 | |\/| | \   /      | | / /\ \|  _ <| |    |  __|    | |     \___ \|  __| |  _  / \ \/ / |  __| |  _  / 
 | |  | |  | |       | |/ ____ \ |_) | |____| |____   | |     ____) | |____| | \ \  \  /  | |____| | \ \ 
 |_|  |_|  |_|       |_/_/    \_\____/|______|______|  |_|    |_____/|______|_|  \_\  \/   |______|_|  \_\
                                                                                                         
  Automated Windows Installer & Provisioning Tool for Android Tablets (SM-T210)
"@ Cyan

# Check ADB
Write-Color "`n[1/8] Checking ADB Connectivity & Device Status..." Yellow

$adbCmd = Get-Command adb -ErrorAction SilentlyContinue
if (-not $adbCmd) {
    Write-Color "[ERROR] ADB (Android Debug Bridge) is not installed or not in PATH!" Red
    Write-Color "Please install Android Platform Tools for Windows:" Yellow
    Write-Color "  https://developer.android.com/tools/releases/platform-tools" Yellow
    Write-Color "Or via winget: winget install Google.PlatformTools" Yellow
    exit 1
}

$devices = adb devices | Select-String -Pattern "device$" | ForEach-Object { $_.Line.Split("`t")[0].Trim() }
if (-not $devices) {
    Write-Color "No active ADB device detected." Yellow
    Write-Color "Please ensure tablet is powered on, connected via USB, and 'USB Debugging' is enabled." Yellow
    Write-Color "Waiting for ADB device..." Cyan
    adb wait-for-device
    $devices = adb devices | Select-String -Pattern "device$" | ForEach-Object { $_.Line.Split("`t")[0].Trim() }
}

$deviceId = $devices[0]
Write-Color "✓ Device Detected: $deviceId" Green

$model = (adb shell getprop ro.product.model 2>$null).Trim()
$androidVer = (adb shell getprop ro.build.version.release 2>$null).Trim()
Write-Color "  Hardware Model : $(if ($model) { $model } else { 'SM-T210' })" Blue
Write-Color "  Android Version: $(if ($androidVer) { $androidVer } else { '4.4.2' })" Blue

# Verify Root
Write-Color "`n[2/8] Verifying Root (su) Privileges..." Yellow
$rootCheck = (adb shell "su -c 'id'" 2>$null)
if ($rootCheck -notmatch "uid=0") {
    Write-Color "[ERROR] Root access could not be acquired! Ensure SuperSU / root access is granted on tablet screen." Red
    exit 1
}
Write-Color "✓ Root Access Verified (uid=0)." Green

# Clean Slate Confirmation Prompt
Write-Color @"
======================================================================
   WARNING: CLEAN SLATE & FRESH INSTALLATION CONFIRMATION             
======================================================================
 This process will wipe previous Linux files and perform a clean install:
   • Existing chroot environments will be wiped (/data/local/linux)
   • Rogue background updaters and bloatware will be disabled
   • Thermal runaway fix (0% CPU idle) will be permanently deployed
   • Android core framework, system drivers and Wi-Fi credentials are preserved
======================================================================
"@ Red

$confirm = Read-Host " Are you sure you want to proceed with a fresh installation? [y/N]"
if ($confirm -notmatch "^[yY]([eE][sS])?$") {
    Write-Color "Installation aborted by user." Yellow
    exit 0
}
Write-Color "✓ Confirmation accepted. Proceeding with clean installation...`n" Green

# Local packages check
$rootfsTar = Join-Path $ScriptDir "packages\alpine-minirootfs-3.24.2-armv7.tar.gz"
if (-not (Test-Path $rootfsTar)) {
    Write-Color "[ERROR] packages\alpine-minirootfs-3.24.2-armv7.tar.gz is missing!" Red
    exit 1
}

$jackpalApk = Join-Path $ScriptDir "packages\jackpal.androidterm_72.apk"
if (-not (Test-Path $jackpalApk)) {
    Write-Color "[INFO] Downloading Jackpal Terminal APK from F-Droid..." Yellow
    Invoke-WebRequest -Uri "https://f-droid.org/repo/jackpal.androidterm_72.apk" -OutFile $jackpalApk
}

$audioBridgeJar = Join-Path $ScriptDir "packages\audio_bridge.jar"
if (-not (Test-Path $audioBridgeJar)) {
    Write-Color "[ERROR] packages\audio_bridge.jar is missing!" Red
    exit 1
}

# Clean Slate Wipe on Tablet
Write-Color "`n[3/8] Performing Clean Slate Wipe on Tablet..." Yellow
adb shell "su -c '
    umount -l /data/local/linux/* /data/local/alpine/* 2>/dev/null || true
    rm -rf /data/local/linux /data/local/alpine /data/local/tmp/* 2>/dev/null || true
    mkdir -p /data/local/linux /data/local/tmp/config /data/local/tmp/core /data/local/tmp/bin /data/local/tmp/packages
    chmod 777 /data/local/linux /data/local/tmp
    chmod 777 /data/local/tmp/config /data/local/tmp/core /data/local/tmp/bin /data/local/tmp/packages
'"
Write-Color "✓ Old chroot environments, caches and temporary files wiped clean." Green

# Extract & Deploy RootFS
Write-Color "`n[4/8] Extracting & Deploying Alpine Linux ARMv7 RootFS..." Yellow
$tempExtract = Join-Path $env:TEMP "alpine_extracted_tablet"
if (Test-Path $tempExtract) { Remove-Item -Recurse -Force $tempExtract }
New-Item -ItemType Directory -Path $tempExtract | Out-Null

Write-Color "  Extracting Alpine rootfs on PC using tar..." Blue
tar -xzf $rootfsTar -C $tempExtract

Write-Color "  Pushing Alpine rootfs to /data/local/linux on tablet..." Blue
adb push "$tempExtract\." /data/local/linux/ > $null
Remove-Item -Recurse -Force $tempExtract

# Auto-detect host PC public SSH key and inject into authorized_keys
$userSshDir = Join-Path $env:USERPROFILE ".ssh"
foreach ($keyName in @("id_ed25519.pub", "id_rsa.pub", "id_ecdsa.pub")) {
    $keyPath = Join-Path $userSshDir $keyName
    if (Test-Path $keyPath) {
        Write-Color "  Found host SSH public key ($keyName), copying to tablet authorized_keys..." Blue
        Copy-Item $keyPath (Join-Path $ScriptDir "config\authorized_keys") -Force
        break
    }
}

Write-Color "  Pushing configurations, audio bridge, precompiled wheels and scripts..." Blue
adb push "$ScriptDir\packages\audio_bridge.jar" /data/local/tmp/packages/ > $null
$wheelsDir = Join-Path $ScriptDir "packages\wheels"
if (Test-Path $wheelsDir) {
    adb push "$wheelsDir\." /data/local/tmp/packages/wheels/ > $null 2>&1
}
adb push "$ScriptDir\config\." /data/local/tmp/config/ > $null
adb push "$ScriptDir\core\." /data/local/tmp/core/ > $null
adb push "$ScriptDir\bin\." /data/local/tmp/bin/ > $null

adb shell "su -c '
    chmod -R 755 /data/local/tmp/core /data/local/tmp/bin
    chmod -R 644 /data/local/tmp/config /data/local/tmp/packages
'"

# Install Jackpal Terminal Emulator APK
Write-Color "  Installing Fullscreen Jackpal Terminal APK..." Blue
adb uninstall jackpal.androidterm 2>$null | Out-Null
adb shell "su -c 'rm -rf /data/data/jackpal.androidterm /data/app/jackpal.androidterm*'" 2>$null | Out-Null
adb install -r $jackpalApk 2>$null | Out-Null

# Install Video Screensaver Engine APK & Media Catalog
$videoScreensaverApk = Join-Path $ScriptDir "packages\videoscreensaver.apk"
if (Test-Path $videoScreensaverApk) {
    Write-Color "  Installing Video Screensaver Engine APK..." Blue
    adb install -r $videoScreensaverApk 2>$null | Out-Null
}

# Install Core Browser & Media Tools (AnimeDLR, SkyTube, VLC, Lightning, bVNC)
Write-Color "  Installing Core Media & Anime APKs (AnimeDLR, SkyTube, VLC, Lightning, bVNC)..." Blue
Get-ChildItem -Path (Join-Path $ScriptDir "packages\browsers\*.apk"), (Join-Path $ScriptDir "packages\tools\*.apk") -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Color "    Installing $($_.Name)..." Blue
    adb install -r $_.FullName 2>$null | Out-Null
}

$screensaversDir = Join-Path $ScriptDir "packages\screensavers"
if (Test-Path $screensaversDir) {
    Write-Color "  Deploying Frutiger Aero & Ambient Screensavers to /sdcard/Screensavers/..." Blue
    adb shell "mkdir -p /sdcard/Screensavers/Wallpapers" 2>$null | Out-Null
    adb push "$screensaversDir\." /sdcard/Screensavers/ > $null 2>&1
}

$retroDir = Join-Path $ScriptDir "packages\retro"
if (Test-Path $retroDir) {
    Write-Color "  Deploying & Installing Selected Retro Classic Games..." Blue
    adb shell "mkdir -p /sdcard/retro-apks" 2>$null | Out-Null
    adb push "$retroDir\." /sdcard/retro-apks/ > $null 2>&1
    Get-ChildItem -Path (Join-Path $retroDir "*.apk") -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Color "    Installing $($_.Name)..." Blue
        adb install -r $_.FullName 2>$null | Out-Null
    }
}

Write-Color "✓ Rootfs, screensavers, retro store and packages successfully deployed." Green

# Execute Provisioning Steps on Device
Write-Color "`n[5/8] Step 1: Applying Thermal Mitigation & Watchdog-Safe Debloat..." Yellow
adb shell "su -c 'sh /data/local/tmp/core/01_thermal_fix.sh'"
adb shell "su -c 'sh /data/local/tmp/core/02_safe_debloat.sh'"
Write-Color "✓ Thermal fix applied (CPU idle stabilized) and bloatware/updaters disabled." Green

Write-Color "`n[6/8] Step 2: Provisioning Minimal Alpine Linux ARMv7 Environment..." Yellow
Write-Color "  (Updating APK repositories & installing lightweight base packages - 1-2 minutes)..." Blue
adb shell "su -c 'sh /data/local/tmp/core/03_setup_rootfs.sh'"
Write-Color "✓ Minimal Alpine Linux environment and base server packages installed." Green

Write-Color "`n[7/8] Step 3: Configuring Fullscreen Console & Hardware Terminal..." Yellow
adb shell "su -c 'sh /data/local/tmp/core/04_setup_terminal.sh'"
adb shell "su -c 'sh /data/local/tmp/core/05_audio_bridge.sh'"
Write-Color "✓ Live terminal console and hardware audio bridge ready." Green

Write-Color "`n[8/8] Step 4: Installing Persistent Auto-Boot Hook & Launching Daemons..." Yellow
adb shell "su -c 'sh /data/local/tmp/core/06_autoboot_hook.sh'"

adb shell "su -c '
    mkdir -p /data/local/linux/var/run /data/local/linux/var/empty
    /data/local/linux/lib/ld-musl-armhf.so.1 /data/local/linux/bin/busybox chroot /data/local/linux /usr/sbin/sshd 2>/dev/null || true
'"
Write-Color "✓ install-recovery.sh auto-boot hook installed and OpenSSH running." Green

# USB Port Forwarding
adb forward tcp:2222 tcp:22 2>$null | Out-Null
adb forward tcp:22 tcp:22 2>$null | Out-Null

# Auto-Sync Windows Wi-Fi to Tablet & Setup Daemon
Write-Color "`n--> Setting up Windows Wi-Fi Auto-Sync & Background Daemon..." Blue
$syncScript = Join-Path $ScriptDir "bin\sync-wifi.ps1"
if (Test-Path $syncScript) {
    & powershell.exe -ExecutionPolicy Bypass -File $syncScript
}

$daemonScript = Join-Path $ScriptDir "bin\tablet-daemon.ps1"
try {
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$daemonScript`""
    $trigger = New-ScheduledTaskTrigger -AtLogOn
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit 0
    Register-ScheduledTask -TaskName "TabletServerSync" -Action $action -Trigger $trigger -Settings $settings -Force -ErrorAction SilentlyContinue | Out-Null
    Start-ScheduledTask -TaskName "TabletServerSync" -ErrorAction SilentlyContinue | Out-Null
    Write-Color "✓ Windows background daemon registered (auto-starts at logon and runs in background)." Green
} catch {
    Write-Color "[NOTE] Run bin\tablet-daemon.ps1 manually or as admin to keep sync active." Yellow
}

# Wi-Fi IP Detection
$wifiIpRaw = (adb shell "su -c 'ip -4 addr show wlan0'" 2>$null) | Select-String -Pattern "inet\s+([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)"
$wifiIp = ""
if ($wifiIpRaw -and $wifiIpRaw.Matches) {
    $wifiIp = $wifiIpRaw.Matches.Groups[1].Value
}

# Cleanup temporary files
adb shell "su -c 'rm -rf /data/local/tmp/*'" 2>$null | Out-Null

# ==============================================================================
# AUTO-DOWNLOADER INTERACTIVE APP SELECTION
# ==============================================================================
Write-Color @"
`n======================================================================
   MINIMAL PURE LINUX SERVER DEPLOYMENT COMPLETED!                    
======================================================================
 The tablet is now running as a clean, low-resource Minimal Linux Server.
 Free RAM is maximized and all heavy background tasks are stopped.

 Would you like to install pre-configured applications & media tools?
 (YouTube audio/video, Web browsers, VLC video stream, Hermes AI, Antigravity CLI)
======================================================================
"@ Yellow

$runAutoDownloader = Read-Host " Do you want to run auto-downloader now? [y/N]"
if ($runAutoDownloader -match "^[yY]([eE][sS])?$") {
    Write-Color "Launching auto-downloader wizard..." Green
    & "$ScriptDir\bin\auto-downloader.ps1"
} else {
    Write-Color "`n✓ Kept as a Pure Minimal Linux Server." Green
    Write-Color "You can run 'auto-downloader.bat' at any time from Windows or tablet terminal." Yellow
}

Write-Color @"
`n======================================================================
   CONGRATULATIONS! MY TABLET SERVER IS READY!                        
======================================================================
How to Connect:
1. Wireless via Wi-Fi (Home LAN):
"@ Green

if ($wifiIp) {
    Write-Color "   ssh root@$wifiIp  or  ssh my-tablet-server" Green
} else {
    Write-Color "   ssh my-tablet-server (after connecting tablet to Wi-Fi)" Green
}

Write-Color @"
2. Wired via USB Cable (ADB Port Forwarding):
   ssh root@localhost -p 2222
   (No password required, your PC SSH key was authorized automatically. Default password: hermes)

Live Synced Terminal Console:
   The tablet physical display is running Jackpal Terminal.
   Run console or tmux attach -t console from your PC terminal
   to view and interact with the exact same live session on the tablet screen.

Master CLI & Tools:
   Server CLI helper  : my-tablet-server (or: my-tablet-server status, console, server)
   Auto-Downloader    : auto-downloader (run auto-downloader.bat anytime)
   CCTV Security Cam  : cctv start [max_gb] (24/7 video surveillance with circular quota)
   Retro Games Store  : retro-store (Talking Tom, Çakmak, Pou, Flappy Bird, Temple Run, Emülatörler)
   Screensaver & Süs  : screensaver art (or: aquarium, fireplace, matrix, sus menu)
   Antigravity CLI    : agy / antigravity (Google Antigravity AI CLI bridge)
   Nous Hermes Agent  : hermes (AI terminal agent)
   Anime & Video watch: watch <URL or search> (Hardware-accelerated VLC player)
   YouTube audio      : yt 'Song Name' (or: yt stop)
   Play sound / music : play-sound <file.mp3> (or: play)
   Internet radio     : radio lofi (or: radio jazz, radio rock)
   Morning alarm      : alarm play
   [1] Linux Server   : server-mode linux (headless, screen off, max RAM)
   [2] Android Tablet : server-mode android (pure tablet, Linux stopped)
   [3] Hybrid Mode    : server-mode hybrid (Android UI ON + Hermes Timers & Cron)
   TTY Console Mode   : server-mode screen-on (fullscreen TTY terminal)
   Screen brightness  : screen on / screen off / screen brightness 150
   Server dashboard   : server-status (or: server-mode status)
======================================================================
"@ Green
