import 'package:weather_forecast/config/env.dart';
import 'package:weather_forecast/services/accuweather_service.dart';
import 'package:weather_forecast/services/openweather_service.dart';
import 'package:weather_forecast/models/weather_models.dart';
import 'package:weather_forecast/models/openweather_models.dart';

/// API Manager - Merkezi API yönetimi
class ApiManager {
  static final AccuWeatherService _accuWeatherService = AccuWeatherService();
  static final OpenWeatherService _openWeatherService = OpenWeatherService();

  /// Aktif API servisini döndürür
  static dynamic get activeService {
    if (Env.isAccuWeatherActive) {
      return _accuWeatherService;
    } else {
      return _openWeatherService;
    }
  }

  /// Konum arama - Aktif API'ye göre
  static Future<List<dynamic>> searchLocations(String query) async {
    if (Env.isAccuWeatherActive) {
      final results = await _accuWeatherService.searchLocations(query);
      return results.map((json) => Location.fromJson(json)).toList();
    } else {
      final results = await _openWeatherService.searchLocations(query);
      return results.map((json) => OpenWeatherLocation.fromJson(json)).toList();
    }
  }

  /// Koordinatlara göre konum bilgisi
  static Future<Map<String, dynamic>> getLocationByCoordinates(double lat, double lon) async {
    if (Env.isAccuWeatherActive) {
      return await _accuWeatherService.getLocationByCoordinates(lat, lon);
    } else {
      return await _openWeatherService.getLocationByCoordinates(lat, lon);
    }
  }

  /// Mevcut hava durumu
  static Future<Map<String, dynamic>> getCurrentWeather(String locationKey) async {
    if (Env.isAccuWeatherActive) {
      return await _accuWeatherService.getCurrentConditions(locationKey);
    } else {
      // OpenWeatherMap için locationKey yerine lat/lon kullanırız
      // Bu durumda locationKey'den lat/lon çıkarmamız gerekir
      // Şimdilik basit bir çözüm:
      final coords = _parseLocationKey(locationKey);
      return await _openWeatherService.getCurrentWeather(coords['lat']!, coords['lon']!);
    }
  }

  /// 5 günlük tahmin
  static Future<Map<String, dynamic>> getFiveDayForecast(String locationKey) async {
    if (Env.isAccuWeatherActive) {
      return await _accuWeatherService.getFiveDayDailyForecast(locationKey);
    } else {
      final coords = _parseLocationKey(locationKey);
      return await _openWeatherService.getFiveDayForecast(coords['lat']!, coords['lon']!);
    }
  }

  /// Saatlik tahmin
  static Future<List<dynamic>> getHourlyForecast(String locationKey) async {
    if (Env.isAccuWeatherActive) {
      return await _accuWeatherService.getHourlyForecast(locationKey);
    } else {
      final coords = _parseLocationKey(locationKey);
      return await _openWeatherService.getHourlyForecast(coords['lat']!, coords['lon']!);
    }
  }

  /// Location key'den koordinat çıkarma (OpenWeatherMap için)
  static Map<String, double> _parseLocationKey(String locationKey) {
    // OpenWeatherMap için locationKey formatı: "lat,lon"
    final parts = locationKey.split(',');
    if (parts.length == 2) {
      return {
        'lat': double.parse(parts[0]),
        'lon': double.parse(parts[1]),
      };
    }
    // Varsayılan değerler (İstanbul)
    return {'lat': 41.0082, 'lon': 28.9784};
  }

  /// Konum objesini location key'e çevirme
  static String getLocationKey(dynamic location) {
    if (Env.isAccuWeatherActive) {
      return (location as Location).key;
    } else {
      final openWeatherLocation = location as OpenWeatherLocation;
      return '${openWeatherLocation.lat},${openWeatherLocation.lon}';
    }
  }

  /// Konum objesini JSON'a çevirme
  static Map<String, dynamic> locationToJson(dynamic location) {
    if (Env.isAccuWeatherActive) {
      return (location as Location).toJson();
    } else {
      return (location as OpenWeatherLocation).toJson();
    }
  }

  /// JSON'dan konum objesi oluşturma
  static dynamic locationFromJson(Map<String, dynamic> json) {
    if (Env.isAccuWeatherActive) {
      return Location.fromJson(json);
    } else {
      return OpenWeatherLocation.fromJson(json);
    }
  }

  /// Aktif API adını döndürür
  static String get activeApiName {
    if (Env.isAccuWeatherActive) {
      return 'AccuWeather';
    } else {
      return 'OpenWeatherMap';
    }
  }
}
