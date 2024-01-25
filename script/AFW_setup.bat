@echo off
setlocal

REM -- Cek apakah PowerShell 7 sudah terinstal
pwsh -Version >nul 2>&1
if %errorlevel% == 0 (
    echo Start...
    pwsh.exe -ExecutionPolicy Bypass -NoExit -File ".\test.ps1"
    goto end
) else (
    powershell.exe -ExecutionPolicy Bypass -NoExit -File ".\test.ps1"
)

:end
endlocal