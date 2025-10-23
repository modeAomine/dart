import 'dart:convert';
import 'package:http/http.dart' as http;

class YandexGeocoderService {
  static const String _apiKey = '689c442f-2649-40ba-9ac0-7be5df360fc9';
  static const String _baseUrl = 'https://geocode-maps.yandex.ru/1.x';

  static Future<List<Map<String, dynamic>>> searchAddress(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final url = '$_baseUrl?format=json&geocode=$encodedQuery&apikey=$_apiKey&lang=ru_RU&results=10';

    try {
      print('🔍 Search URL: $url');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Search response received');

        final featureMembers = data['response']['GeoObjectCollection']['featureMember'] as List? ?? [];

        if (featureMembers.isEmpty) {
          print('⚠️ No results found for query: $query');
          return [];
        }

        return featureMembers.map((member) {
          final geoObject = member['GeoObject'];
          final point = geoObject['Point']['pos'].split(' ');

          final result = {
            'name': geoObject['name'] ?? '',
            'description': geoObject['description'] ?? '',
            'full_address': geoObject['metaDataProperty']['GeocoderMetaData']['text'] ?? '',
            'latitude': double.parse(point[1]),
            'longitude': double.parse(point[0]),
          };

          print('📍 Found: ${result['full_address']}');
          return result;
        }).toList();
      } else {
        print('❌ Search HTTP error: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Search error: $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>?> reverseGeocode(double lat, double lon) async {
    final url = '$_baseUrl?format=json&geocode=$lon,$lat&apikey=$_apiKey&lang=ru_RU';

    try {
      print('🗺️ Reverse geocode URL: $url');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Reverse geocode response received');

        final featureMembers = data['response']['GeoObjectCollection']['featureMember'] as List? ?? [];

        if (featureMembers.isNotEmpty) {
          final geoObject = featureMembers.first['GeoObject'];
          final metaData = geoObject['metaDataProperty']['GeocoderMetaData'];
          final address = metaData['text'] ?? 'Адрес не определен';

          print('🎯 Reverse geocode SUCCESS: $address');
          return {
            'address': address,
            'name': geoObject['name'] ?? '',
            'full_address': address,
          };
        } else {
          print('⚠️ No address found for coordinates: $lat, $lon');
        }
      } else {
        print('❌ Reverse geocode HTTP error: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Reverse geocode error: $e');
    }

    // Fallback если все провалилось
    final fallbackAddress = 'Координаты: ${lat.toStringAsFixed(6)}, ${lon.toStringAsFixed(6)}';
    print('🔄 Using fallback address: $fallbackAddress');
    return {
      'address': fallbackAddress,
      'name': 'Местоположение',
      'full_address': fallbackAddress,
    };
  }

  // Альтернативный метод - используем другой endpoint
  static Future<Map<String, dynamic>?> reverseGeocodeAlternative(double lat, double lon) async {
    final url = 'https://geocode-maps.yandex.ru/1.x/?format=json&geocode=$lon,$lat&apikey=$_apiKey&lang=ru_RU&kind=house';

    try {
      print('🗺️ Alternative reverse geocode URL: $url');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Alternative reverse geocode response received');

        final collection = data['response']['GeoObjectCollection'];
        final featureMembers = collection['featureMember'] as List? ?? [];

        if (featureMembers.isNotEmpty) {
          final geoObject = featureMembers.first['GeoObject'];
          final address = geoObject['name'] ?? 'Адрес не определен';
          final description = geoObject['description'] ?? '';

          final fullAddress = description.isNotEmpty ? '$address, $description' : address;

          print('🎯 Alternative reverse geocode SUCCESS: $fullAddress');
          return {
            'address': fullAddress,
            'name': address,
            'full_address': fullAddress,
          };
        }
      }
    } catch (e) {
      print('❌ Alternative reverse geocode error: $e');
    }
    return null;
  }
}