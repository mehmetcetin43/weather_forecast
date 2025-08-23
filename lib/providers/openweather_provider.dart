import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:weather_forecast/services/openweather_service.dart';
import 'package:weather_forecast/services/location_service.dart';
import 'package:weather_forecast/models/openweather_models.dart';
import 'package:weather_forecast/utils/exceptions.dart';

class OpenWeatherProvider with ChangeNotifier {
  final OpenWeatherService _openWeatherService = OpenWeatherService();
  
  // State variables
  OpenWeatherLocation? _selectedLocation;
  OpenWeatherCurrentConditions? _currentConditions;
  List<OpenWeatherDailyForecast> _dailyForecasts = [];
  List<OpenWeatherHourlyForecast> _hourlyForecasts = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  OpenWeatherLocation? get selectedLocation => _selectedLocation;
  OpenWeatherCurrentConditions? get currentConditions => _currentConditions;
  List<OpenWeatherDailyForecast> get dailyForecasts => _dailyForecasts;
  List<OpenWeatherHourlyForecast> get hourlyForecasts => _hourlyForecasts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasData => _currentConditions != null && _dailyForecasts.isNotEmpty;

  // Search locations
  Future<List<OpenWeatherLocation>> searchLocations(String query) async {
    if (query.isEmpty) return [];
    
    try {
      final results = await _openWeatherService.searchLocations(query);
      return results.map((json) => OpenWeatherLocation.fromJson(json)).toList();
    } catch (e) {
      _handleError(e);
      return [];
    }
  }

  // Set selected location
  void setSelectedLocation(OpenWeatherLocation location) {
    _selectedLocation = location;
    _errorMessage = null;
    notifyListeners();
  }

  // Fetch weather data for selected location
  Future<void> fetchWeatherData() async {
    if (_selectedLocation == null) return;
    
    _setLoading(true);
    _errorMessage = null;

    try {
      final currentData = await _openWeatherService.getCurrentWeather(
        _selectedLocation!.lat, 
        _selectedLocation!.lon
      );
      final forecastData = await _openWeatherService.getFiveDayForecast(
        _selectedLocation!.lat, 
        _selectedLocation!.lon
      );
      final hourlyData = await _openWeatherService.getHourlyForecast(
        _selectedLocation!.lat, 
        _selectedLocation!.lon
      );
      
      final current = OpenWeatherCurrentConditions.fromJson(currentData);
      final forecasts = _processDailyForecasts(forecastData);
      final hourlyForecasts = hourlyData
          .map((json) => OpenWeatherHourlyForecast.fromJson(json))
          .toList();

      _currentConditions = current;
      _dailyForecasts = forecasts;
      _hourlyForecasts = hourlyForecasts;
      _errorMessage = null;
    } catch (e) {
      _handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Fetch weather data for coordinates
  Future<void> fetchWeatherDataForCoordinates(double latitude, double longitude) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final locationData = await _openWeatherService.getLocationByCoordinates(latitude, longitude);
      final location = OpenWeatherLocation.fromJson(locationData);
      
      _selectedLocation = location;
      await fetchWeatherData();
    } catch (e) {
      _handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Get current location and fetch weather
  Future<void> fetchCurrentLocationWeather() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // Önce son bilinen konumu dene (daha hızlı)
      geolocator.Position? position = await LocationService.getLastKnownPosition();
      
      // Son bilinen konum yoksa yeni konum al
      position ??= await LocationService.getCurrentPosition();
      
      await fetchWeatherDataForCoordinates(position.latitude, position.longitude);
    } catch (e) {
      _handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Refresh weather data
  Future<void> refreshWeatherData() async {
    if (_selectedLocation != null) {
      await fetchWeatherData();
    }
  }

  // Clear data
  void clearData() {
    _selectedLocation = null;
    _currentConditions = null;
    _dailyForecasts = [];
    _hourlyForecasts = [];
    _errorMessage = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  List<OpenWeatherDailyForecast> _processDailyForecasts(Map<String, dynamic> forecastData) {
    final list = forecastData['list'] as List<dynamic>;
    final dailyForecasts = <OpenWeatherDailyForecast>[];
    
    // Her gün için bir tahmin oluştur (5 gün)
    for (int i = 0; i < 5 && i < list.length; i++) {
      final dayData = list[i];
      dailyForecasts.add(OpenWeatherDailyForecast.fromJson(dayData));
    }
    
    return dailyForecasts;
  }

  void _handleError(dynamic error) {
    String errorMessage = 'Bir hata oluştu';
    
    if (error is NetworkException) {
      errorMessage = 'İnternet bağlantısı yok. Lütfen bağlantınızı kontrol edin.';
    } else if (error is LocationException) {
      errorMessage = error.message;
    } else if (error is ApiException) {
      errorMessage = 'API hatası: ${error.message}';
    } else {
      errorMessage = 'Beklenmeyen bir hata oluştu: $error';
    }
    
    _errorMessage = errorMessage;
    _currentConditions = null;
    _dailyForecasts = [];
    _hourlyForecasts = [];
    notifyListeners();
  }
}
