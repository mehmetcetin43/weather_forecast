import 'package:flutter_test/flutter_test.dart';
import 'package:weather_forecast/models/weather_models.dart';

void main() {
  group('Location Model Tests', () {
    test('fromJson should create Location correctly', () {
      final Map<String, dynamic> json = {
        'Key': 'test-key',
        'LocalizedName': 'Test City',
        'AdministrativeArea': {'LocalizedName': 'Test Area'},
        'Country': {'LocalizedName': 'Test Country'},
        'GeoPosition': {
          'Latitude': 40.7128,
          'Longitude': -74.0060,
        },
      };

      final location = Location.fromJson(json);

      expect(location.key, equals('test-key'));
      expect(location.localizedName, equals('Test City'));
      expect(location.administrativeArea, equals('Test Area'));
      expect(location.country, equals('Test Country'));
      expect(location.latitude, equals(40.7128));
      expect(location.longitude, equals(-74.0060));
    });

    test('toJson should return correct JSON', () {
      final location = Location(
        key: 'test-key',
        localizedName: 'Test City',
        administrativeArea: 'Test Area',
        country: 'Test Country',
        latitude: 40.7128,
        longitude: -74.0060,
      );

      final json = location.toJson();

      expect(json['Key'], equals('test-key'));
      expect(json['LocalizedName'], equals('Test City'));
      expect(json['AdministrativeArea']['LocalizedName'], equals('Test Area'));
      expect(json['Country']['LocalizedName'], equals('Test Country'));
      expect(json['GeoPosition']['Latitude'], equals(40.7128));
      expect(json['GeoPosition']['Longitude'], equals(-74.0060));
    });
  });

  group('CurrentConditions Model Tests', () {
    test('fromJson should create CurrentConditions correctly', () {
      final Map<String, dynamic> json = {
        'Temperature': {'Metric': {'Value': 25.0}},
        'RealFeelTemperature': {'Metric': {'Value': 27.0}},
        'WeatherText': 'Güneşli',
        'RelativeHumidity': 60,
        'Wind': {'Speed': {'Metric': {'Value': 15.0}}},
        'WeatherIcon': 1,
        'IsDayTime': true,
        'LocalObservationDateTime': '2024-01-01T12:00:00Z',
      };

      final conditions = CurrentConditions.fromJson(json);

      expect(conditions.temperature, equals(25.0));
      expect(conditions.realFeelTemperature, equals(27.0));
      expect(conditions.weatherText, equals('Güneşli'));
      expect(conditions.relativeHumidity, equals(60));
      expect(conditions.windSpeed, equals(15.0));
      expect(conditions.weatherIcon, equals(1));
      expect(conditions.isDayTime, equals(true));
    });

    test('fromJson should handle missing values', () {
      final Map<String, dynamic> json = {};

      final conditions = CurrentConditions.fromJson(json);

      expect(conditions.temperature, equals(0.0));
      expect(conditions.realFeelTemperature, equals(0.0));
      expect(conditions.weatherText, equals(''));
      expect(conditions.relativeHumidity, equals(0));
      expect(conditions.windSpeed, equals(0.0));
      expect(conditions.weatherIcon, equals(1));
      expect(conditions.isDayTime, equals(true));
    });
  });

  group('DailyForecast Model Tests', () {
    test('fromJson should create DailyForecast correctly', () {
      final Map<String, dynamic> json = {
        'Date': '2024-01-01T00:00:00Z',
        'Temperature': {
          'Minimum': {'Value': 15.0},
          'Maximum': {'Value': 25.0},
        },
        'Day': {
          'IconPhrase': 'Güneşli',
          'Icon': 1,
          'PrecipitationProbability': 10.0,
        },
        'Night': {
          'IconPhrase': 'Açık',
          'Icon': 33,
        },
      };

      final forecast = DailyForecast.fromJson(json);

      expect(forecast.minTemperature, equals(15.0));
      expect(forecast.maxTemperature, equals(25.0));
      expect(forecast.dayWeatherText, equals('Güneşli'));
      expect(forecast.nightWeatherText, equals('Açık'));
      expect(forecast.dayWeatherIcon, equals(1));
      expect(forecast.nightWeatherIcon, equals(33));
      expect(forecast.precipitationProbability, equals(10.0));
    });

    test('fromJson should handle missing values', () {
      final Map<String, dynamic> json = {};

      final forecast = DailyForecast.fromJson(json);

      expect(forecast.minTemperature, equals(0.0));
      expect(forecast.maxTemperature, equals(0.0));
      expect(forecast.dayWeatherText, equals(''));
      expect(forecast.nightWeatherText, equals(''));
      expect(forecast.dayWeatherIcon, equals(1));
      expect(forecast.nightWeatherIcon, equals(33));
      expect(forecast.precipitationProbability, isNull);
    });
  });
}
