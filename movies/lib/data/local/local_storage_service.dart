import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/movie.dart';
import '../dto/api_movie_dto.dart';

abstract final class StorageKeys {
  static const String localMovies = 'local_movies';
  static const String categoryKeys = 'category_keys';
  static const String apiMovieCache = 'api_movie_cache';
  static const String customCategories = 'custom_categories';
  static const String customCategoryIcons = 'custom_category_icons';
  static const String searchHistory = 'search_history';
}

class LocalStorageService {
  LocalStorageService(this._prefs);

  final SharedPreferences _prefs;

  List<Movie> loadLocalMovies() {
    final json = _prefs.getString(StorageKeys.localMovies);
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list
          .map((e) => Movie.fromJson(e as Map<String, dynamic>))
          .where((m) => m != null)
          .cast<Movie>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveLocalMovies(List<Movie> movies) async {
    final list = movies.map((m) => m.toJson()).toList();
    await _prefs.setString(StorageKeys.localMovies, jsonEncode(list));
  }

  Map<String, List<String>> loadCategoryKeys() {
    final json = _prefs.getString(StorageKeys.categoryKeys);
    if (json == null) return {};
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return map.map((k, v) {
        final list = (v as List<dynamic>).map((e) => e as String).toList();
        return MapEntry(k, list);
      });
    } catch (_) {
      return {};
    }
  }

  Future<void> saveCategoryKeys(Map<String, List<String>> map) async {
    await _prefs.setString(StorageKeys.categoryKeys, jsonEncode(map));
  }

  Map<int, ApiMovieDto> loadApiMovieCache() {
    final json = _prefs.getString(StorageKeys.apiMovieCache);
    if (json == null) return {};
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      final result = <int, ApiMovieDto>{};
      for (final entry in map.entries) {
        final id = int.tryParse(entry.key.toString());
        if (id == null) continue;
        final dto = ApiMovieDto.fromJson(entry.value as Map<String, dynamic>);
        result[id] = dto;
      }
      return result;
    } catch (_) {
      return {};
    }
  }

  Future<void> saveApiMovieCache(Map<int, ApiMovieDto> cache) async {
    final map = cache.map((k, v) => MapEntry(k.toString(), v.toJson()));
    await _prefs.setString(StorageKeys.apiMovieCache, jsonEncode(map));
  }

  List<String> loadCustomCategories() {
    final json = _prefs.getString(StorageKeys.customCategories);
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list.map((e) => e as String).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCustomCategories(List<String> names) async {
    await _prefs.setString(StorageKeys.customCategories, jsonEncode(names));
  }

  Map<String, int> loadCustomCategoryIcons() {
    final json = _prefs.getString(StorageKeys.customCategoryIcons);
    if (json == null) return {};
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, v as int));
    } catch (_) {
      return {};
    }
  }

  Future<void> saveCustomCategoryIcons(Map<String, int> map) async {
    await _prefs.setString(StorageKeys.customCategoryIcons, jsonEncode(map));
  }

  List<String> loadSearchHistory() {
    final json = _prefs.getString(StorageKeys.searchHistory);
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list.map((e) => e as String).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSearchHistory(List<String> list) async {
    await _prefs.setString(StorageKeys.searchHistory, jsonEncode(list));
  }
}
