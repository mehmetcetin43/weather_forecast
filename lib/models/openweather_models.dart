/// OpenWeatherMap için güvenli dönüşüm yardımcı fonksiyonları
int? _safeIntParse(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    return int.tryParse(value);
  }
  if (value is Map<String, dynamic>) {
    final mapValue = value['Value'];
    if (mapValue != null) {
      return _safeIntParse(mapValue);
    }
  }
  return null;
}

double? _safeDoubleParse(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    return double.tryParse(value);
  }
  if (value is Map<String, dynamic>) {
    final mapValue = value['Value'];
    if (mapValue != null) {
      return _safeDoubleParse(mapValue);
    }
  }
  return null;
}

/// OpenWeatherMap Konum Modeli
class OpenWeatherLocation {
  final String name;
  final String country;
  final String state;
  final double lat;
  final double lon;

  OpenWeatherLocation({
    required this.name,
    required this.country,
    required this.state,
    required this.lat,
    required this.lon,
  });

  factory OpenWeatherLocation.fromJson(Map<String, dynamic> json) {
    return OpenWeatherLocation(
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      state: json['state'] ?? '',
      lat: json['lat']?.toDouble() ?? 0.0,
      lon: json['lon']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'country': country,
      'state': state,
      'lat': lat,
      'lon': lon,
    };
  }
}

/// OpenWeatherMap Mevcut Hava Durumu Modeli
class OpenWeatherCurrentConditions {
  final double temperature;
  final double feelsLike;
  final String weatherDescription;
  final int weatherIcon;
  final int humidity;
  final double windSpeed;
  final int windDirection;
  final double pressure;
  final double visibility;
  final DateTime dateTime;
  final bool isDayTime;

  OpenWeatherCurrentConditions({
    required this.temperature,
    required this.feelsLike,
    required this.weatherDescription,
    required this.weatherIcon,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.pressure,
    required this.visibility,
    required this.dateTime,
    required this.isDayTime,
  });

  factory OpenWeatherCurrentConditions.fromJson(Map<String, dynamic> json) {
    final weather = json['weather']?[0] ?? {};
    final main = json['main'] ?? {};
    final wind = json['wind'] ?? {};
    
    final dateTime = DateTime.fromMillisecondsSinceEpoch(
      (json['dt'] ?? 0) * 1000,
    );
    final hour = dateTime.hour;
    final isDayTime = hour >= 6 && hour <= 18;
    
    return OpenWeatherCurrentConditions(
      temperature: _safeDoubleParse(main['temp']) ?? 0.0,
      feelsLike: _safeDoubleParse(main['feels_like']) ?? 0.0,
      weatherDescription: weather['description'] ?? '',
      weatherIcon: _safeIntParse(weather['id']) ?? 800,
      humidity: _safeIntParse(main['humidity']) ?? 0,
      windSpeed: _safeDoubleParse(wind['speed']) ?? 0.0,
      windDirection: _safeIntParse(wind['deg']) ?? 0,
      pressure: _safeDoubleParse(main['pressure']) ?? 0.0,
      visibility: _safeDoubleParse(json['visibility']) ?? 0.0,
      dateTime: dateTime,
      isDayTime: isDayTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'feelsLike': feelsLike,
      'weatherDescription': weatherDescription,
      'weatherIcon': weatherIcon,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'pressure': pressure,
      'visibility': visibility,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'isDayTime': isDayTime,
    };
  }
}

/// OpenWeatherMap Saatlik Tahmin Modeli
class OpenWeatherHourlyForecast {
  final DateTime dateTime;
  final double temperature;
  final double feelsLike;
  final String weatherDescription;
  final int weatherIcon;
  final int humidity;
  final double windSpeed;
  final int windDirection;
  final double pressure;
  final double? precipitationProbability;
  final bool isDayTime;

  OpenWeatherHourlyForecast({
    required this.dateTime,
    required this.temperature,
    required this.feelsLike,
    required this.weatherDescription,
    required this.weatherIcon,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.pressure,
    this.precipitationProbability,
    required this.isDayTime,
  });

  factory OpenWeatherHourlyForecast.fromJson(Map<String, dynamic> json) {
    final weather = json['weather']?[0] ?? {};
    final main = json['main'] ?? {};
    final wind = json['wind'] ?? {};
    final pop = json['pop']; // Precipitation probability
    
    final dateTime = DateTime.fromMillisecondsSinceEpoch(
      (json['dt'] ?? 0) * 1000,
    );
    final hour = dateTime.hour;
    final isDayTime = hour >= 6 && hour <= 18;
    
    return OpenWeatherHourlyForecast(
      dateTime: dateTime,
      temperature: _safeDoubleParse(main['temp']) ?? 0.0,
      feelsLike: _safeDoubleParse(main['feels_like']) ?? 0.0,
      weatherDescription: weather['description'] ?? '',
      weatherIcon: _safeIntParse(weather['id']) ?? 800,
      humidity: _safeIntParse(main['humidity']) ?? 0,
      windSpeed: _safeDoubleParse(wind['speed']) ?? 0.0,
      windDirection: _safeIntParse(wind['deg']) ?? 0,
      pressure: _safeDoubleParse(main['pressure']) ?? 0.0,
      precipitationProbability: pop != null ? (_safeDoubleParse(pop) ?? 0.0) * 100 : null,
      isDayTime: isDayTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateTime': dateTime.millisecondsSinceEpoch,
      'temperature': temperature,
      'feelsLike': feelsLike,
      'weatherDescription': weatherDescription,
      'weatherIcon': weatherIcon,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'pressure': pressure,
      'precipitationProbability': precipitationProbability,
      'isDayTime': isDayTime,
    };
  }
}

/// OpenWeatherMap Günlük Tahmin Modeli
class OpenWeatherDailyForecast {
  final DateTime date;
  final double maxTemperature;
  final double minTemperature;
  final String dayWeatherDescription;
  final String nightWeatherDescription;
  final int dayWeatherIcon;
  final int nightWeatherIcon;
  final int weatherIcon; // Genel weather icon
  final int humidity;
  final double windSpeed;
  final int windDirection;
  final double? precipitationProbability;

  OpenWeatherDailyForecast({
    required this.date,
    required this.maxTemperature,
    required this.minTemperature,
    required this.dayWeatherDescription,
    required this.nightWeatherDescription,
    required this.dayWeatherIcon,
    required this.nightWeatherIcon,
    required this.weatherIcon,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    this.precipitationProbability,
  });

  factory OpenWeatherDailyForecast.fromJson(Map<String, dynamic> json) {
    final main = json['main'] ?? {};
    final weather = json['weather']?[0] ?? {};
    final wind = json['wind'] ?? {};
    
    return OpenWeatherDailyForecast(
      date: DateTime.fromMillisecondsSinceEpoch(
        (json['dt'] ?? 0) * 1000,
      ),
      maxTemperature: _safeDoubleParse(main['temp']) ?? 0.0,
      minTemperature: _safeDoubleParse(main['temp']) ?? 0.0, // Aynı sıcaklık
      dayWeatherDescription: weather['description'] ?? '',
      nightWeatherDescription: weather['description'] ?? '',
      dayWeatherIcon: _safeIntParse(weather['id']) ?? 800,
      nightWeatherIcon: _safeIntParse(weather['id']) ?? 800,
      weatherIcon: _safeIntParse(weather['id']) ?? 800,
      humidity: _safeIntParse(main['humidity']) ?? 0,
      windSpeed: _safeDoubleParse(wind['speed']) ?? 0.0,
      windDirection: _safeIntParse(wind['deg']) ?? 0,
      precipitationProbability: _safeDoubleParse(json['pop']) != null ? (_safeDoubleParse(json['pop'])! * 100) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.millisecondsSinceEpoch,
      'maxTemperature': maxTemperature,
      'minTemperature': minTemperature,
      'dayWeatherDescription': dayWeatherDescription,
      'nightWeatherDescription': nightWeatherDescription,
      'dayWeatherIcon': dayWeatherIcon,
      'nightWeatherIcon': nightWeatherIcon,
      'weatherIcon': weatherIcon,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'precipitationProbability': precipitationProbability,
    };
  }
}

/// OpenWeatherMap Hava Durumu Verisi Modeli
class OpenWeatherData {
  final OpenWeatherLocation location;
  final OpenWeatherCurrentConditions currentConditions;
  final List<OpenWeatherDailyForecast> dailyForecasts;
  final List<OpenWeatherHourlyForecast> hourlyForecasts;

  OpenWeatherData({
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
