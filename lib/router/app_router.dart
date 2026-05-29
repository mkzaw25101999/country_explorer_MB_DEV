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
