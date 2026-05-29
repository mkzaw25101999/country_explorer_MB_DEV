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
