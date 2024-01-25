@echo off
setlocal

REM -- Cek apakah PowerShell 7 sudah terinstal
pwsh -Version >nul 2>&1
if %errorlevel% == 0 (
    echo PowerShell 7 sudah terinstal, anda bisa menjalankan proses selanjutnya
    REM -- pwsh.exe
    powershell.exe -ExecutionPolicy Bypass -NoExit -File ".\run_server.ps1"
    goto end
) else (
    echo PowerShell 7 tidak ditemukan. Anda masih bisa melanjutkan proses ini dengan Windows PowerShell standar,
    echo namun disarankan menginstal PowerShell 7 untuk mendapatkan pengalaman lebih baik.
    echo Silahkan mengunduhnya di laman ini:
    echo https://github.com/PowerShell/PowerShell/releases
    powershell.exe -ExecutionPolicy Bypass -NoExit -File ".\run_server.ps1"
)

:end
endlocal