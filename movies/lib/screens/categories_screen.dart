import 'package:flutter/material.dart';

import '../app_state.dart';
import '../app_state_scope.dart';
import '../models/movie.dart';
import 'movie_detail_screen.dart';

/// Экран «Мои категории» — Просмотренное, Избранное, Понравившиеся.
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  static IconData _iconForCategory(String name) {
    switch (name) {
      case 'Просмотренное':
        return Icons.visibility_outlined;
      case 'Избранное':
        return Icons.bookmark_outline;
      case 'Понравившиеся':
        return Icons.favorite_border;
      default:
        return Icons.folder_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои категории'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Text(
                'Фильмы',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.movie_outlined),
              title: const Text('Каталог фильмов'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_outlined),
              title: const Text('Мои категории'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        children: [
          for (final categoryName in categoryNames) ...[
            _CategorySection(
              title: categoryName,
              icon: _iconForCategory(categoryName),
              movies: appState.getMoviesInCategory(categoryName),
              onMovieTap: (movie) {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => MovieDetailScreen(movie: movie),
                  ),
                );
              },
              onRemove: (movie) {
                appState.removeFromCategory(categoryName, movie.title);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('«${movie.title}» удалён из $categoryName'),
                    action: SnackBarAction(
                      label: 'Отмена',
                      onPressed: () {
                        appState.addToCategory(categoryName, movie.title);
                      },
                    ),
                  ),
                );
              },
            ),
          ],
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
    required this.onMovieTap,
    required this.onRemove,
  });

  final String title;
  final IconData icon;
  final List<Movie> movies;
  final ValueChanged<Movie> onMovieTap;
  final ValueChanged<Movie> onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(
          movies.isEmpty
              ? 'Пусто — добавьте фильмы с экрана фильма'
              : '${movies.length} ${_plural(movies.length)}',
        ),
        children: [
          if (movies.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Нажмите на фильм в каталоге и добавьте его в категорию.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            )
          else
            ...movies.map(
              (movie) => ListTile(
                dense: true,
                leading: const Icon(Icons.movie_outlined, size: 20),
                title: Text(movie.title),
                subtitle: Text('${movie.year} · ${movie.genre}'),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  tooltip: 'Удалить из категории',
                  onPressed: () => onRemove(movie),
                ),
                onTap: () => onMovieTap(movie),
              ),
            ),
        ],
      ),
    );
  }

  String _plural(int n) {
    if (n % 10 == 1 && n % 100 != 11) return 'фильм';
    if (n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20)) {
      return 'фильма';
    }
    return 'фильмов';
  }
}
