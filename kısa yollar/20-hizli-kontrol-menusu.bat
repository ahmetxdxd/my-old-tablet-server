@echo off
chcp 65001 >nul
title Hızlı Kontrol Menüsü
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\bin\tablet.ps1" menu
