import 'dart:async';

import 'package:flutter/material.dart';

import '../app_state_scope.dart';
import '../data/dto/api_movie_dto.dart';
import '../models/movie.dart';
import '../models/movie_item.dart';
import 'categories_screen.dart';
import 'movie_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showRecentQueries = false;
  Timer? _hideRecentQueriesTimer;

  void _onSearchFocusChange() {
    if (_searchFocusNode.hasFocus) {
      _hideRecentQueriesTimer?.cancel();
      _hideRecentQueriesTimer = null;
      setState(() => _showRecentQueries = true);
    } else {
      _hideRecentQueriesTimer?.cancel();
      _hideRecentQueriesTimer = Timer(const Duration(milliseconds: 150), () {
        if (!mounted) return;
        setState(() => _showRecentQueries = false);
        _hideRecentQueriesTimer = null;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onCatalogScroll);
    _searchFocusNode.addListener(_onSearchFocusChange);
  }

  @override
  void dispose() {
    _hideRecentQueriesTimer?.cancel();
    _scrollController.removeListener(_onCatalogScroll);
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onCatalogScroll() {
    if (!mounted) return;
    final appState = AppStateScope.of(context);
    if (!appState.apiHasMore || appState.apiLoadingMore) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) {
      appState.loadMoreApiMovies();
    }
  }

  void _openCategories(BuildContext context) {
    Navigator.pop(context);
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const CategoriesScreen(),
      ),
    ).then((_) {
      if (!mounted) return;
      final appState = AppStateScope.of(context);
      _searchController.clear();
      appState.clearSearch();
    });
  }

  void _openMovieDetail(
    BuildContext context,
    MovieItem item, {
    ApiMovieDto? apiMovie,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => MovieDetailScreen(
          movieItem: item,
          apiMovie: apiMovie,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Фильмы'),
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
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          final isSearching = appState.searchQuery.isNotEmpty;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: SearchBar(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  hintText: 'Поиск по названию фильма',
                  leading: const Icon(Icons.search),
                  trailing: isSearching
                      ? [
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _searchController.clear();
                              appState.clearSearch();
                            },
                            tooltip: 'Очистить поиск',
                          ),
                        ]
                      : null,
                  onSubmitted: (value) => appState.searchMovies(value),
                ),
              ),
              if (isSearching)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Chip(
                        label: Text('«${appState.searchQuery}»'),
                        onDeleted: () {
                          _searchController.clear();
                          appState.clearSearch();
                        },
                      ),
                    ],
                  ),
                ),
              if (!isSearching &&
                  (_searchFocusNode.hasFocus || _showRecentQueries) &&
                  appState.searchHistory.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Недавние запросы',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          TextButton(
                            onPressed: () {
                              appState.clearSearchHistory();
                              setState(() => _showRecentQueries = false);
                            },
                            style: TextButton.styleFrom(
                              minimumSize: const Size(72, 48),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Очистить'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          for (final query in appState.searchHistory.take(5))
                            () {
                              final q = query;
                              return InputChip(
                                label: Text(q),
                                onPressed: () {
                                  setState(() => _showRecentQueries = false);
                                  _searchController.text = q;
                                  appState.searchMovies(q);
                                  _searchFocusNode.unfocus();
                                },
                                deleteIcon: const Icon(Icons.close, size: 18),
                                onDeleted: () => appState.removeFromSearchHistory(q),
                              );
                            }(),
                        ],
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: isSearching
                    ? _buildSearchBody(context, appState)
                    : _buildCatalogBody(context, appState, _scrollController),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBody(BuildContext context, dynamic appState) {
    final searchLoading = appState.searchLoading;
    final searchResults = appState.searchResults;
    final searchError = appState.searchError;

    if (searchLoading && searchResults.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (searchError != null && searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ошибка поиска',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(searchError, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
    if (searchResults.isEmpty) {
      return Center(
        child: Text(
          'Введите запрос и нажмите поиск',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: searchResults.length + (searchError != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (searchError != null && index == searchResults.length) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Ошибка: $searchError',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }
        final dto = searchResults[index];
        final item = MovieItem.fromApiMovie(dto);
        return _MovieListTile(
          item: item,
          onTap: () => _openMovieDetail(context, item, apiMovie: dto),
        );
      },
    );
  }

  Widget _buildCatalogBody(
      BuildContext context, dynamic appState, ScrollController scrollController) {
    final localMovies = appState.localMovies;
    final apiMovies = appState.apiMovies;
    final apiLoading = appState.apiLoading;
    final apiError = appState.apiError;
    final apiLoadingMore = appState.apiLoadingMore;
    final apiHasMore = appState.apiHasMore;

    return RefreshIndicator(
      onRefresh: () => appState.fetchApiMovies(),
      child: _buildCatalogList(
        context: context,
        scrollController: scrollController,
        localMovies: localMovies,
        apiMovies: apiMovies,
        apiLoading: apiLoading,
        apiError: apiError,
        apiLoadingMore: apiLoadingMore,
        apiHasMore: apiHasMore,
        onLocalTap: (movie) => _openMovieDetail(
          context,
          MovieItem.fromMovie(movie),
          apiMovie: null,
        ),
        onApiTap: (dto) => _openMovieDetail(
          context,
          MovieItem.fromApiMovie(dto),
          apiMovie: dto,
        ),
      ),
    );
  }

  Widget _buildCatalogList({
    required BuildContext context,
    required ScrollController scrollController,
    required List<Movie> localMovies,
    required List<ApiMovieDto> apiMovies,
    required bool apiLoading,
    required String? apiError,
    required bool apiLoadingMore,
    required bool apiHasMore,
    required ValueChanged<Movie> onLocalTap,
    required ValueChanged<ApiMovieDto> onApiTap,
  }) {
    if (apiLoading && apiMovies.isEmpty && localMovies.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final localItems = localMovies.map(MovieItem.fromMovie).toList();
    final apiItems = apiMovies.map(MovieItem.fromApiMovie).toList();
    final totalCount = localItems.length + apiItems.length;
    final hasErrorRow = apiError != null;
    final hasMoreFooter = apiLoadingMore || (apiHasMore && totalCount > 0);
    final itemCount = totalCount +
        (hasErrorRow ? 1 : 0) +
        (hasMoreFooter ? 1 : 0);

    if (totalCount == 0 && apiError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ошибка загрузки',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(apiError, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index < totalCount) {
          if (index < localItems.length) {
            final item = localItems[index];
            return _MovieListTile(
              item: item,
              onTap: () => onLocalTap(localMovies[index]),
            );
          }
          final apiIndex = index - localItems.length;
          final dto = apiMovies[apiIndex];
          final item = apiItems[apiIndex];
          return _MovieListTile(
            item: item,
            onTap: () => onApiTap(dto),
          );
        }
        if (index == totalCount && hasErrorRow) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Ошибка API: $apiError',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }
        if (index == totalCount + (hasErrorRow ? 1 : 0) && hasMoreFooter) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: apiLoadingMore
                  ? const SizedBox(
                      height: 32,
                      width: 32,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const SizedBox.shrink(),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _MovieListTile extends StatelessWidget {
  const _MovieListTile({
    required this.item,
    required this.onTap,
  });

  final MovieItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: item.posterUrl != null && item.posterUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.posterUrl!,
                width: 48,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholderIcon(context),
              ),
            )
          : _placeholderIcon(context),
      title: Text(
        item.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: _buildSubtitle(item),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSubtitle(MovieItem item) {
    final parts = <String>['${item.year} · ${item.genre}'];
    if (item.country != null && item.country!.isNotEmpty) parts.add(item.country!);
    if (item.ratingKp != null && item.ratingKp! > 0) parts.add('КП ${item.ratingKp!.toStringAsFixed(1)}');
    if (item.ratingImdb != null && item.ratingImdb! > 0) parts.add('IMDB ${item.ratingImdb!.toStringAsFixed(1)}');
    if (item.movieLengthMinutes != null && item.movieLengthMinutes! > 0) parts.add('${item.movieLengthMinutes} мин');
    return Text(
      parts.join(' · '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _placeholderIcon(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Icon(
        Icons.movie_outlined,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }
}

