<#
==============================================================================
My Tablet Server - Windows Wi-Fi Auto-Synchronizer
Automatically mirrors Windows Wi-Fi network credentials to the tablet via ADB
and updates %USERPROFILE%\.ssh\config with the tablet's live IP address.
==============================================================================
#>

$ErrorActionPreference = "SilentlyContinue"

# 1. Verify ADB Device
$dev = (adb devices 2>$null | Select-String -Pattern "device$" | ForEach-Object { $_.Line.Split("`t")[0].Trim() })
if (-not $dev) {
    exit 0
}

# 2. Extract Active Wi-Fi SSID from netsh wlan
$wlanOutput = netsh wlan show interfaces
$ssidMatch = ($wlanOutput | Select-String -Pattern '^\s*SSID\s*:\s*(.*)$')
if (-not $ssidMatch -or -not $ssidMatch.Matches) {
    exit 0
}
$ssid = $ssidMatch.Matches.Groups[1].Value.Trim()
if (-not $ssid) {
    exit 0
}

# 3. Extract Wi-Fi Profile Details (Auth & Password)
$profileOutput = netsh wlan show profile name="$ssid" key=clear
$authMatch = ($profileOutput | Select-String -Pattern '^\s*Authentication\s*:\s*(.*)$')
$auth = ""
if ($authMatch -and $authMatch.Matches) {
    $auth = $authMatch.Matches.Groups[1].Value.Trim()
}

$keyMatch = ($profileOutput | Select-String -Pattern '^\s*Key Content\s*:\s*(.*)$')
$psk = ""
if ($keyMatch -and $keyMatch.Matches) {
    $psk = $keyMatch.Matches.Groups[1].Value.Trim()
}

$keyMgmt = "NONE"
if ($auth -match "WPA|WPA2" -or $psk) {
    $keyMgmt = "WPA-PSK"
}

# 4. Check if tablet is already connected to this SSID
$currentTabletSsid = (adb shell "su -c 'dumpsys wifi | grep \"state: CONNECTED\"'" 2>$null) | Select-String -Pattern 'extra: "([^"]+)"'
$connectedSsid = ""
if ($currentTabletSsid -and $currentTabletSsid.Matches) {
    $connectedSsid = $currentTabletSsid.Matches.Groups[1].Value.Trim()
}

$needReload = $false

if ($connectedSsid -ne $ssid) {
    Write-Host "[Wi-Fi Sync] PC is on '$ssid'. Syncing Wi-Fi credentials to tablet..."

    $tabletConf = (adb shell "su -c 'cat /data/misc/wifi/wpa_supplicant.conf'" 2>$null) -join "`n"

    if ($tabletConf) {
        $escapedSsid = [regex]::Escape($ssid)
        $pattern = "network=\{[^{}]*?ssid=`"$escapedSsid`"[^{}]*?\}"

        if ($keyMgmt -eq "WPA-PSK") {
            $newBlock = "network={`n`tssid=`"$ssid`"`n`tpsk=`"$psk`"`n`tkey_mgmt=WPA-PSK`n`tpriority=10`n}"
        } else {
            $newBlock = "network={`n`tssid=`"$ssid`"`n`tkey_mgmt=NONE`n`tpriority=10`n}"
        }

        if ($tabletConf -match $pattern) {
            $updatedConf = [regex]::Replace($tabletConf, $pattern, $newBlock, [System.Text.RegularExpressions.RegexOptions]::Singleline)
        } else {
            $updatedConf = $tabletConf.TrimEnd() + "`n`n" + $newBlock + "`n"
        }

        $tmpFile = Join-Path $env:TEMP "tablet_wpa_sync.conf"
        [System.IO.File]::WriteAllText($tmpFile, $updatedConf, [System.Text.Encoding]::ASCII)
        adb push $tmpFile /data/local/tmp/wpa_supplicant.conf > $null 2>&1
        Remove-Item -Force $tmpFile 2>$null

        adb shell "su -c 'cp /data/local/tmp/wpa_supplicant.conf /data/misc/wifi/wpa_supplicant.conf && chown wifi:wifi /data/misc/wifi/wpa_supplicant.conf && chmod 660 /data/misc/wifi/wpa_supplicant.conf && rm /data/local/tmp/wpa_supplicant.conf && svc wifi disable && sleep 1 && svc wifi enable'" > $null 2>&1
        $needReload = $true
    }
}

if ($needReload) {
    Start-Sleep -Seconds 4
}

# 5. Retrieve Tablet IP and Update Windows %USERPROFILE%\.ssh\config
$ipMatch = (adb shell "su -c 'ip -4 addr show wlan0 2>/dev/null || ifconfig wlan0 2>/dev/null'" 2>$null) | Select-String -Pattern "inet\s+([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)"
$tabletIp = ""
if ($ipMatch -and $ipMatch.Matches) {
    $tabletIp = $ipMatch.Matches.Groups[1].Value.Trim()
}

if ($tabletIp) {
    $sshDir = Join-Path $env:USERPROFILE ".ssh"
    if (-not (Test-Path $sshDir)) { New-Item -ItemType Directory -Path $sshDir | Out-Null }
    $sshConfig = Join-Path $sshDir "config"

    if (Test-Path $sshConfig) {
        $content = Get-Content $sshConfig -Raw
        if ($content -match "Host my-tablet-server") {
            $content = [regex]::Replace($content, "(?s)(Host my-tablet-server.*?HostName\s+)[0-9.]+", "`${1}$tabletIp")
            [System.IO.File]::WriteAllText($sshConfig, $content, [System.Text.Encoding]::UTF8)
        } else {
            $entry = "`nHost my-tablet-server`n    HostName $tabletIp`n    User root`n    Port 22`n"
            Add-Content -Path $sshConfig -Value $entry
        }
    } else {
        $entry = "Host my-tablet-server`n    HostName $tabletIp`n    User root`n    Port 22`n"
        [System.IO.File]::WriteAllText($sshConfig, $entry, [System.Text.Encoding]::UTF8)
    }
    Write-Host "[Wi-Fi Sync] Tablet connected to '$ssid' with IP: $tabletIp"
}
