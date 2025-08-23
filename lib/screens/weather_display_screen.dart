import 'package:flutter/material.dart';
import 'package:weather_forecast/services/api_manager.dart';
import 'package:weather_forecast/models/weather_models.dart';
import 'package:weather_forecast/models/openweather_models.dart';
import 'package:weather_forecast/utils/weather_icons.dart';
import 'package:weather_forecast/theme/app_theme.dart';
import 'package:weather_forecast/utils/exceptions.dart';

class WeatherDisplayScreen extends StatefulWidget {
  final Map<String, dynamic> location;

  const WeatherDisplayScreen({super.key, required this.location});

  @override
  State<WeatherDisplayScreen> createState() => _WeatherDisplayScreenState();
}

class _WeatherDisplayScreenState extends State<WeatherDisplayScreen>
    with TickerProviderStateMixin {
  dynamic _currentConditions;
  List<dynamic> _dailyForecasts = [];
  List<dynamic> _hourlyForecasts = [];
  String? _errorMessage;
  bool _isLoading = true;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    
    _fetchWeatherData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _fetchWeatherData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Location'ı API Manager ile parse et
      final location = ApiManager.locationFromJson(widget.location);
      final locationKey = ApiManager.getLocationKey(location);
      
      // API Manager üzerinden veri çek
      final currentData = await ApiManager.getCurrentWeather(locationKey);
      final forecastData = await ApiManager.getFiveDayForecast(locationKey);
      final hourlyData = await ApiManager.getHourlyForecast(locationKey);
      
      // API'ye göre model objelerini oluştur
      if (ApiManager.activeApiName == 'AccuWeather') {
        final current = CurrentConditions.fromJson(currentData);
        final forecasts = (forecastData['DailyForecasts'] as List<dynamic>)
            .map((json) => DailyForecast.fromJson(json))
            .toList();
        final hourlyForecasts = hourlyData
            .map((json) => HourlyForecast.fromJson(json))
            .toList();

        setState(() {
          _currentConditions = current;
          _dailyForecasts = forecasts;
          _hourlyForecasts = hourlyForecasts;
        });
             } else {
         // OpenWeatherMap
         final current = OpenWeatherCurrentConditions.fromJson(currentData);
         
         // OpenWeatherMap forecast endpoint'i saatlik veri döndürür
         // Günlük veriyi 12:00 saatlerinden çıkaralım
         final allForecasts = (forecastData['list'] as List<dynamic>);
         final dailyForecasts = <Map<String, dynamic>>[];
         
         // Her gün için 12:00 saatindeki veriyi al
         final seenDays = <String>{};
         for (final item in allForecasts) {
           final dtTxt = item['dt_txt'] as String;
           final date = dtTxt.split(' ')[0]; // YYYY-MM-DD
           
           if (dtTxt.contains('12:00:00') && !seenDays.contains(date)) {
             seenDays.add(date);
             dailyForecasts.add(Map<String, dynamic>.from(item));
             
             if (dailyForecasts.length >= 5) break;
           }
         }
         
         final forecasts = dailyForecasts
             .map((json) => OpenWeatherDailyForecast.fromJson(json))
             .toList();
         final hourlyForecasts = hourlyData
             .map((json) => OpenWeatherHourlyForecast.fromJson(json))
             .toList();

         setState(() {
           _currentConditions = current;
           _dailyForecasts = forecasts;
           _hourlyForecasts = hourlyForecasts;
         });
       }

      // Start animations
      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      String errorMessage = 'Hava durumu verileri alınamadı';
      
      if (e is NetworkException) {
        errorMessage = 'İnternet bağlantısı yok. Lütfen bağlantınızı kontrol edin.';
      } else if (e is ApiException) {
        errorMessage = 'API hatası: ${e.message}';
      } else if (e is LocationException) {
        errorMessage = 'Konum hatası: ${e.message}';
      }
      
      setState(() {
        _errorMessage = errorMessage;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = ApiManager.locationFromJson(widget.location);
    final weatherIcon = _getWeatherIcon();
    final isDay = _getIsDayTime();
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.getWeatherGradient(weatherIcon, isDay: isDay),
        ),
        child: SafeArea(
          child: _isLoading
              ? _buildLoadingScreen()
              : _errorMessage != null
                  ? _buildErrorScreen()
                  : _buildWeatherContent(location, weatherIcon, isDay),
        ),
      ),
    );
  }

  int _getWeatherIcon() {
    if (_currentConditions == null) return 1;
    if (ApiManager.activeApiName == 'AccuWeather') {
      return (_currentConditions as CurrentConditions).weatherIcon;
    } else {
      return (_currentConditions as OpenWeatherCurrentConditions).weatherIcon;
    }
  }

  bool _getIsDayTime() {
    if (_currentConditions == null) return true;
    if (ApiManager.activeApiName == 'AccuWeather') {
      return (_currentConditions as CurrentConditions).isDayTime;
    } else {
      return (_currentConditions as OpenWeatherCurrentConditions).isDayTime;
    }
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Hava durumu bilgileri alınıyor...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              'Hata',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchWeatherData,
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherContent(dynamic location, int weatherIcon, bool isDay) {
    return RefreshIndicator(
      onRefresh: _fetchWeatherData,
      color: Colors.white,
      backgroundColor: AppTheme.primaryBlue,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLocationHeader(location),
                  const SizedBox(height: 24),
                  if (_currentConditions != null) _buildCurrentWeather(),
                  const SizedBox(height: 24),
                  _buildForecastSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationHeader(dynamic location) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(
              Icons.location_on,
              size: 32,
              color: AppTheme.primaryBlue,
            ),
            const SizedBox(height: 8),
            Text(
              _getLocationName(location),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _getLocationSubtitle(location),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLocationName(dynamic location) {
    if (ApiManager.activeApiName == 'AccuWeather') {
      return (location as Location).localizedName;
    } else {
      return (location as OpenWeatherLocation).name;
    }
  }

  String _getLocationSubtitle(dynamic location) {
    if (ApiManager.activeApiName == 'AccuWeather') {
      final accuLocation = location as Location;
      return '${accuLocation.administrativeArea}, ${accuLocation.country}';
    } else {
      final openWeatherLocation = location as OpenWeatherLocation;
      return '${openWeatherLocation.state.isNotEmpty ? '${openWeatherLocation.state}, ' : ''}${openWeatherLocation.country}';
    }
  }

  Widget _buildCurrentWeather() {
    final current = _currentConditions!;
    final weatherIcon = _getWeatherIcon();
    final isDay = _getIsDayTime();
    final temperature = _getTemperature();
    final weatherDescription = _getWeatherDescription();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${temperature.round()}°',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: WeatherIcons.getTemperatureColor(temperature),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        weatherDescription,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  WeatherIcons.getWeatherIcon(weatherIcon, isDay: isDay),
                  size: 80,
                  color: WeatherIcons.getWeatherColor(weatherIcon, isDay: isDay),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildWeatherDetails(current),
          ],
        ),
      ),
    );
  }

  double _getTemperature() {
    if (ApiManager.activeApiName == 'AccuWeather') {
      return (_currentConditions as CurrentConditions).temperature;
    } else {
      return (_currentConditions as OpenWeatherCurrentConditions).temperature;
    }
  }

  String _getWeatherDescription() {
    if (ApiManager.activeApiName == 'AccuWeather') {
      final weatherIcon = (_currentConditions as CurrentConditions).weatherIcon;
      return WeatherIcons.getWeatherDescription(weatherIcon);
    } else {
      final weatherIcon = (_currentConditions as OpenWeatherCurrentConditions).weatherIcon;
      return WeatherIcons.getWeatherDescription(weatherIcon);
    }
  }

  Widget _buildWeatherDetails(dynamic current) {
    return Column(
      children: [
        _buildDetailRow(
          Icons.thermostat,
          'Hissedilen',
          '${_getRealFeelTemperature().round()}°',
          WeatherIcons.getTemperatureColor(_getRealFeelTemperature()),
        ),
        const SizedBox(height: 12),
        _buildDetailRow(
          Icons.water_drop,
          'Nem',
          '%${_getRelativeHumidity()}',
          Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildDetailRow(
          Icons.air,
          'Rüzgar',
          '${_getWindSpeed().round()} km/h',
          Colors.grey,
        ),
      ],
    );
  }

  double _getRealFeelTemperature() {
    if (ApiManager.activeApiName == 'AccuWeather') {
      return (_currentConditions as CurrentConditions).realFeelTemperature;
    } else {
      return (_currentConditions as OpenWeatherCurrentConditions).feelsLike;
    }
  }

  int _getRelativeHumidity() {
    if (ApiManager.activeApiName == 'AccuWeather') {
      return (_currentConditions as CurrentConditions).relativeHumidity;
    } else {
      return (_currentConditions as OpenWeatherCurrentConditions).humidity;
    }
  }

  double _getWindSpeed() {
    if (ApiManager.activeApiName == 'AccuWeather') {
      return (_currentConditions as CurrentConditions).windSpeed;
    } else {
      return (_currentConditions as OpenWeatherCurrentConditions).windSpeed;
    }
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildForecastSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_hourlyForecasts.isNotEmpty) ...[
          Text(
            'Saatlik Tahmin',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildHourlyForecast(),
          const SizedBox(height: 32),
        ],
        Text(
          '5 Günlük Tahmin',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._dailyForecasts.map((forecast) => _buildForecastCard(forecast)),
      ],
    );
  }

  Widget _buildForecastCard(dynamic forecast) {
    final dayIcon = _getDayWeatherIcon(forecast);
    final nightIcon = _getNightWeatherIcon(forecast);
    final date = _getForecastDate(forecast);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(date),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatDay(date),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildForecastItem(
                        WeatherIcons.getWeatherIcon(dayIcon, isDay: true),
                        'Gündüz',
                        '${_getMaxTemperature(forecast).round()}°',
                        WeatherIcons.getWeatherColor(dayIcon, isDay: true),
                      ),
                      _buildForecastItem(
                        WeatherIcons.getWeatherIcon(nightIcon, isDay: false),
                        'Gece',
                        '${_getMinTemperature(forecast).round()}°',
                        WeatherIcons.getWeatherColor(nightIcon, isDay: false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_getForecastHumidity(forecast) != null || _getForecastWindSpeed(forecast) != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (_getForecastHumidity(forecast) != null)
                    _buildDetailItem(
                      Icons.water_drop,
                      'Nem',
                      '%${_getForecastHumidity(forecast)}',
                      Colors.blue,
                    ),
                  if (_getForecastWindSpeed(forecast) != null)
                    _buildDetailItem(
                      Icons.air,
                      'Rüzgar',
                      '${_getForecastWindSpeed(forecast)!.round()} km/h',
                      Colors.grey,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  int _getDayWeatherIcon(dynamic forecast) {
    if (ApiManager.activeApiName == 'AccuWeather') {
      return (forecast as DailyForecast).dayWeatherIcon;
    } else {
      return (forecast as OpenWeatherDailyForecast).weatherIcon;
    }
  }

  int _getNightWeatherIcon(dynamic forecast) {
    if (ApiManager.activeApiName == 'AccuWeather') {
      return (forecast as DailyForecast).nightWeatherIcon;
    } else {
      return (forecast as OpenWeatherDailyForecast).weatherIcon;
    }
  }

  DateTime _getForecastDate(dynamic forecast) {
    if (ApiManager.activeApiName == 'AccuWeather') {
      return (forecast as DailyForecast).date;
    } else {
      return (forecast as OpenWeatherDailyForecast).date;
    }
  }

  double _getMaxTemperature(dynamic forecast) {
    if (ApiManager.activeApiName == 'AccuWeather') {
      return (forecast as DailyForecast).maxTemperature;
    } else {
      return (forecast as OpenWeatherDailyForecast).maxTemperature;
    }
  }

  double _getMinTemperature(dynamic forecast) {
    if (ApiManager.activeApiName == 'AccuWeather') {
      return (forecast as DailyForecast).minTemperature;
    } else {
      return (forecast as OpenWeatherDailyForecast).minTemperature;
    }
  }

  int? _getForecastHumidity(dynamic forecast) {
    if (ApiManager.activeApiName == 'AccuWeather') {
      return (forecast as DailyForecast).relativeHumidity;
    } else {
      return (forecast as OpenWeatherDailyForecast).humidity;
    }
  }

  double? _getForecastWindSpeed(dynamic forecast) {
    if (ApiManager.activeApiName == 'AccuWeather') {
      return (forecast as DailyForecast).windSpeed;
    } else {
      return (forecast as OpenWeatherDailyForecast).windSpeed;
    }
  }

  Widget _buildForecastItem(IconData icon, String label, String temp, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          temp,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }

  String _formatDay(DateTime date) {
    final days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return days[date.weekday - 1];
  }

  Widget _buildHourlyForecast() {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _hourlyForecasts.length,
        itemBuilder: (context, index) {
          final forecast = _hourlyForecasts[index];
          return _buildHourlyCard(forecast);
        },
      ),
    );
  }

  Widget _buildHourlyCard(dynamic forecast) {
    return Card(
      margin: const EdgeInsets.only(right: 12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                _formatHour(_getHourlyDateTime(forecast)),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Icon(
                WeatherIcons.getWeatherIcon(_getHourlyWeatherIcon(forecast), isDay: _getHourlyIsDayTime(forecast)),
                size: 32,
                color: WeatherIcons.getWeatherColor(_getHourlyWeatherIcon(forecast), isDay: _getHourlyIsDayTime(forecast)),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                '${_getHourlyTemperature(forecast).round()}°',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: WeatherIcons.getTemperatureColor(_getHourlyTemperature(forecast)),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                '%${_getHourlyHumidity(forecast)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                '${_getHourlyWindSpeed(forecast).round()} km/h',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  DateTime _getHourlyDateTime(dynamic forecast) {
    if (ApiManager.activeApiName == 'AccuWeather') {
      return (forecast as HourlyForecast).dateTime;
    } else {
      return (forecast as OpenWeatherHourlyForecast).dateTime;
    }
  }

  int _getHourlyWeatherIcon(dynamic forecast) {
    if (ApiManager.activeApiName == 'AccuWeather') {
      return (forecast as HourlyForecast).weatherIcon;
    } else {
      return (forecast as OpenWeatherHourlyForecast).weatherIcon;
    }
  }

  bool _getHourlyIsDayTime(dynamic forecast) {
    if (ApiManager.activeApiName == 'AccuWeather') {
      return (forecast as HourlyForecast).isDayTime;
    } else {
      return (forecast as OpenWeatherHourlyForecast).isDayTime;
    }
  }

  double _getHourlyTemperature(dynamic forecast) {
    if (ApiManager.activeApiName == 'AccuWeather') {
      return (forecast as HourlyForecast).temperature;
    } else {
      return (forecast as OpenWeatherHourlyForecast).temperature;
    }
  }

  int _getHourlyHumidity(dynamic forecast) {
    if (ApiManager.activeApiName == 'AccuWeather') {
      return (forecast as HourlyForecast).relativeHumidity;
    } else {
      return (forecast as OpenWeatherHourlyForecast).humidity;
    }
  }

  double _getHourlyWindSpeed(dynamic forecast) {
    if (ApiManager.activeApiName == 'AccuWeather') {
      return (forecast as HourlyForecast).windSpeed;
    } else {
      return (forecast as OpenWeatherHourlyForecast).windSpeed;
    }
  }

  String _formatHour(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:00';
  }
}
