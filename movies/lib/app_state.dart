import 'package:flutter/foundation.dart';

import 'data/dto/api_movie_dto.dart';
import 'data/repository/movie_repository.dart';
import 'models/movie.dart';
import 'models/movie_item.dart';

const List<String> defaultCategoryNames = [
  'Просмотренное',
  'Избранное',
  'Понравившиеся',
];

class AppState extends ChangeNotifier {
  AppState({required MovieRepository repository}) : _repository = repository {
    for (final name in defaultCategoryNames) {
      _categoryKeys[name] = [];
    }
  }

  final MovieRepository _repository;

  List<Movie> _localMovies = [];
  List<String> _customCategoryNames = [];
  Map<String, int> _customCategoryIcons = {};
  Map<String, List<String>> _categoryKeys = {};
  Map<int, ApiMovieDto> _apiMovieCache = {};

  List<ApiMovieDto> _apiMovies = [];
  bool _apiLoading = false;
  bool _apiLoadingMore = false;
  String? _apiError;
  int _apiPage = 1;
  int? _apiTotalPages;

  String _searchQuery = '';
  List<ApiMovieDto> _searchResults = [];
  bool _searchLoading = false;
  String? _searchError;

  static const int _maxSearchHistory = 5;
  List<String> _searchHistory = [];

  List<Movie> get localMovies => List.unmodifiable(_localMovies);
  List<String> get searchHistory => List.unmodifiable(_searchHistory);
  List<ApiMovieDto> get apiMovies => List.unmodifiable(_apiMovies);
  bool get apiLoading => _apiLoading;
  bool get apiLoadingMore => _apiLoadingMore;
  String? get apiError => _apiError;
  int get apiPage => _apiPage;
  int? get apiTotalPages => _apiTotalPages;
  bool get apiHasMore =>
      _apiTotalPages != null && _apiPage < _apiTotalPages!;

  String get searchQuery => _searchQuery;
  List<ApiMovieDto> get searchResults => List.unmodifiable(_searchResults);
  bool get searchLoading => _searchLoading;
  String? get searchError => _searchError;

  List<String> get categoryNames => [...defaultCategoryNames, ..._customCategoryNames];

  ApiMovieDto? getCachedApiMovie(int id) => _apiMovieCache[id];

  Future<void> loadFromStorage() async {
    _localMovies = _repository.getLocalMovies();
    _categoryKeys = _repository.getCategoryKeys();
    _customCategoryNames = _repository.getCustomCategories();
    _customCategoryIcons = _repository.getCustomCategoryIcons();
    for (final name in defaultCategoryNames) {
      _categoryKeys.putIfAbsent(name, () => []);
    }
    for (final name in _customCategoryNames) {
      _categoryKeys.putIfAbsent(name, () => []);
    }
    _apiMovieCache = _repository.getApiMovieCache();
    _searchHistory = _repository.getSearchHistory();
    notifyListeners();
  }

  Future<void> removeFromSearchHistory(String query) async {
    _searchHistory.remove(query);
    await _repository.saveSearchHistory(_searchHistory);
    notifyListeners();
  }

  Future<void> clearSearchHistory() async {
    _searchHistory = [];
    notifyListeners();
    try {
      await _repository.saveSearchHistory(_searchHistory);
    } catch (_) {
      notifyListeners();
    }
  }

  Future<void> fetchApiMovies({int page = 1, int limit = 20}) async {
    if (page == 1) {
      _apiLoading = true;
      _apiError = null;
    } else {
      _apiLoadingMore = true;
    }
    notifyListeners();
    try {
      final response = await _repository.getMoviesFromApi(page: page, limit: limit);
      _apiPage = response.page ?? page;
      _apiTotalPages = response.pages;
      if (page == 1) {
        _apiMovies = response.docs;
      } else {
        _apiMovies = [..._apiMovies, ...response.docs];
      }
    } catch (e, st) {
      _apiError = e.toString();
      if (page == 1) _apiMovies = [];
    } finally {
      _apiLoading = false;
      _apiLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreApiMovies() async {
    if (_apiLoadingMore || !apiHasMore || _apiLoading) return;
    await fetchApiMovies(page: _apiPage + 1, limit: 20);
  }

  Future<void> searchMovies(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      clearSearch();
      return;
    }
    _searchQuery = q;
    _searchLoading = true;
    _searchError = null;
    notifyListeners();
    try {
      final response = await _repository.searchMovies(query: q, page: 1, limit: 20);
      _searchResults = response.docs;
      _searchHistory.remove(q);
      _searchHistory.insert(0, q);
      if (_searchHistory.length > _maxSearchHistory) {
        _searchHistory = _searchHistory.take(_maxSearchHistory).toList();
      }
      await _repository.saveSearchHistory(_searchHistory);
    } catch (e) {
      _searchError = e.toString();
      _searchResults = [];
    } finally {
      _searchLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    _searchError = null;
    _searchLoading = false;
    notifyListeners();
  }

  void addCustomCategory(String name, {int iconIndex = 0}) {
    final n = name.trim();
    if (n.isEmpty) return;
    if (_customCategoryNames.contains(n)) return;
    if (defaultCategoryNames.contains(n)) return;
    _customCategoryNames.add(n);
    _customCategoryIcons[n] = iconIndex;
    _categoryKeys.putIfAbsent(n, () => []);
    _repository.saveCustomCategories(_customCategoryNames);
    _repository.saveCustomCategoryIcons(_customCategoryIcons);
    _saveCategoryKeys();
    notifyListeners();
  }

  int getCategoryIconIndex(String name) =>
      _customCategoryIcons[name] ?? 0;

  void removeCustomCategory(String name) {
    if (!_customCategoryNames.contains(name)) return;
    _customCategoryNames.remove(name);
    _customCategoryIcons.remove(name);
    _categoryKeys.remove(name);
    _repository.saveCustomCategories(_customCategoryNames);
    _repository.saveCustomCategoryIcons(_customCategoryIcons);
    _saveCategoryKeys();
    notifyListeners();
  }

  List<Movie> get movies => localMovies;

  void addMovie(Movie movie) {
    _localMovies.insert(0, movie);
    _saveLocalMovies();
    notifyListeners();
  }

  List<MovieItem> getMoviesInCategory(String category) {
    final keys = _categoryKeys[category];
    if (keys == null || keys.isEmpty) return [];
    final result = <MovieItem>[];
    for (final key in keys) {
      final item = _resolveKeyToMovieItem(key);
      if (item != null) result.add(item);
    }
    return result;
  }

  MovieItem? _resolveKeyToMovieItem(String key) {
    if (key.startsWith('local:')) {
      final title = key.substring(6);
      final movie = _findLocalByTitle(title);
      return movie != null ? MovieItem.fromMovie(movie) : null;
    }
    if (key.startsWith('api:')) {
      final id = int.tryParse(key.substring(4));
      if (id == null) return null;
      final dto = _apiMovieCache[id];
      return dto != null ? MovieItem.fromApiMovie(dto) : null;
    }
    return null;
  }

  Movie? _findLocalByTitle(String title) {
    try {
      return _localMovies.firstWhere((m) => m.title == title);
    } catch (_) {
      return null;
    }
  }

  bool isMovieInCategory(String movieKey, String category) {
    return _categoryKeys[category]?.contains(movieKey) ?? false;
  }

  void addToCategory(String category, String movieKey, {ApiMovieDto? apiMovie}) {
    final list = _categoryKeys[category];
    if (list == null || list.contains(movieKey)) return;
    list.add(movieKey);
    if (apiMovie != null && movieKey.startsWith('api:')) {
      _apiMovieCache[apiMovie.id] = apiMovie;
      _repository.saveApiMovieCache(_apiMovieCache);
    }
    _saveCategoryKeys();
    notifyListeners();
  }

  void removeFromCategory(String category, String movieKey) {
    _categoryKeys[category]?.remove(movieKey);
    _saveCategoryKeys();
    notifyListeners();
  }

  void toggleCategory(String category, String movieKey, {ApiMovieDto? apiMovie}) {
    final list = _categoryKeys[category];
    if (list == null) return;
    if (list.contains(movieKey)) {
      list.remove(movieKey);
    } else {
      list.add(movieKey);
      if (apiMovie != null && movieKey.startsWith('api:')) {
        _apiMovieCache[apiMovie.id] = apiMovie;
        _repository.saveApiMovieCache(_apiMovieCache);
      }
    }
    _saveCategoryKeys();
    notifyListeners();
  }

  Future<void> _saveLocalMovies() async {
    await _repository.saveLocalMovies(_localMovies);
  }

  Future<void> _saveCategoryKeys() async {
    await _repository.saveCategoryKeys(_categoryKeys);
  }
}
