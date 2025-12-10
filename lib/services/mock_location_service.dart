import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class MockLocationService extends ChangeNotifier {
  bool _isRunning = false;
  Timer? _timer;
  String _statusText = 'Gelişmiş mock location sistemi hazır';
  bool _hasAdvancedFeatures = true;
  static const MethodChannel _channel = MethodChannel('app.mock/location');

  bool get isRunning => _isRunning;
  String get statusText => _statusText;
  bool get hasAdvancedFeatures => _hasAdvancedFeatures;

  Future<void> startMock({required double lat, required double lng}) async {
    try {
      print('MockLocationService: Gelişmiş mock location başlatılıyor - $lat, $lng');
      
      // Mock location iznini kontrol et (esnek kontrol)
      try {
        final hasPermission = await _channel.invokeMethod('checkMockPermission');
        print('Mock location izni kontrol sonucu: $hasPermission');
        
        if (hasPermission != true) {
          print('Mock location izni kontrolü başarısız, ancak devam ediliyor...');
          // İzin kontrolü başarısız olsa bile devam et, çünkü bazı cihazlarda farklı davranabilir
        }
      } catch (e) {
        print('Mock location izni kontrol hatası: $e');
        // Hata durumunda da devam et
      }
      
      final result = await _channel.invokeMethod('startMock', {
        'lat': lat,
        'lng': lng,
      });
      print('MockLocationService: Gelişmiş mock location başlatıldı - $result');

      _isRunning = true;
      _statusText = '🚀 Gelişmiş mock location aktif: ($lat, $lng)\n'
          '• Detection bypass etkin\n'
          '• Sürekli güncelleme aktif\n'
          '• WhatsApp/Instagram bypass hazır';
      notifyListeners();
    } catch (e) {
      _statusText = '❌ Gelişmiş mock location başlatılamadı: $e\n'
          'Lütfen sistem izinlerini kontrol edin.';
      notifyListeners();
    }
  }

  Future<void> stopMock() async {
    try {
      _timer?.cancel();
      _timer = null;
      await _channel.invokeMethod('stopMock');
      _isRunning = false;
      _statusText = '🛑 Gelişmiş mock location sistemi durduruldu\n'
          '• Detection bypass devre dışı\n'
          '• Sistem temizlendi';
      notifyListeners();
    } catch (e) {
      _statusText = '❌ Gelişmiş mock location durdurulamadı: $e';
      notifyListeners();
    }
  }
}


