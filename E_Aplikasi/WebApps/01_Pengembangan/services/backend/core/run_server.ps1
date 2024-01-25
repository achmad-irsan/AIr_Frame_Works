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
cd $PathInduk
# Mengaktifkan lingkungan virtual
.\venv\Scripts\activate


#======================================================================
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






