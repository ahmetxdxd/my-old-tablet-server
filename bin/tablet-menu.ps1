<#
==============================================================================
My Tablet Server - Windows Interactive Terminal Quick Menu
==============================================================================
Allows running all README commands without entering the tablet terminal.
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

function Pause-Menu {
    Write-Host ""
    Read-Host "Menüye dönmek için [Enter] tuşuna basın..." | Out-Null
}

function Run-TabletCommand([string]$cmd) {
    Write-Color "`n--> Komut çalıştırılıyor: $cmd" Cyan
    $tabletCli = Join-Path $ScriptDir "tablet.ps1"
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $tabletCli run $cmd
    Pause-Menu
}

while ($true) {
    Clear-Host
    Write-Color @"
  __  __         _______     _     _      _      _____                          
 |  \/  |       |__   __|   | |   | |    | |    / ____|                         
 | \  / |_   _     | | __ _ | |__ | | ___| |_  | (___   ___ _ ____   _____ _ __ 
 | |\/| | | | |    | |/ _` || '_ \| |/ _ \ __|  \___ \ / _ \ '__\ \ / / _ \ '__|
 | |  | | |_| |    | | (_| || |_) | |  __/ |_   ____) |  __/ |   \ V /  __/ |   
 |_|  |_|\__, |    |_|\__,_||_.__/|_|\___|\__| |_____/ \___|_|    \_/ \___|_|   
          __/ |                                                                 
         |___/      📱 HIZLI KONTROL PANELİ & KISAYOL MENÜSÜ                    
"@ Cyan

    Write-Color "Tablet terminaline girmeden tüm işlemleri tek tuşla yönetin:`n" Yellow

    Write-Host "  [ 📊 SİSTEM & DURUM ]" -ForegroundColor White
    Write-Host "   1) Tablet Durum Raporu       " -NoNewline -ForegroundColor Green; Write-Host "(Sıcaklık, RAM, Pil, IP)" -ForegroundColor Cyan
    Write-Host "   2) Canlı Tablet Terminali   " -NoNewline -ForegroundColor Green; Write-Host "(SSH ile uğraşmadan direkt bağlan)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [ 🖥️ İKİNCİ EKRAN (SECOND SCREEN) ]" -ForegroundColor White
    Write-Host "   3) İkinci Ekranı Başlat - USB   " -NoNewline -ForegroundColor Green; Write-Host "(Sıfır gecikme kablolu)" -ForegroundColor Cyan
    Write-Host "   4) İkinci Ekranı Başlat - Wi-Fi " -NoNewline -ForegroundColor Green; Write-Host "(Kablosuz bağlantı)" -ForegroundColor Cyan
    Write-Host "   5) İkinci Ekranı Kapat          " -NoNewline -ForegroundColor Green; Write-Host "(Normal tablete dön)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [ 📻 STEREO HOPARLÖR & CAVA ]" -ForegroundColor White
    Write-Host "   6) Stereo Hoparlörleri Başlat   " -NoNewline -ForegroundColor Green; Write-Host "(PC Sesini Tablete Aktar)" -ForegroundColor Cyan
    Write-Host "   7) CAVA Ses Spektrumunu Aç      " -NoNewline -ForegroundColor Green; Write-Host "(Canlı Müzik Görselleştirici)" -ForegroundColor Cyan
    Write-Host "   8) Stereo Hoparlörleri Durdur   " -NoNewline -ForegroundColor Green; Write-Host "(Ses akışını sonlandır)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [ 🌸 EKRAN KORUYUCU & AMBİYANS ]" -ForegroundColor White
    Write-Host "   9) Frutiger Aero Sanat Döngüsü  " -NoNewline -ForegroundColor Green; Write-Host "(Nostaljik cam & doğa teması)" -ForegroundColor Cyan
    Write-Host "  10) Canlı Akvaryum Döngüsü       " -NoNewline -ForegroundColor Green; Write-Host "(Tropikal mercan resifi)" -ForegroundColor Cyan
    Write-Host "  11) Canlı Şömine Döngüsü        " -NoNewline -ForegroundColor Green; Write-Host "(Huzurlu odun ateşi)" -ForegroundColor Cyan
    Write-Host "  12) Cyber Matrix Dijital Yağmur  " -NoNewline -ForegroundColor Green; Write-Host "(Hacker kod akışı)" -ForegroundColor Cyan
    Write-Host "  13) Ekran Koruyucuyu Durdur      " -NoNewline -ForegroundColor Green; Write-Host "(Masaüstüne dön)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [ 🎌 MEDYA & İNTERNET RADYOSU ]" -ForegroundColor White
    Write-Host "  14) Anime Uygulamasını Aç        " -NoNewline -ForegroundColor Green; Write-Host "(AnimeDLR Reklamsız)" -ForegroundColor Cyan
    Write-Host "  15) Lofi Radyo Akışı             " -NoNewline -ForegroundColor Green; Write-Host "(Chill Lofi Beats)" -ForegroundColor Cyan
    Write-Host "  16) Jazz Radyo Akışı             " -NoNewline -ForegroundColor Green; Write-Host "(Smooth Jazz Cafe)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [ ⚡ ÇALIŞMA MODLARI & YÖNETİM ]" -ForegroundColor White
    Write-Host "  17) Saf Linux Sunucu Modu        " -NoNewline -ForegroundColor Green; Write-Host "(Ekran Kapalı, Maksimum RAM)" -ForegroundColor Cyan
    Write-Host "  18) Saf Android Tablet Modu      " -NoNewline -ForegroundColor Green; Write-Host "(Normal tablet arayüzü)" -ForegroundColor Cyan
    Write-Host "  19) Hibrit Mod                   " -NoNewline -ForegroundColor Green; Write-Host "(Android Saat + Linux Servisleri)" -ForegroundColor Cyan
    Write-Host "  20) Güvenli Debloat (RAM Temizle)" -NoNewline -ForegroundColor Green; Write-Host "(60+ gereksiz servisi dondur)" -ForegroundColor Cyan
    Write-Host "  21) Ekran Işığını Aç / Kapat     " -NoNewline -ForegroundColor Green; Write-Host "(Aç: screen on, Kapat: screen off)" -ForegroundColor Cyan
    Write-Host "  22) Hoparlör Ses Seviyesi Ayarla " -NoNewline -ForegroundColor Green; Write-Host "(0 - 100 arası)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [ ⌨️ ÖZEL KOMUT ÇALIŞTIR ]" -ForegroundColor White
    Write-Host "  23) Serbest README / Linux Komutu Gir " -NoNewline -ForegroundColor Green; Write-Host "(watch, yt, alarm, play...)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   0) Çıkış" -ForegroundColor Red
    Write-Color "----------------------------------------------------------------------" Cyan

    $choice = Read-Host "Lütfen bir seçenek girin [0-23]"

    switch ($choice) {
        "1" { Run-TabletCommand "my-tablet-server status" }
        "2" {
            Clear-Host
            $termScript = Join-Path $ScriptDir "tablet-terminal.ps1"
            & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $termScript
            Pause-Menu
        }
        "3" {
            Clear-Host
            $pos = Read-Host "Monitör konumu [right (varsayılan), left, above, below]"
            if (-not $pos) { $pos = "right" }
            Run-TabletCommand "second-screen usb $pos"
        }
        "4" {
            Clear-Host
            $pos = Read-Host "Monitör konumu [right (varsayılan), left, above, below]"
            if (-not $pos) { $pos = "right" }
            Run-TabletCommand "second-screen wifi $pos"
        }
        "5" { Run-TabletCommand "second-screen stop" }
        "6" {
            $stereoScript = Join-Path $ScriptDir "stereo-speakers.ps1"
            if (Test-Path $stereoScript) {
                & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $stereoScript start
            } else {
                Run-TabletCommand "stereo-speakers start"
            }
            Pause-Menu
        }
        "7" {
            $stereoScript = Join-Path $ScriptDir "stereo-speakers.ps1"
            if (Test-Path $stereoScript) {
                & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $stereoScript cava
            } else {
                Run-TabletCommand "stereo-speakers cava"
            }
            Pause-Menu
        }
        "8" {
            $stereoScript = Join-Path $ScriptDir "stereo-speakers.ps1"
            if (Test-Path $stereoScript) {
                & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $stereoScript stop
            }
            Run-TabletCommand "stereo-speakers stop"
        }
        "9"  { Run-TabletCommand "screensaver art" }
        "10" { Run-TabletCommand "screensaver aquarium" }
        "11" { Run-TabletCommand "screensaver fireplace" }
        "12" { Run-TabletCommand "screensaver matrix" }
        "13" { Run-TabletCommand "screensaver stop" }
        "14" { Run-TabletCommand "anime app" }
        "15" { Run-TabletCommand "radio lofi" }
        "16" { Run-TabletCommand "radio jazz" }
        "17" { Run-TabletCommand "my-tablet-server linux" }
        "18" { Run-TabletCommand "my-tablet-server android" }
        "19" { Run-TabletCommand "my-tablet-server hybrid" }
        "20" { Run-TabletCommand "debloat-tablet" }
        "21" {
            $scr = Read-Host "Ekran Durumu Seçin: [1] Aç (screen on), [2] Kapat (screen off)"
            if ($scr -eq "1") { Run-TabletCommand "screen on" } else { Run-TabletCommand "screen off" }
        }
        "22" {
            $vol = Read-Host "Ses seviyesi girin (0 - 100)"
            if ($vol) { Run-TabletCommand "set-volume $vol" }
        }
        "23" {
            $custom = Read-Host "Tablette çalıştırmak istediğiniz komutu yazın"
            if ($custom) { Run-TabletCommand $custom }
        }
        "0" {
            Write-Color "`nGörüşmek üzere!" Green
            exit 0
        }
        default {
            Write-Color "`nGeçersiz seçenek! Tekrar deneyin." Red
            Start-Sleep -Seconds 1
        }
    }
}
