import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../services/mock_location_service.dart';
import '../services/permissions_service.dart';
import '../services/saved_items_service.dart';
import '../services/preset_locations_service.dart';

class MockLocationPage extends StatefulWidget {
  const MockLocationPage({super.key});

  @override
  State<MockLocationPage> createState() => _MockLocationPageState();
}

class _MockLocationPageState extends State<MockLocationPage> {
  final _formKey = GlobalKey<FormState>();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  LatLng? _picked;
  final _saved = SavedItemsService();
  LatLng _currentLocation = const LatLng(41.015137, 28.979530); // Varsayılan konum
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Konum iznini kontrol et
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Gerçek konumu al
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });
    } catch (e) {
      print('Konum alınamadı: $e');
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<MockLocationService>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🚨 GELİŞMİŞ MOCK LOCATION DETECTION BYPASS',
                  style: TextStyle(
                    color: Colors.red[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bu uygulama, WhatsApp, Instagram gibi popüler uygulamaların mock location tespit mekanizmalarını atlatmak için gelişmiş teknikler kullanır.',
                  style: TextStyle(color: Colors.red[700], fontSize: 12),
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
                        '⚠️ SİSTEM SEVİYESİ UYARILAR:',
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• Bu uygulama sistem seviyesi izinler gerektirir\n'
                        '• Tam işlevsellik için ROOT erişimi gerekebilir\n'
                        '• Sistem uygulaması olarak imzalanması önerilir\n'
                        '• Yanlış kullanım cihaz güvenliğini tehlikeye atabilir',
                        style: TextStyle(color: Colors.orange[700], fontSize: 10),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '📋 KURULUM ADIMLARI:',
                  style: TextStyle(
                    color: Colors.red[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '1. USB Hata Ayıklama (USB Debugging) KAPATIN\n'
                  '2. Ayarlar > Telefon Hakkında > Yapı Numarası\'na 7 kez dokunun\n'
                  '3. Ayarlar > Geliştirici Seçenekleri > Mock Location App\n'
                  '4. "ble_mock_app" uygulamasını seçin\n'
                  '5. Konum servislerini açın\n'
                  '6. Uygulamaya konum izni verin\n'
                  '7. Cihazı yeniden başlatın (önerilen)',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.yellow[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.yellow[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🔧 SORUN GİDERME:',
                        style: TextStyle(
                          color: Colors.yellow[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• Mock location app seçili olmasına rağmen hata alıyorsanız:\n'
                        '• Ayarlar > Uygulamalar > ble_mock_app > İzinler > Konum\n'
                        '• Ayarlar > Konum > Gelişmiş > Mock Location App\n'
                        '• Her iki yerde de uygulamayı seçin\n'
                        '• Cihazı yeniden başlatın\n'
                        '• Uygulamayı kapatıp tekrar açın',
                        style: TextStyle(color: Colors.yellow[700], fontSize: 10),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🔧 GELİŞMİŞ ÖZELLİKLER:',
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• Sürekli mock location güncelleme\n'
                        '• Reflection ile detection bypass\n'
                        '• System properties manipulation\n'
                        '• LocationManager API override\n'
                        '• Mock provider flag masking',
                        style: TextStyle(color: Colors.blue[700], fontSize: 10),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '💡 TAVSİYELER:',
                        style: TextStyle(
                          color: Colors.green[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• En iyi sonuç için Magisk/Xposed modülleri kullanın\n'
                        '• Sistem uygulaması olarak kurulum yapın\n'
                        '• Samsung, Xiaomi gibi özel ROM\'larda ek ayarlar gerekebilir\n'
                        '• Test amaçlı kullanın, güvenlik riski oluşturabilir',
                        style: TextStyle(color: Colors.green[700], fontSize: 10),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bu adımları tamamladıktan sonra tekrar deneyin.',
                  style: TextStyle(
                    color: Colors.red[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                  height: 260,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _isLoadingLocation
                        ? Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 8),
                                  Text('Konum alınıyor...'),
                                ],
                              ),
                            ),
                          )
                        : FlutterMap(
                            options: MapOptions(
                              initialCenter: _currentLocation,
                              initialZoom: 15,
                              onTap: (tapPosition, point) {
                                setState(() {
                                  _picked = point;
                                  _latController.text = point.latitude.toStringAsFixed(6);
                                  _lngController.text = point.longitude.toStringAsFixed(6);
                                });
                              },
                            ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c'],
                          userAgentPackageName: 'com.example.ble_mock_app',
                          maxZoom: 18,
                          errorTileCallback: (tile, error, stackTrace) {
                            print('Tile yükleme hatası: $error');
                          },
                        ),
                        // Gerçek konum marker'ı
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _currentLocation,
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.my_location, color: Colors.blue, size: 36),
                            ),
                          ],
                        ),
                        // Seçilen konum marker'ı
                        if (_picked != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _picked!,
                                width: 40,
                                height: 40,
                                child: const Icon(Icons.location_on, color: Colors.red, size: 36),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Konumumu Al butonu
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isLoadingLocation ? null : () async {
                      setState(() {
                        _isLoadingLocation = true;
                      });
                      await _getCurrentLocation();
                      if (!_isLoadingLocation) {
                        setState(() {
                          _picked = _currentLocation;
                          _latController.text = _currentLocation.latitude.toStringAsFixed(6);
                          _lngController.text = _currentLocation.longitude.toStringAsFixed(6);
                        });
                      }
                    },
                    icon: _isLoadingLocation 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location),
                    label: Text(_isLoadingLocation ? 'Konum alınıyor...' : 'KONUMUMU AL'),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final nameController = TextEditingController();
                          final name = await showDialog<String>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Konumu kaydet'),
                              content: TextField(controller: nameController, decoration: const InputDecoration(labelText: 'İsim')),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
                                TextButton(onPressed: () => Navigator.pop(ctx, nameController.text.trim()), child: const Text('Kaydet')),
                              ],
                            ),
                          );
                          if (name != null && name.isNotEmpty) {
                            final lat = double.tryParse(_latController.text);
                            final lng = double.tryParse(_lngController.text);
                            if (lat != null && lng != null) {
                              await _saved.saveLocation(name: name, lat: lat, lng: lng);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konum kaydedildi.')));
                              }
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
                          final items = await _saved.getSavedLocations();
                          if (!mounted) return;
                          await showModalBottomSheet(
                            context: context,
                            builder: (ctx) => ListView(
                              children: [
                                const ListTile(title: Text('Kayıtlı Konumlar')),
                                ...items.map((e) => ListTile(
                                      title: Text(e['name'] as String),
                                      subtitle: Text('(${e['lat']}, ${e['lng']})'),
                                      onTap: () {
                                        _latController.text = (e['lat']).toString();
                                        _lngController.text = (e['lng']).toString();
                                        _picked = LatLng((e['lat']) as double, (e['lng']) as double);
                                        Navigator.pop(ctx);
                                        setState(() {});
                                      },
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () async {
                                          await _saved.removeLocation(e['name'] as String);
                                          Navigator.pop(ctx);
                                        },
                                      ),
                                    )),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.list_alt),
                        label: const Text('KAYITLILAR'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final presets = PresetLocationsService.getPresetLocations();
                          if (!mounted) return;
                          await showModalBottomSheet(
                            context: context,
                            builder: (ctx) => Container(
                              height: 400,
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Hazır Konumlar (${presets.length}):', style: Theme.of(ctx).textTheme.titleMedium),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: presets.length,
                                      itemBuilder: (ctx, i) {
                                        final preset = presets[i];
                                        return Card(
                                          child: ListTile(
                                            title: Text(preset['name']),
                                            subtitle: Text(preset['description']),
                                            trailing: const Icon(Icons.location_on),
                                            onTap: () {
                                              _latController.text = preset['lat'].toString();
                                              _lngController.text = preset['lng'].toString();
                                              _picked = LatLng(preset['lat'] as double, preset['lng'] as double);
                                              Navigator.pop(ctx);
                                              setState(() {});
                                            },
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
                        icon: const Icon(Icons.public),
                        label: const Text('HAZIR KONUMLAR'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _latController,
                  decoration: const InputDecoration(labelText: 'Enlem (latitude)'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enlem gerekli';
                    final d = double.tryParse(v);
                    if (d == null || d < -90 || d > 90) return 'Geçerli bir enlem giriniz (-90..90)';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _lngController,
                  decoration: const InputDecoration(labelText: 'Boylam (longitude)'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Boylam gerekli';
                    final d = double.tryParse(v);
                    if (d == null || d < -180 || d > 180) return 'Geçerli bir boylam giriniz (-180..180)';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: service.isRunning
                            ? null
                            : () async {
                                print('Mock konum başlatma butonuna basıldı');
                                final granted = await PermissionsService.ensureLocationPermissions();
                                if (!granted) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Konum izni gerekli.')),
                                    );
                                  }
                                  return;
                                }
                                if (_formKey.currentState?.validate() != true) return;
                                final lat = double.parse(_latController.text);
                                final lng = double.parse(_lngController.text);
                                print('Koordinatlar: $lat, $lng');
                                try {
                                  await context.read<MockLocationService>().startMock(lat: lat, lng: lng);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Mock konum başlatıldı!')),
                                    );
                                  }
                                } catch (e) {
                                  print('Mock konum hatası: $e');
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Hata: $e')),
                                    );
                                  }
                                }
                              },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('KONUMU BAŞLAT'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: service.isRunning
                            ? () => context.read<MockLocationService>().stopMock()
                            : null,
                        icon: const Icon(Icons.stop),
                        label: const Text('KONUMU DURDUR'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  service.statusText,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


