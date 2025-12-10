import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/mock_location_page.dart';
import 'pages/bluetooth_cloner_page.dart';
import 'services/mock_location_service.dart';
import 'services/ble_advertiser_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MockLocationService()),
        ChangeNotifierProvider(create: (_) => BleAdvertiserService()),
      ],
      child: const BleMockApp(),
    ),
  );
}

class BleMockApp extends StatefulWidget {
  const BleMockApp({super.key});

  @override
  State<BleMockApp> createState() => _BleMockAppState();
}

class _BleMockAppState extends State<BleMockApp> {
  int _index = 0;

  final _pages = const [
    MockLocationPage(),
    BluetoothClonerPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: Colors.indigo);
    return MaterialApp(
      title: 'BLE & Mock Location',
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(_index == 0 ? 'Fake GPS / Mock Konum' : 'BLE Klonlama Simülasyonu'),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Uygulama Hakkında'),
                    content: const Text(
                      'Bu uygulama gelişmiş mock location ve BLE reklam simülasyonu sağlar.\n\n'
                      'Özellikler:\n'
                      '• Gelişmiş mock location detection bypass\n'
                      '• BLE reklam simülasyonu\n'
                      '• Preset konumlar\n'
                      '• Kayıtlı konumlar\n'
                      '• Gelişmiş izin yönetimi\n\n'
                      '⚠️ Sadece eğitim amaçlı kullanın!',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Tamam'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: SafeArea(child: _pages[_index]),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.location_on_outlined),
              selectedIcon: Icon(Icons.location_on),
              label: 'Mock Konum',
            ),
            NavigationDestination(
              icon: Icon(Icons.bluetooth_outlined),
              selectedIcon: Icon(Icons.bluetooth),
              label: 'BLE Reklam',
            ),
          ],
        ),
      ),
    );
  }
}
