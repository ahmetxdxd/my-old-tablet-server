@echo off
chcp 65001 >nul
title My Tablet Server - CLI
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0bin\tablet.ps1" %*
if %errorlevel% neq 0 (
    echo.
    echo [BILGI] Komut tamamlandi.
)
