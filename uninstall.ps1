<#
==============================================================================
My Tablet Server - Windows Uninstaller & Reversion Wizard
==============================================================================
Cleanly removes My Tablet Server and restores the tablet & PC to original state.
==============================================================================
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Write-Color([string]$text, [ConsoleColor]$color) {
    $orig = [Console]::ForegroundColor
    [Console]::ForegroundColor = $color
    Write-Host $text
    [Console]::ForegroundColor = $orig
}

Write-Color "======================================================================" Red
Write-Color "         MY TABLET SERVER - COMPLETE UNINSTALLATION WIZARD            " Red
Write-Color "======================================================================" Red

$confirm = Read-Host "Are you sure you want to completely uninstall My Tablet Server? [y/N]"
if ($confirm -notmatch "^[yY]") {
    Write-Color "Uninstallation aborted." Yellow
    exit 0
}

Write-Color "`n[1/3] Checking Connected Tablet (ADB)..." Yellow
$devices = adb devices 2>$null | Select-String -Pattern "device$" | ForEach-Object { $_.Line.Split("`t")[0].Trim() }

if ($devices) {
    $dev = $devices[0]
    Write-Color "✓ Found Tablet: $dev" Green
    Write-Color "[2/3] Reverting Tablet Modifications..." Yellow

    & adb -s $dev shell "su -c '
        pkill -9 sshd 2>/dev/null || true
        pkill -9 snapclient 2>/dev/null || true
        pkill -9 -f AudioBridgeServer 2>/dev/null || true
        for mp in /data/local/linux/dev/pts /data/local/linux/dev /data/local/linux/proc /data/local/linux/sys /data/local/linux/system /data/local/linux/android_data /data/local/linux/sdcard /data/local/linux/data; do
            umount -l \"`$mp\" 2>/dev/null || true
        done
        rm -rf /data/local/linux /data/local/alpine /data/local/audio_bridge.jar /data/local/start_audio_bridge.sh 2>/dev/null || true
        mount -o remount,rw /system 2>/dev/null || true
        if [ -f /system/etc/install-recovery.sh.bak ]; then
            mv /system/etc/install-recovery.sh.bak /system/etc/install-recovery.sh 2>/dev/null || true
        fi
        mount -o remount,ro /system 2>/dev/null || true
    '" 2>$null
    Write-Color "✓ Tablet Linux components cleanly removed." Green
} else {
    Write-Color "[!] No tablet detected via USB. Skipping tablet storage cleanup." Yellow
}

Write-Color "`n[3/3] Removing Windows Shortcuts & Port Forwards..." Yellow

$desktopPath = [Environment]::GetFolderPath("Desktop")
$lnkPath = Join-Path $desktopPath "My Tablet Server.lnk"
if (Test-Path $lnkPath) {
    Remove-Item -Force $lnkPath 2>$null
}

adb forward --remove tcp:2222 2>$null | Out-Null
adb forward --remove tcp:4711 2>$null | Out-Null

$cfg = Join-Path $env:USERPROFILE ".config\my-tablet-server"
if (Test-Path $cfg) {
    Remove-Item -Recurse -Force $cfg 2>$null
}

Write-Color "`n======================================================================" Green
Write-Color "   ✓ UNINSTALLATION COMPLETED SUCCESSFULLY!                           " Green
Write-Color "======================================================================" Green
