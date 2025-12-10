import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SavedItemsService {
  static const String _locationsKey = 'saved_locations_v1';
  static const String _bleDevicesKey = 'saved_ble_devices_v1';

  Future<List<Map<String, dynamic>>> getSavedLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_locationsKey);
    if (raw == null) return [];
    final List list = jsonDecode(raw) as List;
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> saveLocation({required String name, required double lat, required double lng}) async {
    final list = await getSavedLocations();
    list.removeWhere((e) => e['name'] == name);
    list.add({'name': name, 'lat': lat, 'lng': lng});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_locationsKey, jsonEncode(list));
  }

  Future<void> removeLocation(String name) async {
    final list = await getSavedLocations();
    list.removeWhere((e) => e['name'] == name);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_locationsKey, jsonEncode(list));
  }

  Future<List<Map<String, dynamic>>> getSavedBleDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_bleDevicesKey);
    if (raw == null) return [];
    final List list = jsonDecode(raw) as List;
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> saveBleDevice({required String name, required String id, String? uuid}) async {
    final list = await getSavedBleDevices();
    list.removeWhere((e) => e['id'] == id);
    list.add({'name': name, 'id': id, if (uuid != null) 'uuid': uuid});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bleDevicesKey, jsonEncode(list));
  }

  Future<void> removeBleDevice(String id) async {
    final list = await getSavedBleDevices();
    list.removeWhere((e) => e['id'] == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bleDevicesKey, jsonEncode(list));
  }

  Future<void> deleteBleDevice(String name) async {
    final list = await getSavedBleDevices();
    list.removeWhere((e) => e['name'] == name);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bleDevicesKey, jsonEncode(list));
  }
}


