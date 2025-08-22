class WeatherException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  WeatherException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'WeatherException: $message${code != null ? ' (Code: $code)' : ''}';
}

class LocationException extends WeatherException {
  LocationException(super.message, {super.code, super.originalError});
}

class NetworkException extends WeatherException {
  NetworkException(super.message, {super.code, super.originalError});
}

class ApiException extends WeatherException {
  final int statusCode;
  
  ApiException(super.message, this.statusCode, {super.code, super.originalError});
}
