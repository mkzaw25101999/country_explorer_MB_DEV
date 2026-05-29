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
