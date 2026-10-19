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
    Read-Host "Press [Enter] to return to the menu..." | Out-Null
}

function Run-TabletCommand([string]$cmd) {
    Write-Color "`n--> Executing command: $cmd" Cyan
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
         |___/      📱 QUICK CONTROL PANEL & SHORTCUT DASHBOARD                 
"@ Cyan

    Write-Color "Manage and trigger all tablet features with a single key without entering the tablet:`n" Yellow

    Write-Host "  [ 📊 SYSTEM & STATUS ]" -ForegroundColor White
    Write-Host "   1) Tablet System Status Report   " -NoNewline -ForegroundColor Green; Write-Host "(CPU temp, RAM, battery %, IP)" -ForegroundColor Cyan
    Write-Host "   2) Live Tablet Terminal (SSH)    " -NoNewline -ForegroundColor Green; Write-Host "(Jump into terminal with zero hassle)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [ 🖥️ PC SECOND MONITOR (SECOND SCREEN) ]" -ForegroundColor White
    Write-Host "   3) Start Second Screen - USB     " -NoNewline -ForegroundColor Green; Write-Host "(Zero latency wired cable mode)" -ForegroundColor Cyan
    Write-Host "   4) Start Second Screen - Wi-Fi   " -NoNewline -ForegroundColor Green; Write-Host "(Wireless local network mode)" -ForegroundColor Cyan
    Write-Host "   5) Stop Second Screen            " -NoNewline -ForegroundColor Green; Write-Host "(Detach monitor & restore tablet)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [ 📻 STEREO SPEAKERS & CAVA ]" -ForegroundColor White
    Write-Host "   6) Start PC Stereo Speakers      " -NoNewline -ForegroundColor Green; Write-Host "(Stream PC audio to tablet speakers)" -ForegroundColor Cyan
    Write-Host "   7) Open CAVA Spectrum Visualizer " -NoNewline -ForegroundColor Green; Write-Host "(Live audio frequency visualizer)" -ForegroundColor Cyan
    Write-Host "   8) Stop Stereo Speakers          " -NoNewline -ForegroundColor Green; Write-Host "(Terminate audio streaming)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [ 🌸 SCREENSAVERS & AMBIENT DISPLAY ]" -ForegroundColor White
    Write-Host "   9) Frutiger Aero Art Slideshow   " -NoNewline -ForegroundColor Green; Write-Host "(Nostalgic nature & glossy artwork)" -ForegroundColor Cyan
    Write-Host "  10) Tropical Coral Aquarium Loop  " -NoNewline -ForegroundColor Green; Write-Host "(Live underwater reef loop)" -ForegroundColor Cyan
    Write-Host "  11) Cozy Glowing Fireplace Loop   " -NoNewline -ForegroundColor Green; Write-Host "(Relaxing burning log fire)" -ForegroundColor Cyan
    Write-Host "  12) Cyber Matrix Digital Rain     " -NoNewline -ForegroundColor Green; Write-Host "(Classic green code rain)" -ForegroundColor Cyan
    Write-Host "  13) Stop Screensaver              " -NoNewline -ForegroundColor Green; Write-Host "(Return to home screen)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [ 🎌 MEDIA & INTERNET RADIO ]" -ForegroundColor White
    Write-Host "  14) Launch AnimeDLR App           " -NoNewline -ForegroundColor Green; Write-Host "(Ad-free streaming anime player)" -ForegroundColor Cyan
    Write-Host "  15) Lofi Hip Hop Radio Stream     " -NoNewline -ForegroundColor Green; Write-Host "(24/7 chill beats)" -ForegroundColor Cyan
    Write-Host "  16) Smooth Jazz Radio Stream      " -NoNewline -ForegroundColor Green; Write-Host "(Relaxing cafe jazz)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [ ⚡ OPERATING MODES & POWER ]" -ForegroundColor White
    Write-Host "  17) Pure Linux Server Mode        " -NoNewline -ForegroundColor Green; Write-Host "(Screen OFF, Maximum free RAM)" -ForegroundColor Cyan
    Write-Host "  18) Pure Android Tablet Mode      " -NoNewline -ForegroundColor Green; Write-Host "(Normal tablet GUI & launcher)" -ForegroundColor Cyan
    Write-Host "  19) Hybrid Dual Mode              " -NoNewline -ForegroundColor Green; Write-Host "(Android UI + Background Linux daemons)" -ForegroundColor Cyan
    Write-Host "  20) Safe Tablet Debloater         " -NoNewline -ForegroundColor Green; Write-Host "(Freeze 60+ bloatware packages safely)" -ForegroundColor Cyan
    Write-Host "  21) Turn Screen Light ON / OFF    " -NoNewline -ForegroundColor Green; Write-Host "(ON: screen on, OFF: screen off)" -ForegroundColor Cyan
    Write-Host "  22) Set Speaker Hardware Volume   " -NoNewline -ForegroundColor Green; Write-Host "(Range: 0 - 100)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [ ⌨️ CUSTOM COMMAND EXECUTION ]" -ForegroundColor White
    Write-Host "  23) Execute Custom Tablet Command " -NoNewline -ForegroundColor Green; Write-Host "(watch, yt, alarm, play-sound...)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   0) Exit" -ForegroundColor Red
    Write-Color "----------------------------------------------------------------------" Cyan

    $choice = Read-Host "Please enter an option [0-23]"

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
            $pos = Read-Host "Monitor position [right (default), left, above, below]"
            if (-not $pos) { $pos = "right" }
            Run-TabletCommand "second-screen usb $pos"
        }
        "4" {
            Clear-Host
            $pos = Read-Host "Monitor position [right (default), left, above, below]"
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
            $scr = Read-Host "Screen Backlight: [1] Turn ON (screen on), [2] Turn OFF (screen off)"
            if ($scr -eq "1") { Run-TabletCommand "screen on" } else { Run-TabletCommand "screen off" }
        }
        "22" {
            $vol = Read-Host "Enter volume level (0 - 100)"
            if ($vol) { Run-TabletCommand "set-volume $vol" }
        }
        "23" {
            $custom = Read-Host "Enter command to execute on tablet"
            if ($custom) { Run-TabletCommand $custom }
        }
        "0" {
            Write-Color "`nGoodbye!" Green
            exit 0
        }
        default {
            Write-Color "`nInvalid option! Please try again." Red
            Start-Sleep -Seconds 1
        }
    }
}
