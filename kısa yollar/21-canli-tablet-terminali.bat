@echo off
chcp 65001 >nul
title Canlı Tablet Terminali (SSH)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\bin\tablet.ps1" terminal
