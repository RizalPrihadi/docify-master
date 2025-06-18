## TATA CARA MENJALANKAN

### Install dependencies
```bash
flutter pub get
```

### Buat environment variables
```bash
cp .env.example .env
```
Isi variabel BACKEND_URL dengan IP dari wifi

### Jalankan aplikasi
```bash
flutter run
```

### Berikut adalah kredensial admin
- email: admin@example.com
- password: password
Dapat diganti di file database/seeders/AdminSeeder.php

### Catatan
- Aplikasi Flutter pada emulator/hp dan aplikasi Laravel pada laptop harus berada di satu jaringan wifi
- Untuk mencari tahu IP dari wifi dapat mejalankan perintah **ipconfig** di CMD/Powershell