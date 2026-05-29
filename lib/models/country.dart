class Country {
  final String name;
  final String flagUrl;
  final String capital;
  final String region;
  final String subregion;
  final int population;
  final List<String> languages;
  final List<String> currencies;

  Country({
    required this.name,
    required this.flagUrl,
    required this.capital,
    required this.region,
    required this.subregion,
    required this.population,
    required this.languages,
    required this.currencies,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    final nameMap = json['name'] as Map<String, dynamic>? ?? {};
    final capitals = (json['capital'] as List?)?.cast<String>() ?? [];
    final languagesMap = json['languages'] as Map<String, dynamic>? ?? {};
    final currenciesMap = json['currencies'] as Map<String, dynamic>? ?? {};
    final flagsMap = json['flags'] as Map<String, dynamic>? ?? {};

    return Country(
      name: nameMap['common']?.toString() ?? 'Unknown',
      flagUrl: flagsMap['png']?.toString() ?? '',
      capital: capitals.isNotEmpty ? capitals.first : 'N/A',
      region: json['region']?.toString() ?? 'N/A',
      subregion: json['subregion']?.toString() ?? 'N/A',
      population: (json['population'] as num?)?.toInt() ?? 0,
      languages: languagesMap.values.map((v) => v.toString()).toList(),
      currencies: currenciesMap.values
          .map((v) => (v as Map)['name']?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': {'common': name},
    'flags': {'png': flagUrl},
    'capital': [capital],
    'region': region,
    'subregion': subregion,
    'population': population,
    'languages': {
      for (var i = 0; i < languages.length; i++) 'l$i': languages[i],
    },
    'currencies': {
      for (var i = 0; i < currencies.length; i++)
        'c$i': {'name': currencies[i]},
    },
  };
}
