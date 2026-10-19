@echo off
chcp 65001 >nul
title 💻 Live Tablet Terminal (SSH)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\bin\tablet.ps1" terminal
