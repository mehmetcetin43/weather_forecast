class Env {
  // API Selection - Burayı değiştirerek API seçimi yapabilirsiniz
  static const String activeApi = 'openweather'; // 'accuweather' veya 'openweather'
  
  // AccuWeather API Configuration
  static const String accuWeatherApiKey = 'bCIjxKsLM39fGvY8SIms7r5T08vwRsOG';
  static const String accuWeatherBaseUrl = 'https://dataservice.accuweather.com';
  
  // AccuWeather API Endpoints
  static const String locationSearchEndpoint = '/locations/v1/cities/autocomplete';
  static const String locationByCoordinatesEndpoint = '/locations/v1/cities/geoposition/search';
  static const String currentConditionsEndpoint = '/currentconditions/v1';
  static const String fiveDayForecastEndpoint = '/forecasts/v1/daily/5day';
  static const String hourlyForecastEndpoint = '/forecasts/v1/hourly/12hour';
  
  // OpenWeatherMap API Configuration
  static const String openWeatherApiKey = '8c796008941708cdafc6b5f9be1017bd';
  static const String openWeatherBaseUrl = 'https://api.openweathermap.org/data/2.5';
  
  // OpenWeatherMap API Endpoints
  static const String openWeatherCurrentEndpoint = '/weather';
  static const String openWeatherForecastEndpoint = '/forecast';
  static const String openWeatherGeocodingEndpoint = 'https://api.openweathermap.org/geo/1.0/direct';
  static const String openWeatherReverseGeocodingEndpoint = 'https://api.openweathermap.org/geo/1.0/reverse';
  
  // Helper methods
  static bool get isAccuWeatherActive => activeApi == 'accuweather';
  static bool get isOpenWeatherActive => activeApi == 'openweather';
}
