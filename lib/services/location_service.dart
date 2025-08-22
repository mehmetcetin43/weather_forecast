import 'package:geolocator/geolocator.dart';
import 'package:weather_forecast/utils/exceptions.dart';

class LocationService {
  /// Konum izinlerini kontrol eder ve gerekirse izin ister
  static Future<bool> checkAndRequestPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Konum servislerinin açık olup olmadığını kontrol et
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException(
        'Konum servisleri kapalı. Lütfen GPS\'i açın.',
        code: 'LOCATION_SERVICE_DISABLED',
      );
    }

    // Konum izinlerini kontrol et
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationException(
          'Konum izni reddedildi.',
          code: 'LOCATION_PERMISSION_DENIED',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationException(
        'Konum izinleri kalıcı olarak reddedildi. Ayarlardan izin verin.',
        code: 'LOCATION_PERMISSION_DENIED_FOREVER',
      );
    }

    return true;
  }

  /// Mevcut konumu alır
  static Future<Position> getCurrentPosition() async {
    try {
      // İzinleri kontrol et
      await checkAndRequestPermissions();

      // Mevcut konumu al
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } on LocationException {
      rethrow;
    } catch (e) {
      throw LocationException(
        'Konum alınamadı: $e',
        code: 'LOCATION_FETCH_FAILED',
        originalError: e,
      );
    }
  }

  /// Son bilinen konumu alır (daha hızlı)
  static Future<Position?> getLastKnownPosition() async {
    try {
      await checkAndRequestPermissions();
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      // Son bilinen konum yoksa null döndür
      return null;
    }
  }

  /// İki konum arasındaki mesafeyi hesaplar (km)
  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    ) / 1000; // Metreyi km'ye çevir
  }
}
