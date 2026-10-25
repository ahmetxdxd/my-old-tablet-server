<#
==============================================================================
My Tablet Server - Windows Master CLI & Shortcut Runner
==============================================================================
Allows running any tablet command from Windows without entering the tablet
terminal directly.
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

function Run-OnTablet([string]$cmd) {
    # 1. Check USB
    $devices = adb devices 2>$null | Select-String -Pattern "device$" | ForEach-Object { $_.Line.Split("`t")[0].Trim() }
    if ($devices) {
        $deviceId = $devices[0]
        adb forward tcp:2222 tcp:22 2>$null | Out-Null

        # Try SSH check
        $sshTest = Start-Process -FilePath "ssh" -ArgumentList "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=2 -p 2222 root@127.0.0.1 exit" -NoNewWindow -PassThru -Wait -ErrorAction SilentlyContinue
        if ($sshTest -and $sshTest.ExitCode -eq 0) {
            & ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 2222 -t root@127.0.0.1 "export PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin:`$PATH; $cmd"
            return $LASTEXITCODE
        } else {
            # ADB chroot fallback
            & adb -s $deviceId shell "su -c 'L=/data/local/linux/lib/ld-musl-armhf.so.1; B=/data/local/linux/bin/busybox; R=/data/local/linux; if [ -f `$R/bin/bash ]; then SH=/bin/bash; else SH=/bin/sh; fi; `$L `$B chroot `$R `$SH -c `"export PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin:\`$PATH; $cmd`"'"
            return $LASTEXITCODE
        }
    }

    # 2. Check Wi-Fi IP
    $sshConfig = Join-Path $env:USERPROFILE ".ssh\config"
    $targetIp = ""
    if (Test-Path $sshConfig) {
        $content = Get-Content $sshConfig -Raw
        $ipMatch = [regex]::Match($content, "(?s)Host my-tablet-server.*?HostName\s+([0-9.]+)")
        if ($ipMatch.Success) {
            $targetIp = $ipMatch.Groups[1].Value.Trim()
        }
    }

    if ($targetIp) {
        & ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -t "root@$targetIp" "export PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin:`$PATH; $cmd"
        return $LASTEXITCODE
    }

    Write-Color "[ERROR] Failed to connect to tablet! Please connect USB cable or check Wi-Fi network." Red
    return 1
}

if ($args.Count -eq 0) {
    $menuScript = Join-Path $ScriptDir "tablet-menu.ps1"
    if (Test-Path $menuScript) {
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $menuScript
        exit $LASTEXITCODE
    } else {
        Write-Color "[ERROR] tablet-menu.ps1 not found!" Red
        exit 1
    }
}

$action = $args[0]
$remainingArgs = if ($args.Count -gt 1) { $args[1..($args.Count - 1)] -join " " } else { "" }

switch -regex ($action) {
    "^(terminal|term|ssh|console|shell|connect)$" {
        $termScript = Join-Path $ScriptDir "tablet-terminal.ps1"
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $termScript $remainingArgs
        exit $LASTEXITCODE
    }
    "^(menu|panel|quick)$" {
        $menuScript = Join-Path $ScriptDir "tablet-menu.ps1"
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $menuScript
        exit $LASTEXITCODE
    }
    "^(run|exec)$" {
        Run-OnTablet $remainingArgs
        exit $LASTEXITCODE
    }
    "^status$" {
        Run-OnTablet "server-status 2>/dev/null || my-tablet-server status 2>/dev/null || uname -a"
        exit $LASTEXITCODE
    }
    "^(help|--help|-h)$" {
        Write-Color "======================================================" Cyan
        Write-Color "          📱 MY TABLET SERVER - CLI USER GUIDE        " Cyan
        Write-Color "======================================================" Cyan
        Write-Host "Usage:"
        Write-Host "  tablet                      : Open interactive Quick Control Menu" -ForegroundColor Green
        Write-Host "  tablet terminal             : Connect directly to live tablet terminal" -ForegroundColor Green
        Write-Host "  tablet status               : View tablet CPU temp, RAM, battery & IP" -ForegroundColor Green
        Write-Host "  tablet <command>            : Execute README command directly on tablet" -ForegroundColor Green
        Write-Host ""
        Write-Host "Example Commands:"
        Write-Host "  tablet screensaver art      : Start Frutiger Aero screensaver"
        Write-Host "  tablet screensaver aquarium : Start Coral Reef Aquarium screensaver"
        Write-Host "  tablet second-screen usb    : Turn tablet into PC second display via USB"
        Write-Host "  tablet stereo-speakers start: Stream PC audio to tablet speakers"
        Write-Host "  tablet anime app            : Open AnimeDLR streaming app"
        Write-Host "  tablet debloat              : Clean up 60+ background services"
        Write-Host "  tablet screen off           : Turn off screen backlight (power saving)"
        Write-Host "  tablet screen on            : Turn on screen backlight"
        Write-Color "======================================================" Cyan
        exit 0
    }
    default {
        $fullCmd = ($args -join " ")
        Run-OnTablet $fullCmd
        exit $LASTEXITCODE
    }
}
