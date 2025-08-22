import 'package:flutter_test/flutter_test.dart';
import 'package:weather_forecast/providers/weather_provider.dart';
import 'package:weather_forecast/models/weather_models.dart';

void main() {
  group('WeatherProvider Tests', () {
    late WeatherProvider weatherProvider;

    setUp(() {
      weatherProvider = WeatherProvider();
    });

    test('initial state should be correct', () {
      expect(weatherProvider.selectedLocation, isNull);
      expect(weatherProvider.currentConditions, isNull);
      expect(weatherProvider.dailyForecasts, isEmpty);
      expect(weatherProvider.isLoading, isFalse);
      expect(weatherProvider.errorMessage, isNull);
      expect(weatherProvider.hasData, isFalse);
    });

    test('setSelectedLocation should update selectedLocation', () {
      final location = Location(
        key: 'test-key',
        localizedName: 'Test City',
        administrativeArea: 'Test Area',
        country: 'Test Country',
      );

      weatherProvider.setSelectedLocation(location);

      expect(weatherProvider.selectedLocation, equals(location));
      expect(weatherProvider.errorMessage, isNull);
    });

    test('clearData should reset all data', () {
      // First set some data
      final location = Location(
        key: 'test-key',
        localizedName: 'Test City',
        administrativeArea: 'Test Area',
        country: 'Test Country',
      );
      weatherProvider.setSelectedLocation(location);

      // Then clear data
      weatherProvider.clearData();

      expect(weatherProvider.selectedLocation, isNull);
      expect(weatherProvider.currentConditions, isNull);
      expect(weatherProvider.dailyForecasts, isEmpty);
      expect(weatherProvider.errorMessage, isNull);
    });

    test('clearError should clear error message', () {
      // Simulate an error state
      weatherProvider.clearError();
      expect(weatherProvider.errorMessage, isNull);
    });

    test('searchLocations should return empty list for empty query', () async {
      final results = await weatherProvider.searchLocations('');
      expect(results, isEmpty);
    });

    test('fetchWeatherData should not proceed without selected location', () async {
      await weatherProvider.fetchWeatherData();
      expect(weatherProvider.currentConditions, isNull);
      expect(weatherProvider.dailyForecasts, isEmpty);
    });
  });
}
