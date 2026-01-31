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
}
