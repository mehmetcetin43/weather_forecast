class Location {
  final String key;
  final String localizedName;
  final String administrativeArea;
  final String country;
  final double? latitude;
  final double? longitude;

  Location({
    required this.key,
    required this.localizedName,
    required this.administrativeArea,
    required this.country,
    this.latitude,
    this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      key: json['Key'] ?? '',
      localizedName: json['LocalizedName'] ?? '',
      administrativeArea: json['AdministrativeArea']?['LocalizedName'] ?? '',
      country: json['Country']?['LocalizedName'] ?? '',
      latitude: json['GeoPosition']?['Latitude']?.toDouble(),
      longitude: json['GeoPosition']?['Longitude']?.toDouble(),
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
  final int weatherIcon;
  final bool isDayTime;
  final DateTime localObservationDateTime;

  CurrentConditions({
    required this.temperature,
    required this.realFeelTemperature,
    required this.weatherText,
    required this.relativeHumidity,
    required this.windSpeed,
    required this.weatherIcon,
    required this.isDayTime,
    required this.localObservationDateTime,
  });

  factory CurrentConditions.fromJson(Map<String, dynamic> json) {
    return CurrentConditions(
      temperature: json['Temperature']?['Metric']?['Value']?.toDouble() ?? 0.0,
      realFeelTemperature: json['RealFeelTemperature']?['Metric']?['Value']?.toDouble() ?? 0.0,
      weatherText: json['WeatherText'] ?? '',
      relativeHumidity: json['RelativeHumidity'] ?? 0,
      windSpeed: json['Wind']?['Speed']?['Metric']?['Value']?.toDouble() ?? 0.0,
      weatherIcon: json['WeatherIcon'] ?? 1,
      isDayTime: json['IsDayTime'] ?? true,
      localObservationDateTime: DateTime.tryParse(json['LocalObservationDateTime'] ?? '') ?? DateTime.now(),
    );
  }
}

class DailyForecast {
  final DateTime date;
  final double minTemperature;
  final double maxTemperature;
  final String dayIconPhrase;
  final String nightIconPhrase;
  final int dayIcon;
  final int nightIcon;
  final double precipitationProbability;

  DailyForecast({
    required this.date,
    required this.minTemperature,
    required this.maxTemperature,
    required this.dayIconPhrase,
    required this.nightIconPhrase,
    required this.dayIcon,
    required this.nightIcon,
    required this.precipitationProbability,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: DateTime.tryParse(json['Date'] ?? '') ?? DateTime.now(),
      minTemperature: json['Temperature']?['Minimum']?['Value']?.toDouble() ?? 0.0,
      maxTemperature: json['Temperature']?['Maximum']?['Value']?.toDouble() ?? 0.0,
      dayIconPhrase: json['Day']?['IconPhrase'] ?? '',
      nightIconPhrase: json['Night']?['IconPhrase'] ?? '',
      dayIcon: json['Day']?['Icon'] ?? 1,
      nightIcon: json['Night']?['Icon'] ?? 1,
      precipitationProbability: json['Day']?['PrecipitationProbability']?.toDouble() ?? 0.0,
    );
  }
}

class WeatherData {
  final Location location;
  final CurrentConditions? currentConditions;
  final List<DailyForecast> dailyForecasts;

  WeatherData({
    required this.location,
    this.currentConditions,
    required this.dailyForecasts,
  });
}
