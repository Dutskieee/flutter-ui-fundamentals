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