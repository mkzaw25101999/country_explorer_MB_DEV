# country_explorer

A Flutter mobile app to browse countries around the world. Search, view flags, and explore details like capitals, populations, languages, and currencies.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Setup & Run

**Requirements**
- Flutter 3.41.6
- Dart 3.11.4

**Steps**
```bash
git clone
cd country_explorer
flutter pub get
flutter run
```

**Run tests**
```bash
flutter test
```

## Main Packages

| Package | Purpose |
|---|---|
| `flutter_riverpod` | State management for theme, search, and country list |
| `cached_network_image` | Efficiently loads and caches country flag images from URLs |
| `shared_preferences` | Persists dark/light theme choice between app restarts |
| `http` | Fetches country data from the REST Countries API |
| `go_router` / `app_router` | Named route navigation between screens |

## Data Source

[REST Countries API](https://restcountries.com) — free public API providing data on all countries worldwide.

## Developers
- Min Zaw — min.123@tuni.fi
- Oliver Chandler — oliver.chandler@tuni.fi
- May Khine — may.khine@tuni.fi