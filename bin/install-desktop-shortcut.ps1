<#
==============================================================================
My Tablet Server - Windows Desktop Shortcut Installer
==============================================================================
Creates a desktop shortcut (.lnk) pointing to the dashboard launcher.
==============================================================================
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BaseDir = Split-Path -Parent $ScriptDir

$DesktopPath = [Environment]::GetFolderPath("Desktop")
$ShortcutPath = Join-Path $DesktopPath "My Tablet Server.lnk"
$TargetBat = Join-Path $BaseDir "shortcuts\windows\00-tablet-dashboard.bat"

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "         INSTALLING WINDOWS DESKTOP SHORTCUT                          " -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan

$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = $TargetBat
$Shortcut.WorkingDirectory = $BaseDir
$Shortcut.Description = "My Tablet Server - Modern Control Center"
$Shortcut.Save()

Write-Host "[OK] Desktop shortcut created at: $ShortcutPath" -ForegroundColor Green
Write-Host "[OK] You can now open My Tablet Server directly from your Windows Desktop!" -ForegroundColor Green
