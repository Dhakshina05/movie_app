import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movie_app/models/movie.dart';

class FavoriteService {
  static const String favoritesKey = 'favorite_movies';

  static Future<void> addFavorite(Movie movie) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> favorites =
        prefs.getStringList(favoritesKey) ?? [];

    favorites.add(jsonEncode({
      'id': movie.id,
      'title': movie.title,
      'backdrop_path': movie.backDropPath,
      'original_title': movie.originalTitle,
      'overview': movie.overview,
      'poster_path': movie.posterPath,
      'release_date': movie.releaseDate,
      'vote_average': movie.voteAverage,
    }));

    await prefs.setStringList(favoritesKey, favorites);
  }

  static Future<List<Movie>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    List<String> favorites =
        prefs.getStringList(favoritesKey) ?? [];

    return favorites
        .map((movie) => Movie.fromJson(jsonDecode(movie)))
        .toList();
  }

  static Future<void> removeFavorite(int movieId) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> favorites =
        prefs.getStringList(favoritesKey) ?? [];

    favorites.removeWhere((movie) {
      final data = jsonDecode(movie);
      return data['id'] == movieId;
    });

    await prefs.setStringList(favoritesKey, favorites);
  }

  static Future<bool> isFavorite(int movieId) async {
    final favorites = await getFavorites();

    return favorites.any((movie) => movie.id == movieId);
  }
}