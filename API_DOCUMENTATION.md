# 🔌 API Documentation

Weather Forecast App'in API entegrasyonları ve kullanımı.

## 🎯 API Manager Sistemi

### Konfigürasyon
```dart
// lib/config/env.dart
static const String activeApi = 'openweather'; // 'accuweather' veya 'openweather'
static const String accuWeatherApiKey = 'YOUR_KEY';
static const String openWeatherApiKey = 'YOUR_KEY';
```

### Kullanım
```dart
// Konum arama
final locations = await ApiManager.searchLocations('İstanbul');

// Hava durumu
final weather = await ApiManager.getCurrentWeather(locationData);

// Tahminler
final forecast = await ApiManager.getFiveDayForecast(locationData);
final hourly = await ApiManager.getHourlyForecast(locationData);
```

## 🌤️ AccuWeather API

### Endpoint'ler
- `GET /locations/v1/cities/autocomplete` - Konum arama
- `GET /currentconditions/v1/{key}` - Mevcut hava durumu
- `GET /forecasts/v1/daily/5day/{key}` - 5 günlük tahmin
- `GET /forecasts/v1/hourly/12hour/{key}` - 12 saatlik tahmin

### Limit: 50 istek/gün (ücretsiz)

## 🌍 OpenWeatherMap API

### Endpoint'ler
- `GET /geo/1.0/direct` - Konum arama
- `GET /weather` - Mevcut hava durumu
- `GET /forecast` - 5 günlük tahmin

### Limit: 1000 istek/gün (ücretsiz)

## 🔄 API Geçiş

1. `lib/config/env.dart` dosyasını açın
2. `activeApi` değerini değiştirin
3. Uygulamayı yeniden başlatın

## 🛡️ Hata Yönetimi

```dart
try {
  final data = await ApiManager.searchLocations('İstanbul');
} catch (e) {
  if (e is ApiException) {
    print('API Hatası: ${e.message}');
  } else if (e is NetworkException) {
    print('Ağ Hatası: ${e.message}');
  }
}
```

## 📝 Örnekler

### Konum Arama
```dart
final locations = await ApiManager.searchLocations('Ankara');
print('Bulunan: ${locations.length} konum');
```

### Hava Durumu
```dart
final weather = await ApiManager.getCurrentWeather(location);
print('Sıcaklık: ${weather.temperature}°C');
```
