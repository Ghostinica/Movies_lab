import 'package:flutter/material.dart';

import '../app_state_scope.dart';
import '../models/movie.dart';
import 'categories_screen.dart';
import 'movie_detail_screen.dart';

/// Главный экран — список фильмов.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openCategories(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const CategoriesScreen(),
      ),
    );
  }

  void _openMovieDetail(BuildContext context, Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => MovieDetailScreen(movie: movie),
      ),
    );
  }

  void _showAddMovieDialog(BuildContext context) {
    final appState = AppStateScope.of(context);
    final titleController = TextEditingController();
    final yearController = TextEditingController();
    final genreController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Добавить фильм'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Название',
                  hintText: 'Введите название фильма',
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: yearController,
                decoration: const InputDecoration(
                  labelText: 'Год',
                  hintText: 'Например, 2020',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: genreController,
                decoration: const InputDecoration(
                  labelText: 'Жанр',
                  hintText: 'Драма, Комедия',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Описание (необязательно)',
                  hintText: 'Краткое описание сюжета',
                ),
                maxLines: 3,
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
              final title = titleController.text.trim();
              final year = yearController.text.trim();
              final genre = genreController.text.trim();
              if (title.isEmpty || year.isEmpty || genre.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Заполните название, год и жанр'),
                  ),
                );
                return;
              }
              appState.addMovie(
                Movie(
                  title: title,
                  year: year,
                  genre: genre,
                  description: descriptionController.text.trim(),
                ),
              );
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Фильм «$title» добавлен')),
              );
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final movies = appState.movies;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Фильмы'),
        actions: [
          IconButton(
            onPressed: () => _openCategories(context),
            icon: const Icon(Icons.bookmark_outlined),
            tooltip: 'Мои категории',
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
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_outlined),
              title: const Text('Мои категории'),
              onTap: () => _openCategories(context),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return _MovieListTile(
            movie: movie,
            onTap: () => _openMovieDetail(context, movie),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMovieDialog(context),
        tooltip: 'Добавить фильм',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _MovieListTile extends StatelessWidget {
  const _MovieListTile({
    required this.movie,
    required this.onTap,
  });

  final Movie movie;
  final VoidCallback onTap;

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
      title: Text(movie.title),
      subtitle: Text('${movie.year} · ${movie.genre}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
