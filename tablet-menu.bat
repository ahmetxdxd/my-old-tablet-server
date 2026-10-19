@echo off
chcp 65001 >nul
title My Tablet Server - Quick Menu
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0bin\tablet-menu.ps1" %*
if %errorlevel% neq 0 (
    echo.
    echo [BILGI] Menuden cikis yapildi.
)
