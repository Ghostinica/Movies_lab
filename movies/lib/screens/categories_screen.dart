import 'package:flutter/material.dart';
import 'package:my_app/data/dto/api_movie_dto.dart';

import '../app_state.dart';
import '../app_state_scope.dart';

import '../models/movie_item.dart';
import '../utils/category_icons.dart';
import 'movie_detail_screen.dart';

bool _isCustomCategory(String name) =>
    !defaultCategoryNames.contains(name);

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  void _showAddCategoryDialog(BuildContext context, AppState appState) {
    final controller = TextEditingController();
    int selectedIconIndex = 0;
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Новая категория'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        labelText: 'Название категории',
                        hintText: 'Например: Комедии',
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      autofocus: true,
                      onSubmitted: (value) {
                        final n = value.trim();
                        if (n.isNotEmpty) {
                          appState.addCustomCategory(n, iconIndex: selectedIconIndex);
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Категория «$n» создана')),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Выберите иконку',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(categoryIconChoices.length, (i) {
                        final selected = i == selectedIconIndex;
                        return IconButton(
                          onPressed: () => setState(() => selectedIconIndex = i),
                          icon: Icon(
                            categoryIconChoices[i],
                            color: selected
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: selected
                                ? Theme.of(context).colorScheme.primaryContainer
                                : null,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Отмена'),
                ),
                FilledButton(
                  onPressed: () {
                    final n = controller.text.trim();
                    if (n.isEmpty) return;
                    appState.addCustomCategory(n, iconIndex: selectedIconIndex);
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Категория «$n» создана')),
                    );
                  },
                  child: const Text('Создать'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteCategoryDialog(
    BuildContext context,
    AppState appState,
    String categoryName,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить категорию?'),
        content: Text(
          'Категория «$categoryName» и все фильмы в ней будут удалены. Это действие нельзя отменить.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              appState.removeCustomCategory(categoryName);
              Navigator.pop(dialogContext);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Категория «$categoryName» удалена')),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  static IconData _iconForCategory(String name, AppState appState) {
    switch (name) {
      case 'Просмотренное':
        return Icons.visibility_outlined;
      case 'Избранное':
        return Icons.bookmark_outline;
      case 'Понравившиеся':
        return Icons.favorite_border;
      default:
        final idx = appState.getCategoryIconIndex(name);
        return categoryIconChoices[idx % categoryIconChoices.length];
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои категории'),
        actions: [
          IconButton(
            onPressed: () => _showAddCategoryDialog(context, appState),
            icon: const Icon(Icons.add),
            tooltip: 'Создать категорию',
          ),
        ],
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
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            children: [
              for (final categoryName in appState.categoryNames) ...[
                _CategorySection(
                  title: categoryName,
                  icon: _iconForCategory(categoryName, appState),
                  movies: appState.getMoviesInCategory(categoryName),
                  isCustom: _isCustomCategory(categoryName),
                  onDelete: _isCustomCategory(categoryName)
                      ? () => _showDeleteCategoryDialog(
                            context,
                            appState,
                            categoryName,
                          )
                      : null,
                  onMovieTap: (item) {
                    ApiMovieDto? apiMovie;
                    if (item.key.startsWith('api:')) {
                      final id = int.tryParse(item.key.substring(4));
                      if (id != null) apiMovie = appState.getCachedApiMovie(id);
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => MovieDetailScreen(
                          movieItem: item,
                          apiMovie: apiMovie,
                        ),
                      ),
                    );
                  },
                  onRemove: (item) {
                    appState.removeFromCategory(categoryName, item.key);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('«${item.title}» удалён из $categoryName'),
                        action: SnackBarAction(
                          label: 'Отмена',
                          onPressed: () {
                            appState.addToCategory(categoryName, item.key);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.title,
    required this.icon,
    required this.movies,
    required this.isCustom,
    this.onDelete,
    required this.onMovieTap,
    required this.onRemove,
  });

  final String title;
  final IconData icon;
  final List<MovieItem> movies;
  final bool isCustom;
  final VoidCallback? onDelete;
  final ValueChanged<MovieItem> onMovieTap;
  final ValueChanged<MovieItem> onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Row(
          children: [
            Expanded(child: Text(title)),
            if (isCustom && onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Удалить категорию',
                onPressed: onDelete,
                style: IconButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
          ],
        ),
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
              (item) => ListTile(
                dense: true,
                leading: item.posterUrl != null && item.posterUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          item.posterUrl!,
                          width: 32,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.movie_outlined,
                            size: 20,
                          ),
                        ),
                      )
                    : const Icon(Icons.movie_outlined, size: 20),
                title: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${item.year} · ${item.genre}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  tooltip: 'Удалить из категории',
                  onPressed: () => onRemove(item),
                ),
                onTap: () => onMovieTap(item),
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
