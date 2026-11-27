@echo off
:: Run this as Administrator (right-click > Run as administrator)
:: Keep Fix-ICS.ps1 in the same folder as this file.

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Please right-click this file and choose "Run as administrator".
    pause
    exit /b
)

if not exist "C:\Scripts" mkdir "C:\Scripts"
copy /Y "%~dp0Fix-ICS.ps1" "C:\Scripts\Fix-ICS.ps1"

schtasks /create /tn "Fix ICS Sharing" ^
  /tr "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File C:\Scripts\Fix-ICS.ps1" ^
  /sc onstart /delay 0001:00 /ru SYSTEM /rl HIGHEST /f

echo.
echo Installed. The script will run 1 minute after every startup.
echo To test now:  schtasks /run /tn "Fix ICS Sharing"
echo Log file:     C:\Scripts\Fix-ICS.log
pause
