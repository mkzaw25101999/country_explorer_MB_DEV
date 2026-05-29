import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/country.dart';

class CountryService {
  final http.Client client;
  static const String _baseUrl =
      'https://restcountries.com/v3.1/all?fields=name,flags,capital,region,subregion,population,languages,currencies';

  CountryService({http.Client? client}) : client = client ?? http.Client();

  Future<List<Country>> fetchCountries() async {
    final response = await client.get(Uri.parse(_baseUrl));
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load countries (status ${response.statusCode})',
      );
    }
    final List<dynamic> data = json.decode(response.body) as List<dynamic>;
    return data.map((e) => Country.fromJson(e as Map<String, dynamic>)).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }
}
