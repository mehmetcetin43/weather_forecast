class Env {
  static const String accuWeatherApiKey = 'bCIjxKsLM39fGvY8SIms7r5T08vwRsOG';
  static const String accuWeatherBaseUrl = 'https://dataservice.accuweather.com';
  
  // API Endpoints
  static const String locationSearchEndpoint = '/locations/v1/cities/autocomplete';
  static const String locationByCoordinatesEndpoint = '/locations/v1/cities/geoposition/search';
  static const String currentConditionsEndpoint = '/currentconditions/v1';
  static const String fiveDayForecastEndpoint = '/forecasts/v1/daily/5day';
}
