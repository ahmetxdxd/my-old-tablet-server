@echo off
chcp 65001 >nul
title CAVA Audio Visualizer
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\bin\tablet.ps1" cava
