import 'dart:convert';

import 'package:http/http.dart' as http;

import '../dto/api_movie_dto.dart';

class MovieApiService {
  MovieApiService({
    this.baseUrl = 'https://api.poiskkino.dev',
    this.apiVersion = 'v1.4',
    required this.apiKey,
  });

  final String baseUrl;
  final String apiVersion;
  final String apiKey;

  String get _moviePath => '$baseUrl/$apiVersion/movie';
  String get _searchPath => '$baseUrl/$apiVersion/movie/search';

  Future<ApiMovieListResponse> searchMovies({
    required String query,
    int page = 1,
    int limit = 10,
  }) async {
    if (query.trim().isEmpty) {
      return ApiMovieListResponse(docs: []);
    }
    final uri = Uri.parse(_searchPath).replace(
      queryParameters: <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        'query': query.trim(),
      },
    );
    final response = await http.get(
      uri,
      headers: {'X-API-KEY': apiKey},
    );
    if (response.statusCode != 200) {
      throw MovieApiException(
        statusCode: response.statusCode,
        body: response.body,
      );
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return ApiMovieListResponse.fromJson(json);
  }

  Future<ApiMovieListResponse> getMovies({
    int page = 1,
    int limit = 20,
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse(_moviePath).replace(
      queryParameters: <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        ...?queryParams,
      },
    );
    final response = await http.get(
      uri,
      headers: {'X-API-KEY': apiKey},
    );
    if (response.statusCode != 200) {
      throw MovieApiException(
        statusCode: response.statusCode,
        body: response.body,
      );
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return ApiMovieListResponse.fromJson(json);
  }
}

class MovieApiException implements Exception {
  MovieApiException({required this.statusCode, this.body});

  final int statusCode;
  final String? body;

  @override
  String toString() => 'MovieApiException: $statusCode ${body ?? ""}';
}
