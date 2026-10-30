# Course Data Manager

Aplikasi Course Data Manager berbasis Flutter untuk mengelola data mata kuliah menggunakan REST API dan backend Supabase.

## Arsitektur Aplikasi
Aplikasi ini menggunakan arsitektur berbasis layer dan Provider sebagai State Management. Arah dependensinya adalah: **Screen/Widget -> Provider -> Repository -> Service/Data Source**.

Tanggung jawab masing-masing folder (`lib/`):
*   **`models/`**: Menyimpan representasi data berwujud *object*.
*   **`services/`**: Bertindak sebagai *Data Source* untuk mengambil data dari internet (REST API / Supabase).
*   **`repositories/`**: Berfungsi sebagai lapisan abstraksi antara data dan logika aplikasi.
*   **`providers/`**: Mengelola *State Management* (Loading, Success, Empty, Error).
*   **`screens/` & `widgets/`**: Lapisan antarmuka pengguna (UI).

## Dokumentasi REST API (Tahap 1)
*   **Base URL:** `https://course-api-pearl.vercel.app`
*   **Endpoint List Courses:** `/courses`
*   **HTTP Method:** `GET`
*   **Status Code (Success):** `200 OK`
*   **Struktur JSON (Resource):**
    Mengembalikan array of objects. Setiap object minimal memiliki 5 field:
    1. `id` (Number)
    2. `code` (String)
    3. `title` (String)
    4. `credits` (Number)
    5. `status` (String: planned/active/done)

    ## Tentang Course Data Manager (v2)
Aplikasi ini adalah sistem manajemen data mata kuliah (CRUD) yang dikembangkan dari Course Explorer v2. Fitur utama mencakup penambahan, pengubahan, penghapusan, dan pembacaan data (State: Loading, Success, Empty, Error) secara real-time.

## Cara Menjalankan Aplikasi
1. Pastikan Flutter SDK telah terinstal.
2. Jalankan perintah `flutter pub get` untuk mengunduh dependency.
3. Jalankan aplikasi menggunakan perintah `flutter run` atau melalui emulator.

## Arsitektur Singkat
Aplikasi ini dibangun dengan prinsip *Separation of Concerns* menggunakan pola:
**UI (Screens/Widgets) -> State Management (Provider) -> Repository Pattern -> Service/Data Source**.

## Backend
Menggunakan **Supabase (PostgreSQL)** sebagai backend service dan database utama.