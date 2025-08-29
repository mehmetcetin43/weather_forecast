# 🚀 Quick Start Guide - Weather Forecast App

Bu rehber, Weather Forecast App'i hızlıca kurmanız ve çalıştırmanız için tasarlanmıştır.

## ⚡ 5 Dakikada Kurulum

### **1. Gereksinimler Kontrolü**
```bash
# Flutter versiyonunu kontrol et
flutter --version

# Dart versiyonunu kontrol et
dart --version

# Gerekli minimum versiyonlar:
# Flutter: 3.7.0+
# Dart: 3.0.0+
```

### **2. Projeyi İndir**
```bash
# Projeyi klonla
git clone https://github.com/your-username/weather_forecast.git
cd weather_forecast

# Bağımlılıkları yükle
flutter pub get
```

### **3. API Anahtarlarını Ayarla**
```dart
// lib/config/env.dart dosyasını aç
// API anahtarlarını ekle:

class Env {
  // Hangi API'yi kullanacağını seç
  static const String activeApi = 'openweather'; // 'accuweather' veya 'openweather'
  
  // AccuWeather API (ücretsiz)
  static const String accuWeatherApiKey = 'YOUR_ACCUWEATHER_KEY';
  
  // OpenWeatherMap API (ücretsiz)
  static const String openWeatherApiKey = 'YOUR_OPENWEATHER_KEY';
}
```

### **4. API Anahtarlarını Al**
- **AccuWeather**: [developer.accuweather.com](https://developer.accuweather.com/)
- **OpenWeatherMap**: [home.openweathermap.org](https://home.openweathermap.org/)

### **5. Uygulamayı Çalıştır**
```bash
# Debug modunda çalıştır
flutter run

# Release build
flutter run --release
```

## 🎯 Hızlı Test

### **Temel Fonksiyonları Test Et**
1. **Ana Ekran**: Uygulama açıldığında hava durumu görünmeli
2. **Konum Arama**: 🔍 butonuna tıkla → "İstanbul" ara → seç
3. **Mevcut Konum**: 📍 butonuna tıkla → GPS konumunu al
4. **API Değiştirme**: `lib/config/env.dart`'da `activeApi` değerini değiştir

### **Beklenen Sonuçlar**
- ✅ Hava durumu verileri görünmeli
- ✅ Konum arama çalışmalı
- ✅ GPS konum tespiti çalışmalı
- ✅ Hata mesajları Türkçe olmalı

## 🔧 Hızlı Sorun Giderme

### **Yaygın Hatalar**

#### **1. "API Key Invalid" Hatası**
```bash
# Çözüm: API anahtarını kontrol et
flutter clean
flutter pub get
# lib/config/env.dart dosyasını kontrol et
```

#### **2. "Location Permission" Hatası**
```bash
# Android için: android/app/src/main/AndroidManifest.xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

# Cihaz ayarlarından konum iznini ver
```

#### **3. "RenderFlex overflowed" Hatası**
```bash
# Çözüm: Responsive tasarım güncellemeleri yapıldı
# Eğer hala varsa: SingleChildScrollView kullan
```

#### **4. "type 'int' is not a subtype of type 'double?'"**
```bash
# Çözüm: Safe parsing fonksiyonları eklendi
# Eğer hala varsa: _safeIntParse/_safeDoubleParse kullan
```

## 📱 Platform Desteği

### **Desteklenen Platformlar**
- ✅ **Android**: API 21+ (Android 5.0+)
- ✅ **iOS**: iOS 11.0+
- ✅ **Web**: Modern tarayıcılar
- ✅ **Windows**: Windows 10+
- ✅ **macOS**: macOS 10.14+
- ✅ **Linux**: Ubuntu 18.04+

### **Test Edilen Cihazlar**
- ✅ **Android**: Xiaomi Mi 6, Samsung Galaxy S21
- ✅ **iOS**: iPhone 12, iPhone 13
- ✅ **Emulator**: Android Studio AVD, iOS Simulator

## 🎨 UI/UX Özellikleri

### **Modern Tasarım**
- 🌈 **Gradient Arka Planlar**: Hava durumuna göre değişen renkler
- 🎭 **Dinamik İkonlar**: Hava durumuna göre değişen ikonlar
- ✨ **Animasyonlar**: Smooth geçişler ve efektler
- 📱 **Responsive**: Tüm ekran boyutlarında uyumlu

### **Kullanıcı Deneyimi**
- 🔍 **Akıllı Arama**: Otomatik tamamlama
- 📍 **GPS Entegrasyonu**: Tek tıkla mevcut konum
- 🔄 **Pull to Refresh**: Aşağı çekerek yenileme
- 🌍 **Çift API**: AccuWeather + OpenWeatherMap

## 🔄 API Geçiş Rehberi

### **AccuWeather'dan OpenWeatherMap'e**
```dart
// lib/config/env.dart
static const String activeApi = 'openweather';
static const String openWeatherApiKey = 'YOUR_KEY';
```

### **OpenWeatherMap'den AccuWeather'a**
```dart
// lib/config/env.dart
static const String activeApi = 'accuweather';
static const String accuWeatherApiKey = 'YOUR_KEY';
```

## 🧪 Test Çalıştırma

### **Unit Test'ler**
```bash
# Tüm test'leri çalıştır
flutter test

# Belirli test dosyası
flutter test test/weather_provider_test.dart

# Coverage ile
flutter test --coverage
```

### **Widget Test'ler**
```bash
# Widget test'leri
flutter test test/widget_test.dart
```

## 📊 Performans

### **Mevcut Metrikler**
- **App Size**: ~15MB
- **Startup Time**: ~2 saniye
- **Memory Usage**: ~50MB
- **API Response**: ~1-2 saniye

### **Optimizasyon Önerileri**
- **Release Build**: `flutter run --release`
- **Proguard**: Android için kod küçültme
- **Image Optimization**: Asset'leri sıkıştır

## 🚀 Production'a Hazırlık

### **Release Build**
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

### **Güvenlik Kontrolü**
- ✅ API anahtarları config dosyasında
- ✅ HTTPS kullanımı
- ✅ Permission handling
- ⚠️ Backend proxy önerilir (production için)

## 📚 Hızlı Referans

### **Önemli Dosyalar**
```
lib/
├── config/env.dart              # API konfigürasyonu
├── main.dart                    # Ana uygulama
├── screens/                     # UI ekranları
├── services/                    # API servisleri
├── providers/                   # State management
└── utils/                       # Yardımcı fonksiyonlar
```

### **Önemli Komutlar**
```bash
flutter pub get                  # Bağımlılıkları yükle
flutter clean                    # Cache temizle
flutter run                      # Debug modunda çalıştır
flutter test                     # Test'leri çalıştır
flutter build apk --release      # Release APK oluştur
```

### **Debug Komutları**
```bash
flutter doctor                   # Sistem kontrolü
flutter analyze                  # Kod analizi
flutter pub deps                 # Bağımlılık ağacı
flutter pub outdated             # Güncel olmayan paketler
```

## 🆘 Yardım

### **Sorun Yaşıyorsanız**
1. **Log'ları kontrol et**: `flutter logs`
2. **Flutter doctor**: `flutter doctor -v`
3. **Clean build**: `flutter clean && flutter pub get`
4. **Issue aç**: GitHub'da detaylı açıklama ile

### **Faydalı Linkler**
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Material Design](https://material.io/design)
- [AccuWeather API](https://developer.accuweather.com/)
- [OpenWeatherMap API](https://openweathermap.org/api)

## 🎉 Başarı!

Artık Weather Forecast App'i başarıyla kurduğunuz ve çalıştırdığınız için tebrikler! 🚀

**Sonraki Adımlar:**
1. **Özelleştirme**: UI'ı kendi ihtiyaçlarınıza göre düzenleyin
2. **API Entegrasyonu**: Kendi API anahtarlarınızı ekleyin
3. **Test**: Farklı cihazlarda test edin
4. **Deploy**: Production'a hazırlayın

---

**⏱️ Tahmini Kurulum Süresi**: 5-10 dakika
**📱 Desteklenen Platformlar**: Android, iOS, Web, Desktop
**🔧 Gereksinimler**: Flutter 3.7.0+, API anahtarları
