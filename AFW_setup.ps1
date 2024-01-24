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
Write-Host "Deskripsi       : " $InfoRilis.body
Write-Host "
"

Write-Host "MIT License
Copyright (c) [$TahunRilis] [$PengembangSoftware]

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
"


$UrlGitHub = "https://github.com/achmad-irsan/AIr_Frame_Works/archive/refs/tags/$($InfoRilis.tag_name).zip"
try {
    # Mengirim permintaan ke URL
    $response = Invoke-WebRequest -Uri $UrlGitHub -Method Head -ErrorAction Stop
    # Jika tidak ada eksepsi dan mendapat respons, maka link aktif
    Write-Host "Link aktif, Status Code: $($response.StatusCode)"
}
catch {
    # Menangkap eksepsi jika permintaan gagal
    Write-Host "Link tidak aktif atau terjadi kesalahan. Detail: $($_.Exception.Message)"
}


#======================================================================
# Cek path temporari untuk menyimpan hasil unduhan atau membuat folder .temp baru
if (-not (Test-Path "C:\.temp")) {
    New-Item -ItemType Directory -Path "C:\.temp" -Force -ErrorAction SilentlyContinue | Out-Null
}

# Menentukan path hasil unduhan dan menunduh dari sumber github
$PathSimpan = "C:\.temp\AIr_Frame_Works-$($InfoRilis.tag_name).zip"
Invoke-WebRequest -Uri $UrlGithub -OutFile $PathSimpan -ErrorAction SilentlyContinue

# Melakukan ekstraksi hasil unduhan
$PathEkstrak = "C:\.temp"
Expand-Archive -LiteralPath $PathSimpan -DestinationPath $PathEkstrak -Force


#======================================================================
# Menentukan path sumber ikon dari hasil ekstraksi
$PathIcon = "C:\.temp\AIr_Frame_Works-$($InfoRilis.tag_name)\etc\.airicon"
# Menentukan path untuk menyimpan folder ikon .airicon
$PathSalinIcon = "C:\Users\Public"
# Salin folder .airicon dari path hasil ekstraksi ke direktori penyimpanan baru
Copy-Item -Path $PathIcon -Destination $PathSalinIcon -Recurse -Force


#======================================================================
# Fungsi untuk memvalidasi nama proyek
function Get-ValidasiInput($InisialProyek) {
    return $InisialProyek -match '^[A-Z0-9]{4}$'
}

# Meminta inisialProyek dari pengguna
$InisialProyek = Read-Host "
Silahkan memasukkan 4 digit untuk inisial nama Proyek (XXXX)"

# Cek validitas inisialProyek
while (-not (Get-ValidasiInput $InisialProyek)) {
    Write-Host "
    !! Maaf, input tidak valid.
    Pastikan Anda memasukkan 4 digit dengan format kombinasi angka-huruf kapital
    atau huruf kapital.
    "
    $InisialProyek = Read-Host "Silahkan memasukkan kembali 4 digit untuk inisial nama Proyek (XXXX)"
}

# Nama direktori
$NamaDir = "Project_$inisialProyek"
$PathProyek = Join-Path -Path $PWD.Path -ChildPath $NamaDir

# Cek apakah direktori sudah ada
if (Test-Path $PathProyek) {
    $ResponUser = Read-Host "
    !! Direktori '$NamaDir' sudah ada. Anda ingin menghapusnya?
    Perhatian: Menghapus Direktori '$NamaDir' yang sudah ada sebelumnya
    berarti akan menghapus keseluruhan isi folder didalamnya.
    Apakah anda sudah yakin? (Y/N)"
    if ($ResponUser.ToLower() -eq 'y') {
        Remove-Item -Path $PathProyek -Recurse -Force
        New-Item -ItemType Directory -Path $PathProyek -Force -ErrorAction SilentlyContinue | Out-Null
        Write-Host "
Direktori baru '$NamaDir' telah dibuat di lokasi:
$PathProyek
        "
    } else {
        Write-Host "
Akan dilanjutkan menggunakan direktori yang sudah ada di lokasi:
$PathProyek
        "
    }
} else {
    New-Item -ItemType Directory -Path $PathProyek -Force -ErrorAction SilentlyContinue | Out-Null
    Write-Host "
Direktori baru '$NamaDir' telah dibuat di lokasi: $PathProyek
    "
}


#======================================================================
# Fungsi untuk mendapatkan pilihan domain dari pengguna
function Get-PilihanDomain {
    do {
        $InputUser = Read-Host "Berikutnya, silahkan menentukan Subdomain kerja sesuai penugasan dengan memasukkan minimal salah satu atau beberapa nomor (pisahkan dengan koma untuk pilihan beberapa nomor, contoh : 1,2,3 dst):
    1. Subdomain Konsep
    2. Subdomain Perencanaan
    3. Subdomain Perancangan
    4. Subdomain Simulasi
    5. Subdomain Aplikasi

    Jawaban anda"
        Write-Host " "

        # Memisahkan input pengguna dan mengonversinya menjadi array
        $PilihanDomain = $InputUser.Split(',') |
            Where-Object { $_ -ne '' } |
            ForEach-Object { [int]$_ }

        # Cek apakah ada pilihan yang valid
        $PilihanValid = $PilihanDomain |
                Where-Object { $_ -ge 1 -and $_ -le 5 }

        # Cek apakah ada pilihan yang tidak valid
        $PilihanTidakValid = $PilihanDomain |
            Where-Object { $_ -lt 1 -or $_ -gt 5 }

        # Cek duplikasi
        $Duplikasi = $PilihanDomain |
                Group-Object |
                Where-Object { $_.Count -gt 1 }

        $DuplikatNomor = $Duplikasi |
                ForEach-Object { $_.Name }

        # Sorting duplikasi pilihan tidak valid dan mengeleminasinya
        $PilihanTidakValidUnik = $PilihanTidakValid |
                sort-Object -Unique


        # User memberikan pilihan valid, tidak valid, dan terdapat duplikasi
        if ($PilihanValid.length -gt 0 -and
                $PilihanTidakValid.Length -gt 0 -and $DuplikatNomor) {
            Write-Host "
            !! Maaf, terdapat pilihan yang tidak valid dan duplikasi.
            Pilihan yang tidak valid: $($PilihanTidakValidUnik -join ', '),
            dan pilihan duplikat: $($DuplikatNomor -join ', ').
            Silahkan kembali memilih Subdomain kerja anda sesuai daftar yang tersedia
            "
            continue
        }

        # User tidak memilih apapun (kosong)
        if ($PilihanValid.Length -eq 0 -and $PilihanTidakValid.Length -eq 0) {
            Write-Host "
            !! Maaf, anda belum melakukan pilihan,
            silahkan kembali memilih Subdomain kerja anda sesuai daftar yang tersedia
            "
            continue
        }

        # User memberikan pilihan tunggal, namun tidak tersedia dalam daftar
        if ($PilihanTidakValid.Length -eq 1 -and $PilihanDomain.Length -eq 1) {
            Write-Host "
            !! Maaf, pilihan anda nomor: $PilihanTidakValid tidak tersedia di dalam daftar,
            silahkan kembali memilih Subdomain kerja anda sesuai daftar yang tersedia
            "
            continue
        }

        # User memberikan pilihan jamak, namun terdapat pilihan yang tidak sesuai daftar
        if ($PilihanTidakValid.Length -gt 0) {
            Write-Host "
            !! Maaf, silahkan memilih kembali,
            terdapat pilihan yang tidak valid yaitu nomor: $($PilihanTidakValid -join ', ')
            "
            continue
        }

        # User memberikan pilihan yang valid, namun terdapat duplikasi, sehingga jumlah pilihan melebihi 5
        if ($PilihanValid.Length -gt 5) {
            Write-Host "
            !! Maaf, terdapat duplikasi pilihan, yaitu pilihan nomor: $($DuplikatNomor -join ', '),
            silahkan memilih kembali Subdomain kerja anda sesuai daftar yang tersedia
            "
            continue
        }

        # User memberikan pilihan valid, namun terdapat duplikasi
         if ($Duplikasi) {
             Write-Host "
             !! Maaf, terdapat duplikasi pilihan, yaitu pilihan nomor: $($DuplikatNomor -join ', '),
             silahkan memilih kembali Subdomain kerja anda sesuai daftar yang tersedia
             "
             continue
         }

        return $PilihanDomain

    } while ($true)
}

# Menyimpan hasil pilihan akhir
$HasilPilihan = Get-PilihanDomain

# Menampilkan pesan berdasarkan pilihan
Write-Host "
Anda memilih:"
foreach ($Pilihan in $HasilPilihan) {
    switch ($Pilihan) {
        "1" { Write-Host "Subdomain Konsep" }
        "2" { Write-Host "Subdomain Perencanaan" }
        "3" { Write-Host "Subdomain Perancangan" }
        "4" { Write-Host "Subdomain Simulasi" }
        "5" { Write-Host "Subdomain Aplikasi" }
    }
}

Write-Host "
Terimakasih, kita lanjutkan pengaturan direktori kerja"


#======================================================================
# Sumber folder hasil ekstraksi di C:\.temp\
$SumberDirektori = "C:\.temp\AIr_Frame_Works-$($InfoRilis.tag_name)"

# Mapping folder
$MappingDir = @{
    1 = "A_Konsep";
    2 = "B_Perencanaan";
    3 = "C_Perancangan";
    4 = "D_Simulasi";
    5 = "E_Aplikasi";
}

# Selalu menyalin folder 'etc'
Copy-Item -Path "$SumberDirektori\etc" -Destination $PathProyek -Recurse -Force

# Selalu menyalin file dekstop.ini
Copy-Item -Path "$SumberDirektori\desktop.ini" -Destination $PathProyek -Recurse -Force

# Menyalin direktori sesuai pilihan subdomain kerja
foreach ($Pilihan in $HasilPilihan) {
    $DirSalinan = $MappingDir[$Pilihan]
    if (Test-Path "$SumberDirektori\$DirSalinan") {
        Copy-Item -Path "$SumberDirektori\$DirSalinan" -Destination $PathProyek -Recurse -Force
        Write-Host "Direktori $DirSalinan telah disiapkan."
    }
}

# Pengaturan file .gitignore
# Mengganti nama .gitignore.bak menjadi .gitignore
Rename-Item -Path "$SumberDirektori\E_Aplikasi\WebApps\01_Pengembangan\.gitignore.bak" -NewName ".gitignore"

# Memindahkan .gitignore ke lokasi baru
Move-Item -Path "$SumberDirektori\E_Aplikasi\WebApps\01_Pengembangan\.gitignore" -Destination "$PathProyek\E_Aplikasi\WebApps\01_Pengembangan\.gitignore"

# Menghapus file .gitignore.bak yang ada di lokasi tujuan, jika ada
if (Test-Path "$PathProyek\E_Aplikasi\WebApps\01_Pengembangan\.gitignore.bak") {
    Remove-Item -Path "$PathProyek\E_Aplikasi\WebApps\01_Pengembangan\.gitignore.bak"
}


Write-Host "
Berikut susunan direktori kerja anda:"

cd .\$NamaDir
ls


#======================================================================
# Menentukan lokasi root dari struktur folder Anda berdasarkan lokasi script PowerShell
$PathInduk = $PSScriptRoot

# Lokasi penyimpanan ikon di sistem lokal
$PathSumberIcon = "$PathSalinIcon\.airicon"

# Mendefinisikan nama folder dan ikon yang sesuai
$DirIcon = @{
    "Project_$inisialProyek" = Join-Path $PathSumberIcon "AIr_Logo_01.ico"
    "01_Diproses" = Join-Path $PathSumberIcon "DC_Diproses_01.ico"
    "02_Dibagikan" = Join-Path $PathSumberIcon "DC_Dibagikan_01.ico"
    "03_Diarsipkan" = Join-Path $PathSumberIcon "DC_Diarsipkan_01.ico"
    "04_Diterbitkan" = Join-Path $PathSumberIcon "DC_Diterbitkan_01.ico"
    "01_Pengembangan" = Join-Path $PathSumberIcon "WB_Pengembangan_01.ico"
    "02_Pengujian" = Join-Path $PathSumberIcon "WB_Pengujian_01.ico"
    "03_Pengarsipan" = Join-Path $PathSumberIcon "WB_Pengarsipan_01.ico"
    "04_Produksi" = Join-Path $PathSumberIcon "WB_Produksi_01.ico"
}

# Fungsi untuk mengganti ikon folder
function Set-FolderIcon {
    param (
        [string]$PathDirKerja,
        [string]$PathIconKerja
    )
    $PathDesktopIni = Join-Path $PathDirKerja "desktop.ini"

    # Mengatur atribut folder dan file desktop.ini
    Set-ItemProperty -Path $PathDirKerja -Name Attributes -Value "ReadOnly"
    if (Test-Path $PathDesktopIni) {
        Set-ItemProperty -Path $PathDesktopIni -Name Attributes -Value "Normal"
    }

    # Pengaturan skrip desktop.ini
    "[.ShellClassInfo]" > $PathDesktopIni
    "IconResource=$PathIconKerja,0" >> $PathDesktopIni

    # Mengatur kembali atribut file desktop.ini
    Set-ItemProperty -Path $PathDesktopIni -Name Attributes -Value "Hidden,System"
    Set-ItemProperty -Path $PathDirKerja -Name Attributes -Value "ReadOnly,System"
}

# Melakukan pencarian folder dan mengganti ikon
foreach ($NamaFolder in $DirIcon.Keys) {
    $PathIconKerja = $DirIcon[$NamaFolder]
    $folders = Get-ChildItem -Path $PathInduk -Recurse -Directory -Filter $NamaFolder
    foreach ($folder in $folders) {
        Set-FolderIcon -PathDirKerja $folder.FullName -PathIconKerja $PathIconKerja
    }
}

# Opsional: Restart Windows Explorer untuk melihat perubahan
#Stop-Process -Name explorer -Force
#Start-Process explorer


#======================================================================
# Menghapus folder temporari (sementara)
Remove-Item -Path "C:\.temp" -Recurse -Force

# Membuat log


#======================================================================
Write-Host "
Selamat, anda sukses melakukan pengaturan direktori kerja...
Selamat bekerja dan jangan lupa bahagia
salam sukses
AIrsan."
Read-Host "
Tekan Enter untuk keluar..."