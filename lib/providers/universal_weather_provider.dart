import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:weather_forecast/services/location_service.dart';
import 'package:weather_forecast/services/api_manager.dart';
import 'package:weather_forecast/utils/exceptions.dart';

/// Universal Weather Provider - Her iki API'yi de destekler
class UniversalWeatherProvider with ChangeNotifier {
  // State variables
  dynamic _selectedLocation;
  dynamic _currentConditions;
  List<dynamic> _dailyForecasts = [];
  List<dynamic> _hourlyForecasts = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  dynamic get selectedLocation => _selectedLocation;
  dynamic get currentConditions => _currentConditions;
  List<dynamic> get dailyForecasts => _dailyForecasts;
  List<dynamic> get hourlyForecasts => _hourlyForecasts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasData => _currentConditions != null && _dailyForecasts.isNotEmpty;
  String get activeApiName => ApiManager.activeApiName;

  // Search locations
  Future<List<dynamic>> searchLocations(String query) async {
    if (query.isEmpty) return [];
    
    try {
      final results = await ApiManager.searchLocations(query);
      return results;
    } catch (e) {
      _handleError(e);
      return [];
    }
  }

  // Set selected location
  void setSelectedLocation(dynamic location) {
    // Eğer location bir Map ise (JSON'dan geldiyse), model objesine çevir
    if (location is Map<String, dynamic>) {
      _selectedLocation = ApiManager.locationFromJson(location);
    } else {
      _selectedLocation = location;
    }
    _errorMessage = null;
    notifyListeners();
  }

  // Fetch weather data for selected location
  Future<void> fetchWeatherData() async {
    if (_selectedLocation == null) return;
    
    _setLoading(true);
    _errorMessage = null;

    try {
      final locationKey = ApiManager.getLocationKey(_selectedLocation);
      
      final currentData = await ApiManager.getCurrentWeather(locationKey);
      final forecastData = await ApiManager.getFiveDayForecast(locationKey);
      final hourlyData = await ApiManager.getHourlyForecast(locationKey);
      
      // Model dönüşümleri API'ye göre yapılacak
      _currentConditions = currentData;
      _dailyForecasts = forecastData['DailyForecasts'] ?? [];
      _hourlyForecasts = hourlyData;
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
      final locationData = await ApiManager.getLocationByCoordinates(latitude, longitude);
      final location = ApiManager.locationFromJson(locationData);
      
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
