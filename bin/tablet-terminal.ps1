<#
==============================================================================
My Tablet Server - Windows Quick Terminal Launcher (No SSH Confusion)
==============================================================================
Connects directly to the tablet's live Linux console with a single command.
Automatically detects USB cable (ADB port forward) or Wi-Fi LAN IP.
Seamlessly falls back to direct ADB chroot if SSH is temporarily unavailable.
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

Write-Color "======================================================" Cyan
Write-Color "       📱 MY TABLET SERVER - HIZLI TERMİNAL           " Cyan
Write-Color "======================================================" Cyan

$targetIp = $args[0]

# 1. Check if tablet is connected via USB (ADB)
$devices = adb devices 2>$null | Select-String -Pattern "device$" | ForEach-Object { $_.Line.Split("`t")[0].Trim() }
if ($devices) {
    $deviceId = $devices[0]
    Write-Color "✓ USB üzerinden tablet tespit edildi ($deviceId)" Green

    adb forward tcp:2222 tcp:22 2>$null | Out-Null

    # Try quick SSH check
    $sshCheck = $false
    try {
        $sshTest = Start-Process -FilePath "ssh" -ArgumentList "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=2 -p 2222 root@127.0.0.1 exit" -NoNewWindow -PassThru -Wait -ErrorAction SilentlyContinue
        if ($sshTest -and $sshTest.ExitCode -eq 0) {
            $sshCheck = $true
        }
    } catch {
        $sshCheck = $false
    }

    if ($sshCheck) {
        Write-Color "--> Canlı konsola bağlanılıyor (USB SSH :2222)...`n" Blue
        & ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 2222 -t root@127.0.0.1 "console 2>/dev/null || tmux attach -t console 2>/dev/null || /bin/bash 2>/dev/null || /bin/sh"
        exit $LASTEXITCODE
    } else {
        Write-Color "--> ADB doğrudan chroot konsoluna bağlanılıyor...`n" Yellow
        & adb -s $deviceId shell "su -c 'L=/data/local/linux/lib/ld-musl-armhf.so.1; B=/data/local/linux/bin/busybox; R=/data/local/linux; if [ -f `$R/enter.sh ]; then sh `$R/enter.sh; elif [ -f `$R/bin/bash ]; then `$L `$B chroot `$R /bin/bash; else `$L `$B chroot `$R /bin/sh; fi'"
        exit $LASTEXITCODE
    }
}

# 2. Check Wi-Fi IP
if (-not $targetIp) {
    $sshConfig = Join-Path $env:USERPROFILE ".ssh\config"
    if (Test-Path $sshConfig) {
        $content = Get-Content $sshConfig -Raw
        $ipMatch = [regex]::Match($content, "(?s)Host my-tablet-server.*?HostName\s+([0-9.]+)")
        if ($ipMatch.Success) {
            $targetIp = $ipMatch.Groups[1].Value.Trim()
        }
    }
}

if ($targetIp) {
    Write-Color "✓ Wi-Fi IP tespit edildi: $targetIp" Green
    Write-Color "--> Canlı konsola bağlanılıyor (Wi-Fi SSH)...`n" Blue
    & ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -t "root@$targetIp" "console 2>/dev/null || tmux attach -t console 2>/dev/null || /bin/bash 2>/dev/null || /bin/sh"
    exit $LASTEXITCODE
}

# 3. No connection found
Write-Color "[UYARI] Tablet bağlantısı bulunamadı!" Red
Write-Host "Lütfen aşağıdakilerden birini yapın:"
Write-Host "  1. USB Kablosu: Tableti USB ile bilgisayara bağlayın (USB Hata Ayıklama açık olmalı)." -ForegroundColor Yellow
Write-Host "  2. Wi-Fi Bağlantısı: Tableti PC ile aynı Wi-Fi ağına bağlayın." -ForegroundColor Yellow
Write-Host "  3. Manuel IP: powershell -File bin\tablet-terminal.ps1 <TABLET_IP>" -ForegroundColor Yellow
Write-Color "======================================================" Cyan
exit 1
