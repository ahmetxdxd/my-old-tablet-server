@echo off
powershell.exe -NoProfile -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('İkinci Ekran (Second Screen) oturumu sonlandırıldı.', 'My Tablet Server', 'OK', 'Information')"
