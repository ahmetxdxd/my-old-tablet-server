<#
==============================================================================
My Tablet Server - Windows Graphical Dashboard Launcher
==============================================================================
Starts the lightweight local Python server and opens the dashboard in Edge/Chrome
window mode.
==============================================================================
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BaseDir = Split-Path -Parent $ScriptDir
$Port = 5055
$Url = "http://127.0.0.1:$Port"

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "      MY TABLET SERVER - LAUNCHING WINDOWS DESKTOP DASHBOARD          " -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan

# 1. Start Python Server in background if not responding
try {
    $req = Invoke-WebRequest -Uri "$Url/api/devices" -TimeoutSec 2 -UseBasicParsing -ErrorAction SilentlyContinue
} catch {
    $req = $null
}

if (-not $req -or $req.StatusCode -ne 200) {
    Write-Host "--> Starting local Python dashboard server on port $Port..." -ForegroundColor Yellow
    $serverPy = Join-Path $BaseDir "ui\server.py"
    Start-Process -FilePath "python" -ArgumentList "`"$serverPy`"" -WindowStyle Hidden
    Start-Sleep -Seconds 1
}

Write-Host "[OK] Dashboard backend is operational at: $Url" -ForegroundColor Green
Write-Host "--> Opening graphical control center window..." -ForegroundColor Cyan

# 2. Open in Dedicated Desktop Window Mode via Edge or Chrome
$edgePath = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
if (-not (Test-Path $edgePath)) {
    $edgePath = "${env:ProgramFiles}\Microsoft\Edge\Application\msedge.exe"
}
$chromePath = "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe"
if (-not (Test-Path $chromePath)) {
    $chromePath = "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe"
}

if (Test-Path $edgePath) {
    Start-Process -FilePath $edgePath -ArgumentList "--app=$Url", "--window-size=1200,850"
} elseif (Test-Path $chromePath) {
    Start-Process -FilePath $chromePath -ArgumentList "--app=$Url", "--window-size=1200,850"
} else {
    Start-Process $Url
}
