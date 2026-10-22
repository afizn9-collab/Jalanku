# JalanKu — panduan pembangunan menggunakan telefon sahaja

## Fail projek
ZIP ini mengandungi kod sumber Flutter dan `codemagic.yaml`. Folder platform Android/iOS dijana oleh Flutter dalam pipeline awan. API key tidak disertakan dan tidak direka.

## Aliran yang disyorkan
1. Muat turun dan ekstrak ZIP pada telefon.
2. Buat repositori GitHub baharu menggunakan browser telefon.
3. Muat naik semua fail projek ke root repositori (termasuk `pubspec.yaml`, folder `lib/`, `test/`, `README.md`, `codemagic.yaml`, `.gitignore`, `.env.example`).
4. Daftar/log masuk ke Codemagic melalui browser: https://codemagic.io/
5. Sambungkan repositori GitHub kepada Codemagic, pilih projek Flutter dan jalankan workflow `JalanKu Android debug APK`.
6. Semak log `flutter analyze` dan `flutter test`; muat turun `app-debug.apk` daripada Artifacts jika build berjaya.
7. Pada telefon Android, benarkan pemasangan daripada sumber yang digunakan untuk memuat turun APK hanya jika anda mempercayai sumber itu. Pasang dan uji.

Codemagic ialah servis pihak ketiga. Ketersediaan mesin, had build, dan kos bergantung pada akaun/pelan semasa. Semak terma semasa sebelum menggunakannya. Dokumentasi build: https://docs.codemagic.io/flutter-configuration/flutter-projects/

## Penting tentang Google Maps
- Tanpa API key yang sah, Google Map mungkin tidak memaparkan peta sebenar walaupun APK berjaya dibina.
- Untuk Android, cipta API key dalam Google Cloud, aktifkan Maps SDK for Android dan tetapkan restriction Android app (package name + SHA-1).
- Untuk iOS, aktifkan Maps SDK for iOS dan gunakan key berasingan yang dihadkan kepada bundle ID.
- Jangan commit key ke GitHub. Masukkan melalui secret/environment variable dan konfigurasi native mengikut dokumentasi rasmi Google Maps Flutter.
- Kunci SDK aplikasi mudah alih masih boleh diekstrak daripada aplikasi; restriction API/app penting. Jangan letak server-side secret dalam app.

## Apa yang projek ini boleh uji
- Peta Google (selepas key dipasang)
- Permintaan lokasi foreground
- Carian alamat melalui geocoding plugin
- Membuka Google Maps untuk navigasi belok demi belok
- Penanda laporan kemalangan/bahaya/kesesakan/kerosakan yang disimpan dalam memori peranti sahaja

## Bukan ciri siap lagi
Ini belum setaraf Waze: belum ada turn-by-turn dalam app, route line/ETA daripada Routes API, backend komuniti, akaun pengguna, perkongsian laporan masa nyata, moderasi, laporan tamat tempoh, push notifications atau pengesanan trafik komuniti.

## iPhone
Workflow iOS di Codemagic hanya menjalankan build unsigned untuk semakan kompilasi. Untuk memasang di iPhone atau menerbitkan ke App Store, anda perlukan signing dan kelayakan Apple yang berkenaan (biasanya Apple Developer account), serta binaan macOS/Xcode di awan. Anda tidak boleh membina iOS secara tempatan pada telefon Android atau Windows; Flutter rasmi menyatakan sasaran iOS memerlukan macOS: https://docs.flutter.dev/install/custom

## Ujian
Dalam pipeline:
- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `flutter build apk --debug`

Ujian manual pada Android:
1. Pastikan peta memuat selepas API key dikonfigurasi.
2. Beri izin lokasi dan tekan ikon lokasi.
3. Cari alamat penuh.
4. Tekan navigasi; pastikan Google Maps dibuka.
5. Tekan setiap laporan; marker ditambah secara tempatan.
6. Uji dengan permission ditolak dan internet dimatikan.
