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
