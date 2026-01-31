import 'dart:async';

import 'package:flutter/material.dart';

import '../app_state_scope.dart';
import '../data/dto/api_movie_dto.dart';
import '../models/movie_item.dart';
import '../utils/category_icons.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({
    super.key,
    required this.movieItem,
    this.apiMovie,
  });

  final MovieItem movieItem;
  final ApiMovieDto? apiMovie;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  static const int _maxSnackMessages = 3;
  static const Duration _snackShowDelay = Duration(milliseconds: 80);
  static const Duration _snackDuration = Duration(seconds: 2);

  final List<String> _pendingSnackMessages = [];
  Timer? _snackTimer;

  @override
  void dispose() {
    _snackTimer?.cancel();
    super.dispose();
  }

  void _showCategorySnack(BuildContext context, String message) {
    _pendingSnackMessages.add(message);
    if (_pendingSnackMessages.length > _maxSnackMessages) {
      _pendingSnackMessages.removeAt(0);
    }
    _snackTimer?.cancel();
    _snackTimer = Timer(_snackShowDelay, () {
      _snackTimer = null;
      if (!context.mounted) return;
      final messages = List<String>.from(_pendingSnackMessages);
      _pendingSnackMessages.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: messages.length == 1
              ? Text(messages.single)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: messages
                      .expand((m) => [Text(m), const SizedBox(height: 4)])
                      .toList()
                    ..removeLast(),
                ),
          duration: _snackDuration,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final movieItem = widget.movieItem;
    final apiMovie = widget.apiMovie;

    return Scaffold(
      appBar: AppBar(
        title: Text(movieItem.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPoster(context),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.movieItem.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.movieItem.year} · ${widget.movieItem.genre}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  if (widget.movieItem.country != null && widget.movieItem.country!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.public, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          widget.movieItem.country!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ],
                  if (widget.movieItem.ratingKp != null || widget.movieItem.ratingImdb != null) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 16,
                      runSpacing: 4,
                      children: [
                        if (widget.movieItem.ratingKp != null && widget.movieItem.ratingKp! > 0)
                          _RatingChip(
                            label: 'КП',
                            value: widget.movieItem.ratingKp!,
                          ),
                        if (widget.movieItem.ratingImdb != null && widget.movieItem.ratingImdb! > 0)
                          _RatingChip(
                            label: 'IMDB',
                            value: widget.movieItem.ratingImdb!,
                          ),
                      ],
                    ),
                  ],
                  if (widget.movieItem.movieLengthMinutes != null && widget.movieItem.movieLengthMinutes! > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Продолжительность: ${widget.movieItem.movieLengthMinutes} мин',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    widget.movieItem.description.isEmpty
                        ? 'Описание отсутствует.'
                        : widget.movieItem.description,
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
                      for (final category in appState.categoryNames)
                        _CategoryChip(
                          category: category,
                          movieKey: widget.movieItem.key,
                          apiMovie: apiMovie,
                          onToggle: () {
                            appState.toggleCategory(
                              category,
                              widget.movieItem.key,
                              apiMovie: apiMovie,
                            );
                            final inCategory =
                                appState.isMovieInCategory(widget.movieItem.key, category);
                            _showCategorySnack(
                              context,
                              inCategory
                                  ? '«${movieItem.title}» добавлен в $category'
                                  : '«${movieItem.title}» удалён из $category',
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

  Widget _buildPoster(BuildContext context) {
    final url = widget.movieItem.posterUrl;
    if (url != null && url.isNotEmpty) {
      return SizedBox(
        height: 220,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (_, __, ___) => _posterPlaceholder(context),
        ),
      );
    }
    return _posterPlaceholder(context);
  }

  Widget _posterPlaceholder(BuildContext context) {
    return Container(
      height: 220,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.movie_outlined,
          size: 80,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

}

class _RatingChip extends StatelessWidget {
  const _RatingChip({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label ',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          Text(
            value.toStringAsFixed(1),
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.movieKey,
    required this.apiMovie,
    required this.onToggle,
  });

  final String category;
  final String movieKey;
  final ApiMovieDto? apiMovie;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final selected = appState.isMovieInCategory(movieKey, category);
    final iconData = getCategoryIcon(category, appState.getCategoryIconIndex);

    return FilterChip(
      label: Text(category),
      selected: selected,
      onSelected: (_) => onToggle(),
      avatar: Icon(
        iconData,
        size: 18,
        color: selected
            ? Theme.of(context).colorScheme.onSecondaryContainer
            : null,
      ),
    );
  }
}
