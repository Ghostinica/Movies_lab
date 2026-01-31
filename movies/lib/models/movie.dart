class Movie {
  const Movie({
    required this.title,
    required this.year,
    required this.genre,
    this.description = '',
  });

  final String title;
  final String year;
  final String genre;
  final String description;

  Map<String, dynamic> toJson() => {
        'title': title,
        'year': year,
        'genre': genre,
        'description': description,
      };

  static Movie? fromJson(Map<String, dynamic> json) {
    final title = json['title'] as String?;
    final year = json['year'] as String?;
    final genre = json['genre'] as String?;
    if (title == null || title.isEmpty || year == null || genre == null) {
      return null;
    }
    return Movie(
      title: title,
      year: year,
      genre: genre,
      description: json['description'] as String? ?? '',
    );
  }
}
