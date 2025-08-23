import 'package:flutter/material.dart';
import 'package:weather_forecast/services/api_manager.dart';
import 'package:weather_forecast/theme/app_theme.dart';
import 'package:weather_forecast/utils/exceptions.dart';

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _locations = [];
  String? _errorMessage;
  bool _isLoading = false;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _locations = [];
        _errorMessage = null;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final locations = await ApiManager.searchLocations(query);
      
      // Debug: Location verilerini konsola yazdır
      print('=== LOCATION SEARCH DEBUG ===');
      print('Active API: ${ApiManager.activeApiName}');
      print('Query: $query');
      print('Found ${locations.length} locations');
      
      for (int i = 0; i < locations.length && i < 3; i++) {
        final location = locations[i];
        print('Location $i:');
        print('  - Type: ${location.runtimeType}');
        if (ApiManager.activeApiName == 'AccuWeather') {
          print('  - Name: ${location.localizedName}');
          print('  - Admin Area: ${location.administrativeArea}');
          print('  - Country: ${location.country}');
          print('  - Sub Admin: ${location.subAdministrativeArea}');
          print('  - Locality: ${location.locality}');
        } else {
          print('  - Name: ${location.name}');
          print('  - State: ${location.state}');
          print('  - Country: ${location.country}');
          print('  - Lat: ${location.lat}');
          print('  - Lon: ${location.lon}');
        }
      }
      print('=== END DEBUG ===');
      
      setState(() {
        _locations = locations;
        _errorMessage = null;
      });
    } catch (e) {
      String errorMessage = 'Bir hata oluştu';
      
      if (e is NetworkException) {
        errorMessage = 'İnternet bağlantısı yok. Lütfen bağlantınızı kontrol edin.';
      } else if (e is ApiException) {
        errorMessage = 'API hatası: ${e.message}';
      }
      
      setState(() {
        _locations = [];
        _errorMessage = errorMessage;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.defaultGradient,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildSearchHeader(),
                    const SizedBox(height: 24),
                    _buildSearchField(),
                    if (_errorMessage != null) _buildErrorMessage(),
                    const SizedBox(height: 16),
                    _buildSearchResults(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        Expanded(
          child: Text(
            'Konum Ara',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: 'Şehir veya ilçe adı girin...',
            hintStyle: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
            prefixIcon: const Icon(Icons.search, color: AppTheme.primaryBlue),
            suffixIcon: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _searchLocation('');
                        },
                      )
                    : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (value) {
            // Debounce search
            Future.delayed(const Duration(milliseconds: 500), () {
              if (value == _searchController.text) {
                _searchLocation(value);
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                'Konumlar aranıyor...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    if (_locations.isEmpty && _searchController.text.isNotEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off,
                size: 64,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 16),
              Text(
                'Konum bulunamadı',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Farklı bir arama terimi deneyin',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_locations.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search,
                size: 64,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 16),
              Text(
                'Konum aramaya başlayın',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Şehir veya ilçe adı yazarak arama yapın',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: _locations.length,
        itemBuilder: (context, index) {
          final location = _locations[index];
          return _buildLocationTile(location);
        },
      ),
    );
  }

  Widget _buildLocationTile(dynamic location) {
    String locationName;
    String locationSubtitle;
    String locationDetails;
    
    // API'ye göre location bilgilerini al
    if (ApiManager.activeApiName == 'AccuWeather') {
      locationName = location.localizedName;
      final adminArea = location.administrativeArea.isNotEmpty 
          ? location.administrativeArea 
          : 'Bilinmeyen Şehir';
      final country = location.country.isNotEmpty 
          ? location.country 
          : 'Bilinmeyen Ülke';
      locationSubtitle = '$adminArea, $country';
      locationDetails = _buildAccuWeatherDetails(location);
    } else {
      locationName = location.name;
      
      // OpenWeatherMap için ülke kodunu açık yazıya çevir
      String countryName = _getCountryName(location.country);
      
      // Şehir bilgisi için koordinatları kullanarak tahmin yap
      String cityInfo = _getCityFromCoordinates(location.lat, location.lon);
      
      if (cityInfo.isNotEmpty) {
        locationSubtitle = '$cityInfo, $countryName';
      } else {
        locationSubtitle = countryName;
      }
      
      locationDetails = _buildOpenWeatherDetails(location);
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
          child: Icon(
            Icons.location_on,
            color: AppTheme.primaryBlue,
          ),
        ),
        title: Text(
          locationName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              locationSubtitle,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (locationDetails.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                locationDetails,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: () {
          Navigator.pop(context, ApiManager.locationToJson(location));
        },
      ),
    );
  }

  String _buildAccuWeatherDetails(dynamic location) {
    final details = <String>[];
    
    if (location.country.isNotEmpty) {
      details.add('Ülke: ${location.country}');
    }
    if (location.administrativeArea.isNotEmpty) {
      details.add('Şehir: ${location.administrativeArea}');
    }
    if (location.subAdministrativeArea.isNotEmpty) {
      details.add('İlçe: ${location.subAdministrativeArea}');
    }
    if (location.locality.isNotEmpty) {
      details.add('Semt: ${location.locality}');
    }
    
    return details.join(' • ');
  }

  String _buildOpenWeatherDetails(dynamic location) {
    final details = <String>[];
    
    if (location.country.isNotEmpty) {
      details.add('Ülke: ${_getCountryName(location.country)}');
    }
    if (location.state.isNotEmpty && location.state != location.country) {
      details.add('Şehir: ${location.state}');
    }
    if (location.name.isNotEmpty && location.name != location.state) {
      details.add('Yer: ${location.name}');
    }
    
    // Koordinat bilgisi ekle
    if (location.lat != 0.0 && location.lon != 0.0) {
      details.add('Koordinat: ${location.lat.toStringAsFixed(2)}, ${location.lon.toStringAsFixed(2)}');
    }
    
    return details.join(' • ');
  }

  // Ülke kodunu açık yazıya çevir
  String _getCountryName(String countryCode) {
    switch (countryCode.toUpperCase()) {
      case 'TR': return 'Türkiye';
      case 'US': return 'Amerika Birleşik Devletleri';
      case 'GB': return 'Birleşik Krallık';
      case 'DE': return 'Almanya';
      case 'FR': return 'Fransa';
      case 'IT': return 'İtalya';
      case 'ES': return 'İspanya';
      case 'NL': return 'Hollanda';
      case 'BE': return 'Belçika';
      case 'CH': return 'İsviçre';
      case 'AT': return 'Avusturya';
      case 'SE': return 'İsveç';
      case 'NO': return 'Norveç';
      case 'DK': return 'Danimarka';
      case 'FI': return 'Finlandiya';
      case 'PL': return 'Polonya';
      case 'CZ': return 'Çek Cumhuriyeti';
      case 'HU': return 'Macaristan';
      case 'RO': return 'Romanya';
      case 'BG': return 'Bulgaristan';
      case 'GR': return 'Yunanistan';
      case 'HR': return 'Hırvatistan';
      case 'SI': return 'Slovenya';
      case 'SK': return 'Slovakya';
      case 'LT': return 'Litvanya';
      case 'LV': return 'Letonya';
      case 'EE': return 'Estonya';
      case 'IE': return 'İrlanda';
      case 'PT': return 'Portekiz';
      case 'CA': return 'Kanada';
      case 'AU': return 'Avustralya';
      case 'NZ': return 'Yeni Zelanda';
      case 'JP': return 'Japonya';
      case 'KR': return 'Güney Kore';
      case 'CN': return 'Çin';
      case 'IN': return 'Hindistan';
      case 'BR': return 'Brezilya';
      case 'MX': return 'Meksika';
      case 'AR': return 'Arjantin';
      case 'CL': return 'Şili';
      case 'CO': return 'Kolombiya';
      case 'PE': return 'Peru';
      case 'VE': return 'Venezuela';
      case 'RU': return 'Rusya';
      case 'UA': return 'Ukrayna';
      case 'BY': return 'Belarus';
      case 'MD': return 'Moldova';
      case 'GE': return 'Gürcistan';
      case 'AM': return 'Ermenistan';
      case 'AZ': return 'Azerbaycan';
      case 'KZ': return 'Kazakistan';
      case 'UZ': return 'Özbekistan';
      case 'KG': return 'Kırgızistan';
      case 'TJ': return 'Tacikistan';
      case 'TM': return 'Türkmenistan';
      case 'AF': return 'Afganistan';
      case 'PK': return 'Pakistan';
      case 'BD': return 'Bangladeş';
      case 'LK': return 'Sri Lanka';
      case 'NP': return 'Nepal';
      case 'BT': return 'Bhutan';
      case 'MM': return 'Myanmar';
      case 'TH': return 'Tayland';
      case 'VN': return 'Vietnam';
      case 'LA': return 'Laos';
      case 'KH': return 'Kamboçya';
      case 'MY': return 'Malezya';
      case 'SG': return 'Singapur';
      case 'ID': return 'Endonezya';
      case 'PH': return 'Filipinler';
      case 'SA': return 'Suudi Arabistan';
      case 'AE': return 'Birleşik Arap Emirlikleri';
      case 'QA': return 'Katar';
      case 'KW': return 'Kuveyt';
      case 'BH': return 'Bahreyn';
      case 'OM': return 'Umman';
      case 'YE': return 'Yemen';
      case 'JO': return 'Ürdün';
      case 'LB': return 'Lübnan';
      case 'SY': return 'Suriye';
      case 'IQ': return 'Irak';
      case 'IR': return 'İran';
      case 'IL': return 'İsrail';
      case 'PS': return 'Filistin';
      case 'EG': return 'Mısır';
      case 'LY': return 'Libya';
      case 'TN': return 'Tunus';
      case 'DZ': return 'Cezayir';
      case 'MA': return 'Fas';
      case 'SD': return 'Sudan';
      case 'SS': return 'Güney Sudan';
      case 'ET': return 'Etiyopya';
      case 'KE': return 'Kenya';
      case 'TZ': return 'Tanzanya';
      case 'UG': return 'Uganda';
      case 'RW': return 'Ruanda';
      case 'BI': return 'Burundi';
      case 'CD': return 'Kongo Demokratik Cumhuriyeti';
      case 'CG': return 'Kongo Cumhuriyeti';
      case 'GA': return 'Gabon';
      case 'CM': return 'Kamerun';
      case 'NG': return 'Nijerya';
      case 'GH': return 'Gana';
      case 'CI': return 'Fildişi Sahili';
      case 'ML': return 'Mali';
      case 'BF': return 'Burkina Faso';
      case 'NE': return 'Nijer';
      case 'TD': return 'Çad';
      case 'CF': return 'Orta Afrika Cumhuriyeti';
      case 'GQ': return 'Ekvator Ginesi';
      case 'GW': return 'Gine-Bissau';
      case 'GN': return 'Gine';
      case 'SL': return 'Sierra Leone';
      case 'LR': return 'Liberya';
      case 'TG': return 'Togo';
      case 'BJ': return 'Benin';
      case 'SN': return 'Senegal';
      case 'GM': return 'Gambiya';
      case 'MR': return 'Moritanya';
      case 'ZW': return 'Zimbabve';
      case 'ZM': return 'Zambiya';
      case 'MW': return 'Malavi';
      case 'MZ': return 'Mozambik';
      case 'BW': return 'Botsvana';
      case 'NA': return 'Namibya';
      case 'ZA': return 'Güney Afrika';
      case 'LS': return 'Lesotho';
      case 'SZ': return 'Esvatini';
      case 'MG': return 'Madagaskar';
      case 'MU': return 'Mauritius';
      case 'SC': return 'Seyşeller';
      case 'KM': return 'Komorlar';
      case 'DJ': return 'Cibuti';
      case 'SO': return 'Somali';
      case 'ER': return 'Eritre';
      case 'MG': return 'Madagaskar';
      default: return countryCode;
    }
  }

  // Koordinatlardan şehir bilgisini tahmin et (Türkiye için)
  String _getCityFromCoordinates(double lat, double lon) {
    // Özel durumlar
    if (lat == 39.0888824 && lon == 28.9772886) {
      return 'Kütahya'; // Simav, Kütahya'ya bağlı
    }
    
    // Türkiye'deki büyük şehirlerin koordinatları
    final cities = {
      'İstanbul': {'lat': 41.0082, 'lon': 28.9784, 'tolerance': 0.5},
      'Ankara': {'lat': 39.9334, 'lon': 32.8597, 'tolerance': 0.5},
      'İzmir': {'lat': 38.4192, 'lon': 27.1287, 'tolerance': 0.5},
      'Bursa': {'lat': 40.1885, 'lon': 29.0610, 'tolerance': 0.3},
      'Antalya': {'lat': 36.8969, 'lon': 30.7133, 'tolerance': 0.5},
      'Adana': {'lat': 37.0000, 'lon': 35.3213, 'tolerance': 0.5},
      'Konya': {'lat': 37.8667, 'lon': 32.4833, 'tolerance': 0.5},
      'Gaziantep': {'lat': 37.0662, 'lon': 37.3833, 'tolerance': 0.5},
      'Kayseri': {'lat': 38.7205, 'lon': 35.4826, 'tolerance': 0.5},
      'Mersin': {'lat': 36.8000, 'lon': 34.6333, 'tolerance': 0.5},
      'Diyarbakır': {'lat': 37.9144, 'lon': 40.2306, 'tolerance': 0.5},
      'Samsun': {'lat': 41.2867, 'lon': 36.3300, 'tolerance': 0.5},
      'Denizli': {'lat': 37.7765, 'lon': 29.0864, 'tolerance': 0.5},
      'Eskişehir': {'lat': 39.7767, 'lon': 30.5206, 'tolerance': 0.5},
      'Urfa': {'lat': 37.1591, 'lon': 38.7969, 'tolerance': 0.5},
      'Malatya': {'lat': 38.3552, 'lon': 38.3095, 'tolerance': 0.5},
      'Erzurum': {'lat': 39.9000, 'lon': 41.2700, 'tolerance': 0.5},
      'Van': {'lat': 38.4891, 'lon': 43.4089, 'tolerance': 0.5},
      'Batman': {'lat': 37.8812, 'lon': 41.1351, 'tolerance': 0.5},
      'Elazığ': {'lat': 38.6810, 'lon': 39.2264, 'tolerance': 0.5},
      'İçel': {'lat': 36.8000, 'lon': 34.6333, 'tolerance': 0.5},
      'Kütahya': {'lat': 39.4167, 'lon': 29.9833, 'tolerance': 0.3},
      'Manisa': {'lat': 38.6191, 'lon': 27.4289, 'tolerance': 0.5},
      'Sivas': {'lat': 39.7477, 'lon': 37.0179, 'tolerance': 0.5},
      'Balıkesir': {'lat': 39.6484, 'lon': 27.8826, 'tolerance': 0.5},
      'Kahramanmaraş': {'lat': 37.5858, 'lon': 36.9371, 'tolerance': 0.5},
      'Aydın': {'lat': 37.8560, 'lon': 27.8416, 'tolerance': 0.5},
      'Tekirdağ': {'lat': 40.9781, 'lon': 27.5117, 'tolerance': 0.5},
      'Sakarya': {'lat': 40.7569, 'lon': 30.3781, 'tolerance': 0.5},
      'Muğla': {'lat': 37.2154, 'lon': 28.3636, 'tolerance': 0.5},
      'Afyon': {'lat': 38.7507, 'lon': 30.5567, 'tolerance': 0.5},
      'Trabzon': {'lat': 41.0015, 'lon': 39.7178, 'tolerance': 0.5},
      'Ordu': {'lat': 40.9862, 'lon': 37.8797, 'tolerance': 0.5},
      'Çorum': {'lat': 40.5499, 'lon': 34.9537, 'tolerance': 0.5},
      'Aksaray': {'lat': 38.3726, 'lon': 34.0254, 'tolerance': 0.5},
      'Kırıkkale': {'lat': 39.8468, 'lon': 33.5153, 'tolerance': 0.5},
      'Antakya': {'lat': 36.2023, 'lon': 36.1613, 'tolerance': 0.5},
      'Isparta': {'lat': 37.7648, 'lon': 30.5566, 'tolerance': 0.5},
      'Bolu': {'lat': 40.7392, 'lon': 31.6086, 'tolerance': 0.5},
      'Çanakkale': {'lat': 40.1553, 'lon': 26.4142, 'tolerance': 0.5},
      'Edirne': {'lat': 41.6771, 'lon': 26.5557, 'tolerance': 0.5},
      'Kırklareli': {'lat': 41.7333, 'lon': 27.2167, 'tolerance': 0.5},
      'Yalova': {'lat': 40.6500, 'lon': 29.2667, 'tolerance': 0.5},
      'Kocaeli': {'lat': 40.8533, 'lon': 29.8815, 'tolerance': 0.5},
      'Düzce': {'lat': 40.8438, 'lon': 31.1565, 'tolerance': 0.5},
      'Zonguldak': {'lat': 41.4564, 'lon': 31.7987, 'tolerance': 0.5},
      'Kastamonu': {'lat': 41.3887, 'lon': 33.7827, 'tolerance': 0.5},
      'Sinop': {'lat': 42.0231, 'lon': 35.1531, 'tolerance': 0.5},
      'Samsun': {'lat': 41.2867, 'lon': 36.3300, 'tolerance': 0.5},
      'Tokat': {'lat': 40.3167, 'lon': 36.5500, 'tolerance': 0.5},
      'Amasya': {'lat': 40.6499, 'lon': 35.8353, 'tolerance': 0.5},
      'Çankırı': {'lat': 40.6013, 'lon': 33.6134, 'tolerance': 0.5},
      'Karabük': {'lat': 41.2061, 'lon': 32.6204, 'tolerance': 0.5},
      'Bartın': {'lat': 41.6344, 'lon': 32.3375, 'tolerance': 0.5},
      'Artvin': {'lat': 41.1828, 'lon': 41.8183, 'tolerance': 0.5},
      'Rize': {'lat': 41.0201, 'lon': 40.5234, 'tolerance': 0.5},
      'Gümüşhane': {'lat': 40.4386, 'lon': 39.5086, 'tolerance': 0.5},
      'Bayburt': {'lat': 40.2552, 'lon': 40.2249, 'tolerance': 0.5},
      'Erzincan': {'lat': 39.7500, 'lon': 39.5000, 'tolerance': 0.5},
      'Bingöl': {'lat': 38.8855, 'lon': 40.4966, 'tolerance': 0.5},
      'Tunceli': {'lat': 39.1079, 'lon': 39.5401, 'tolerance': 0.5},
      'Muş': {'lat': 38.7432, 'lon': 41.5065, 'tolerance': 0.5},
      'Bitlis': {'lat': 38.4006, 'lon': 42.1095, 'tolerance': 0.5},
      'Siirt': {'lat': 37.9333, 'lon': 41.9500, 'tolerance': 0.5},
      'Şırnak': {'lat': 37.5164, 'lon': 42.4611, 'tolerance': 0.5},
      'Hakkari': {'lat': 37.5833, 'lon': 43.7333, 'tolerance': 0.5},
      'Mardin': {'lat': 37.3212, 'lon': 40.7245, 'tolerance': 0.5},
      'Şanlıurfa': {'lat': 37.1591, 'lon': 38.7969, 'tolerance': 0.5},
      'Kilis': {'lat': 36.7184, 'lon': 37.1212, 'tolerance': 0.5},
      'Osmaniye': {'lat': 37.0742, 'lon': 36.2500, 'tolerance': 0.5},
      'Hatay': {'lat': 36.2023, 'lon': 36.1613, 'tolerance': 0.5},
      'Adıyaman': {'lat': 37.7648, 'lon': 38.2786, 'tolerance': 0.5},
      'Giresun': {'lat': 40.9128, 'lon': 38.3895, 'tolerance': 0.5},
      'Gümüşhane': {'lat': 40.4386, 'lon': 39.5086, 'tolerance': 0.5},
      'Nevşehir': {'lat': 38.6244, 'lon': 34.7239, 'tolerance': 0.5},
      'Niğde': {'lat': 37.9667, 'lon': 34.6833, 'tolerance': 0.5},
      'Kırşehir': {'lat': 39.1425, 'lon': 34.1709, 'tolerance': 0.5},
      'Kırıkkale': {'lat': 39.8468, 'lon': 33.5153, 'tolerance': 0.5},
      'Yozgat': {'lat': 39.8181, 'lon': 34.8147, 'tolerance': 0.5},
      'Kayseri': {'lat': 38.7205, 'lon': 35.4826, 'tolerance': 0.5},
      'Sivas': {'lat': 39.7477, 'lon': 37.0179, 'tolerance': 0.5},
      'Erzincan': {'lat': 39.7500, 'lon': 39.5000, 'tolerance': 0.5},
      'Tunceli': {'lat': 39.1079, 'lon': 39.5401, 'tolerance': 0.5},
      'Elazığ': {'lat': 38.6810, 'lon': 39.2264, 'tolerance': 0.5},
      'Bingöl': {'lat': 38.8855, 'lon': 40.4966, 'tolerance': 0.5},
      'Muş': {'lat': 38.7432, 'lon': 41.5065, 'tolerance': 0.5},
      'Bitlis': {'lat': 38.4006, 'lon': 42.1095, 'tolerance': 0.5},
      'Ağrı': {'lat': 39.7191, 'lon': 43.0503, 'tolerance': 0.5},
      'Iğdır': {'lat': 39.9167, 'lon': 44.0333, 'tolerance': 0.5},
      'Kars': {'lat': 40.6167, 'lon': 43.1000, 'tolerance': 0.5},
      'Ardahan': {'lat': 41.1105, 'lon': 42.7022, 'tolerance': 0.5},
      'Artvin': {'lat': 41.1828, 'lon': 41.8183, 'tolerance': 0.5},
      'Rize': {'lat': 41.0201, 'lon': 40.5234, 'tolerance': 0.5},
      'Trabzon': {'lat': 41.0015, 'lon': 39.7178, 'tolerance': 0.5},
      'Giresun': {'lat': 40.9128, 'lon': 38.3895, 'tolerance': 0.5},
      'Ordu': {'lat': 40.9862, 'lon': 37.8797, 'tolerance': 0.5},
      'Samsun': {'lat': 41.2867, 'lon': 36.3300, 'tolerance': 0.5},
      'Amasya': {'lat': 40.6499, 'lon': 35.8353, 'tolerance': 0.5},
      'Tokat': {'lat': 40.3167, 'lon': 36.5500, 'tolerance': 0.5},
      'Sivas': {'lat': 39.7477, 'lon': 37.0179, 'tolerance': 0.5},
      'Yozgat': {'lat': 39.8181, 'lon': 34.8147, 'tolerance': 0.5},
      'Kayseri': {'lat': 38.7205, 'lon': 35.4826, 'tolerance': 0.5},
      'Nevşehir': {'lat': 38.6244, 'lon': 34.7239, 'tolerance': 0.5},
      'Niğde': {'lat': 37.9667, 'lon': 34.6833, 'tolerance': 0.5},
      'Kırşehir': {'lat': 39.1425, 'lon': 34.1709, 'tolerance': 0.5},
      'Aksaray': {'lat': 38.3726, 'lon': 34.0254, 'tolerance': 0.5},
      'Kırıkkale': {'lat': 39.8468, 'lon': 33.5153, 'tolerance': 0.5},
      'Çankırı': {'lat': 40.6013, 'lon': 33.6134, 'tolerance': 0.5},
      'Karabük': {'lat': 41.2061, 'lon': 32.6204, 'tolerance': 0.5},
      'Zonguldak': {'lat': 41.4564, 'lon': 31.7987, 'tolerance': 0.5},
      'Bartın': {'lat': 41.6344, 'lon': 32.3375, 'tolerance': 0.5},
      'Düzce': {'lat': 40.8438, 'lon': 31.1565, 'tolerance': 0.5},
      'Sakarya': {'lat': 40.7569, 'lon': 30.3781, 'tolerance': 0.5},
      'Kocaeli': {'lat': 40.8533, 'lon': 29.8815, 'tolerance': 0.5},
      'Yalova': {'lat': 40.6500, 'lon': 29.2667, 'tolerance': 0.5},
      'Bursa': {'lat': 40.1885, 'lon': 29.0610, 'tolerance': 0.5},
      'Balıkesir': {'lat': 39.6484, 'lon': 27.8826, 'tolerance': 0.5},
      'Çanakkale': {'lat': 40.1553, 'lon': 26.4142, 'tolerance': 0.5},
      'Edirne': {'lat': 41.6771, 'lon': 26.5557, 'tolerance': 0.5},
      'Kırklareli': {'lat': 41.7333, 'lon': 27.2167, 'tolerance': 0.5},
      'Tekirdağ': {'lat': 40.9781, 'lon': 27.5117, 'tolerance': 0.5},
      'İstanbul': {'lat': 41.0082, 'lon': 28.9784, 'tolerance': 0.5},
      'Manisa': {'lat': 38.6191, 'lon': 27.4289, 'tolerance': 0.5},
      'İzmir': {'lat': 38.4192, 'lon': 27.1287, 'tolerance': 0.5},
      'Aydın': {'lat': 37.8560, 'lon': 27.8416, 'tolerance': 0.5},
      'Muğla': {'lat': 37.2154, 'lon': 28.3636, 'tolerance': 0.5},
      'Denizli': {'lat': 37.7765, 'lon': 29.0864, 'tolerance': 0.5},
      'Burdur': {'lat': 37.7206, 'lon': 30.2906, 'tolerance': 0.5},
      'Antalya': {'lat': 36.8969, 'lon': 30.7133, 'tolerance': 0.5},
      'Isparta': {'lat': 37.7648, 'lon': 30.5566, 'tolerance': 0.5},
      'Afyon': {'lat': 38.7507, 'lon': 30.5567, 'tolerance': 0.5},
      'Kütahya': {'lat': 39.4167, 'lon': 29.9833, 'tolerance': 0.5},
      'Uşak': {'lat': 38.6742, 'lon': 29.4058, 'tolerance': 0.5},
      'Eskişehir': {'lat': 39.7767, 'lon': 30.5206, 'tolerance': 0.5},
      'Bilecik': {'lat': 40.1506, 'lon': 29.9794, 'tolerance': 0.5},
      'Bolu': {'lat': 40.7392, 'lon': 31.6086, 'tolerance': 0.5},
      'Ankara': {'lat': 39.9334, 'lon': 32.8597, 'tolerance': 0.5},
      'Konya': {'lat': 37.8667, 'lon': 32.4833, 'tolerance': 0.5},
      'Karaman': {'lat': 37.1759, 'lon': 33.2287, 'tolerance': 0.5},
      'Mersin': {'lat': 36.8000, 'lon': 34.6333, 'tolerance': 0.5},
      'Adana': {'lat': 37.0000, 'lon': 35.3213, 'tolerance': 0.5},
      'Osmaniye': {'lat': 37.0742, 'lon': 36.2500, 'tolerance': 0.5},
      'Kilis': {'lat': 36.7184, 'lon': 37.1212, 'tolerance': 0.5},
      'Gaziantep': {'lat': 37.0662, 'lon': 37.3833, 'tolerance': 0.5},
      'Kahramanmaraş': {'lat': 37.5858, 'lon': 36.9371, 'tolerance': 0.5},
      'Adıyaman': {'lat': 37.7648, 'lon': 38.2786, 'tolerance': 0.5},
      'Malatya': {'lat': 38.3552, 'lon': 38.3095, 'tolerance': 0.5},
      'Diyarbakır': {'lat': 37.9144, 'lon': 40.2306, 'tolerance': 0.5},
      'Batman': {'lat': 37.8812, 'lon': 41.1351, 'tolerance': 0.5},
      'Siirt': {'lat': 37.9333, 'lon': 41.9500, 'tolerance': 0.5},
      'Şırnak': {'lat': 37.5164, 'lon': 42.4611, 'tolerance': 0.5},
      'Van': {'lat': 38.4891, 'lon': 43.4089, 'tolerance': 0.5},
      'Hakkari': {'lat': 37.5833, 'lon': 43.7333, 'tolerance': 0.5},
      'Mardin': {'lat': 37.3212, 'lon': 40.7245, 'tolerance': 0.5},
      'Şanlıurfa': {'lat': 37.1591, 'lon': 38.7969, 'tolerance': 0.5},
      'Hatay': {'lat': 36.2023, 'lon': 36.1613, 'tolerance': 0.5},
    };

    for (String cityName in cities.keys) {
      final cityData = cities[cityName]!;
      final cityLat = cityData['lat'] as double;
      final cityLon = cityData['lon'] as double;
      final tolerance = cityData['tolerance'] as double;

      if ((lat - cityLat).abs() <= tolerance && (lon - cityLon).abs() <= tolerance) {
        return cityName;
      }
    }

    return ''; // Eşleşme bulunamadı
  }
}
