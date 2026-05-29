import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/country.dart';
import '../services/country_service.dart';

final countryServiceProvider = Provider<CountryService>(
  (ref) => CountryService(),
);

final countryListProvider = FutureProvider<List<Country>>((ref) async {
  final service = ref.watch(countryServiceProvider);
  return service.fetchCountries();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredCountriesProvider = Provider<AsyncValue<List<Country>>>((ref) {
  final asyncCountries = ref.watch(countryListProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();

  return asyncCountries.whenData((countries) {
    if (query.isEmpty) return countries;
    return countries
        .where((c) => c.name.toLowerCase().contains(query))
        .toList();
  });
});


final pageSizeProvider = StateProvider<int>((ref) => 20);

final paginatedCountriesProvider = Provider<AsyncValue<List<Country>>>((ref) {
  final filtered = ref.watch(filteredCountriesProvider);
  final pageSize = ref.watch(pageSizeProvider);
  return filtered.whenData((list) => list.take(pageSize).toList());
});
