import 'package:flutter/material.dart';

/// Экран «Мои категории» — Просмотренное, Избранное, Понравившиеся.
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои категории'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        children: const [
          _CategorySection(
            title: 'Просмотренное',
            icon: Icons.visibility_outlined,
            movies: ['Интерстеллар', 'Начало', 'Побег из Шоушенка'],
          ),
          _CategorySection(
            title: 'Избранное',
            icon: Icons.bookmark_outline,
            movies: ['Крёстный отец', 'Тёмный рыцарь'],
          ),
          _CategorySection(
            title: 'Понравившиеся',
            icon: Icons.favorite_border,
            movies: ['Интерстеллар', 'Начало', 'Крёстный отец'],
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.title,
    required this.icon,
    required this.movies,
  });

  final String title;
  final IconData icon;
  final List<String> movies;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        children: [
          ...movies.map(
            (name) => ListTile(
              dense: true,
              leading: const Icon(Icons.movie_outlined, size: 20),
              title: Text(name),
              onTap: null,
            ),
          ),
        ],
      ),
    );
  }
}
