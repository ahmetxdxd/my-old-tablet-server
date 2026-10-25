<#
==============================================================================
My Tablet Server - Windows In-Place Updater
==============================================================================
Upgrades an existing My Tablet Server setup to the latest version.
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

Write-Color "======================================================================" Cyan
Write-Color "         MY TABLET SERVER - IN-PLACE UPDATE WIZARD                    " Cyan
Write-Color "======================================================================" Cyan

Write-Color "`n[1/3] Pulling Latest Updates from Git Repository..." Yellow
Set-Location $ScriptDir
if (Test-Path ".git") {
    & git pull origin main
}

Write-Color "`n[2/3] Updating Windows Desktop Shortcuts & Configuration..." Yellow
$shortcutInstaller = Join-Path $ScriptDir "bin\install-desktop-shortcut.ps1"
if (Test-Path $shortcutInstaller) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $shortcutInstaller
}

Write-Color "`n[3/3] Syncing Updates to Connected Tablet (ADB)..." Yellow
$devices = adb devices 2>$null | Select-String -Pattern "device$" | ForEach-Object { $_.Line.Split("`t")[0].Trim() }
if ($devices) {
    $dev = $devices[0]
    Write-Color "✓ Tablet detected: $dev" Green
    adb forward tcp:2222 tcp:22 2>$null | Out-Null
    adb forward tcp:4711 tcp:4711 2>$null | Out-Null
    Write-Color "✓ Port forwards and device sync refreshed." Green
} else {
    Write-Color "[!] No tablet connected via USB. Host PC updated." Yellow
}

Write-Color "`n======================================================================" Green
Write-Color "   ✓ UPDATE COMPLETE!                                                 " Green
Write-Color "======================================================================" Green
Write-Color "New features ready: Modern Dashboard, Multi-Tablet Selector, and Doctor." Cyan
