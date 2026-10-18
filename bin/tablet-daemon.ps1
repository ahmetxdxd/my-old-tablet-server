<#
==============================================================================
My Tablet Server - Windows Continuous Background Daemon
1. Keeps ADB Port Forwarding active (2222 -> 22)
2. Monitors Windows Wi-Fi changes and syncs credentials to tablet
3. Dynamically updates %USERPROFILE%\.ssh\config with live tablet IP
==============================================================================
#>

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SyncScript = Join-Path $ScriptDir "sync-wifi.ps1"
$LastSsid = ""

while ($true) {
    $dev = (adb devices 2>$null | Select-String -Pattern "device$" | ForEach-Object { $_.Line.Split("`t")[0].Trim() })

    if ($dev) {
        adb forward tcp:2222 tcp:22 2>$null | Out-Null
        adb forward tcp:22 tcp:22 2>$null | Out-Null

        $wlanOutput = netsh wlan show interfaces 2>$null
        $ssidMatch = ($wlanOutput | Select-String -Pattern '^\s*SSID\s*:\s*(.*)$')
        $currentSsid = ""
        if ($ssidMatch -and $ssidMatch.Matches) {
            $currentSsid = $ssidMatch.Matches.Groups[1].Value.Trim()
        }

        if ($currentSsid -and ($currentSsid -ne $LastSsid)) {
            if (Test-Path $SyncScript) {
                & powershell.exe -ExecutionPolicy Bypass -File $SyncScript | Out-Null
            }
            $LastSsid = $currentSsid
        }
    } else {
        $LastSsid = ""
    }

    Start-Sleep -Seconds 5
}
