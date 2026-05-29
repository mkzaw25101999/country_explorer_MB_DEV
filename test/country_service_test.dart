import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:country_explorer/services/country_service.dart';

void main() {
  group('CountryService', () {
    test('fetchCountries returns parsed list on 200', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode([
            {
              'name': {'common': 'Finland'},
              'flags': {'png': 'https://flagcdn.com/fi.png'},
              'capital': ['Helsinki'],
              'region': 'Europe',
              'subregion': 'Northern Europe',
              'population': 5530719,
              'languages': {'fin': 'Finnish'},
              'currencies': {
                'EUR': {'name': 'Euro'},
              },
            },
          ]),
          200,
        );
      });

      final service = CountryService(client: mockClient);
      final result = await service.fetchCountries();

      expect(result, hasLength(1));
      expect(result.first.name, 'Finland');
      expect(result.first.capital, 'Helsinki');
    });

    test('fetchCountries throws on non-200', () async {
      final mockClient = MockClient((_) async => http.Response('error', 500));
      final service = CountryService(client: mockClient);
      expect(() => service.fetchCountries(), throwsException);
    });
  });
}
