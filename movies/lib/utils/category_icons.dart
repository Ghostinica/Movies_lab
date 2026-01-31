import 'package:flutter/material.dart';

const List<IconData> categoryIconChoices = [
  Icons.folder_outlined,
  Icons.star_outline,
  Icons.movie_outlined,
  Icons.bookmark_outline,
  Icons.favorite_border,
  Icons.visibility_outlined,
  Icons.theaters_outlined,
  Icons.live_tv_outlined,
  Icons.emoji_emotions_outlined,
  Icons.sports_esports_outlined,
  Icons.music_note_outlined,
  Icons.science_outlined,
];

IconData getCategoryIcon(String name, int Function(String) getIconIndex) {
  switch (name) {
    case 'Просмотренное':
      return Icons.visibility_outlined;
    case 'Избранное':
      return Icons.bookmark_outline;
    case 'Понравившиеся':
      return Icons.favorite_border;
    default:
      final idx = getIconIndex(name);
      return categoryIconChoices[idx % categoryIconChoices.length];
  }
}
