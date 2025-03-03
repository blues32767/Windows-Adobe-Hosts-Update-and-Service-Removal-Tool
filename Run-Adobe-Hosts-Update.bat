@echo off
powershell -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-ExecutionPolicy Bypass -File \"%~dp0Update-Hosts-adobe.ps1\"' -Verb RunAs}"
pause
