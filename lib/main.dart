import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_forecast/screens/location_search_screen.dart';
import 'package:weather_forecast/screens/weather_display_screen.dart';
import 'package:weather_forecast/theme/app_theme.dart';
import 'package:weather_forecast/providers/universal_weather_provider.dart';
import 'package:weather_forecast/services/api_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UniversalWeatherProvider(),
      child: MaterialApp(
        title: 'Weather Forecast',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const MainWeatherScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainWeatherScreen extends StatefulWidget {
  const MainWeatherScreen({super.key});

  @override
  State<MainWeatherScreen> createState() => _MainWeatherScreenState();
}

class _MainWeatherScreenState extends State<MainWeatherScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _bounceController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _bounceController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _navigateToLocationSearch() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocationSearchScreen()),
    );

    if (result != null && result is Map<String, dynamic> && mounted) {
      final weatherProvider = Provider.of<UniversalWeatherProvider>(
        context,
        listen: false,
      );
      weatherProvider.setSelectedLocation(result);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WeatherDisplayScreen(location: result),
        ),
      );
    }
  }

  Future<void> _fetchCurrentLocationWeather() async {
    final weatherProvider = Provider.of<UniversalWeatherProvider>(
      context,
      listen: false,
    );
    await weatherProvider.fetchCurrentLocationWeather();

    if (weatherProvider.selectedLocation != null &&
        weatherProvider.hasData &&
        mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => WeatherDisplayScreen(
                location: weatherProvider.selectedLocation!.toJson(),
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.defaultGradient),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  Expanded(child: _buildMainContent()),
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hava Durumu',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Tahmin Uygulaması',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        Icon(
          Icons.wb_sunny,
          size: 48,
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return Consumer<UniversalWeatherProvider>(
      builder: (context, weatherProvider, child) {
        return ScaleTransition(
          scale: _bounceAnimation,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Icon(
                  Icons.cloud,
                  size: 120,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                const SizedBox(height: 32),
                if (weatherProvider.isLoading)
                  Column(
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Hava durumu bilgileri alınıyor...',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                      ),
                    ],
                  )
                else if (weatherProvider.errorMessage != null)
                  Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Hata',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        weatherProvider.errorMessage!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                else if (weatherProvider.selectedLocation != null)
                  Card(
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
                            _getLocationName(weatherProvider.selectedLocation!),
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _getLocationSubtitle(
                              weatherProvider.selectedLocation!,
                            ),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => WeatherDisplayScreen(
                                        location:
                                            weatherProvider.selectedLocation!
                                                .toJson(),
                                      ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.visibility),
                            label: const Text('Hava Durumunu Görüntüle'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      Text(
                        'Hava durumu bilgilerini görüntülemek için',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'bir konum seçin veya mevcut konumunuzu kullanın',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Consumer<UniversalWeatherProvider>(
      builder: (context, weatherProvider, child) {
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _navigateToLocationSearch,
                icon: const Icon(Icons.search),
                label: const Text('Konum Ara'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed:
                    weatherProvider.isLoading
                        ? null
                        : _fetchCurrentLocationWeather,
                icon:
                    weatherProvider.isLoading
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.my_location),
                label: Text(
                  weatherProvider.isLoading
                      ? 'Konum Alınıyor...'
                      : 'Mevcut Konum',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getLocationName(dynamic location) {
    if (ApiManager.activeApiName == 'AccuWeather') {
      return location.localizedName;
    } else {
      return location.name;
    }
  }

  String _getLocationSubtitle(dynamic location) {
    if (ApiManager.activeApiName == 'AccuWeather') {
      return '${location.administrativeArea}, ${location.country}';
    } else {
      return '${location.state.isNotEmpty ? '${location.state}, ' : ''}${location.country}';
    }
  }
}
