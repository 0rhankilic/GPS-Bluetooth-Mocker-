import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ble_advertiser_service.dart';
import '../services/permissions_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../services/saved_items_service.dart';
import '../services/ble_uuid_service.dart';

class BluetoothClonerPage extends StatefulWidget {
  const BluetoothClonerPage({super.key});

  @override
  State<BluetoothClonerPage> createState() => _BluetoothClonerPageState();
}

class _BluetoothClonerPageState extends State<BluetoothClonerPage> {
  final _deviceNameController = TextEditingController();
  final _macController = TextEditingController();
  final _uuidController = TextEditingController();
  final _saved = SavedItemsService();
  final List<ScanResult> _results = [];
  bool _scanning = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Varsayılan UUID'yi ayarla
    _uuidController.text = '0000180D-0000-1000-8000-00805F9B34FB';
  }

  @override
  void dispose() {
    _deviceNameController.dispose();
    _macController.dispose();
    _uuidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<BleAdvertiserService>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🔵 BLE REKLAM SİMÜLASYONU',
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bu ekran BLE reklam (advertising) yayınlamayı simüle eder. Gerçek dünyada başka cihazın kimlik bilgilerini kullanmak yasal olmayabilir.',
                  style: TextStyle(color: Colors.blue[700], fontSize: 12),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⚠️ ÖNEMLİ UYARILAR:',
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• Bu uygulama sadece eğitim amaçlıdır\n'
                        '• Başka cihazların kimlik bilgilerini kullanmak yasal değildir\n'
                        '• Bluetooth izinleri gereklidir\n'
                        '• Android 12+ için ek izinler gerekebilir',
                        style: TextStyle(color: Colors.orange[700], fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _deviceNameController,
            decoration: const InputDecoration(labelText: 'Klonlanacak Cihaz Adı'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _macController,
            decoration: const InputDecoration(labelText: 'MAC Adresi (simülasyon)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _uuidController,
            decoration: const InputDecoration(
              labelText: 'Reklam UUID (otomatik doldurulur)',
              hintText: '0000180D-0000-1000-8000-00805F9B34FB',
              helperText: 'Cihaz tarama sonuçlarından otomatik doldurulur',
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                        onPressed: _scanning
                            ? null
                            : () async {
                                final granted = await PermissionsService.ensureBlePermissions();
                                if (!granted) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Bluetooth izinleri gerekli.'),
                                        action: SnackBarAction(
                                          label: 'Ayarlar',
                                          onPressed: () => PermissionsService.openAppSettings(),
                                        ),
                                      ),
                                    );
                                  }
                                  return;
                                }
                          setState(() {
                            _results.clear();
                            _scanning = true;
                          });
                          await FlutterBluePlus.startScan(
                            timeout: const Duration(seconds: 15),
                            withServices: [],
                          );
                          FlutterBluePlus.scanResults.listen((event) {
                            setState(() {
                              _results
                                ..clear()
                                ..addAll(event);
                            });
                          });
                          await Future.delayed(const Duration(seconds: 15));
                          await FlutterBluePlus.stopScan();
                          if (mounted) setState(() => _scanning = false);
                        },
                  icon: const Icon(Icons.search),
                  label: const Text('ÇEVREDEKİ CİHAZLARI TARA'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_results.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _searchQuery.isEmpty 
                          ? 'Bulunan cihazlar (${_results.length}):'
                          : 'Arama sonuçları (${_results.where((r) {
                              if (_searchQuery.isEmpty) return true;
                              String name = 'Bilinmeyen Cihaz';
                              if (r.advertisementData.advName.isNotEmpty) {
                                name = r.advertisementData.advName;
                              } else if (r.device.platformName.isNotEmpty) {
                                name = r.device.platformName;
                              } else if (r.advertisementData.manufacturerData.isNotEmpty) {
                                name = 'BLE Cihaz (${r.advertisementData.manufacturerData.length} byte)';
                              } else if (r.advertisementData.serviceUuids.isNotEmpty) {
                                name = 'BLE Servis (${r.advertisementData.serviceUuids.length} UUID)';
                              }
                              return name.toLowerCase().contains(_searchQuery) ||
                                     r.device.remoteId.str.toLowerCase().contains(_searchQuery) ||
                                     r.advertisementData.serviceUuids.any((u) => 
                                       u.str.toLowerCase().contains(_searchQuery));
                            }).length}):',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      icon: Icon(_searchQuery.isEmpty ? Icons.search : Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = _searchQuery.isEmpty ? ' ' : '';
                        });
                      },
                    ),
                  ],
                ),
                if (_searchQuery.isNotEmpty) ...[
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Cihaz adı ara...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                ],
                ..._results.where((r) {
                  // Arama filtresi
                  if (_searchQuery.isEmpty) return true;
                  
                  // Cihaz adını belirle
                  String name = 'Bilinmeyen Cihaz';
                  if (r.advertisementData.advName.isNotEmpty) {
                    name = r.advertisementData.advName;
                  } else if (r.device.platformName.isNotEmpty) {
                    name = r.device.platformName;
                  } else if (r.advertisementData.manufacturerData.isNotEmpty) {
                    name = 'BLE Cihaz (${r.advertisementData.manufacturerData.length} byte)';
                  } else if (r.advertisementData.serviceUuids.isNotEmpty) {
                    name = 'BLE Servis (${r.advertisementData.serviceUuids.length} UUID)';
                  }
                  
                  // Arama kriterleri
                  return name.toLowerCase().contains(_searchQuery) ||
                         r.device.remoteId.str.toLowerCase().contains(_searchQuery) ||
                         r.advertisementData.serviceUuids.any((u) => 
                           u.str.toLowerCase().contains(_searchQuery));
                }).map((r) {
                  // Cihaz adını daha iyi belirle
                  String name = 'Bilinmeyen Cihaz';
                  if (r.advertisementData.advName.isNotEmpty) {
                    name = r.advertisementData.advName;
                  } else if (r.device.platformName.isNotEmpty) {
                    name = r.device.platformName;
                  } else if (r.advertisementData.manufacturerData.isNotEmpty) {
                    name = 'BLE Cihaz (${r.advertisementData.manufacturerData.length} byte)';
                  } else if (r.advertisementData.serviceUuids.isNotEmpty) {
                    name = 'BLE Servis (${r.advertisementData.serviceUuids.length} UUID)';
                  }
                  
                  final id = r.device.remoteId.str;
                  final uuids = r.advertisementData.serviceUuids;
                  final manufacturerData = r.advertisementData.manufacturerData;
                  final txPowerLevel = r.advertisementData.txPowerLevel;
                  
                  // UUID'leri daha iyi göster
                  String uuidText = 'UUID yok';
                  if (uuids.isNotEmpty) {
                    uuidText = uuids.map((u) => u.str).join(', ');
                  }
                  
                  // Ek bilgiler
                  List<String> extraInfo = [];
                  if (manufacturerData.isNotEmpty) {
                    extraInfo.add('MFG: ${manufacturerData.length} byte');
                  }
                  if (txPowerLevel != null) {
                    extraInfo.add('TX: ${txPowerLevel}dBm');
                  }
                  // RSSI bilgisi scan result'ta değil, device'ta
                  if (r.rssi != null) {
                    extraInfo.add('RSSI: ${r.rssi}dBm');
                  }
                  
                  return Card(
                    child: ListTile(
                      title: Text(name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ID: $id'),
                          if (uuidText != 'UUID yok') Text('UUIDs: $uuidText'),
                          if (extraInfo.isNotEmpty) Text('Ek: ${extraInfo.join(', ')}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy),
                        tooltip: 'Bilgileri klonla',
                        onPressed: () {
                          _deviceNameController.text = name;
                          _macController.text = id;
                          if (uuids.isNotEmpty) {
                            _uuidController.text = uuids.first.str;
                          }
                        },
                      ),
                      onLongPress: () async {
                        final textController = TextEditingController(text: name);
                        final newName = await showDialog<String>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Cihazı kaydet'),
                            content: TextField(controller: textController, decoration: const InputDecoration(labelText: 'İsim')), 
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
                              TextButton(onPressed: () => Navigator.pop(ctx, textController.text.trim()), child: const Text('Kaydet')),
                            ],
                          ),
                        );
                        if (newName != null && newName.isNotEmpty) {
                          await _saved.saveBleDevice(name: newName, id: id, uuid: uuids.isNotEmpty ? uuids.first.str : null);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cihaz kaydedildi.')));
                          }
                        }
                      },
                    ),
                  );
                }),
              ],
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                        onPressed: service.isAdvertising
                            ? null
                            : () async {
                                final granted = await PermissionsService.ensureBlePermissions();
                                if (!granted) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Bluetooth izinleri gerekli.'),
                                        action: SnackBarAction(
                                          label: 'Ayarlar',
                                          onPressed: () => PermissionsService.openAppSettings(),
                                        ),
                                      ),
                                    );
                                  }
                                  return;
                                }
                          service.startAdvertising(
                            deviceName: _deviceNameController.text.trim().isEmpty
                                ? 'BLE-Mock'
                                : _deviceNameController.text.trim(),
                            mockMac: _macController.text.trim(),
                            uuid: _uuidController.text.trim(),
                          );
                        },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('REKLAMI BAŞLAT'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: service.isAdvertising ? service.stopAdvertising : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('REKLAMI DURDUR'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Kaydetme ve yükleme butonları
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final nameController = TextEditingController();
                    final name = await showDialog<String>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Cihazı kaydet'),
                        content: TextField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: 'İsim'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('İptal'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, nameController.text.trim()),
                            child: const Text('Kaydet'),
                          ),
                        ],
                      ),
                    );
                    if (name != null && name.isNotEmpty) {
                      await _saved.saveBleDevice(
                        name: name,
                        id: _macController.text.trim(),
                        uuid: _uuidController.text.trim().isEmpty ? null : _uuidController.text.trim(),
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cihaz kaydedildi.')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.bookmark_add_outlined),
                  label: const Text('KAYDET'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final items = await _saved.getSavedBleDevices();
                    if (!mounted) return;
                    await showModalBottomSheet(
                      context: context,
                      builder: (ctx) => Container(
                        height: 400,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Kayıtlı cihazlar (${items.length}):', style: Theme.of(ctx).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Expanded(
                              child: items.isEmpty
                                  ? const Center(child: Text('Kayıtlı cihaz yok.'))
                                  : ListView.builder(
                                      itemCount: items.length,
                                      itemBuilder: (ctx, i) {
                                        final item = items[i];
                                        return Card(
                                          child: ListTile(
                                            title: Text(item['name'] ?? 'İsimsiz'),
                                            subtitle: Text('ID: ${item['id']}\nUUID: ${item['uuid'] ?? 'Yok'}'),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.delete),
                                                  onPressed: () async {
                                                    await _saved.deleteBleDevice(item['name']);
                                                    Navigator.pop(ctx);
                                                    setState(() {});
                                                  },
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.download),
                                                  onPressed: () {
                                                    _deviceNameController.text = item['name'] ?? '';
                                                    _macController.text = item['id'] ?? '';
                                                    _uuidController.text = item['uuid'] ?? '';
                                                    Navigator.pop(ctx);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.bookmark_outlined),
                  label: const Text('YÜKLE'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(service.statusText),
        ],
      ),
    );
  }
}


