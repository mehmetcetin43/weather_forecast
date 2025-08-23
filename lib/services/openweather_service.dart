import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:weather_forecast/config/env.dart';
import 'package:weather_forecast/utils/exceptions.dart';

class OpenWeatherService {
  static const Duration _retryDelay = Duration(seconds: 2);
  static const int _maxRetries = 3;

  /// API çağrısı yapar ve retry mekanizması ile hata yönetimi sağlar
  Future<dynamic> _makeApiCall(String url, String errorMessage) async {
    int retryCount = 0;
    
    while (retryCount < _maxRetries) {
      try {
        final response = await http.get(Uri.parse(url)).timeout(
          const Duration(seconds: 10),
        );

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else if (response.statusCode == 401) {
          throw ApiException('API anahtarı geçersiz', response.statusCode, code: 'INVALID_API_KEY');
        } else if (response.statusCode == 429) {
          throw ApiException('API limiti aşıldı', response.statusCode, code: 'RATE_LIMIT_EXCEEDED');
        } else {
          throw ApiException('HTTP ${response.statusCode}: $errorMessage', response.statusCode, code: 'HTTP_ERROR');
        }
      } on SocketException {
        if (retryCount == _maxRetries - 1) {
          throw NetworkException('İnternet bağlantısı yok');
        }
        retryCount++;
        await Future.delayed(_retryDelay);
      } on FormatException {
        throw ApiException('API yanıtı geçersiz format', 0, code: 'INVALID_RESPONSE');
      } catch (e) {
        if (retryCount == _maxRetries - 1) {
          throw ApiException('$errorMessage: $e', 0, code: 'UNKNOWN_ERROR');
        }
        retryCount++;
        await Future.delayed(_retryDelay);
      }
    }
  }

  /// Şehir adına göre konum arama
  Future<List<Map<String, dynamic>>> searchLocations(String query) async {
    if (query.isEmpty) return [];
    
    final url = '${Env.openWeatherGeocodingEndpoint}?q=$query&limit=5&appid=${Env.openWeatherApiKey}';
    
    final response = await _makeApiCall(url, 'Konum arama başarısız');
    return List<Map<String, dynamic>>.from(response);
  }

  /// Koordinatlara göre konum bilgisi alma
  Future<Map<String, dynamic>> getLocationByCoordinates(double lat, double lon) async {
    final url = '${Env.openWeatherReverseGeocodingEndpoint}?lat=$lat&lon=$lon&limit=1&appid=${Env.openWeatherApiKey}';
    
    final response = await _makeApiCall(url, 'Koordinat konum bilgisi alınamadı');
    final locations = List<Map<String, dynamic>>.from(response);
    
    if (locations.isNotEmpty) {
      return locations.first;
    } else {
      throw LocationException('Bu koordinatlar için konum bulunamadı');
    }
  }

  /// Mevcut hava durumu bilgisi alma
  Future<Map<String, dynamic>> getCurrentWeather(double lat, double lon) async {
    final url = '${Env.openWeatherBaseUrl}${Env.openWeatherCurrentEndpoint}?lat=$lat&lon=$lon&appid=${Env.openWeatherApiKey}&units=metric&lang=tr';
    
    return await _makeApiCall(url, 'Mevcut hava durumu alınamadı');
  }

  /// 5 günlük hava durumu tahmini alma
  Future<Map<String, dynamic>> getFiveDayForecast(double lat, double lon) async {
    final url = '${Env.openWeatherBaseUrl}${Env.openWeatherForecastEndpoint}?lat=$lat&lon=$lon&appid=${Env.openWeatherApiKey}&units=metric&lang=tr';
    
    return await _makeApiCall(url, '5 günlük tahmin alınamadı');
  }

  /// Saatlik hava durumu tahmini alma (5 günlük veriden çıkarılır)
  Future<List<Map<String, dynamic>>> getHourlyForecast(double lat, double lon) async {
    final forecastData = await getFiveDayForecast(lat, lon);
    final list = forecastData['list'] as List<dynamic>;
    
    // İlk 12 saatlik veriyi al
    return list.take(12).map((item) => Map<String, dynamic>.from(item)).toList();
  }
}
