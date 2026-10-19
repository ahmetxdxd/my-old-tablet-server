@echo off
powershell.exe -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\bin\tablet.ps1" run my-tablet-server android
