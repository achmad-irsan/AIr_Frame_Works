# 1. Tentukan image dasar
# alpine adalah versi ringan dengan ukuran image jauh lebih kecil
FROM python:3.11.7-alpine3.19

# 2. Set working directory di dalam container
WORKDIR /app/backend

# 3. Upgrade pip
RUN python -m pip install pip --upgrade
RUN pip install --upgrade setuptools

# 4. Salin file requirements.txt ke dalam container
COPY requirements.txt /app/backend

# 5. Install dependencies Python
RUN pip install --no-cache-dir --default-timeout=120 -r requirements.txt

# 6. Salin sisa kode sumber aplikasi ke dalam container
COPY . /app/backend

# 7. Atur variabel lingkungan
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# 8. Ekspose port di mana Django akan berjalan
EXPOSE 8000

# 9. Tentukan perintah untuk menjalankan aplikasi secara berurutan, dengan dipisahkan wajib menggunakan tanda "" pada CMD
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]