import 'package:flutter/material.dart';
import 'package:weather_forecast/services/accuweather_service.dart';
import 'package:weather_forecast/models/weather_models.dart';
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
  final AccuWeatherService _accuWeatherService = AccuWeatherService();
  CurrentConditions? _currentConditions;
  List<DailyForecast> _dailyForecasts = [];
  List<HourlyForecast> _hourlyForecasts = [];
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
      final location = Location.fromJson(widget.location);
      
      final currentData = await _accuWeatherService.getCurrentConditions(location.key);
      final forecastData = await _accuWeatherService.getFiveDayDailyForecast(location.key);
      final hourlyData = await _accuWeatherService.getHourlyForecast(location.key);
      
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
    final location = Location.fromJson(widget.location);
    final weatherIcon = _currentConditions?.weatherIcon ?? 1;
    final isDay = _currentConditions?.isDayTime ?? true;
    
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

  Widget _buildWeatherContent(Location location, int weatherIcon, bool isDay) {
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

  Widget _buildLocationHeader(Location location) {
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
              location.localizedName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${location.administrativeArea}, ${location.country}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeather() {
    final current = _currentConditions!;
    final weatherIcon = current.weatherIcon;
    final isDay = current.isDayTime;
    
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
                        '${current.temperature.round()}°',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: WeatherIcons.getTemperatureColor(current.temperature),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        WeatherIcons.getWeatherDescription(weatherIcon),
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

  Widget _buildWeatherDetails(CurrentConditions current) {
    return Column(
      children: [
        _buildDetailRow(
          Icons.thermostat,
          'Hissedilen',
          '${current.realFeelTemperature.round()}°',
          WeatherIcons.getTemperatureColor(current.realFeelTemperature),
        ),
        const SizedBox(height: 12),
        _buildDetailRow(
          Icons.water_drop,
          'Nem',
          '%${current.relativeHumidity}',
          Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildDetailRow(
          Icons.air,
          'Rüzgar',
          '${current.windSpeed.round()} km/h',
          Colors.grey,
        ),
      ],
    );
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

  Widget _buildForecastCard(DailyForecast forecast) {
    final dayIcon = forecast.dayWeatherIcon;
    final nightIcon = forecast.nightWeatherIcon;
    
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
                        _formatDate(forecast.date),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatDay(forecast.date),
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
                        '${forecast.maxTemperature.round()}°',
                        WeatherIcons.getWeatherColor(dayIcon, isDay: true),
                      ),
                      _buildForecastItem(
                        WeatherIcons.getWeatherIcon(nightIcon, isDay: false),
                        'Gece',
                        '${forecast.minTemperature.round()}°',
                        WeatherIcons.getWeatherColor(nightIcon, isDay: false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (forecast.relativeHumidity != null || forecast.windSpeed != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (forecast.relativeHumidity != null)
                    _buildDetailItem(
                      Icons.water_drop,
                      'Nem',
                      '%${forecast.relativeHumidity}',
                      Colors.blue,
                    ),
                  if (forecast.windSpeed != null)
                    _buildDetailItem(
                      Icons.air,
                      'Rüzgar',
                      '${forecast.windSpeed!.round()} km/h',
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

  Widget _buildHourlyCard(HourlyForecast forecast) {
    return Card(
      margin: const EdgeInsets.only(right: 12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatHour(forecast.dateTime),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Icon(
              WeatherIcons.getWeatherIcon(forecast.weatherIcon, isDay: forecast.isDayTime),
              size: 32,
              color: WeatherIcons.getWeatherColor(forecast.weatherIcon, isDay: forecast.isDayTime),
            ),
            const SizedBox(height: 8),
            Text(
              '${forecast.temperature.round()}°',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: WeatherIcons.getTemperatureColor(forecast.temperature),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '%${forecast.relativeHumidity}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${forecast.windSpeed.round()} km/h',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatHour(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:00';
  }
}
