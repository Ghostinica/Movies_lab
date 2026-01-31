import 'package:flutter/material.dart';

/// Главный экран — список фильмов.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Фильмы'),
        actions: [
          IconButton(
            onPressed: null,
            icon: const Icon(Icons.bookmark_outlined),
            tooltip: 'Мои категории',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: const [
          _MovieListTile(
            title: 'Интерстеллар',
            year: '2014',
            genre: 'Фантастика, Драма',
          ),
          _MovieListTile(
            title: 'Начало',
            year: '2010',
            genre: 'Фантастика, Триллер',
          ),
          _MovieListTile(
            title: 'Побег из Шоушенка',
            year: '1994',
            genre: 'Драма',
          ),
          _MovieListTile(
            title: 'Крёстный отец',
            year: '1972',
            genre: 'Криминал, Драма',
          ),
          _MovieListTile(
            title: 'Тёмный рыцарь',
            year: '2008',
            genre: 'Боевик, Криминал',
          ),
        ],
      ),
    );
  }
}

class _MovieListTile extends StatelessWidget {
  const _MovieListTile({
    required this.title,
    required this.year,
    required this.genre,
  });

  final String title;
  final String year;
  final String genre;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          Icons.movie_outlined,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(title),
      subtitle: Text('$year · $genre'),
      trailing: const Icon(Icons.chevron_right),
      onTap: null,
    );
  }
}
