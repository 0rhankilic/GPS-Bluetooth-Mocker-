class BleUuidService {
  // Yaygın kullanılan BLE servis UUID'leri
  static const Map<String, String> commonUuids = {
    'Heart Rate': '0000180D-0000-1000-8000-00805F9B34FB',
    'Battery Service': '0000180F-0000-1000-8000-00805F9B34FB',
    'Device Information': '0000180A-0000-1000-8000-00805F9B34FB',
    'Generic Access': '00001800-0000-1000-8000-00805F9B34FB',
    'Generic Attribute': '00001801-0000-1000-8000-00805F9B34FB',
    'Immediate Alert': '00001802-0000-1000-8000-00805F9B34FB',
    'Link Loss': '00001803-0000-1000-8000-00805F9B34FB',
    'Tx Power': '00001804-0000-1000-8000-00805F9B34FB',
    'Current Time': '00001805-0000-1000-8000-00805F9B34FB',
    'Reference Time': '00001806-0000-1000-8000-00805F9B34FB',
    'Next DST Change': '00001807-0000-1000-8000-00805F9B34FB',
    'Glucose': '00001808-0000-1000-8000-00805F9B34FB',
    'Health Thermometer': '00001809-0000-1000-8000-00805F9B34FB',
    'Cycling Speed and Cadence': '00001816-0000-1000-8000-00805F9B34FB',
    'Cycling Power': '00001818-0000-1000-8000-00805F9B34FB',
    'Location and Navigation': '00001819-0000-1000-8000-00805F9B34FB',
    'Environmental Sensing': '0000181A-0000-1000-8000-00805F9B34FB',
    'Body Composition': '0000181B-0000-1000-8000-00805F9B34FB',
    'User Data': '0000181C-0000-1000-8000-00805F9B34FB',
    'Weight Scale': '0000181D-0000-1000-8000-00805F9B34FB',
    'Bond Management': '0000181E-0000-1000-8000-00805F9B34FB',
    'Continuous Glucose Monitoring': '0000181F-0000-1000-8000-00805F9B34FB',
    'Internet Protocol Support': '00001820-0000-1000-8000-00805F9B34FB',
    'Indoor Positioning': '00001821-0000-1000-8000-00805F9B34FB',
    'Pulse Oximeter': '00001822-0000-1000-8000-00805F9B34FB',
    'HTTP Proxy': '00001823-0000-1000-8000-00805F9B34FB',
    'Transport Discovery': '00001824-0000-1000-8000-00805F9B34FB',
    'Object Transfer': '00001825-0000-1000-8000-00805F9B34FB',
    'Fitness Machine': '00001826-0000-1000-8000-00805F9B34FB',
    'Mesh Provisioning': '00001827-0000-1000-8000-00805F9B34FB',
    'Mesh Proxy': '00001828-0000-1000-8000-00805F9B34FB',
    'Reconnection Configuration': '00001829-0000-1000-8000-00805F9B34FB',
    'Insulin Delivery': '0000182A-0000-1000-8000-00805F9B34FB',
    'Binary Sensor': '0000182B-0000-1000-8000-00805F9B34FB',
    'Emergency Configuration': '0000182C-0000-1000-8000-00805F9B34FB',
    'Authorization Control': '0000182D-0000-1000-8000-00805F9B34FB',
    'Volume Control': '0000184E-0000-1000-8000-00805F9B34FB',
    'Volume Offset Control': '0000184F-0000-1000-8000-00805F9B34FB',
    'Coordinated Set Identification': '00001850-0000-1000-8000-00805F9B34FB',
    'Device Time Control': '00001851-0000-1000-8000-00805F9B34FB',
    'Media Control': '00001852-0000-1000-8000-00805F9B34FB',
    'Generic Media Control': '00001853-0000-1000-8000-00805F9B34FB',
    'Constant Tone Extension': '00001854-0000-1000-8000-00805F9B34FB',
    'Telephone Bearer': '00001855-0000-1000-8000-00805F9B34FB',
    'Generic Telephone Bearer': '00001856-0000-1000-8000-00805F9B34FB',
    'Microphone Control': '00001857-0000-1000-8000-00805F9B34FB',
    'Audio Stream Control': '00001858-0000-1000-8000-00805F9B34FB',
    'Broadcast Audio Scan': '00001859-0000-1000-8000-00805F9B34FB',
    'Published Audio Capabilities': '0000185A-0000-1000-8000-00805F9B34FB',
    'Basic Audio Announcement': '0000185B-0000-1000-8000-00805F9B34FB',
    'Broadcast Audio Announcement': '0000185C-0000-1000-8000-00805F9B34FB',
    'Common Audio': '0000185D-0000-1000-8000-00805F9B34FB',
    'Hearing Access': '0000185E-0000-1000-8000-00805F9B34FB',
    'Telephony and Media Audio': '0000185F-0000-1000-8000-00805F9B34FB',
    'Public Broadcast Announcement': '00001860-0000-1000-8000-00805F9B34FB',
  };

  static List<Map<String, String>> getCommonUuids() {
    return commonUuids.entries
        .map((entry) => {'name': entry.key, 'uuid': entry.value})
        .toList();
  }

  static String? formatUuid(String uuid) {
    if (uuid.isEmpty) return null;
    
    // UUID'yi temizle
    String cleanUuid = uuid.replaceAll('-', '').replaceAll(' ', '').toUpperCase();
    
    // 32 karakter kontrolü
    if (cleanUuid.length != 32) {
      print('Geçersiz UUID formatı: $uuid (32 karakter olmalı)');
      return null;
    }
    
    // Doğru formatta UUID oluştur
    return '${cleanUuid.substring(0, 8)}-${cleanUuid.substring(8, 12)}-${cleanUuid.substring(12, 16)}-${cleanUuid.substring(16, 20)}-${cleanUuid.substring(20, 32)}';
  }

  static bool isValidUuid(String uuid) {
    if (uuid.isEmpty) return false;
    
    String cleanUuid = uuid.replaceAll('-', '').replaceAll(' ', '').toUpperCase();
    
    // 32 karakter ve sadece hex karakterler
    if (cleanUuid.length != 32) return false;
    
    return RegExp(r'^[0-9A-F]{32}$').hasMatch(cleanUuid);
  }

  static String generateRandomUuid() {
    // Basit UUID üretici (gerçek UUID değil, sadece format)
    final random = DateTime.now().millisecondsSinceEpoch;
    final hex = random.toRadixString(16).padLeft(8, '0');
    return '0000$hex-0000-1000-8000-00805F9B34FB';
  }
}

