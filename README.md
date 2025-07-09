![Flutter](https://img.shields.io/badge/Flutter-Framework-blue?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Backend-orange?logo=firebase)
![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)
![Made in Indonesia](https://img.shields.io/badge/Made%20in-Indonesia-red)

> ✨ Aplikasi mobile modern berbasis **Flutter** dan **Firebase** yang memungkinkan pengguna mencari dan mengelola resep makanan favorit mereka secara real-time.  
> Cocok untuk para pecinta masakan yang ingin menyimpan dan menemukan inspirasi resep dengan mudah.

---
```text
# 🍲 Aplikasi Resep Makanan (Recipe Food Mobile App)

---

```text
## 🚀 Fitur Utama

- 🍛 **Menampilkan berbagai resep makanan**
- 🔍 **Pencarian resep** berdasarkan nama atau kategori
- 🔐 **Login & Register** menggunakan Firebase Authentication
- ☁️ **Simpan data** resep ke Cloud Firestore
- 📷 **Upload gambar resep** ke Firebase Storage
- 📝 **Tambah, edit, dan hapus resep** milik pengguna
- 📱 **Tampilan UI modern & responsif**

---

# Tampilan Antarmuka
<p align="center"> <img src="https://github.com/user-attachments/assets/e271f2e3-aa80-4824-9982-8b3b5dea2e69" width="200"/> <img src="https://github.com/user-attachments/assets/13b4581d-e6cd-4c81-85c8-caf750484adf" width="200"/> <img src="https://github.com/user-attachments/assets/c4871cfc-5989-4cfe-903e-3a27e8c954b0" width="200"/> <img src="https://github.com/user-attachments/assets/36cfd231-273e-4327-b515-64520cbea3e4" width="200"/> <img src="https://github.com/user-attachments/assets/e77f7dc2-303a-4a18-9381-7468b460d252" width="200"/> <img src="https://github.com/user-attachments/assets/a5a450ab-1868-4bc3-b3fc-00bf59df0e62" width="200"/> <img src="https://github.com/user-attachments/assets/e34f31a5-b69d-4c0d-904c-fbcafd01da52" width="200"/> </p>


---

## 🔥 Struktur Firebase

Struktur database dan layanan Firebase yang digunakan pada aplikasi ini mencakup:

- Autentikasi pengguna (Firebase Auth)
- Penyimpanan data resep (Cloud Firestore)
- Penyimpanan gambar (Firebase Storage)
- Koleksi `recipes`, `users`, dan `favorites`

Berikut adalah tampilan dari konfigurasi Firebase pada project ini:

<p align="center">
  <img src="https://github.com/user-attachments/assets/dd8dfb3b-40a6-4df9-9313-b04d7ff1d00f" width="200"/>
  <img src="https://github.com/user-attachments/assets/6b69a6c0-4f5a-45fb-8c5f-75c9de2d5f11" width="300"/>
  <img src="https://github.com/user-attachments/assets/902341a8-0f4f-4479-85ba-3762663d091c" width="300"/>
  <img src="https://github.com/user-attachments/assets/2def1da5-717b-4d32-a027-98305d543260" width="300"/>
  <img src="https://github.com/user-attachments/assets/e7830c57-37a9-4180-b14e-c8c68217a608" width="300"/>
  <img src="https://github.com/user-attachments/assets/6b61febc-926b-43af-ab18-564671ff08a4" width="300"/>
  <img src="https://github.com/user-attachments/assets/16e0a35a-4ec2-4809-88f1-23235d071b70" width="300"/>
  <img src="https://github.com/user-attachments/assets/865d6ffe-7afa-49d7-a664-13aae3bcd350" width="300"/>
</p>

```text
## 🛠️ Teknologi yang Digunakan

| Teknologi            | Keterangan                           |
|----------------------|---------------------------------------|
| **Flutter** (Dart)   | Framework UI cross-platform           |
| **Firebase Auth**    | Autentikasi pengguna                  |
| **Cloud Firestore**  | Database real-time                    |
| **Firebase Storage** | Penyimpanan gambar                    |
| **Provider / Bloc**  | Manajemen state aplikasi              |
| **Material Design 3**| Desain antarmuka modern dan elegan    |

---

## 📁 Struktur Folder

```text
Recipe-Food-Mobile-Develop/
├── android/                 # Proyek Android (native)
├── ios/                    # Proyek iOS (native)
├── lib/                    # Kode utama Flutter
│   ├── models/             # Model data (Recipe, User, dsb.)
│   ├── screens/            # Semua halaman tampilan
│   │   ├── home_screen.dart
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── recipe_detail_screen.dart
│   │   └── add_recipe_screen.dart
│   ├── services/           # Firebase services & logika backend
│   │   ├── auth_service.dart
│   │   ├── recipe_service.dart
│   │   └── storage_service.dart
│   ├── widgets/            # Widget kustom (UI reusable)
│   │   ├── recipe_card.dart
│   │   ├── custom_button.dart
│   │   └── input_field.dart
│   ├── constants/          # Konstanta warna, style, dsb.
│   │   └── theme.dart
│   └── main.dart           # Entry point aplikasi
├── assets/                 # Gambar, ikon, font, dll
│   ├── images/
│   └── icons/
├── pubspec.yaml            # File konfigurasi & dependensi
├── README.md               # Dokumentasi proyek
├── .gitignore              # Daftar file/folder yang diabaikan git
└── firebase.json           # (opsional) Konfigurasi Firebase CLI


## ⚙️ Cara Menjalankan Proyek

### 🔧 1. Clone Repository
```bash
git clone https://github.com/hilmihzq/Recipe-Food-Mobile-Develop.git
cd Recipe-Food-Mobile-Develop
