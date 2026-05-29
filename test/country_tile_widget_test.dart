import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:country_explorer/models/country.dart';
import 'package:country_explorer/widgets/country_tile.dart';

void main() {
  testWidgets('CountryTile shows name and region', (tester) async {
    final country = Country(
      name: 'Finland',
      flagUrl: '',
      capital: 'Helsinki',
      region: 'Europe',
      subregion: 'Northern Europe',
      population: 5530719,
      languages: ['Finnish'],
      currencies: ['Euro'],
    );

    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CountryTile(country: country, onTap: () => tapped = true),
        ),
      ),
    );

    expect(find.text('Finland'), findsOneWidget);
    expect(find.textContaining('Europe'), findsOneWidget);
    expect(find.textContaining('Helsinki'), findsOneWidget);

    await tester.tap(find.byType(CountryTile));
    expect(tapped, isTrue);
  });
}
