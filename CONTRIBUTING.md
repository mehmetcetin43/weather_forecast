# 🤝 Contributing Guide

Weather Forecast App'e katkıda bulunmak için bu rehberi takip edin.

## 📋 İçindekiler

1. [Başlangıç](#başlangıç)
2. [Geliştirme Süreci](#geliştirme-süreci)
3. [Kod Standartları](#kod-standartları)
4. [Test Yazma](#test-yazma)
5. [Pull Request](#pull-request)
6. [Hata Bildirimi](#hata-bildirimi)

## 🚀 Başlangıç

### Gereksinimler
- Flutter SDK 3.7.0+
- Dart SDK 3.0.0+
- Git
- IDE (VS Code, Android Studio)

### Kurulum
```bash
# Projeyi fork edin
git clone https://github.com/YOUR_USERNAME/weather_forecast.git
cd weather_forecast

# Bağımlılıkları yükleyin
flutter pub get

# API anahtarlarını ayarlayın
# lib/config/env.dart dosyasını düzenleyin
```

## 🔄 Geliştirme Süreci

### 1. Issue Oluşturma
- Yeni özellik için issue açın
- Hata bildirimi için detaylı açıklama yazın
- Etiketleri doğru kullanın

### 2. Branch Oluşturma
```bash
# Ana branch'i güncelleyin
git checkout main
git pull origin main

# Feature branch oluşturun
git checkout -b feature/yeni-ozellik
# veya
git checkout -b fix/hata-duzeltmesi
```

### 3. Geliştirme
- Kodunuzu yazın
- Test'leri çalıştırın
- Lint kurallarına uyun

### 4. Commit
```bash
# Değişiklikleri ekleyin
git add .

# Commit yapın
git commit -m "feat: yeni özellik eklendi"
git commit -m "fix: hata düzeltildi"
git commit -m "docs: dokümantasyon güncellendi"
```

## 📝 Kod Standartları

### Commit Mesajları
```
feat: yeni özellik
fix: hata düzeltmesi
docs: dokümantasyon
style: kod formatı
refactor: kod yeniden düzenleme
test: test ekleme
chore: bakım işleri
```

### Dart/Flutter Standartları
```dart
// Dosya adları: snake_case
weather_service.dart
location_provider.dart

// Sınıf adları: PascalCase
class WeatherService {}
class LocationProvider {}

// Değişken adları: camelCase
String userName;
int temperatureValue;

// Sabitler: SCREAMING_SNAKE_CASE
static const String API_BASE_URL = 'https://api.example.com';

// Fonksiyon adları: camelCase
Future<void> fetchWeatherData() {}
String formatTemperature(double temp) {}
```

### Dosya Organizasyonu
```
lib/
├── config/          # Konfigürasyon dosyaları
├── models/          # Veri modelleri
├── services/        # API servisleri
├── providers/       # State management
├── screens/         # UI ekranları
├── utils/           # Yardımcı fonksiyonlar
├── theme/           # Tema dosyaları
└── main.dart        # Ana uygulama
```

### Kod Kalitesi
```dart
// ✅ İyi örnek
class WeatherService {
  static const String _baseUrl = 'https://api.example.com';
  
  Future<WeatherData> getWeather(String location) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/weather'));
      return WeatherData.fromJson(jsonDecode(response.body));
    } catch (e) {
      throw WeatherException('Hava durumu alınamadı: $e');
    }
  }
}

// ❌ Kötü örnek
class weatherservice {
  Future getweather(String l) async {
    var r = await http.get(Uri.parse('https://api.example.com/weather'));
    return jsonDecode(r.body);
  }
}
```

## 🧪 Test Yazma

### Unit Test'ler
```dart
// test/services/weather_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_forecast/services/weather_service.dart';

void main() {
  group('WeatherService', () {
    test('getWeather returns WeatherData', () async {
      final service = WeatherService();
      final result = await service.getWeather('İstanbul');
      
      expect(result, isA<WeatherData>());
      expect(result.temperature, isNotNull);
    });
  });
}
```

### Widget Test'ler
```dart
// test/widgets/weather_display_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_forecast/screens/weather_display_screen.dart';

void main() {
  testWidgets('WeatherDisplayScreen shows weather data', (tester) async {
    await tester.pumpWidget(WeatherDisplayScreen());
    
    expect(find.text('Hava Durumu'), findsOneWidget);
    expect(find.byType(Card), findsWidgets);
  });
}
```

### Test Çalıştırma
```bash
# Tüm test'leri çalıştır
flutter test

# Belirli test dosyası
flutter test test/services/weather_service_test.dart

# Coverage ile
flutter test --coverage
```

## 🔄 Pull Request

### PR Oluşturma
1. Fork'unuzda branch oluşturun
2. Değişikliklerinizi commit edin
3. Pull Request açın

### PR Template
```markdown
## 📝 Açıklama
Bu PR ne yapıyor?

## 🔧 Değişiklikler
- [ ] Yeni özellik eklendi
- [ ] Hata düzeltildi
- [ ] Dokümantasyon güncellendi

## 🧪 Test'ler
- [ ] Unit test'ler yazıldı
- [ ] Widget test'ler yazıldı
- [ ] Manuel test yapıldı

## 📸 Ekran Görüntüleri
(UI değişiklikleri için)

## ✅ Kontrol Listesi
- [ ] Kod standartlarına uyuldu
- [ ] Test'ler geçiyor
- [ ] Dokümantasyon güncellendi
- [ ] Lint hataları yok
```

### PR Review
- En az bir review gerekli
- CI/CD pipeline'ları geçmeli
- Test coverage düşmemeli

## 🐛 Hata Bildirimi

### Bug Report Template
```markdown
## 🐛 Hata Açıklaması
Hatanın ne olduğunu açıklayın.

## 🔄 Tekrar Adımları
1. Uygulamayı açın
2. Şu adımları takip edin
3. Hata oluşur

## 📱 Cihaz Bilgileri
- Cihaz: iPhone 12 / Samsung Galaxy S21
- OS: iOS 15 / Android 12
- App Version: 1.0.0

## 📸 Ekran Görüntüleri
Hata ekranının görüntüsü

## 🔍 Beklenen Davranış
Ne olması gerekiyordu?

## 📋 Ek Bilgiler
API anahtarı, konum bilgisi vb.
```

### Feature Request Template
```markdown
## 💡 Özellik İsteği
Yeni özelliğin açıklaması

## 🎯 Kullanım Senaryosu
Bu özellik ne zaman kullanılacak?

## 🔧 Teknik Detaylar
Nasıl implement edilebilir?

## 📊 Öncelik
- [ ] Yüksek
- [ ] Orta
- [ ] Düşük
```

## 🛠️ Geliştirme Araçları

### VS Code Extensions
- Dart
- Flutter
- Flutter Widget Snippets
- Error Lens
- GitLens

### Android Studio Plugins
- Flutter
- Dart
- Git Integration

### Debug Araçları
```dart
// Debug print'leri
print('DEBUG: $variable');

// Assert'ler
assert(condition, 'Hata mesajı');

// Logging
import 'package:logging/logging.dart';
final _logger = Logger('WeatherService');
_logger.info('Hava durumu alındı');
```

## 📚 Faydalı Linkler

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Material Design](https://material.io/design)
- [Flutter Testing](https://flutter.dev/docs/testing)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)

## 🎉 Teşekkürler

Katkıda bulunduğunuz için teşekkürler! 🚀

Her katkı projeyi daha iyi hale getiriyor.
