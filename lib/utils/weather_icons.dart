import 'package:flutter/material.dart';

class WeatherIcons {
  static IconData getWeatherIcon(int iconCode, {bool isDay = true}) {
    // OpenWeatherMap icon codes (200-899)
    if (iconCode >= 200 && iconCode <= 899) {
      return _getOpenWeatherIcon(iconCode, isDay);
    }
    
    // AccuWeather icon codes mapping (1-44)
    switch (iconCode) {
      case 1: // Sunny
      case 2: // Mostly Sunny
      case 3: // Partly Sunny
        return isDay ? Icons.wb_sunny : Icons.nightlight_round;
      
      case 4: // Intermittent Clouds
      case 5: // Hazy Sunshine
      case 6: // Mostly Cloudy
        return isDay ? Icons.cloud : Icons.nights_stay;
      
      case 7: // Cloudy
      case 8: // Dreary (Overcast)
        return Icons.cloud;
      
      case 11: // Fog
        return Icons.cloud;
      
      case 12: // Showers
      case 13: // Mostly Cloudy w/ Showers
      case 14: // Partly Sunny w/ Showers
        return Icons.grain;
      
      case 15: // T-Storms
      case 16: // Mostly Cloudy w/ T-Storms
      case 17: // Partly Sunny w/ T-Storms
        return Icons.thunderstorm;
      
      case 18: // Rain
        return Icons.water_drop;
      
      case 19: // Flurries
      case 20: // Mostly Cloudy w/ Flurries
      case 21: // Partly Sunny w/ Flurries
        return Icons.ac_unit;
      
      case 22: // Snow
        return Icons.ac_unit;
      
      case 23: // Ice
        return Icons.ac_unit;
      
      case 24: // Sleet
        return Icons.ac_unit;
      
      case 25: // Freezing Rain
        return Icons.water_drop;
      
      case 26: // Frigid
        return Icons.thermostat;
      
      case 29: // Rain and Snow
        return Icons.ac_unit;
      
      case 30: // Hot
        return Icons.thermostat;
      
      case 31: // Cold
        return Icons.thermostat;
      
      case 32: // Windy
        return Icons.air;
      
      case 33: // Clear
      case 34: // Mostly Clear
      case 35: // Partly Cloudy
        return isDay ? Icons.wb_sunny : Icons.nightlight_round;
      
      case 36: // Intermittent Clouds
      case 37: // Hazy Moonlight
      case 38: // Mostly Cloudy
        return Icons.nights_stay;
      
      case 39: // Partly Cloudy w/ Showers
        return Icons.grain;
      
      case 40: // Mostly Cloudy w/ Showers
        return Icons.grain;
      
      case 41: // Partly Cloudy w/ T-Storms
        return Icons.thunderstorm;
      
      case 42: // Mostly Cloudy w/ T-Storms
        return Icons.thunderstorm;
      
      case 43: // Mostly Cloudy w/ Flurries
        return Icons.ac_unit;
      
      case 44: // Mostly Cloudy w/ Snow
        return Icons.ac_unit;
      
      default:
        return Icons.cloud;
    }
  }

  static IconData _getOpenWeatherIcon(int iconCode, bool isDay) {
    // Thunderstorm (200-299)
    if (iconCode >= 200 && iconCode < 300) {
      return Icons.thunderstorm;
    }
    
    // Drizzle (300-399)
    if (iconCode >= 300 && iconCode < 400) {
      return Icons.grain;
    }
    
    // Rain (400-499)
    if (iconCode >= 400 && iconCode < 500) {
      return Icons.water_drop;
    }
    
    // Snow (500-599)
    if (iconCode >= 500 && iconCode < 600) {
      return Icons.ac_unit;
    }
    
    // Atmosphere (fog, mist, etc.) (600-699)
    if (iconCode >= 600 && iconCode < 700) {
      return Icons.cloud;
    }
    
    // Clear (700-799)
    if (iconCode >= 700 && iconCode < 800) {
      return isDay ? Icons.wb_sunny : Icons.nightlight_round;
    }
    
    // Clear sky (800)
    if (iconCode == 800) {
      return isDay ? Icons.wb_sunny : Icons.nightlight_round;
    }
    
    // Clouds (801-899)
    if (iconCode >= 801 && iconCode <= 899) {
      if (iconCode == 801) {
        // Few clouds
        return isDay ? Icons.wb_sunny : Icons.nightlight_round;
      } else if (iconCode == 802) {
        // Scattered clouds
        return isDay ? Icons.wb_sunny : Icons.nightlight_round;
      } else {
        // Broken/Overcast clouds
        return Icons.cloud;
      }
    }
    
    return Icons.cloud;
  }

  static Color getWeatherColor(int iconCode, {bool isDay = true}) {
    // OpenWeatherMap colors (200-899)
    if (iconCode >= 200 && iconCode <= 899) {
      return _getOpenWeatherColor(iconCode, isDay);
    }
    
    // AccuWeather colors (1-44)
    if (iconCode >= 1 && iconCode <= 3) {
      return isDay ? Colors.orange : Colors.indigo; // Sunny/Clear
    } else if (iconCode >= 4 && iconCode <= 8) {
      return Colors.grey; // Cloudy
    } else if (iconCode >= 12 && iconCode <= 18) {
      return Colors.blue; // Rain
    } else if (iconCode >= 15 && iconCode <= 17) {
      return Colors.purple; // Thunderstorm
    } else if (iconCode >= 19 && iconCode <= 24) {
      return Colors.cyan; // Snow/Ice
    } else if (iconCode >= 30 && iconCode <= 31) {
      return Colors.red; // Hot/Cold extremes
    } else if (iconCode == 32) {
      return Colors.grey; // Windy
    } else if (iconCode >= 33 && iconCode <= 35) {
      return isDay ? Colors.orange : Colors.indigo; // Clear night
    } else {
      return Colors.grey; // Default
    }
  }

  static Color _getOpenWeatherColor(int iconCode, bool isDay) {
    // Thunderstorm (200-299)
    if (iconCode >= 200 && iconCode < 300) {
      return Colors.purple;
    }
    
    // Drizzle (300-399)
    if (iconCode >= 300 && iconCode < 400) {
      return Colors.blue;
    }
    
    // Rain (400-499)
    if (iconCode >= 400 && iconCode < 500) {
      return Colors.blue;
    }
    
    // Snow (500-599)
    if (iconCode >= 500 && iconCode < 600) {
      return Colors.cyan;
    }
    
    // Atmosphere (fog, mist, etc.) (600-699)
    if (iconCode >= 600 && iconCode < 700) {
      return Colors.grey;
    }
    
    // Clear (700-799)
    if (iconCode >= 700 && iconCode < 800) {
      return isDay ? Colors.orange : Colors.indigo;
    }
    
    // Clear sky (800)
    if (iconCode == 800) {
      return isDay ? Colors.orange : Colors.indigo;
    }
    
    // Clouds (801-899)
    if (iconCode >= 801 && iconCode <= 899) {
      if (iconCode == 801 || iconCode == 802) {
        return isDay ? Colors.orange : Colors.indigo; // Few/Scattered clouds
      } else {
        return Colors.grey; // Broken/Overcast clouds
      }
    }
    
    return Colors.grey; // Default
  }

  static Color getTemperatureColor(double temperature) {
    if (temperature >= 30) {
      return Colors.red;
    } else if (temperature >= 20) {
      return Colors.orange;
    } else if (temperature >= 10) {
      return Colors.yellow.shade700;
    } else if (temperature >= 0) {
      return Colors.blue;
    } else {
      return Colors.cyan;
    }
  }

  static String getWeatherDescription(int iconCode) {
    // OpenWeatherMap descriptions (200-899)
    if (iconCode >= 200 && iconCode <= 899) {
      return _getOpenWeatherDescription(iconCode);
    }
    
    // AccuWeather descriptions (1-44)
    switch (iconCode) {
      case 1: return 'Güneşli';
      case 2: return 'Çoğunlukla Güneşli';
      case 3: return 'Parçalı Bulutlu';
      case 4: return 'Ara Sıra Bulutlu';
      case 5: return 'Puslu Güneşli';
      case 6: return 'Çoğunlukla Bulutlu';
      case 7: return 'Bulutlu';
      case 8: return 'Kapalı';
      case 11: return 'Sisli';
      case 12: return 'Sağanak';
      case 13: return 'Çoğunlukla Bulutlu ve Sağanak';
      case 14: return 'Parçalı Güneşli ve Sağanak';
      case 15: return 'Gök Gürültülü';
      case 16: return 'Çoğunlukla Bulutlu ve Gök Gürültülü';
      case 17: return 'Parçalı Güneşli ve Gök Gürültülü';
      case 18: return 'Yağmurlu';
      case 19: return 'Kar Taneleri';
      case 20: return 'Çoğunlukla Bulutlu ve Kar Taneleri';
      case 21: return 'Parçalı Güneşli ve Kar Taneleri';
      case 22: return 'Karlı';
      case 23: return 'Buzlu';
      case 24: return 'Karla Karışık Yağmur';
      case 25: return 'Dondurucu Yağmur';
      case 26: return 'Dondurucu';
      case 29: return 'Yağmur ve Kar';
      case 30: return 'Sıcak';
      case 31: return 'Soğuk';
      case 32: return 'Rüzgarlı';
      case 33: return 'Açık';
      case 34: return 'Çoğunlukla Açık';
      case 35: return 'Parçalı Bulutlu';
      case 36: return 'Ara Sıra Bulutlu';
      case 37: return 'Puslu Ay Işığı';
      case 38: return 'Çoğunlukla Bulutlu';
      case 39: return 'Parçalı Bulutlu ve Sağanak';
      case 40: return 'Çoğunlukla Bulutlu ve Sağanak';
      case 41: return 'Parçalı Bulutlu ve Gök Gürültülü';
      case 42: return 'Çoğunlukla Bulutlu ve Gök Gürültülü';
      case 43: return 'Çoğunlukla Bulutlu ve Kar Taneleri';
      case 44: return 'Çoğunlukla Bulutlu ve Karlı';
      default: return 'Bilinmeyen';
    }
  }

  static String _getOpenWeatherDescription(int iconCode) {
    // Thunderstorm (200-299)
    if (iconCode >= 200 && iconCode < 300) {
      if (iconCode >= 200 && iconCode < 210) return 'Gök Gürültülü Fırtına';
      if (iconCode >= 210 && iconCode < 220) return 'Hafif Gök Gürültülü';
      if (iconCode >= 220 && iconCode < 230) return 'Gök Gürültülü Sağanak';
      if (iconCode >= 230 && iconCode < 240) return 'Gök Gürültülü Kar';
      return 'Gök Gürültülü';
    }
    
    // Drizzle (300-399)
    if (iconCode >= 300 && iconCode < 400) {
      if (iconCode == 300) return 'Hafif Sağanak';
      if (iconCode == 301) return 'Sağanak';
      if (iconCode == 302) return 'Güçlü Sağanak';
      if (iconCode >= 310 && iconCode < 320) return 'Sağanak Yağmur';
      if (iconCode >= 320 && iconCode < 330) return 'Güçlü Sağanak Yağmur';
      if (iconCode >= 330 && iconCode < 340) return 'Sağanak Kar';
      if (iconCode >= 340 && iconCode < 350) return 'Güçlü Sağanak Kar';
      return 'Sağanak';
    }
    
    // Rain (400-499)
    if (iconCode >= 400 && iconCode < 500) {
      if (iconCode == 400) return 'Hafif Yağmur';
      if (iconCode == 401) return 'Yağmur';
      if (iconCode == 402) return 'Güçlü Yağmur';
      if (iconCode >= 410 && iconCode < 420) return 'Sağanak Yağmur';
      if (iconCode >= 420 && iconCode < 430) return 'Güçlü Sağanak Yağmur';
      if (iconCode >= 430 && iconCode < 440) return 'Yağmur ve Kar';
      if (iconCode >= 440 && iconCode < 450) return 'Güçlü Yağmur ve Kar';
      return 'Yağmurlu';
    }
    
    // Snow (500-599)
    if (iconCode >= 500 && iconCode < 600) {
      if (iconCode == 500) return 'Hafif Kar';
      if (iconCode == 501) return 'Kar';
      if (iconCode == 502) return 'Güçlü Kar';
      if (iconCode >= 510 && iconCode < 520) return 'Kar Taneleri';
      if (iconCode >= 520 && iconCode < 530) return 'Güçlü Kar Taneleri';
      if (iconCode >= 530 && iconCode < 540) return 'Dolu';
      if (iconCode >= 540 && iconCode < 550) return 'Güçlü Dolu';
      return 'Karlı';
    }
    
    // Atmosphere (fog, mist, etc.) (600-699)
    if (iconCode >= 600 && iconCode < 700) {
      if (iconCode == 600) return 'Hafif Sis';
      if (iconCode == 601) return 'Sisli';
      if (iconCode == 602) return 'Yoğun Sis';
      if (iconCode >= 610 && iconCode < 620) return 'Puslu';
      if (iconCode >= 620 && iconCode < 630) return 'Dumanlı';
      if (iconCode >= 630 && iconCode < 640) return 'Tozlu';
      if (iconCode >= 640 && iconCode < 650) return 'Kum Fırtınası';
      return 'Sisli';
    }
    
    // Clear (700-799)
    if (iconCode >= 700 && iconCode < 800) {
      return 'Açık';
    }
    
    // Clear sky (800)
    if (iconCode == 800) {
      return 'Açık';
    }
    
    // Clouds (801-899)
    if (iconCode >= 801 && iconCode <= 899) {
      if (iconCode == 801) return 'Az Bulutlu';
      if (iconCode == 802) return 'Parçalı Bulutlu';
      if (iconCode == 803) return 'Çoğunlukla Bulutlu';
      if (iconCode == 804) return 'Kapalı';
      return 'Bulutlu';
    }
    
    return 'Bilinmeyen';
  }
}
