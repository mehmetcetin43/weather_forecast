/// Güvenli int dönüşümü için yardımcı fonksiyon
int? _safeIntParse(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    return int.tryParse(value);
  }
  if (value is Map<String, dynamic>) {
    // API bazen Map döndürebiliyor, Value alanını kontrol et
    final mapValue = value['Value'];
    if (mapValue != null) {
      return _safeIntParse(mapValue);
    }
  }
  return null;
}

/// Güvenli double dönüşümü için yardımcı fonksiyon
double? _safeDoubleParse(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    return double.tryParse(value);
  }
  if (value is Map<String, dynamic>) {
    // API bazen Map döndürebiliyor, Value alanını kontrol et
    final mapValue = value['Value'];
    if (mapValue != null) {
      return _safeDoubleParse(mapValue);
    }
  }
  return null;
}

class Location {
  final String key;
  final String localizedName;
  final String administrativeArea;
  final String country;
  final double latitude;
  final double longitude;

  Location({
    required this.key,
    required this.localizedName,
    required this.administrativeArea,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      key: json['Key'] ?? '',
      localizedName: json['LocalizedName'] ?? '',
      administrativeArea: json['AdministrativeArea']?['LocalizedName'] ?? '',
      country: json['Country']?['LocalizedName'] ?? '',
      latitude: json['GeoPosition']?['Latitude']?.toDouble() ?? 0.0,
      longitude: json['GeoPosition']?['Longitude']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Key': key,
      'LocalizedName': localizedName,
      'AdministrativeArea': {'LocalizedName': administrativeArea},
      'Country': {'LocalizedName': country},
      'GeoPosition': {
        'Latitude': latitude,
        'Longitude': longitude,
      },
    };
  }
}

class CurrentConditions {
  final double temperature;
  final double realFeelTemperature;
  final String weatherText;
  final int relativeHumidity;
  final double windSpeed;
  final String? windDirection;
  final int weatherIcon;
  final bool isDayTime;
  final DateTime observationDateTime;
  final double? uvIndex;
  final double? visibility;
  final double? pressure;

  CurrentConditions({
    required this.temperature,
    required this.realFeelTemperature,
    required this.weatherText,
    required this.relativeHumidity,
    required this.windSpeed,
    this.windDirection,
    required this.weatherIcon,
    required this.isDayTime,
    required this.observationDateTime,
    this.uvIndex,
    this.visibility,
    this.pressure,
  });

  factory CurrentConditions.fromJson(Map<String, dynamic> json) {
    return CurrentConditions(
      temperature: json['Temperature']?['Metric']?['Value']?.toDouble() ?? 0.0,
      realFeelTemperature: json['RealFeelTemperature']?['Metric']?['Value']?.toDouble() ?? 0.0,
      weatherText: json['WeatherText'] ?? '',
      relativeHumidity: _safeIntParse(json['RelativeHumidity']) ?? 0,
      windSpeed: json['Wind']?['Speed']?['Metric']?['Value']?.toDouble() ?? 0.0,
      windDirection: json['Wind']?['Direction']?['Localized'],
      weatherIcon: _safeIntParse(json['WeatherIcon']) ?? 1,
      isDayTime: json['IsDayTime'] ?? true,
      observationDateTime: DateTime.parse(json['LocalObservationDateTime'] ?? DateTime.now().toIso8601String()),
      uvIndex: _safeDoubleParse(json['UVIndex']),
      visibility: json['Visibility']?['Metric']?['Value']?.toDouble(),
      pressure: json['Pressure']?['Metric']?['Value']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Temperature': {'Metric': {'Value': temperature}},
      'RealFeelTemperature': {'Metric': {'Value': realFeelTemperature}},
      'WeatherText': weatherText,
      'RelativeHumidity': relativeHumidity,
      'Wind': {
        'Speed': {'Metric': {'Value': windSpeed}},
        'Direction': windDirection != null ? {'Localized': windDirection} : null,
      },
      'WeatherIcon': weatherIcon,
      'IsDayTime': isDayTime,
      'LocalObservationDateTime': observationDateTime.toIso8601String(),
      'UVIndex': uvIndex,
      'Visibility': visibility != null ? {'Metric': {'Value': visibility}} : null,
      'Pressure': pressure != null ? {'Metric': {'Value': pressure}} : null,
    };
  }
}

class HourlyForecast {
  final DateTime dateTime;
  final double temperature;
  final double realFeelTemperature;
  final String weatherText;
  final int weatherIcon;
  final int relativeHumidity;
  final double windSpeed;
  final String windDirection;
  final double? uvIndex;
  final double? visibility;
  final double? pressure;
  final double? precipitationProbability;
  final bool isDayTime;

  HourlyForecast({
    required this.dateTime,
    required this.temperature,
    required this.realFeelTemperature,
    required this.weatherText,
    required this.weatherIcon,
    required this.relativeHumidity,
    required this.windSpeed,
    required this.windDirection,
    this.uvIndex,
    this.visibility,
    this.pressure,
    this.precipitationProbability,
    required this.isDayTime,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      dateTime: DateTime.parse(json['DateTime'] ?? DateTime.now().toIso8601String()),
      temperature: json['Temperature']?['Value']?.toDouble() ?? 0.0,
      realFeelTemperature: json['RealFeelTemperature']?['Value']?.toDouble() ?? 0.0,
      weatherText: json['IconPhrase'] ?? '',
      weatherIcon: _safeIntParse(json['WeatherIcon']) ?? 1,
      relativeHumidity: _safeIntParse(json['RelativeHumidity']) ?? 0,
      windSpeed: json['Wind']?['Speed']?['Value']?.toDouble() ?? 0.0,
      windDirection: json['Wind']?['Direction']?['Localized'] ?? '',
      uvIndex: _safeDoubleParse(json['UVIndex']),
      visibility: json['Visibility']?['Value']?.toDouble(),
      pressure: json['Pressure']?['Value']?.toDouble(),
      precipitationProbability: json['PrecipitationProbability']?.toDouble(),
      isDayTime: json['IsDaylight'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'DateTime': dateTime.toIso8601String(),
      'Temperature': {'Value': temperature},
      'RealFeelTemperature': {'Value': realFeelTemperature},
      'IconPhrase': weatherText,
      'WeatherIcon': weatherIcon,
      'RelativeHumidity': relativeHumidity,
      'Wind': {
        'Speed': {'Value': windSpeed},
        'Direction': {'Localized': windDirection},
      },
      'UVIndex': uvIndex,
      'Visibility': visibility != null ? {'Value': visibility} : null,
      'Pressure': pressure != null ? {'Value': pressure} : null,
      'PrecipitationProbability': precipitationProbability,
      'IsDaylight': isDayTime,
    };
  }
}

class DailyForecast {
  final DateTime date;
  final double maxTemperature;
  final double minTemperature;
  final String dayWeatherText;
  final String nightWeatherText;
  final int dayWeatherIcon;
  final int nightWeatherIcon;
  final double? precipitationProbability;
  final double? windSpeed;
  final String? windDirection;
  final int? relativeHumidity;

  DailyForecast({
    required this.date,
    required this.maxTemperature,
    required this.minTemperature,
    required this.dayWeatherText,
    required this.nightWeatherText,
    required this.dayWeatherIcon,
    required this.nightWeatherIcon,
    this.precipitationProbability,
    this.windSpeed,
    this.windDirection,
    this.relativeHumidity,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    final temp = json['Temperature'] ?? {};
    final day = json['Day'] ?? {};
    final night = json['Night'] ?? {};
    
    return DailyForecast(
      date: DateTime.parse(json['Date'] ?? DateTime.now().toIso8601String()),
      maxTemperature: temp['Maximum']?['Value']?.toDouble() ?? 0.0,
      minTemperature: temp['Minimum']?['Value']?.toDouble() ?? 0.0,
      dayWeatherText: day['IconPhrase'] ?? '',
      nightWeatherText: night['IconPhrase'] ?? '',
      dayWeatherIcon: _safeIntParse(day['Icon']) ?? 1,
      nightWeatherIcon: _safeIntParse(night['Icon']) ?? 33,
      precipitationProbability: day['PrecipitationProbability']?.toDouble(),
      windSpeed: day['Wind']?['Speed']?['Value']?.toDouble(),
      windDirection: day['Wind']?['Direction']?['Localized'],
      relativeHumidity: _safeIntParse(day['RelativeHumidity']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Date': date.toIso8601String(),
      'Temperature': {
        'Maximum': {'Value': maxTemperature},
        'Minimum': {'Value': minTemperature},
      },
      'Day': {
        'IconPhrase': dayWeatherText,
        'Icon': dayWeatherIcon,
        'PrecipitationProbability': precipitationProbability,
        'Wind': windSpeed != null ? {
          'Speed': {'Value': windSpeed},
          'Direction': windDirection != null ? {'Localized': windDirection} : null,
        } : null,
        'RelativeHumidity': relativeHumidity,
      },
      'Night': {
        'IconPhrase': nightWeatherText,
        'Icon': nightWeatherIcon,
      },
    };
  }
}

class WeatherData {
  final Location location;
  final CurrentConditions currentConditions;
  final List<DailyForecast> dailyForecasts;
  final List<HourlyForecast> hourlyForecasts;

  WeatherData({
    required this.location,
    required this.currentConditions,
    required this.dailyForecasts,
    required this.hourlyForecasts,
  });

  Map<String, dynamic> toJson() {
    return {
      'location': location.toJson(),
      'currentConditions': currentConditions.toJson(),
      'dailyForecasts': dailyForecasts.map((f) => f.toJson()).toList(),
      'hourlyForecasts': hourlyForecasts.map((f) => f.toJson()).toList(),
    };
  }
}
