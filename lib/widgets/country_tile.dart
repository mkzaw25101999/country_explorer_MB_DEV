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
