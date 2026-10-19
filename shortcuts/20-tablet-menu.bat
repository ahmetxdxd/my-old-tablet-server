@echo off
chcp 65001 >nul
title 🎛️ Quick Control Menu
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\bin\tablet.ps1" menu
