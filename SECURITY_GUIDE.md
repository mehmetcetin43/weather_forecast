# 🛡️ Security Guide - Weather Forecast App

Bu rehber, Weather Forecast App'in güvenlik açıklarını kapatmak ve production'a hazır hale getirmek için tasarlanmıştır.

## 🚨 Güvenlik Durumu

### **Mevcut Durum**
- ⚠️ **API Anahtarları**: Client-side'da saklanıyor (GÜVENSİZ)
- ✅ **HTTPS**: API çağrıları güvenli
- ✅ **Permissions**: Sadece gerekli izinler
- ⚠️ **Code Obfuscation**: Yok
- ⚠️ **Backend Proxy**: Yok

### **Risk Seviyesi**
- **Development**: Düşük risk
- **Production**: Yüksek risk (API key exposure)

## 🔐 API Key Güvenliği

### **Problem: Client-Side API Keys**
```dart
// ❌ GÜVENSİZ - API anahtarı client'da görünür
class Env {
  static const String accuWeatherApiKey = 'bCIjxKsLM39fGvY8SIms7r5T08vwRsOG';
}
```

**Riskler:**
- 🔍 **Reverse Engineering**: APK decompile edilebilir
- 🌐 **Network Sniffing**: API key ağ trafiğinde görünür
- 📱 **App Store**: Kod public olabilir
- 💰 **API Abuse**: Başkaları sizin API key'inizi kullanabilir

### **Çözüm 1: Backend Proxy (ÖNERİLEN)**

#### **Vercel ile Hızlı Kurulum**
```bash
# 1. Vercel CLI kur
npm install -g vercel

# 2. Proje oluştur
mkdir weather-backend
cd weather-backend

# 3. Package.json oluştur
npm init -y

# 4. Gerekli paketleri yükle
npm install axios cors
```

#### **API Kodları**
```javascript
// api/weather.js
import axios from 'axios';

export default async function handler(req, res) {
  // CORS ayarları
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  
  const { city, type } = req.query;
  const apiKey = process.env.ACCUWEATHER_API_KEY;
  
  try {
    let response;
    
    if (type === 'search') {
      response = await axios.get(
        `https://dataservice.accuweather.com/locations/v1/cities/search?apikey=${apiKey}&q=${city}&language=tr-tr`
      );
    } else if (type === 'current') {
      response = await axios.get(
        `https://dataservice.accuweather.com/currentconditions/v1/${city}?apikey=${apiKey}&language=tr-tr`
      );
    }
    
    res.status(200).json(response.data);
  } catch (error) {
    res.status(500).json({ error: 'Hava durumu alınamadı' });
  }
}
```

#### **Environment Variables**
```bash
# Vercel dashboard'da ayarla
ACCUWEATHER_API_KEY=bCIjxKsLM39fGvY8SIms7r5T08vwRsOG
OPENWEATHER_API_KEY=8c796008941708cdafc6b5f9be1017bd
```

#### **Flutter Uygulamasında Kullanım**
```dart
// lib/services/weather_service.dart
class WeatherService {
  static const String backendUrl = 'https://your-project.vercel.app/api';
  
  Future<List<Location>> searchLocations(String query) async {
    final response = await http.get(
      Uri.parse('$backendUrl/weather?city=$query&type=search')
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Location.fromJson(json)).toList();
    } else {
      throw WeatherException('Konum arama başarısız');
    }
  }
}
```

### **Çözüm 2: API Key Obfuscation (GEÇİCİ)**

#### **Basit Obfuscation**
```dart
// lib/utils/key_obfuscator.dart
class KeyObfuscator {
  static String get accuWeatherKey {
    // Basit encoding (güvenli değil, sadece gizleme)
    const encoded = 'YkNJanhLczNNOWZHdlk4U0ltczdyNVQwOHZ3UnNPRw==';
    return String.fromCharCodes(base64Decode(encoded));
  }
}
```

#### **Gelişmiş Obfuscation**
```dart
// lib/utils/advanced_obfuscator.dart
class AdvancedObfuscator {
  static String get accuWeatherKey {
    // XOR encryption ile
    const key = [98, 67, 73, 106, 120, 75, 115, 77, 51, 57, 102, 71, 118, 89, 56, 83, 73, 109, 115, 55, 114, 53, 84, 48, 56, 118, 119, 82, 115, 79, 71];
    const xorKey = 42;
    
    return String.fromCharCodes(
      key.map((byte) => byte ^ xorKey)
    );
  }
}
```

**⚠️ Uyarı**: Obfuscation güvenli değil, sadece basit gizleme yapar!

### **Çözüm 3: API Key Rotation**

#### **Çoklu API Key Sistemi**
```dart
// lib/utils/api_key_manager.dart
class ApiKeyManager {
  static final List<String> _accuWeatherKeys = [
    'key1',
    'key2', 
    'key3',
  ];
  
  static int _currentIndex = 0;
  
  static String get currentKey => _accuWeatherKeys[_currentIndex];
  
  static void rotateKey() {
    _currentIndex = (_currentIndex + 1) % _accuWeatherKeys.length;
  }
  
  static void handleApiLimit() {
    rotateKey();
  }
}
```

## 🏗️ Backend Proxy Kurulumu

### **Platform Seçenekleri**

#### **1. Vercel (ÖNERİLEN)**
```bash
# Avantajlar: Ücretsiz, kolay, hızlı
# Limit: 100GB/ay
# SSL: Otomatik
# Deploy: GitHub entegrasyonu

# Kurulum
npm install -g vercel
vercel login
vercel --prod
```

#### **2. Netlify Functions**
```bash
# Avantajlar: Ücretsiz, kolay
# Limit: 125GB/ay
# SSL: Otomatik

# Kurulum
npm install -g netlify-cli
netlify login
netlify deploy --prod
```

#### **3. Railway**
```bash
# Avantajlar: $5 kredi/ay, database desteği
# Limit: Ücretsiz tier
# SSL: Otomatik

# Kurulum
npm install -g @railway/cli
railway login
railway up
```

#### **4. Render**
```bash
# Avantajlar: Ücretsiz tier
# Limit: Sınırlı
# SSL: Otomatik

# Kurulum
# GitHub entegrasyonu ile otomatik deploy
```

### **Tam Backend Kurulumu (Vercel)**

#### **1. Proje Yapısı**
```
weather-backend/
├── api/
│   ├── weather.js          # Hava durumu API
│   ├── location.js         # Konum API
│   └── forecast.js         # Tahmin API
├── package.json
├── vercel.json
└── .env.local
```

#### **2. API Endpoints**
```javascript
// api/weather.js
export default async function handler(req, res) {
  const { city, type } = req.query;
  
  switch (type) {
    case 'search':
      return await handleLocationSearch(req, res);
    case 'current':
      return await handleCurrentWeather(req, res);
    case 'forecast':
      return await handleForecast(req, res);
    default:
      res.status(400).json({ error: 'Geçersiz tip' });
  }
}
```

#### **3. Error Handling**
```javascript
// utils/error-handler.js
export function handleApiError(error, res) {
  if (error.response?.status === 401) {
    return res.status(401).json({ error: 'API anahtarı geçersiz' });
  }
  
  if (error.response?.status === 429) {
    return res.status(429).json({ error: 'API limit aşıldı' });
  }
  
  return res.status(500).json({ error: 'Sunucu hatası' });
}
```

#### **4. Rate Limiting**
```javascript
// utils/rate-limiter.js
import rateLimit from 'express-rate-limit';

export const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 dakika
  max: 100, // IP başına 100 istek
  message: { error: 'Çok fazla istek' }
});
```

## 🔒 Production Güvenlik Kontrol Listesi

### **✅ Yapılması Gerekenler**

#### **1. API Key Güvenliği**
- [ ] Backend proxy kurulumu
- [ ] Environment variables kullanımı
- [ ] API key rotation sistemi
- [ ] Rate limiting

#### **2. Code Security**
- [ ] Code obfuscation
- [ ] ProGuard/R8 (Android)
- [ ] Dead code elimination
- [ ] Debug symbols kaldırma

#### **3. Network Security**
- [ ] HTTPS enforcement
- [ ] Certificate pinning
- [ ] Network security config
- [ ] SSL/TLS 1.2+

#### **4. App Security**
- [ ] Permission minimization
- [ ] Data encryption
- [ ] Secure storage
- [ ] Input validation

### **🔧 Implementation**

#### **Android Security**
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<application
    android:allowBackup="false"
    android:networkSecurityConfig="@xml/network_security_config"
    android:usesCleartextTraffic="false">
```

```xml
<!-- android/app/src/main/res/xml/network_security_config.xml -->
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="false">
        <domain includeSubdomains="true">api.example.com</domain>
    </domain-config>
</network-security-config>
```

#### **iOS Security**
```xml
<!-- ios/Runner/Info.plist -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>api.example.com</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <false/>
        </dict>
    </dict>
</dict>
```

## 🚀 Deployment Güvenliği

### **Google Play Store**

#### **1. App Signing**
```bash
# Keystore oluştur
keytool -genkey -v -keystore weather-app.keystore -alias weather-app -keyalg RSA -keysize 2048 -validity 10000

# Release build
flutter build appbundle --release
```

#### **2. Privacy Policy**
```markdown
# Privacy Policy gereksinimleri:
- Hangi veriler toplanıyor
- Veriler nasıl kullanılıyor
- Üçüncü taraf servisler
- Kullanıcı hakları
- İletişim bilgileri
```

#### **3. App Store Listing**
- [ ] App icon (512x512)
- [ ] Screenshots (farklı cihazlar)
- [ ] App description
- [ ] Privacy policy link
- [ ] Support email

### **App Store Connect (iOS)**

#### **1. Code Signing**
```bash
# Xcode'da otomatik signing
# Development ve Distribution certificates
# Provisioning profiles
```

#### **2. App Review**
- [ ] Privacy policy
- [ ] App permissions justification
- [ ] Content guidelines compliance
- [ ] Technical requirements

## 📊 Güvenlik Testleri

### **Penetration Testing**
```bash
# API endpoint testleri
curl -X GET "https://your-api.vercel.app/api/weather?city=test"

# Rate limiting testi
for i in {1..200}; do
  curl -X GET "https://your-api.vercel.app/api/weather?city=test"
done

# CORS testi
curl -H "Origin: https://malicious-site.com" \
     -X GET "https://your-api.vercel.app/api/weather?city=test"
```

### **Static Analysis**
```bash
# Flutter analyze
flutter analyze

# Security scanning
flutter pub deps --style=tree

# Dependency vulnerabilities
flutter pub outdated
```

## 🆘 Güvenlik İhlali Durumunda

### **Acil Durum Planı**
1. **API Key'i Deaktive Et**
   - AccuWeather Developer Portal
   - OpenWeatherMap Dashboard

2. **Yeni API Key Al**
   - Yeni key oluştur
   - Backend'e deploy et

3. **App Güncelle**
   - Yeni backend URL'i
   - Force update zorla

4. **Monitoring**
   - API kullanımını takip et
   - Anormal aktiviteleri izle

### **Monitoring Tools**
```javascript
// api/monitoring.js
export function logApiUsage(req, res, next) {
  const { ip, method, url } = req;
  const timestamp = new Date().toISOString();
  
  console.log(`[${timestamp}] ${ip} ${method} ${url}`);
  
  // Analytics service'e gönder
  analytics.track('api_request', {
    ip,
    method,
    url,
    timestamp
  });
  
  next();
}
```

## 📚 Güvenlik Kaynakları

### **Flutter Security**
- [Flutter Security Best Practices](https://flutter.dev/docs/deployment/security)
- [OWASP Mobile Security](https://owasp.org/www-project-mobile-top-10/)
- [Flutter Security Checklist](https://github.com/OWASP/owasp-mstg)

### **API Security**
- [REST API Security](https://restfulapi.net/security-essentials/)
- [API Rate Limiting](https://cloud.google.com/architecture/rate-limiting-strategies-techniques)
- [CORS Security](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)

### **Backend Security**
- [Vercel Security](https://vercel.com/docs/security)
- [Netlify Security](https://docs.netlify.com/security/)
- [Railway Security](https://docs.railway.app/security)

---

**⚠️ Önemli**: Bu rehber sadece başlangıç seviyesi güvenlik sağlar. Production uygulamalar için profesyonel güvenlik danışmanlığı önerilir.

**Son Güncelleme**: $(date)
**Güvenlik Seviyesi**: Production Ready (Backend Proxy ile)
