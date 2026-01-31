import 'movie.dart';

import '../data/dto/api_movie_dto.dart';

class MovieItem {
  const MovieItem({
    required this.key,
    required this.title,
    required this.year,
    required this.genre,
    this.description = '',
    this.posterUrl,
    this.country,
    this.ratingKp,
    this.ratingImdb,
    this.movieLengthMinutes,
  });

  final String key;
  final String title;
  final String year;
  final String genre;
  final String description;
  final String? posterUrl;
  final String? country;
  final double? ratingKp;
  final double? ratingImdb;
  final int? movieLengthMinutes;

  static MovieItem fromMovie(Movie movie) {
    final titleKey = movie.title;
    return MovieItem(
      key: 'local:$titleKey',
      title: movie.title,
      year: movie.year,
      genre: movie.genre,
      description: movie.description,
    );
  }

  static MovieItem fromApiMovie(ApiMovieDto dto) {
    final yearStr = dto.year?.toString() ?? '—';
    final genreStr = dto.genresString.isNotEmpty ? dto.genresString : '—';
    final desc = dto.description ?? dto.shortDescription ?? '';
    final countryStr = dto.countriesString.isNotEmpty ? dto.countriesString : null;
    return MovieItem(
      key: 'api:${dto.id}',
      title: dto.displayName,
      year: yearStr,
      genre: genreStr,
      description: desc,
      posterUrl: dto.poster?.previewUrl ?? dto.poster?.url,
      country: countryStr,
      ratingKp: dto.rating?.kp,
      ratingImdb: dto.rating?.imdb,
      movieLengthMinutes: dto.movieLength,
    );
  }
}
