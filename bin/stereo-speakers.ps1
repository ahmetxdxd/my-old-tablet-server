<#
 ==============================================================================
 MY TABLET SERVER - Dual Tablet PC Stereo Speakers (Windows PowerShell)
 ==============================================================================
#>

param (
    [string]$Action = "status"
)

$ErrorActionPreference = "Continue"

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "       MY TABLET SERVER - DUAL STEREO HOPARLÖR YÖNETİCİSİ             " -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

function Show-Help {
    Write-Host "Kullanım:" -ForegroundColor Yellow
    Write-Host "  .\stereo-speakers.ps1 start   : Stereo hoparlör modunu başlat"
    Write-Host "  .\stereo-speakers.ps1 stop    : Servisleri durdur"
    Write-Host "  .\stereo-speakers.ps1 status  : Durumu kontrol et"
    Write-Host "  .\stereo-speakers.ps1 config  : Ayar rehberini görüntüle"
    Write-Host ""
    Write-Host "Windows Notu:" -ForegroundColor Gray
    Write-Host "Windows üzerinde Snapcast (snapserver.exe) veya Scream Sanal Ses Kartı"
    Write-Host "aracılığıyla tabletler stereo hoparlör olarak kullanılır."
    Write-Host "Web Kontrol Paneli: http://localhost:1780"
}

switch ($Action.ToLower()) {
    "start" {
        Write-Host "[BİLGİ] Tablet ses bağlantıları kontrol ediliyor..." -ForegroundColor Blue
        # Detect connected ADB devices
        $adbDevices = adb devices 2>$null | Where-Object { $_ -match "\bdevice$" }
        if ($adbDevices) {
            Write-Host "[TAMAM] ✓ ADB üzerinden tablet tespit edildi." -ForegroundColor Green
            adb shell "am start -n de.badaix.snapcast/.MainActivity" 2>$null
        }
        Write-Host "[BİLGİ] Snapclient ve ses köprüsü aktif." -ForegroundColor Green
        Write-Host "Web Kontrol Paneli: http://localhost:1780" -ForegroundColor Cyan
    }
    "stop" {
        Write-Host "[BİLGİ] Hoparlör servisleri durduruluyor..." -ForegroundColor Blue
        adb shell "am force-stop de.badaix.snapcast" 2>$null
        Write-Host "[TAMAM] Durduruldu." -ForegroundColor Green
    }
    "status" {
        Write-Host "Stereo Hoparlör Durumu:" -ForegroundColor Cyan
        adb devices
    }
    default {
        Show-Help
    }
}
