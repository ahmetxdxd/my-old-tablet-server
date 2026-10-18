@echo off
chcp 65001 >nul
title My Tablet Server - Auto-Downloader
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0bin\auto-downloader.ps1" %*
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Auto-Downloader exited with error.
)
echo.
pause
