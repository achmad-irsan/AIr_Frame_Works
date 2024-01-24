# Menarik keterangan info rilis
$response = Invoke-WebRequest -Uri https://api.github.com/repos/achmad-irsan/AIr_Frame_Works/releases/latest
$InfoRilis = $response.Content | ConvertFrom-Json

# Nama software menggunakan variabel $InfoRilis.name
# Tag versi software dalam format "0.0.0" menggunakan variabel $InfoRilis.tag_name
# Dalam format "dd/mm/yyyy hh:mn:ss" tergantung pengaturan region di sistem lokal, namun posisi string yyyy biasanya tetap (baik untuk format INA maupun Eng-USA) menggunakan variabel $InfoRilis.published_at

# Nama Pengembang
$PengembangSoftware = "Achmad Irsan"
# Memecah string berdasarkan '/' dan ' '
$WaktuRilis = $InfoRilis.published_at -split '[/ ]'
# Seleksi string tanggal dan tahun
$TanggalRilis = $WaktuRilis[0..2] -join '/'
$TahunRilis = $WaktuRilis[2]

# Lisensi Software
Write-Host " "
Write-Host "Nama pengembang : " $PengembangSoftware
Write-Host "Nama            : " $InfoRilis.name
Write-Host "Versi           : " $InfoRilis.tag_name
Write-Host "Tanggal rilis   : " $TanggalRilis
Write-Host "Deskripsi       : "
$InfoRilis.body
Write-Host "
"

Write-Host "MIT License
Copyright (c) [$TahunRilis] [$PengembangSoftware]

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
"


#======================================================================
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
    py -3.11 -m venv venv

    .\venv\Scripts\activate

    python -m pip install pip --upgrade

    pip install --upgrade setuptools wheel

    pip install -r requirements.txt
}


#======================================================================
# Pesan yang perlu dicermati:
Read-Host "
    !! Jika anda memiliki lingkungan virtual python yang terinstall sebelumnya,
    maka silahkan untuk menghapusnya terlebih dahulu.
    Tekan Enter untuk melanjutkan...
    "

Read-Host "
    !! jika saat pengecekan, Python versi $TargetVersiPython tidak ditemukan pada sistem global anda,
    maka saat anda memilih akan menginstall Python nantinya,
    anda akan diminta untuk menerima pilihan 'Run as administrator'
    agar installasi Python bisa dilanjutkan,
    Tekan Enter untuk melanjutkan...
    "


#======================================================================
# Cek apakah versi Python yang diinginkan sudah terinstal
$PythonTerinstall = py -0 | Out-String

if ($PythonTerinstall -like "*$TargetVersiPython*") {
    Write-Host "Selamat, Python $TargetVersiPython sudah terinstall pada system global anda, kita lanjutkan menginstall lingkungan virtual. Mohon tunggu beberapa saat hingga proses selesai ...
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
.\venv\Scripts\activate

#======================================================================
Write-Host "
Anda dapat menjalankan perintah: python --version
di terminal ini untuk memeriksa apakah versi python $TargetVersiPython terinstall pada lingkungan virtual)

"

Write-Host "
Berikut daftar independensi/ pustaka/ framework yang berhasil diinstall pada lingkungan virtual python anda
"
pip list

Read-Host "

Selanjutnya kita akan mempersiapkan server web berbasiskan Django Framework
Tekan Enter untuk melanjutkan...

"


#======================================================================
# Membuat proyek Django
django-admin startproject air .

# Menyalin templates konfigurasi proyek (air)
Copy-Item -Path "$PathInduk\.etc\*" -Destination "$PathInduk\air" -Recurse -Force

python manage.py collectstatic --noinput
python manage.py makemigrations --noinput
python manage.py migrate --noinput


# Test server Django
$InputUser = Read-Host "

Pilih Y untuk test server Django anda "
if ($InputUser.ToLower() -eq 'y') {
    Start-Job -ScriptBlock { python manage.py runserver }
    Start-Sleep -Seconds 5
    Start-Process "http://127.0.0.1:8000"
}


#======================================================================
Write-Host "

Selamat, anda sukses melakukan pengaturan lingkungan web apps anda...
Selamat bekerja dan jangan lupa bahagia
salam sukses
AIrsan."
Read-Host "
Tekan Enter untuk keluar..."






