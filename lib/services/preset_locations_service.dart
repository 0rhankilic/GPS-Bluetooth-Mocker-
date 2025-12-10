class PresetLocationsService {
  static const List<Map<String, dynamic>> presetLocations = [
    {
      'name': 'İstanbul - Taksim',
      'lat': 41.0369,
      'lng': 28.9850,
      'description': 'Taksim Meydanı, İstanbul',
    },
    {
      'name': 'İstanbul - Sultanahmet',
      'lat': 41.0082,
      'lng': 28.9784,
      'description': 'Sultanahmet Camii, İstanbul',
    },
    {
      'name': 'İstanbul - Kadıköy',
      'lat': 40.9900,
      'lng': 29.0200,
      'description': 'Kadıköy Merkez, İstanbul',
    },
    {
      'name': 'Ankara - Kızılay',
      'lat': 39.9208,
      'lng': 32.8541,
      'description': 'Kızılay Meydanı, Ankara',
    },
    {
      'name': 'İzmir - Konak',
      'lat': 38.4192,
      'lng': 27.1287,
      'description': 'Konak Meydanı, İzmir',
    },
    {
      'name': 'New York - Times Square',
      'lat': 40.7580,
      'lng': -73.9855,
      'description': 'Times Square, New York',
    },
    {
      'name': 'London - Big Ben',
      'lat': 51.4994,
      'lng': -0.1245,
      'description': 'Big Ben, London',
    },
    {
      'name': 'Paris - Eiffel Tower',
      'lat': 48.8584,
      'lng': 2.2945,
      'description': 'Eiffel Tower, Paris',
    },
    {
      'name': 'Tokyo - Shibuya',
      'lat': 35.6598,
      'lng': 139.7006,
      'description': 'Shibuya Crossing, Tokyo',
    },
    {
      'name': 'Dubai - Burj Khalifa',
      'lat': 25.1972,
      'lng': 55.2744,
      'description': 'Burj Khalifa, Dubai',
    },
  ];

  static List<Map<String, dynamic>> getPresetLocations() {
    return List.from(presetLocations);
  }

  static Map<String, dynamic>? getPresetLocationByName(String name) {
    try {
      return presetLocations.firstWhere((location) => location['name'] == name);
    } catch (e) {
      return null;
    }
  }

  static List<Map<String, dynamic>> searchPresetLocations(String query) {
    if (query.isEmpty) return getPresetLocations();
    
    return presetLocations.where((location) {
      final name = location['name'].toString().toLowerCase();
      final description = location['description'].toString().toLowerCase();
      final searchQuery = query.toLowerCase();
      
      return name.contains(searchQuery) || description.contains(searchQuery);
    }).toList();
  }
}

