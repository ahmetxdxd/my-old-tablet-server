@echo off
chcp 65001 >nul
title Canlı CAVA Ses Spektrumu
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\bin\tablet.ps1" cava
