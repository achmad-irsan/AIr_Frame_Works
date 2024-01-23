# Menentukan direktori dimana skrip dijalankan
$PathInduk = $PSScriptRoot

# Tentukan versi Python yang diinginkan
$TargetVersiPython = "3.11"

# SETUP PYTHON
function Get-InstallPython {

    # Tentukan URL installer Python
    $UrlInstallerPython = "https://www.python.org/ftp/python/3.11.3/python-3.11.3-amd64.exe"

    # Tentukan lokasi tempat menyimpan file installer
    $PathInstaller = "C:\.temp\python_installer.exe"

    # Buat direktori temp jika belum ada
    if (-not (Test-Path "C:\.temp")) {
    New-Item -ItemType Directory -Path "C:\.temp"
    }
    # Unduh installer
    Invoke-WebRequest -Uri $UrlInstallerPython -OutFile $PathInstaller

    # Jalankan installer
    Start-Process $PathInstaller -ArgumentList '/quiet InstallAllUsers=1 PrependPath=1' -Wait

    # Hapus installer
    Remove-Item -Path "C:\.temp" -Recurse -Force
}

# Pengaturan Lingkungan Virtual Python
function Get-SetupVenv {
    py -3.11 -m venv venvrh311

    .\venvrh311\Scripts\activate

    python -m pip install pip --upgrade

    pip install --upgrade setuptools wheel

    pip install -r requirements.txt
}

# Cek apakah versi Python yang diinginkan sudah terinstal
$PythonTerinstall = py -0 | Out-String

if ($PythonTerinstall -like "*$TargetVersiPython*") {
    Write-Host "Python $TargetVersiPython sudah terinstall pada system global anda, kita lanjutkan menginstall lingkungan virtual. Mohon tunggu beberapa saat hingga proses selesai ...
     "

}
else
{
    $PesanSistem = Read-Host "Sistem global anda belum memiliki python versi $TargetVersiPython, Apakah anda mau melanjutkan instalasi python versi tersebut? (Y/N)"
    if ($PesanSistem.ToLower() -eq 'y') {

        # Melakukan instalasi Python
        Get-InstallPython

        Write-Host "Python $TargetVersiPython sudah terinstall pada system global anda, kita lanjutkan menginstall lingkungan virtual. Mohon tunggu beberapa saat hingga proses selesai ...
        "
    }
    else
    {
        Write-Host "Silahkan menginstall versi python $TargetVersiPython pada sistem global anda, secara manual dan dilanjutkan dengan pengaturan lingkungan virtual."
		Read-Host "Tekan Enter untuk keluar..."
        exit
    }
}

# Setup venv
Get-SetupVenv

# Mengaktifkan lingkungan virtual
.\venvrh311\Scripts\activate

Write-Host "

Selamat, lingkungan virtual anda sudah teraktivasi dan siap digunakan !!
Selamat bekerja dan jangan lupa bahagia
salam sukses
AIrsan.
"
Read-Host "Tekan enter untuk melanjutkan"






