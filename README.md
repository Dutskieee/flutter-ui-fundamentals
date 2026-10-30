# flutter_ui_fundamentals

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Arsitektur Aplikasi (Course Explorer v2)

Aplikasi ini menggunakan arsitektur berbasis layer dan Provider sebagai State Management. Arah dependensinya adalah: **Screen/Widget -> Provider -> Repository -> Service/Data Source**.

Tanggung jawab masing-masing folder (`lib/`):
*   **`models/`**: Menyimpan representasi data berwujud *object* (misalnya `Course`). Bertanggung jawab untuk proses *parsing* dari JSON (`fromJson`).
*   **`services/`**: Bertindak sebagai *Data Source*. Menangani detail teknis pengambilan data mentah dari *asset* (JSON), API, atau Database.
*   **`repositories/`**: Berfungsi sebagai lapisan abstraksi antara *Service* dan *Provider*. Menyediakan metode yang lebih sederhana (API internal) tanpa mempedulikan sumber datanya.
*   **`providers/`**: Mengelola *State Management* (bisnis logika) dan mewarisi `ChangeNotifier`. Menyimpan state seperti `isLoading`, `error`, dan `favorites`, serta memberitahu UI jika ada perubahan (`notifyListeners()`).
*   **`screens/` & `widgets/`**: Lapisan UI (*User Interface*). Hanya bertugas menampilkan antarmuka dan membaca state dari *Provider* menggunakan `context.watch()` atau `context.read()`.