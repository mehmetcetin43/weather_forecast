# 🌤️ Weather Forecast App

Modern ve kullanıcı dostu bir Flutter hava durumu uygulaması. AccuWeather API'sini kullanarak gerçek zamanlı hava durumu bilgileri ve 5 günlük tahminler sunar.

## ✨ Özellikler

- 🔍 **Konum Arama**: Şehir ve ilçe adlarına göre otomatik tamamlama ile konum arama
- 📍 **Mevcut Konum**: GPS ile otomatik konum tespiti
- 🌡️ **Anlık Hava Durumu**: Sıcaklık, hissedilen sıcaklık, nem, rüzgar hızı
- 📅 **5 Günlük Tahmin**: Detaylı günlük hava durumu tahminleri
- 🌍 **Türkçe Dil Desteği**: Tam Türkçe arayüz ve hava durumu açıklamaları
- 🔄 **Retry Mekanizması**: Bağlantı hatalarında otomatik yeniden deneme
- 🛡️ **Güvenli API**: Güvenli API anahtarı yönetimi
- 📱 **Responsive Tasarım**: Tüm cihazlarda uyumlu tasarım

## 🚀 Kurulum

### Gereksinimler

- Flutter SDK (3.7.0 veya üzeri)
- Dart SDK
- Android Studio / VS Code
- AccuWeather API anahtarı

### Adımlar

1. **Projeyi klonlayın**
   ```bash
   git clone https://github.com/your-username/weather_forecast.git
   cd weather_forecast
   ```

2. **Bağımlılıkları yükleyin**
   ```bash
   flutter pub get
   ```

3. **API Anahtarını Ayarlayın**
   - [AccuWeather Developer Portal](https://developer.accuweather.com/)'dan ücretsiz API anahtarı alın
   - `lib/config/env.dart` dosyasındaki `accuWeatherApiKey` değerini güncelleyin

4. **Uygulamayı çalıştırın**
   ```bash
   flutter run
   ```

## 📱 Kullanım

### Ana Ekran
- **Arama Butonu**: Konum arama ekranını açar
- **Konum Butonu**: Mevcut konumunuzun hava durumunu gösterir

### Konum Arama
- Arama kutusuna şehir veya ilçe adı yazın
- Otomatik tamamlama ile konumları görün
- İstediğiniz konumu seçin

### Hava Durumu Ekranı
- **Mevcut Koşullar**: Anlık hava durumu bilgileri
- **5 Günlük Tahmin**: Günlük hava durumu tahminleri
- **Yenileme**: Aşağı çekerek verileri yenileyin

## 🏗️ Proje Yapısı

```
lib/
├── config/
│   └── env.dart              # API konfigürasyonu
├── models/
│   └── weather_models.dart   # Veri modelleri
├── screens/
│   ├── location_search_screen.dart    # Konum arama ekranı
│   └── weather_display_screen.dart    # Hava durumu ekranı
├── services/
│   └── accuweather_service.dart       # API servisleri
├── utils/
│   └── exceptions.dart       # Özel hata sınıfları
└── main.dart                 # Ana uygulama dosyası
```

## 🔧 Teknik Detaylar

### Kullanılan Teknolojiler
- **Flutter**: UI framework
- **Dart**: Programlama dili
- **AccuWeather API**: Hava durumu verileri
- **Geolocator**: Konum servisleri
- **HTTP**: API istekleri

### API Endpoints
- `GET /locations/v1/cities/autocomplete` - Konum arama
- `GET /locations/v1/cities/geoposition/search` - Koordinat ile konum
- `GET /currentconditions/v1/{key}` - Anlık hava durumu
- `GET /forecasts/v1/daily/5day/{key}` - 5 günlük tahmin

### Hata Yönetimi
- **NetworkException**: İnternet bağlantısı hataları
- **LocationException**: Konum servisi hataları
- **ApiException**: API hataları
- **Retry Mekanizması**: Otomatik yeniden deneme

## 🧪 Test

```bash
# Unit testleri çalıştır
flutter test

# Widget testleri çalıştır
flutter test test/widget_test.dart
```

## 📦 Build

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için `LICENSE` dosyasına bakın.

## 🙏 Teşekkürler

- [AccuWeather](https://www.accuweather.com/) - Hava durumu API'si
- [Flutter](https://flutter.dev/) - UI framework
- [Material Design](https://material.io/) - Tasarım sistemi

## 📞 İletişim

- **Email**: your-email@example.com
- **GitHub**: [@your-username](https://github.com/your-username)

---

⭐ Bu projeyi beğendiyseniz yıldız vermeyi unutmayın!
