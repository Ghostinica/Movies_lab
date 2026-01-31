import 'package:flutter/material.dart';

/// Экран детальной информации о фильме и категориях.
class MovieDetailScreen extends StatelessWidget {
  const MovieDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Интерстеллар'),
        actions: [
          IconButton(
            onPressed: null,
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Поделиться',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Заглушка постер
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
                    'Интерстеллар',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '2014 · Фантастика, Драма',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Описание фильма. Сюжет о путешествии группы исследователей через червоточину в космосе в поисках нового дома для человечества.',
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
                      FilterChip(
                        label: const Text('Просмотренное'),
                        onSelected: null,
                        avatar: const Icon(Icons.visibility_outlined, size: 18),
                      ),
                      FilterChip(
                        label: const Text('Избранное'),
                        onSelected: null,
                        avatar: const Icon(Icons.bookmark_outline, size: 18),
                      ),
                      FilterChip(
                        label: const Text('Понравившиеся'),
                        onSelected: null,
                        avatar: const Icon(Icons.favorite_border, size: 18),
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
}
