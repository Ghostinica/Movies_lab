class ApiMovieDto {
  ApiMovieDto({
    required this.id,
    this.name,
    this.alternativeName,
    this.year,
    this.description,
    this.shortDescription,
    this.poster,
    this.rating,
    this.genres = const [],
    this.countries = const [],
    this.movieLength,
    this.isSeries = false,
  });

  final int id;
  final String? name;
  final String? alternativeName;
  final int? year;
  final String? description;
  final String? shortDescription;
  final ApiPoster? poster;
  final ApiRating? rating;
  final List<ApiGenre> genres;
  final List<ApiCountry> countries;
  final int? movieLength;
  final bool isSeries;

  String get displayName => name ?? alternativeName ?? 'Без названия';

  String get genresString =>
      genres.map((g) => g.name).whereType<String>().join(', ');

  String get countriesString =>
      countries.map((c) => c.name).whereType<String>().join(', ');

  factory ApiMovieDto.fromJson(Map<String, dynamic> json) {
    return ApiMovieDto(
      id: json['id'] as int,
      name: json['name'] as String?,
      alternativeName: json['alternativeName'] as String?,
      year: json['year'] as int?,
      description: json['description'] as String?,
      shortDescription: json['shortDescription'] as String?,
      poster: json['poster'] != null
          ? ApiPoster.fromJson(json['poster'] as Map<String, dynamic>)
          : null,
      rating: json['rating'] != null
          ? ApiRating.fromJson(json['rating'] as Map<String, dynamic>)
          : null,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => ApiGenre.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      countries: (json['countries'] as List<dynamic>?)
              ?.map((e) => ApiCountry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      movieLength: json['movieLength'] as int?,
      isSeries: json['isSeries'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'alternativeName': alternativeName,
      'year': year,
      'description': description,
      'shortDescription': shortDescription,
      'poster': poster?.toJson(),
      'rating': rating?.toJson(),
      'genres': genres.map((e) => e.toJson()).toList(),
      'countries': countries.map((e) => e.toJson()).toList(),
      'movieLength': movieLength,
      'isSeries': isSeries,
    };
  }
}

class ApiPoster {
  ApiPoster({this.url, this.previewUrl});

  final String? url;
  final String? previewUrl;

  factory ApiPoster.fromJson(Map<String, dynamic> json) {
    return ApiPoster(
      url: json['url'] as String?,
      previewUrl: json['previewUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'url': url, 'previewUrl': previewUrl};
}

class ApiRating {
  ApiRating({this.kp, this.imdb});

  final double? kp;
  final double? imdb;

  factory ApiRating.fromJson(Map<String, dynamic> json) {
    return ApiRating(
      kp: (json['kp'] as num?)?.toDouble(),
      imdb: (json['imdb'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'kp': kp, 'imdb': imdb};
}

class ApiGenre {
  ApiGenre({this.name});

  final String? name;

  factory ApiGenre.fromJson(Map<String, dynamic> json) {
    return ApiGenre(name: json['name'] as String?);
  }

  Map<String, dynamic> toJson() => {'name': name};
}

class ApiCountry {
  ApiCountry({this.name});

  final String? name;

  factory ApiCountry.fromJson(Map<String, dynamic> json) {
    return ApiCountry(name: json['name'] as String?);
  }

  Map<String, dynamic> toJson() => {'name': name};
}

class ApiMovieListResponse {
  ApiMovieListResponse({
    required this.docs,
    this.total,
    this.limit,
    this.page,
    this.pages,
  });

  final List<ApiMovieDto> docs;
  final int? total;
  final int? limit;
  final int? page;
  final int? pages;

  factory ApiMovieListResponse.fromJson(Map<String, dynamic> json) {
    return ApiMovieListResponse(
      docs: (json['docs'] as List<dynamic>)
          .map((e) => ApiMovieDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int?,
      limit: json['limit'] as int?,
      page: json['page'] as int?,
      pages: json['pages'] as int?,
    );
  }
}
