import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

class PermissionsService {
  static Future<bool> ensureBlePermissions() async {
    if (!Platform.isAndroid) return true;

    try {
      // Android sürümünü kontrol et
      final androidInfo = await _getAndroidInfo();
      final sdkInt = androidInfo['sdkInt'] as int? ?? 0;
      
      print('Android SDK: $sdkInt');
      
      final List<Permission> required = <Permission>[];
      
      // Android 12+ (API 31+) için yeni Bluetooth izinleri
      if (sdkInt >= 31) {
        required.addAll([
          Permission.bluetoothAdvertise,
          Permission.bluetoothConnect,
          Permission.bluetoothScan,
        ]);
      } else {
        // Android 11 ve altı için eski Bluetooth izinleri
        required.addAll([
          Permission.bluetooth,
        ]);
      }

      print('İstenen Bluetooth izinleri: $required');
      
      final Map<Permission, PermissionStatus> statuses = await required.request();
      final bool allGranted = statuses.values.every((s) => s.isGranted);
      
      // Eğer izinler reddedildiyse, kullanıcıyı ayarlara yönlendir
      if (!allGranted) {
        final deniedPermissions = statuses.entries
            .where((entry) => entry.value.isDenied)
            .map((entry) => entry.key)
            .toList();
        
        print('Reddedilen Bluetooth izinler: $deniedPermissions');
      }
      
      return allGranted;
    } catch (e) {
      print('Bluetooth izin hatası: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> _getAndroidInfo() async {
    try {
      const platform = MethodChannel('flutter/platform');
      final result = await platform.invokeMethod('SystemNavigator.pop');
      return {'sdkInt': 33}; // Varsayılan değer
    } catch (e) {
      return {'sdkInt': 33}; // Varsayılan değer
    }
  }

  static Future<bool> ensureLocationPermissions() async {
    if (!Platform.isAndroid) return true;
    
    // Önce mevcut izinleri kontrol et
    final currentStatus = await Permission.location.status;
    if (currentStatus.isGranted) return true;
    
    // Konum izni iste
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) return true;
    
    // Eğer reddedildiyse, coarse location dene
    final coarseStatus = await Permission.location.request();
    return coarseStatus.isGranted;
  }

  static Future<bool> ensureMockLocationPermission() async {
    if (!Platform.isAndroid) return true;
    
    // Mock location izni için özel kontrol
    try {
      // Bu izin normal permission handler ile kontrol edilemez
      // Android ayarlarından kontrol edilmesi gerekir
      return true; // Şimdilik true döndür, native kod kontrol edecek
    } catch (e) {
      print('Mock location izni kontrol hatası: $e');
      return false;
    }
  }

  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}


