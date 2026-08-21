# 📱 MdgInvoiceManager - Mobil Fatura Yönetim Uygulaması

MdgInvoiceManager Web API ile tam entegre çalışan; kullanıcıların fatura oluşturmasını, listelemesini, sağlayan **Flutter** mobil uygulaması.

---

## 🏗️ Mimari & State Management

Uygulama, **Feature-First (Özellik Odaklı)** ve temiz mimari prensipleri doğrultusunda geliştirilmiştir:

- **State Management:** `Cubit` (BLoC Pattern) ile reaktif durum yönetimi (`AuthCubit`, `InvoiceCubit`).
- **Data Layer:** `RemoteDataSource` üzerinden REST API çağrıları ve JSON model dönüşümleri (`InvoiceModel`).
- **Presentation Layer:** Modüler `views` yapısı ile responsive ekran tasarımları.

```text
lib/
├── features/
│   ├── auth/                          # Kimlik Doğrulama Modülü
│   │   ├── data/                      # Auth modelleri
│   │   └── presentation/              # AuthCubit, LoginView, RegisterView, TokenLoginView
│   │
│   └── invoice/                       # Fatura Yönetim Modülü
│       ├── data/
│       │   ├── datasources/           # invoice_remote_data_source.dart (API İstekleri)
│       │   └── models/                # invoice_model.dart (JSON Serialization)
│       └── presentation/
│           ├── cubit/                 # invoice_cubit.dart, invoice_state.dart
│           └── views/                 # invoice_list_view.dart, add_invoice_view.dart
│
└── main.dart                          # Uygulama başlangıcı ve bağımlılık enjeksiyonu

```

---

## ✨ Özellikler

* 🔐 **Güvenli Kimlik Doğrulama:** Kullanıcı adı/şifre ve Token bazlı hızlı giriş desteği (`TokenLoginView`).
* 📋 **Dinamik Fatura Listeleme:** Sunucudan anlık çekilen, durum ve tutar detaylı fatura listesi (`InvoiceListView`).
* ➕ **Fatura Oluşturma:** Satış ve Ticari Fatura senaryoları, dinamik KDV/vergi hesaplamaları (`AddInvoiceView`).
* 🛡️ **Yerel Doğrulama:** İl/İlçe ve VKN/TCKN kontrolleri ile hatalı veri girişini engelleyen akış.
* ⚡ **Asenkron Durum Yönetimi:** `Cubit` ile yükleme (loading), hata ve başarı durumlarının anlık yönetimi.

---

## 🚀 Teknolojiler

*  — UI Framework
*  — Programlama Dili
*  — State Management
*  — Backend Entegrasyonu & JSON Serialization
*  — Token & Oturum Yönetimi

---

## ⚡ Hızlı Başlangıç

1. **Paketleri Yükleyin:**
```bash
flutter pub get

```


2. **Uygulamayı Başlatın:**
```bash
flutter run

```



---

## 👤 Geliştirici

**Meltem Dilan Gümüş** — [GitHub Profilim](https://github.com)

```



```