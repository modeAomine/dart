import 'dart:convert';
import 'package:http/http.dart' as http;

class YandexGeocoderService {
  static const String _apiKey = '689c442f-2649-40ba-9ac0-7be5df360fc9';
  static const String _baseUrl = 'https://geocode-maps.yandex.ru/1.x'; // ← ИСПРАВЬ URL

  static Future<List<Map<String, dynamic>>> searchAddress(String query) async {
    final url = '$_baseUrl?format=json&geocode=$query&apikey=$_apiKey&lang=ru_RU&results=10';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final featureMembers = data['response']['GeoObjectCollection']['featureMember'] as List;

        return featureMembers.map((member) {
          final geoObject = member['GeoObject'];
          final point = geoObject['Point']['pos'].split(' ');

          return {
            'name': geoObject['name'],
            'description': geoObject['description'] ?? '',
            'full_address': geoObject['metaDataProperty']['GeocoderMetaData']['text'],
            'latitude': double.parse(point[1]),
            'longitude': double.parse(point[0]),
          };
        }).toList();
      }
    } catch (e) {
      print('Error searching address: $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>?> reverseGeocode(double lat, double lon) async {
    final url = '$_baseUrl?format=json&geocode=$lon,$lat&apikey=$_apiKey&lang=ru_RU';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final featureMembers = data['response']['GeoObjectCollection']['featureMember'] as List;

        if (featureMembers.isNotEmpty) {
          final geoObject = featureMembers.first['GeoObject'];
          return {
            'address': geoObject['metaDataProperty']['GeocoderMetaData']['text'],
            'name': geoObject['name'],
          };
        }
      }
    } catch (e) {
      print('Error reverse geocoding: $e');
    }
    return null;
  }
}