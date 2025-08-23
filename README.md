# 🌤️ Weather Forecast App

Modern ve kullanıcı dostu bir Flutter hava durumu uygulaması. **AccuWeather** ve **OpenWeatherMap** API'lerini destekleyen, gerçek zamanlı hava durumu bilgileri ve detaylı tahminler sunan uygulama.

## ✨ Özellikler

### 🌍 **Çift API Desteği**
- **AccuWeather API**: Yüksek doğruluk oranı
- **OpenWeatherMap API**: Ücretsiz ve güvenilir
- **Tek Tıkla Geçiş**: `lib/config/env.dart` dosyasından kolay API değiştirme

### 🔍 **Gelişmiş Konum Arama**
- **Otomatik Tamamlama**: Şehir ve ilçe adlarına göre arama
- **Detaylı Sonuçlar**: Ülke, şehir, ilçe bilgileri
- **Koordinat Tabanlı Şehir Tespiti**: Türkiye için özel algoritma
- **Çoklu Sonuç**: Aynı isimli yerler için detaylı bilgi

### 📍 **Konum Servisleri**
- **GPS Konum Tespiti**: Otomatik mevcut konum
- **İzin Yönetimi**: Akıllı konum izni istekleri
- **Son Bilinen Konum**: İnternet olmadan da çalışma

### 🌡️ **Kapsamlı Hava Durumu**
- **Anlık Koşullar**: Sıcaklık, hissedilen sıcaklık, nem, rüzgar
- **Detaylı Bilgiler**: UV indeksi, görüş mesafesi, basınç
- **5 Günlük Tahmin**: Günlük hava durumu tahminleri
- **12 Saatlik Tahmin**: Saatlik detaylı tahminler
- **Nem ve Rüzgar**: Her tahmin için detaylı bilgiler

### 🎨 **Modern UI/UX**
- **Responsive Tasarım**: Tüm cihazlarda uyumlu
- **Dinamik İkonlar**: Hava durumuna göre değişen ikonlar
- **Gradient Arka Planlar**: Modern görsel tasarım
- **Animasyonlar**: Smooth geçişler ve efektler
- **Türkçe Arayüz**: Tam yerelleştirme

### 🛡️ **Güvenilirlik**
- **Retry Mekanizması**: Bağlantı hatalarında otomatik yeniden deneme
- **Hata Yönetimi**: Kapsamlı exception handling
- **Offline Desteği**: Son bilinen konum ile çalışma
- **API Limit Yönetimi**: Akıllı API kullanımı

## 🚀 Kurulum

### Gereksinimler

- **Flutter SDK**: 3.7.0 veya üzeri
- **Dart SDK**: 3.0.0 veya üzeri
- **Android Studio** / **VS Code**
- **API Anahtarları**: AccuWeather ve/veya OpenWeatherMap

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

3. **API Anahtarlarını Ayarlayın**

   **AccuWeather API:**
   - [AccuWeather Developer Portal](https://developer.accuweather.com/)'dan ücretsiz API anahtarı alın
   
   **OpenWeatherMap API:**
   - [OpenWeatherMap](https://home.openweathermap.org/)'den ücretsiz API anahtarı alın

   **Konfigürasyon:**
   ```dart
   // lib/config/env.dart dosyasında
   static const String activeApi = 'openweather'; // 'accuweather' veya 'openweather'
   static const String accuWeatherApiKey = 'YOUR_ACCUWEATHER_KEY';
   static const String openWeatherApiKey = 'YOUR_OPENWEATHER_KEY';
   ```

4. **Uygulamayı çalıştırın**
   ```bash
   flutter run
   ```

## 📱 Kullanım

### Ana Ekran
- **🔍 Arama Butonu**: Konum arama ekranını açar
- **📍 Konum Butonu**: Mevcut konumunuzun hava durumunu gösterir
- **⚙️ API Değiştirme**: Konfigürasyon dosyasından API seçimi

### Konum Arama
- Arama kutusuna şehir veya ilçe adı yazın
- Otomatik tamamlama ile konumları görün
- Detaylı bilgilerle doğru konumu seçin
- **Örnek**: "Simav" yazın → "Simav, Kütahya, Türkiye" görünür

### Hava Durumu Ekranı
- **🌡️ Mevcut Koşullar**: Anlık hava durumu bilgileri
- **📅 5 Günlük Tahmin**: Günlük hava durumu tahminleri
- **⏰ 12 Saatlik Tahmin**: Saatlik detaylı tahminler
- **🔄 Yenileme**: Aşağı çekerek verileri yenileyin

## 🏗️ Proje Yapısı

```
lib/
├── config/
│   └── env.dart                    # API konfigürasyonu ve seçimi
├── models/
│   ├── weather_models.dart         # AccuWeather veri modelleri
│   └── openweather_models.dart     # OpenWeatherMap veri modelleri
├── screens/
│   ├── location_search_screen.dart # Gelişmiş konum arama ekranı
│   └── weather_display_screen.dart # Kapsamlı hava durumu ekranı
├── services/
│   ├── api_manager.dart           # Merkezi API yönetimi
│   ├── accuweather_service.dart   # AccuWeather API servisi
│   ├── openweather_service.dart   # OpenWeatherMap API servisi
│   └── location_service.dart      # Konum servisleri
├── providers/
│   └── universal_weather_provider.dart # API-agnostic state management
├── utils/
│   ├── exceptions.dart            # Özel hata sınıfları
│   └── weather_icons.dart         # Dinamik hava durumu ikonları
├── theme/
│   └── app_theme.dart             # Uygulama teması
└── main.dart                      # Ana uygulama dosyası
```

## 🔧 Teknik Detaylar

### Kullanılan Teknolojiler
- **Flutter**: UI framework
- **Dart**: Programlama dili
- **Provider**: State management
- **HTTP**: API istekleri
- **Geolocator**: Konum servisleri

### API Manager Sistemi
```dart
// Tek noktadan API yönetimi
class ApiManager {
  static String get activeApiName => Env.activeApi == 'accuweather' ? 'AccuWeather' : 'OpenWeatherMap';
  
  // Tüm API çağrıları buradan yapılır
  static Future<List<dynamic>> searchLocations(String query)
  static Future<dynamic> getCurrentWeather(Map<String, dynamic> location)
  static Future<List<dynamic>> getFiveDayForecast(Map<String, dynamic> location)
  static Future<List<dynamic>> getHourlyForecast(Map<String, dynamic> location)
}
```

### API Endpoints

**AccuWeather:**
- `GET /locations/v1/cities/autocomplete` - Konum arama
- `GET /locations/v1/cities/geoposition/search` - Koordinat ile konum
- `GET /currentconditions/v1/{key}` - Anlık hava durumu
- `GET /forecasts/v1/daily/5day/{key}` - 5 günlük tahmin
- `GET /forecasts/v1/hourly/12hour/{key}` - 12 saatlik tahmin

**OpenWeatherMap:**
- `GET /geo/1.0/direct` - Konum arama
- `GET /weather` - Anlık hava durumu
- `GET /forecast` - 5 günlük tahmin (3 saatlik aralıklarla)

### Hata Yönetimi
- **NetworkException**: İnternet bağlantısı hataları
- **LocationException**: Konum servisi hataları
- **ApiException**: API hataları (status code ile)
- **Retry Mekanizması**: 3 kez otomatik yeniden deneme

### Konum Arama Algoritması
```dart
// Türkiye için özel koordinat tabanlı şehir tespiti
String _getCityFromCoordinates(double lat, double lon) {
  // 81 il için koordinat veritabanı
  // Tolerance ile yakın şehir tespiti
  // Özel durumlar (Simav → Kütahya)
}
```

## 🎯 Özellikler Detayı

### Konum Arama İyileştirmeleri
- **Ülke Kodu Çevirisi**: TR → Türkiye
- **Şehir Tespiti**: Koordinat tabanlı algoritma
- **Detaylı Bilgiler**: Ülke, şehir, ilçe, koordinat
- **Çoklu Sonuç**: Aynı isimli yerler için ayrıştırma

### Hava Durumu Detayları
- **Sıcaklık**: Celsius derece
- **Hissedilen**: Rüzgar ve nem etkisi
- **Nem**: Yüzde olarak
- **Rüzgar**: Hız ve yön
- **Basınç**: hPa cinsinden
- **Görüş**: Kilometre cinsinden
- **UV İndeksi**: Güneş ışınımı

### UI/UX Özellikleri
- **Dinamik İkonlar**: Hava durumuna göre değişen ikonlar
- **Renk Kodlaması**: Sıcaklığa göre renk değişimi
- **Animasyonlar**: Fade, slide, bounce efektleri
- **Responsive**: Tüm ekran boyutlarında uyumlu

## 🔄 API Geçiş Rehberi

### AccuWeather'dan OpenWeatherMap'e
1. `lib/config/env.dart` dosyasını açın
2. `activeApi` değerini `'openweather'` yapın
3. `openWeatherApiKey` değerini güncelleyin
4. Uygulamayı yeniden başlatın

### OpenWeatherMap'den AccuWeather'a
1. `lib/config/env.dart` dosyasını açın
2. `activeApi` değerini `'accuweather'` yapın
3. `accuWeatherApiKey` değerini güncelleyin
4. Uygulamayı yeniden başlatın

## �� Sorun Giderme

### Yaygın Sorunlar

**API Anahtarı Hatası:**
```bash
# API anahtarınızı kontrol edin
# Rate limit'i aştıysanız API değiştirin
# İnternet bağlantınızı kontrol edin
```

**Konum İzni Hatası:**
```bash
# AndroidManifest.xml'de izinlerin olduğunu kontrol edin
# Cihaz ayarlarından konum iznini verin
# GPS'in açık olduğunu kontrol edin
```

**Render Overflow Hatası:**
```bash
# Responsive tasarım güncellemeleri yapıldı
# Flexible widget'lar kullanıldı
# SingleChildScrollView eklendi
```

## 📈 Gelecek Planları

### Yakın Vadede
- [ ] Unit test'ler ekleme
- [ ] Integration test'ler
- [ ] Performance optimizasyonu
- [ ] Offline cache sistemi

### Orta Vadede
- [ ] Widget desteği
- [ ] Dark mode
- [ ] Çoklu dil desteği
- [ ] Push notification'lar

### Uzun Vadede
- [ ] Web desteği
- [ ] Desktop uygulaması
- [ ] AI tabanlı tahminler
- [ ] Sosyal özellikler

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit yapın (`git commit -m 'Add amazing feature'`)
4. Push yapın (`git push origin feature/amazing-feature`)
5. Pull Request açın

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için `LICENSE` dosyasına bakın.

## 📞 İletişim

- **Proje Linki**: [https://github.com/your-username/weather_forecast](https://github.com/your-username/weather_forecast)
- **Sorun Bildirimi**: [Issues](https://github.com/your-username/weather_forecast/issues)

---

⭐ Bu projeyi beğendiyseniz yıldız vermeyi unutmayın!
