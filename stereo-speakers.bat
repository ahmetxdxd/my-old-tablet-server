@echo off
chcp 65001 >nul
title My Tablet Server - Stereo Speakers & CAVA
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0bin\stereo-speakers.ps1" %*
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Stereo-Speakers script exited with error.
)
echo.
pause
