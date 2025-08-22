import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:weather_forecast/config/env.dart';
import 'package:weather_forecast/utils/exceptions.dart';

class AccuWeatherService {
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  Future<List<dynamic>> searchLocations(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final response = await _makeApiCall(
      '${Env.accuWeatherBaseUrl}${Env.locationSearchEndpoint}?apikey=${Env.accuWeatherApiKey}&q=${Uri.encodeQueryComponent(query)}&language=tr-tr',
      'Konum arama başarısız',
    );
    
    return response as List<dynamic>;
  }

  Future<Map<String, dynamic>> getLocationByCoordinates(
    double latitude,
    double longitude,
  ) async {
    final response = await _makeApiCall(
      '${Env.accuWeatherBaseUrl}${Env.locationByCoordinatesEndpoint}?apikey=${Env.accuWeatherApiKey}&q=$latitude,$longitude&language=tr-tr',
      'Koordinatlarla konum alınamadı',
    );
    
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getCurrentConditions(String locationKey) async {
    final response = await _makeApiCall(
      '${Env.accuWeatherBaseUrl}${Env.currentConditionsEndpoint}/$locationKey?apikey=${Env.accuWeatherApiKey}&language=tr-tr&details=true',
      'Mevcut hava durumu verisi alınamadı',
    );
    
    final List<dynamic> conditions = response as List<dynamic>;
    if (conditions.isEmpty) {
      throw ApiException('Hava durumu verisi bulunamadı', 404);
    }
    
    return conditions[0] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getFiveDayDailyForecast(
    String locationKey,
  ) async {
    final response = await _makeApiCall(
      '${Env.accuWeatherBaseUrl}${Env.fiveDayForecastEndpoint}/$locationKey?apikey=${Env.accuWeatherApiKey}&language=tr-tr&details=true&metric=true',
      '5 günlük tahmin verisi alınamadı',
    );
    
    return response as Map<String, dynamic>;
  }

  Future<List<dynamic>> getHourlyForecast(String locationKey) async {
    final response = await _makeApiCall(
      '${Env.accuWeatherBaseUrl}${Env.hourlyForecastEndpoint}/$locationKey?apikey=${Env.accuWeatherApiKey}&language=tr-tr&details=true&metric=true',
      'Saatlik tahmin verisi alınamadı',
    );
    
    return response as List<dynamic>;
  }



  Future<dynamic> _makeApiCall(String url, String errorMessage) async {
    int retryCount = 0;
    
    while (retryCount < _maxRetries) {
      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else if (response.statusCode == 401) {
          throw ApiException('API anahtarı geçersiz', response.statusCode);
        } else if (response.statusCode == 429) {
          throw ApiException('API istek limiti aşıldı. Lütfen daha sonra tekrar deneyin.', response.statusCode);
        } else if (response.statusCode >= 500) {
          throw ApiException('Sunucu hatası', response.statusCode);
        } else {
          throw ApiException('$errorMessage: ${response.statusCode}', response.statusCode);
        }
      } on SocketException {
        throw NetworkException('İnternet bağlantısı yok. Lütfen bağlantınızı kontrol edin.');
      } on ApiException {
        rethrow;
      } catch (e) {
        retryCount++;
        if (retryCount >= _maxRetries) {
          throw NetworkException('$errorMessage: $e');
        }
        await Future.delayed(_retryDelay * retryCount);
      }
    }
  }
}
