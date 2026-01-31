import 'package:flutter/foundation.dart';

import 'data/movies_data.dart';
import 'models/movie.dart';

const List<String> categoryNames = [
  'Просмотренное',
  'Избранное',
  'Понравившиеся',
];

class AppState extends ChangeNotifier {
  AppState() {
    _movies = List.from(initialMovies);
    for (final name in categoryNames) {
      _categoryTitles[name] = [];
    }
  }

  List<Movie> _movies = [];
  final Map<String, List<String>> _categoryTitles = {};

  List<Movie> get movies => List.unmodifiable(_movies);

  void addMovie(Movie movie) {
    _movies.insert(0, movie);
    notifyListeners();
  }

  List<Movie> getMoviesInCategory(String category) {
    final titles = _categoryTitles[category];
    if (titles == null || titles.isEmpty) return [];
    final result = <Movie>[];
    for (final title in titles) {
      final movie = _findMovieByTitle(title);
      if (movie != null) result.add(movie);
    }
    return result;
  }

  Movie? _findMovieByTitle(String title) {
    try {
      return _movies.firstWhere((m) => m.title == title);
    } catch (_) {
      return null;
    }
  }

  bool isMovieInCategory(String movieTitle, String category) {
    return _categoryTitles[category]?.contains(movieTitle) ?? false;
  }

  void addToCategory(String category, String movieTitle) {
    final list = _categoryTitles[category];
    if (list == null || list.contains(movieTitle)) return;
    list.add(movieTitle);
    notifyListeners();
  }

  void removeFromCategory(String category, String movieTitle) {
    _categoryTitles[category]?.remove(movieTitle);
    notifyListeners();
  }

  void toggleCategory(String category, String movieTitle) {
    final list = _categoryTitles[category];
    if (list == null) return;
    if (list.contains(movieTitle)) {
      list.remove(movieTitle);
    } else {
      list.add(movieTitle);
    }
    notifyListeners();
  }
}
