import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'ble_uuid_service.dart';
import 'ble_gatt_service.dart';

class BleAdvertiserService extends ChangeNotifier {
  final _blePeripheral = FlutterBlePeripheral();
  final _gattService = BleGattService();
  bool _isAdvertising = false;
  String _statusText = 'Reklam pasif';

  bool get isAdvertising => _isAdvertising;
  String get statusText => _statusText;

  Future<void> startAdvertising({
    required String deviceName,
    required String mockMac,
    required String uuid,
  }) async {
    try {
      final settings = AdvertiseSettings(
        advertiseMode: AdvertiseMode.advertiseModeLowLatency,
        txPowerLevel: AdvertiseTxPower.advertiseTxPowerHigh,
        connectable: true, // Bağlantıya izin ver
        timeout: 0, // Süresiz
      );

      // UUID'yi doğru formatta hazırla
      String? formattedUuid = BleUuidService.formatUuid(uuid);
      
      if (formattedUuid == null && uuid.isNotEmpty) {
        print('Geçersiz UUID formatı: $uuid');
        _statusText = '❌ Geçersiz UUID formatı: $uuid';
        notifyListeners();
        return;
      }

      // Daha iyi reklam verisi oluştur
      final data = AdvertiseData(
        serviceUuid: formattedUuid,
        serviceDataUuid: formattedUuid,
        manufacturerId: 0xFFFF,
        manufacturerData: Uint8List.fromList([
          0x01, 0x02, 0x03, 0x04, // Test verisi
          ...deviceName.codeUnits.take(10), // Cihaz adından ilk 10 karakter
        ]),
        includeDeviceName: deviceName.isNotEmpty,
        localName: deviceName.isNotEmpty ? deviceName : 'BLE Mock Device',
        includePowerLevel: true,
      );

      print('BLE Advertiser: Başlatılıyor...');
      print('BLE Advertiser: Cihaz: $deviceName');
      print('BLE Advertiser: MAC: $mockMac');
      print('BLE Advertiser: UUID: $uuid');

      await _blePeripheral.start(
        advertiseData: data,
        advertiseSettings: settings,
      );

      // GATT server'ı da başlat
      await _gattService.setupGattServer(
        deviceName: deviceName,
        uuid: uuid,
      );

      _isAdvertising = true;
      _statusText = '📡 BLE Reklam + GATT aktif\n'
          '• Cihaz: $deviceName\n'
          '• MAC: ${mockMac.isEmpty ? 'Simüle ediliyor' : mockMac}\n'
          '• UUID: ${uuid.isEmpty ? 'Yok' : uuid}\n'
          '• Bağlantı: Mümkün';
      notifyListeners();
    } catch (e) {
      _statusText = '❌ BLE Reklam başlatılamadı: $e';
      notifyListeners();
    }
  }

  Future<void> stopAdvertising() async {
    try {
      await _blePeripheral.stop();
      await _gattService.stopGattServer();
      _isAdvertising = false;
      _statusText = '🛑 BLE Reklam + GATT durduruldu';
      notifyListeners();
    } catch (e) {
      _statusText = '❌ BLE Reklam durdurulamadı: $e';
      notifyListeners();
    }
  }
}


