import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:weather_forecast/utils/exceptions.dart';

class LocationService {
  /// Konum izinlerini kontrol eder ve gerekirse izin ister
  static Future<bool> checkAndRequestPermissions() async {
    bool serviceEnabled;
    geolocator.LocationPermission permission;

    // Konum servislerinin açık olup olmadığını kontrol et
    serviceEnabled = await geolocator.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException(
        'Konum servisleri kapalı. Lütfen GPS\'i açın.',
        code: 'LOCATION_SERVICE_DISABLED',
      );
    }

    // Konum izinlerini kontrol et
    permission = await geolocator.Geolocator.checkPermission();
    if (permission == geolocator.LocationPermission.denied) {
      permission = await geolocator.Geolocator.requestPermission();
      if (permission == geolocator.LocationPermission.denied) {
        throw LocationException(
          'Konum izni reddedildi.',
          code: 'LOCATION_PERMISSION_DENIED',
        );
      }
    }

    if (permission == geolocator.LocationPermission.deniedForever) {
      throw LocationException(
        'Konum izinleri kalıcı olarak reddedildi. Ayarlardan izin verin.',
        code: 'LOCATION_PERMISSION_DENIED_FOREVER',
      );
    }

    return true;
  }

  /// Mevcut konumu alır
  static Future<geolocator.Position> getCurrentPosition() async {
    try {
      // İzinleri kontrol et
      await checkAndRequestPermissions();

      // Mevcut konumu al
      return await geolocator.Geolocator.getCurrentPosition(
        desiredAccuracy: geolocator.LocationAccuracy.high,
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
  static Future<geolocator.Position?> getLastKnownPosition() async {
    try {
      await checkAndRequestPermissions();
      return await geolocator.Geolocator.getLastKnownPosition();
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
    return geolocator.Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    ) / 1000; // Metreyi km'ye çevir
  }
}
