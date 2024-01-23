# Cek path temporari untuk menyimpan hasil unduhan
if (-not (Test-Path "C:\.temp")) {
    New-Item -ItemType Directory -Path "C:\.temp"
}

# Unduh sistem direktori dari github
$UrlGithub = "https://github.com/achmad-irsan/TPL_Project_Setup/archive/refs/heads/main.zip"
$PathSimpan = "C:\.temp\TPL_Project_Setup.zip"

Invoke-WebRequest -Uri $UrlGithub -OutFile $PathSimpan

# Melakukan ekstraksi hasil unduhan
$PathEkstrak = "C:\.temp"
Expand-Archive -LiteralPath $PathSimpan -DestinationPath $PathEkstrak -Force

# Path sumber folder .airicon
$PathIcon = "C:\.temp\TPL_Project_Setup-main\etc\.airicon"

# Path tujuan ke direktori home user
$PathSalinIcon = "C:\Users\Public"

# Salin folder .airicon ke direktori home user
Copy-Item -Path $PathIcon -Destination $PathSalinIcon -Recurse -Force


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
    Pastikan Anda memasukkan 4 digit dengan format kombinasi angka-huruf kapital atau huruf kapital.
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
        New-Item -ItemType Directory -Path $PathProyek
        Write-Host "
Direktori baru '$NamaDir' telah dibuat di lokasi: $PathProyek
        "
    } else {
        Write-Host "
Menggunakan direktori yang sudah ada di lokasi: $PathProyek
        "
    }
} else {
    New-Item -ItemType Directory -Path $PathProyek
    Write-Host "
Direktori baru '$NamaDir' telah dibuat di lokasi: $PathProyek
    "
}
#================================================================================

# Fungsi untuk mendapatkan pilihan domain dari pengguna
function Get-PilihanDomain {
    do {
        $InputUser = Read-Host "Berikutnya, silahkan menentukan domain kerja sesuai penugasan dengan memasukkan minimal salah satu atau beberapa nomor (pisahkan dengan koma untuk pilihan beberapa nomor, contoh : 1,2,3 dst):
    1. Domain Konsep
    2. Domain Perencanaan
    3. Domain Perancangan
    4. Domain Simulasi
    5. Domain Aplikasi
    "

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
            Silahkan kembali memilih domain kerja anda sesuai daftar yang tersedia
            "
            continue
        }

        # User tidak memilih apapun (kosong)
        if ($PilihanValid.Length -eq 0 -and $PilihanTidakValid.Length -eq 0) {
            Write-Host "
            !! Maaf, anda belum melakukan pilihan,
            silahkan kembali memilih domain kerja anda sesuai daftar yang tersedia
            "
            continue
        }

        # User memberikan pilihan tunggal, namun tidak tersedia dalam daftar
        if ($PilihanTidakValid.Length -eq 1 -and $PilihanDomain.Length -eq 1) {
            Write-Host "
            !! Maaf, pilihan anda nomor: $PilihanTidakValid tidak tersedia di dalam daftar,
            silahkan kembali memilih domain kerja anda sesuai daftar yang tersedia
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
            silahkan memilih kembali domain kerja anda sesuai daftar yang tersedia
            "
            continue
        }

        # User memberikan pilihan valid, namun terdapat duplikasi
         if ($Duplikasi) {
             Write-Host "
             !! Maaf, terdapat duplikasi pilihan, yaitu pilihan nomor: $($DuplikatNomor -join ', '),
             silahkan memilih kembali domain kerja anda sesuai daftar yang tersedia
             "
             continue
         }

        return $PilihanDomain

    } while ($true)
}

# Menyimpan hasil pilihan akhir
$HasilPilihan = Get-PilihanDomain

# Menampilkan pesan berdasarkan pilihan
Write-Host
"Anda memilih:"
foreach ($Pilihan in $HasilPilihan) {
    switch ($Pilihan) {
        "1" { Write-Host "Domain Konsep" }
        "2" { Write-Host "Domain Perencanaan" }
        "3" { Write-Host "Domain Perancangan" }
        "4" { Write-Host "Domain Simulasi" }
        "5" { Write-Host "Domain Aplikasi" }
    }
}

Write-Host "
Terimakasih, kita lanjutkan pengaturan direktori kerja"

# Mapping folder
$MappingDir = @{
    1 = "A_Konsep";
    2 = "B_Perencanaan";
    3 = "C_Perancangan";
    4 = "D_Simulasi";
    5 = "E_Aplikasi";
}

# Sumber folder hasil ekstraksi di C:\.temp\
$SumberDirektori = "C:\.temp\TPL_Project_Setup-main"

# Selalu pindahkan folder 'etc'
Copy-Item -Path "$SumberDirektori\etc" -Destination $PathProyek -Recurse -Force

# Selalu pindahkan file dekstop.ini
Copy-Item -Path "$SumberDirektori\desktop.ini" -Destination $PathProyek -Recurse -Force

foreach ($Pilihan in $HasilPilihan) {
    $DirDikopi = $MappingDir[$Pilihan]
    if (Test-Path "$SumberDirektori\$DirDikopi") {
        Copy-Item -Path "$SumberDirektori\$DirDikopi" -Destination $PathProyek -Recurse -Force
        Write-Host "Direktori $DirDikopi telah disiapkan."
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

Remove-Item -Path "C:\.temp" -Recurse -Force

# Merubah icon direktori
# Lokasi root dari struktur folder Anda berdasarkan lokasi script PowerShell
$PathInduk = $PSScriptRoot

# Lokasi penyimpanan ikon
$PathSumberIcon = "C:\Users\Public\.airicon"

# Mendefinisikan nama folder dan ikon yang sesuai
$DirIcon = @{
    "Project_$inisialProyek" = Join-Path $PathSumberIcon "air_01.ico"
    "01_Diproses" = Join-Path $PathSumberIcon "01.ico"
    "02_Dibagikan" = Join-Path $PathSumberIcon "02.ico"
    "03_Diarsipkan" = Join-Path $PathSumberIcon "03.ico"
    "04_Diterbitkan" = Join-Path $PathSumberIcon "04.ico"
    "01_Pengembangan" = Join-Path $PathSumberIcon "01.ico"
    "02_Pengujian" = Join-Path $PathSumberIcon "02.ico"
    "03_Pengarsipan" = Join-Path $PathSumberIcon "03.ico"
    "04_Produksi" = Join-Path $PathSumberIcon "04.ico"
}

# Fungsi untuk mengganti ikon folder
function Set-FolderIcon {
    param (
        [string]$PathDirKerja,
        [string]$PathIconKerja
    )
    $desktopIniPath = Join-Path $PathDirKerja "desktop.ini"

    # Mengatur atribut folder dan file desktop.ini
    Set-ItemProperty -Path $PathDirKerja -Name Attributes -Value "ReadOnly"
    if (Test-Path $desktopIniPath) {
        Set-ItemProperty -Path $desktopIniPath -Name Attributes -Value "Normal"
    }

    # Membuat atau mengedit isi desktop.ini
    "[.ShellClassInfo]" > $desktopIniPath
    "IconResource=$PathIconKerja,0" >> $desktopIniPath

    # Mengatur kembali atribut file desktop.ini
    Set-ItemProperty -Path $desktopIniPath -Name Attributes -Value "Hidden,System"
    Set-ItemProperty -Path $PathDirKerja -Name Attributes -Value "ReadOnly,System"
}

# Melakukan pencarian folder dan mengganti ikon
foreach ($folderName in $DirIcon.Keys) {
    $PathIconKerja = $DirIcon[$folderName]
    $folders = Get-ChildItem -Path $PathInduk -Recurse -Directory -Filter $folderName
    foreach ($folder in $folders) {
        Set-FolderIcon -PathDirKerja $folder.FullName -PathIconKerja $PathIconKerja
    }
}

# Opsional: Restart Windows Explorer untuk melihat perubahan
#Stop-Process -Name explorer -Force
#Start-Process explorer




Write-Host "
Selamat, anda sukses melakukan pengaturan direktori kerja...
Selamat bekerja dan jangan lupa bahagia
salam sukses
AIrsan."
Read-Host "
Tekan Enter untuk keluar..."

