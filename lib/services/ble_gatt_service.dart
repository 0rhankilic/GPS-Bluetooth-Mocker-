import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';

class BleGattService extends ChangeNotifier {
  final _blePeripheral = FlutterBlePeripheral();
  bool _isConnected = false;
  String _statusText = 'GATT servis pasif';
  List<BluetoothGattCharacteristic> _characteristics = [];

  bool get isConnected => _isConnected;
  String get statusText => _statusText;
  List<BluetoothGattCharacteristic> get characteristics => _characteristics;

  Future<void> setupGattServer({
    required String deviceName,
    required String uuid,
  }) async {
    try {
      // GATT servisleri oluştur
      final services = await _createGattServices(uuid);
      
      // GATT server'ı başlat
      await _blePeripheral.startGattServer(services);
      
      _isConnected = true;
      _statusText = '🔗 GATT Server aktif\n'
          '• Cihaz: $deviceName\n'
          '• Servisler: ${services.length}\n'
          '• Bağlantıya hazır';
      notifyListeners();
      
    } catch (e) {
      _statusText = '❌ GATT Server başlatılamadı: $e';
      notifyListeners();
    }
  }

  Future<List<BluetoothGattService>> _createGattServices(String uuid) async {
    final services = <BluetoothGattService>[];
    
    // Ana servis UUID'si
    final serviceUuid = uuid.isNotEmpty ? uuid : '0000180D-0000-1000-8000-00805F9B34FB';
    
    // Heart Rate Service (örnek)
    final heartRateService = BluetoothGattService(
      uuid: serviceUuid,
      type: BluetoothGattServiceType.primary,
      characteristics: [
        BluetoothGattCharacteristic(
          uuid: '00002A37-0000-1000-8000-00805F9B34FB', // Heart Rate Measurement
          properties: BluetoothGattCharacteristicProperty.read | 
                      BluetoothGattCharacteristicProperty.notify,
          permissions: BluetoothGattCharacteristicPermission.read,
          value: Uint8List.fromList([0x06, 0x64]), // Örnek kalp atışı verisi
        ),
        BluetoothGattCharacteristic(
          uuid: '00002A38-0000-1000-8000-00805F9B34FB', // Body Sensor Location
          properties: BluetoothGattCharacteristicProperty.read,
          permissions: BluetoothGattCharacteristicPermission.read,
          value: Uint8List.fromList([0x01]), // Göğüs
        ),
      ],
    );
    
    services.add(heartRateService);
    
    // Device Information Service
    final deviceInfoService = BluetoothGattService(
      uuid: '0000180A-0000-1000-8000-00805F9B34FB',
      type: BluetoothGattServiceType.primary,
      characteristics: [
        BluetoothGattCharacteristic(
          uuid: '00002A29-0000-1000-8000-00805F9B34FB', // Manufacturer Name
          properties: BluetoothGattCharacteristicProperty.read,
          permissions: BluetoothGattCharacteristicPermission.read,
          value: Uint8List.fromList('BLE Mock Device'.codeUnits),
        ),
        BluetoothGattCharacteristic(
          uuid: '00002A24-0000-1000-8000-00805F9B34FB', // Model Number
          properties: BluetoothGattCharacteristicProperty.read,
          permissions: BluetoothGattCharacteristicPermission.read,
          value: Uint8List.fromList('Mock v1.0'.codeUnits),
        ),
      ],
    );
    
    services.add(deviceInfoService);
    
    return services;
  }

  Future<void> stopGattServer() async {
    try {
      await _blePeripheral.stopGattServer();
      _isConnected = false;
      _characteristics.clear();
      _statusText = '🛑 GATT Server durduruldu';
      notifyListeners();
    } catch (e) {
      _statusText = '❌ GATT Server durdurulamadı: $e';
      notifyListeners();
    }
  }

  Future<void> updateCharacteristicValue(String characteristicUuid, Uint8List value) async {
    try {
      await _blePeripheral.updateCharacteristicValue(characteristicUuid, value);
      _statusText = '📡 Karakteristik güncellendi: $characteristicUuid';
      notifyListeners();
    } catch (e) {
      _statusText = '❌ Karakteristik güncellenemedi: $e';
      notifyListeners();
    }
  }
}

