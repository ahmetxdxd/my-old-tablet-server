@echo off
chcp 65001 >nul
title My Tablet Server - Installer
echo ======================================================================
echo    MY TABLET SERVER - Windows Installer
echo ======================================================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Installation failed or was aborted.
)

echo.
pause
