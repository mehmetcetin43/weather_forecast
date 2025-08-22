import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart' show Position;
import 'package:weather_forecast/services/accuweather_service.dart';
import 'package:weather_forecast/services/location_service.dart';
import 'package:weather_forecast/models/weather_models.dart';
import 'package:weather_forecast/utils/exceptions.dart';

class WeatherProvider with ChangeNotifier {
  final AccuWeatherService _accuWeatherService = AccuWeatherService();
  
  // State variables
  Location? _selectedLocation;
  CurrentConditions? _currentConditions;
  List<DailyForecast> _dailyForecasts = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  Location? get selectedLocation => _selectedLocation;
  CurrentConditions? get currentConditions => _currentConditions;
  List<DailyForecast> get dailyForecasts => _dailyForecasts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasData => _currentConditions != null && _dailyForecasts.isNotEmpty;

  // Search locations
  Future<List<Location>> searchLocations(String query) async {
    if (query.isEmpty) return [];
    
    try {
      final results = await _accuWeatherService.searchLocations(query);
      return results.map((json) => Location.fromJson(json)).toList();
    } catch (e) {
      _handleError(e);
      return [];
    }
  }

  // Set selected location
  void setSelectedLocation(Location location) {
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
      final currentData = await _accuWeatherService.getCurrentConditions(_selectedLocation!.key);
      final forecastData = await _accuWeatherService.getFiveDayDailyForecast(_selectedLocation!.key);
      
      final current = CurrentConditions.fromJson(currentData);
      final forecasts = (forecastData['DailyForecasts'] as List<dynamic>)
          .map((json) => DailyForecast.fromJson(json))
          .toList();

      _currentConditions = current;
      _dailyForecasts = forecasts;
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
      final locationData = await _accuWeatherService.getLocationByCoordinates(latitude, longitude);
      final location = Location.fromJson(locationData);
      
      if (location.key.isNotEmpty) {
        _selectedLocation = location;
        await fetchWeatherData();
      } else {
        _errorMessage = 'Mevcut konum için hava durumu bulunamadı.';
      }
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
      Position? position = await LocationService.getLastKnownPosition();
      
      // Son bilinen konum yoksa yeni konum al
      if (position == null) {
        position = await LocationService.getCurrentPosition();
      }
      
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
    notifyListeners();
  }
}
