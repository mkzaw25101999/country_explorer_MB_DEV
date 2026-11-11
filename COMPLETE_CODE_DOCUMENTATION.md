# Country Explorer - Complete Code Documentation

**App Version:** 1.0.0
**Developers:** Min Zaw, Oliver, May
**Data Source:** REST Countries API (restcountries.com)

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Main Entry Point](#main-entry-point)
3. [Models](#models)
4. [Services](#services)
5. [Providers (State Management)](#providers-state-management)
6. [Screens](#screens)
7. [Widgets](#widgets)
8. [Router](#router)
9. [Utilities](#utilities)

---

## Project Overview

Country Explorer is a Flutter application that allows users to:

- Browse all countries in the world
- Search for countries by name
- View detailed information about each country (capital, region, population, languages, currencies)
- Toggle between light and dark themes
- Access an about page with app information

**Key Technologies:**

- Flutter (UI Framework)
- Riverpod (State Management)
- GoRouter (Navigation)
- HTTP (REST API calls)
- SharedPreferences (Theme persistence)
- CachedNetworkImage (Image caching)

---

## Main Entry Point

### `main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/theme_provider.dart';
import 'router/app_router.dart';

void main() {
  runApp(const ProviderScope(child: CountryExplorerApp()));
}

class CountryExplorerApp extends ConsumerWidget {
  const CountryExplorerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    return MaterialApp.router(
      title: 'Country Explorer',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
      ),
      routerConfig: appRouter,
    );
  }
}
```

**Key Points:**

- Uses `ProviderScope` to enable Riverpod
- Watches `themeProvider` to apply light/dark theme
- Uses Material 3 design
- Indigo color scheme
- Configured with `GoRouter` for navigation

---

## Models

### `models/country.dart`

```dart
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
```

**Responsibilities:**

- Data model for country information
- Parses JSON from REST API into Dart objects
- Handles missing/optional fields with defaults
- Provides serialization to JSON

---

## Services

### `services/country_service.dart`

```dart
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
```

**Responsibilities:**

- Handles HTTP communication with REST Countries API
- Fetches all countries data
- Parses JSON response into `Country` objects
- Sorts countries alphabetically
- Provides error handling and status code checking

**API Endpoint:**

- Base URL: `https://restcountries.com/v3.1/all`
- Fields: name, flags, capital, region, subregion, population, languages, currencies

---

## Providers (State Management)

### `providers/country_provider.dart`

```dart
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
```

**Provider Breakdown:**

| Provider                     | Type             | Purpose                                            |
| ---------------------------- | ---------------- | -------------------------------------------------- |
| `countryServiceProvider`     | `Provider`       | Provides singleton instance of `CountryService`    |
| `countryListProvider`        | `FutureProvider` | Fetches all countries from API (one-time)          |
| `searchQueryProvider`        | `StateProvider`  | Stores current search query text                   |
| `filteredCountriesProvider`  | `Provider`       | Filters countries based on search query            |
| `pageSizeProvider`           | `StateProvider`  | Manages pagination - tracks how many items to show |
| `paginatedCountriesProvider` | `Provider`       | Combines filtered results with pagination          |

### `providers/theme_provider.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light) {
    _load();
  }

  static const _key = 'isDarkMode';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_key) ?? false;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggle() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = newMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, newMode == ThemeMode.dark);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (ref) => ThemeNotifier(),
);
```

**Responsibilities:**

- Manages app theme state (light/dark)
- Persists theme preference to device storage
- Loads saved preference on app start
- Provides toggle functionality

---

## Screens

### `screens/home_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/country_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/validators.dart';
import '../widgets/country_tile.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  String? _searchError;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final currentSize = ref.read(pageSizeProvider);
      final filtered = ref.read(filteredCountriesProvider);
      filtered.whenData((list) {
        if (currentSize < list.length) {
          ref.read(pageSizeProvider.notifier).state = currentSize + 20;
        }
      });
    }
  }

  void _onSearchChanged(String value) {
    final error = validateSearchQuery(value);
    setState(() => _searchError = error);
    if (error == null) {
      ref.read(searchQueryProvider.notifier).state = value;
      ref.read(pageSizeProvider.notifier).state = 20;
    }
  }

  @override
  Widget build(BuildContext context) {
    final paginated = ref.watch(paginatedCountriesProvider);
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Country Explorer'),
        actions: [
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () => ref.read(themeProvider.notifier).toggle(),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo),
              child: Text(
                'Country Explorer',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                context.pushNamed('settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                context.pushNamed('about');
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search countries...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                errorText: _searchError,
              ),
            ),
          ),
          Expanded(
            child: paginated.when(
              loading: () => const LoadingView(message: 'Loading countries...'),
              error: (err, _) => ErrorView(
                message: 'Failed to load: $err',
                onRetry: () => ref.invalidate(countryListProvider),
              ),
              data: (list) {
                if (list.isEmpty) {
                  return const EmptyView(message: 'No countries match');
                }
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: list.length,
                  itemBuilder: (_, i) => CountryTile(
                    country: list[i],
                    onTap: () => context.pushNamed('detail', extra: list[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

**Key Features:**

- Displays list of all countries
- Real-time search with validation
- Infinite scroll pagination (loads 20 more items at a time)
- Theme toggle button
- Navigation drawer
- Error and empty states

**UI Elements:**

- AppBar with title and theme toggle
- Search input field with validation
- Navigation drawer (Home, Settings, About)
- ListView of countries with lazy loading
- Loading, error, and empty view states

### `screens/detail_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/country.dart';

class DetailScreen extends StatelessWidget {
  final Country country;
  const DetailScreen({super.key, required this.country});

  String _formatPopulation(int pop) {
    if (pop >= 1000000000) return '${(pop / 1000000000).toStringAsFixed(1)}B';
    if (pop >= 1000000) return '${(pop / 1000000).toStringAsFixed(1)}M';
    if (pop >= 1000) return '${(pop / 1000).toStringAsFixed(1)}K';
    return pop.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(country.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (country.flagUrl.isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: country.flagUrl,
                    height: 160,
                    width: 240,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 160,
                      width: 240,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 160,
                      width: 240,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.flag_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            _row(Icons.location_city, 'Capital', country.capital),
            _row(Icons.public, 'Region', country.region),
            _row(Icons.map, 'Subregion', country.subregion),
            _row(
              Icons.people,
              'Population',
              _formatPopulation(country.population),
            ),
            _row(
              Icons.language,
              'Languages',
              country.languages.isEmpty ? 'N/A' : country.languages.join(', '),
            ),
            _row(
              Icons.attach_money,
              'Currencies',
              country.currencies.isEmpty
                  ? 'N/A'
                  : country.currencies.join(', '),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

**Key Features:**

- Displays full country details
- Large flag image with caching
- Population formatting (B, M, K suffix)
- Icon-based information layout
- Error handling for missing flag
- Scrollable content for long lists

**Information Displayed:**

- Country flag
- Capital
- Region and subregion
- Population (formatted)
- Languages
- Currencies

### `screens/settings_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            subtitle: Text(isDark ? 'On' : 'Off'),
            value: isDark,
            onChanged: (_) => ref.read(themeProvider.notifier).toggle(),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Settings are saved automatically'),
            subtitle: Text('Your theme choice persists between app restarts'),
          ),
        ],
      ),
    );
  }
}
```

**Features:**

- Dark mode toggle switch
- Auto-saves preferences to device
- Information about persistence
- Simple, clean UI

### `screens/about_screen.dart`

```dart
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Center(child: Icon(Icons.public, size: 80, color: Colors.indigo)),
          SizedBox(height: 16),
          Center(
            child: Text(
              'Country Explorer',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 8),
          Center(child: Text('Version 1.0.0')),
          SizedBox(height: 24),
          ListTile(
            leading: Icon(Icons.description),
            title: Text('Description'),
            subtitle: Text(
              'Browse countries around the world. Search, view flags, '
              'and learn about capitals, populations, languages, and currencies.',
            ),
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Developers'),
            subtitle: Text('Min Zaw\nOliver\nMay'),
          ),
          ListTile(
            leading: Icon(Icons.email),
            title: Text('Contact'),
            subtitle: Text(
              'min.zaw@tuni.fi\noliver.chandler@tuni.fi\nmay.khine@tuni.fi',
            ),
          ),
          ListTile(
            leading: Icon(Icons.cloud),
            title: Text('Data Source'),
            subtitle: Text('REST Countries API (restcountries.com)'),
          ),
        ],
      ),
    );
  }
}
```

**Information Provided:**

- App name and version
- App description
- Developer names
- Contact emails
- Data source attribution

---

## Widgets

### `widgets/country_tile.dart`

```dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/country.dart';

class CountryTile extends StatelessWidget {
  final Country country;
  final VoidCallback onTap;
  const CountryTile({super.key, required this.country, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: SizedBox(
          width: 56,
          height: 40,
          child: country.flagUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: country.flagUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: (_, __, ___) => const Icon(Icons.flag),
                )
              : const Icon(Icons.flag),
        ),
        title: Text(
          country.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${country.region} • ${country.capital}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
```

**Purpose:** Reusable widget for displaying country in a list

**Displays:**

- Country flag image
- Country name (bold)
- Region and capital (subtitle)
- Chevron icon (indicates tappable)

### `widgets/loading_view.dart`

```dart
import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  final String? message;
  const LoadingView({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[const SizedBox(height: 16), Text(message!)],
        ],
      ),
    );
  }
}
```

**Purpose:** Shows loading state with spinner and optional message

### `widgets/error_view.dart`

```dart
import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Purpose:** Shows error state with message and retry button

### `widgets/empty_view.dart`

```dart
import 'package:flutter/material.dart';

class EmptyView extends StatelessWidget {
  final String message;
  const EmptyView({super.key, this.message = 'No results found'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}
```

**Purpose:** Shows empty state when no countries match search

---

## Router

### `router/app_router.dart`

```dart
import 'package:go_router/go_router.dart';
import '../models/country.dart';
import '../screens/home_screen.dart';
import '../screens/detail_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/about_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', name: 'home', builder: (_, __) => const HomeScreen()),
    GoRoute(
      path: '/detail',
      name: 'detail',
      builder: (_, state) => DetailScreen(country: state.extra as Country),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (_, __) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/about',
      name: 'about',
      builder: (_, __) => const AboutScreen(),
    ),
  ],
);
```

**Routes:**

| Route    | Path        | Screen         | Purpose                                       |
| -------- | ----------- | -------------- | --------------------------------------------- |
| home     | `/`         | HomeScreen     | Main list of countries                        |
| detail   | `/detail`   | DetailScreen   | Country details (receives `Country` as extra) |
| settings | `/settings` | SettingsScreen | App settings                                  |
| about    | `/about`    | AboutScreen    | App information                               |

---

## Utilities

### `utils/validators.dart`

```dart
String? validateSearchQuery(String? input) {
  if (input == null || input.trim().isEmpty) {
    return null; // this is for showing all countries when search is cleared
  }
  final trimmed = input.trim();
  if (trimmed.length < 2) {
    return 'Please enter at least 2 characters';
  }
  final validPattern = RegExp(r'^[a-zA-Z\s]+$');
  if (!validPattern.hasMatch(trimmed)) {
    return 'Only letters and spaces are allowed';
  }
  return null;
}
```

**Validation Rules:**

- Minimum 2 characters required
- Only letters and spaces allowed
- Empty input clears search (returns null)
- Returns error message string or null if valid

---

## Architecture Summary

```
country_explorer/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── models/
│   │   └── country.dart             # Country data model
│   ├── services/
│   │   └── country_service.dart     # API service
│   ├── providers/
│   │   ├── country_provider.dart    # State management for countries
│   │   └── theme_provider.dart      # State management for theme
│   ├── screens/
│   │   ├── home_screen.dart         # Main list screen
│   │   ├── detail_screen.dart       # Country details screen
│   │   ├── settings_screen.dart     # Settings screen
│   │   └── about_screen.dart        # About screen
│   ├── widgets/
│   │   ├── country_tile.dart        # Country list item widget
│   │   ├── loading_view.dart        # Loading state widget
│   │   ├── error_view.dart          # Error state widget
│   │   └── empty_view.dart          # Empty state widget
│   ├── router/
│   │   └── app_router.dart          # Navigation routing
│   └── utils/
│       └── validators.dart          # Input validation
```

---

## State Flow Diagram

```
User Input (Search)
    ↓
searchQueryProvider (stores query)
    ↓
validateSearchQuery (validates)
    ↓
filteredCountriesProvider (filters countries)
    ↓
pageSizeProvider (manages pagination)
    ↓
paginatedCountriesProvider (returns paginated results)
    ↓
HomeScreen displays list
    ↓
User taps country
    ↓
Navigation to DetailScreen with Country object
```

---

## Key Features Implementation

### 1. **Real-time Search**

- Validates input (minimum 2 characters, letters only)
- Filters countries based on case-insensitive name matching
- Resets pagination when search changes
- Shows error message for invalid input

### 2. **Infinite Scroll Pagination**

- Loads 20 countries at a time
- Automatically loads more when user scrolls near bottom
- Works with filtered results

### 3. **Theme Persistence**

- Saves theme preference to SharedPreferences
- Loads on app startup
- Can be toggled from HomeScreen or SettingsScreen

### 4. **Error Handling**

- API errors display with retry button
- Missing data handled with defaults
- Network image errors show fallback icon

### 5. **Image Caching**

- CachedNetworkImage caches flags locally
- Improves performance on repeated views
- Shows placeholder while loading

---

## Dependencies Used

- `flutter_riverpod` - State management
- `go_router` - Navigation and routing
- `http` - HTTP requests
- `shared_preferences` - Persistent storage
- `cached_network_image` - Image caching
- `flutter` - UI framework

---

## Future Enhancement Ideas

1. Add favorite countries functionality
2. Implement comparison between countries
3. Add more detailed statistics (GDP, area, etc.)
4. Implement offline mode with cached data
5. Add multiple language support
6. Implement country filtering by region
7. Add share functionality for country details

---

**Documentation Generated:** May 29, 2026
**App Version:** 1.0.0
