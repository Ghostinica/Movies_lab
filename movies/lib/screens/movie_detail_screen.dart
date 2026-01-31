import 'package:flutter/material.dart';

import '../app_state.dart';
import '../app_state_scope.dart';
import '../models/movie.dart';

/// Экран детальной информации о фильме и категориях.
class MovieDetailScreen extends StatelessWidget {
  const MovieDetailScreen({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
        actions: [
          IconButton(
            onPressed: () => _share(context),
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Поделиться',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 220,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Center(
                child: Icon(
                  Icons.movie_outlined,
                  size: 80,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${movie.year} · ${movie.genre}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    movie.description.isEmpty
                        ? 'Описание отсутствует.'
                        : movie.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Добавить в категорию',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final category in categoryNames)
                        _CategoryChip(
                          category: category,
                          movieTitle: movie.title,
                          onToggle: () {
                            appState.toggleCategory(category, movie.title);
                            final inCategory =
                                appState.isMovieInCategory(movie.title, category);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  inCategory
                                      ? '«${movie.title}» добавлен в $category'
                                      : '«${movie.title}» удалён из $category',
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _share(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Поделиться: ${movie.title}'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.movieTitle,
    required this.onToggle,
  });

  final String category;
  final String movieTitle;
  final VoidCallback onToggle;

  static IconData _iconFor(String name) {
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
    final selected =
        appState.isMovieInCategory(movieTitle, category);

    return FilterChip(
      label: Text(category),
      selected: selected,
      onSelected: (_) => onToggle(),
      avatar: Icon(
        _iconFor(category),
        size: 18,
        color: selected
            ? Theme.of(context).colorScheme.onSecondaryContainer
            : null,
      ),
    );
  }
}
