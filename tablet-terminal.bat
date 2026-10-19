@echo off
chcp 65001 >nul
title My Tablet Server - Quick Terminal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0bin\tablet-terminal.ps1" %*
if %errorlevel% neq 0 (
    echo.
    echo [BILGI] Terminal baglantisi sonlandi veya hata alindi.
    pause
)
