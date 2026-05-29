import 'package:flutter_test/flutter_test.dart';
import 'package:country_explorer/models/country.dart';

void main() {
  group('Country', () {
    final sampleJson = {
      'name': {'common': 'Finland'},
      'flags': {'png': 'https://flagcdn.com/fi.png'},
      'capital': ['Helsinki'],
      'region': 'Europe',
      'subregion': 'Northern Europe',
      'population': 5530719,
      'languages': {'fin': 'Finnish', 'swe': 'Swedish'},
      'currencies': {
        'EUR': {'name': 'Euro', 'symbol': '€'},
      },
    };

    test('fromJson parses correctly', () {
      final c = Country.fromJson(sampleJson);
      expect(c.name, 'Finland');
      expect(c.capital, 'Helsinki');
      expect(c.region, 'Europe');
      expect(c.population, 5530719);
      expect(c.languages, containsAll(['Finnish', 'Swedish']));
      expect(c.currencies, contains('Euro'));
      expect(c.flagUrl, 'https://flagcdn.com/fi.png');
    });

    test('handles missing fields gracefully', () {
      final c = Country.fromJson({});
      expect(c.name, 'Unknown');
      expect(c.capital, 'N/A');
      expect(c.population, 0);
      expect(c.languages, isEmpty);
    });

    test('toJson roundtrip preserves name and capital', () {
      final c = Country.fromJson(sampleJson);
      final json = c.toJson();
      final c2 = Country.fromJson(json);
      expect(c2.name, c.name);
      expect(c2.capital, c.capital);
    });
  });
}
