import 'dart:convert';

import 'package:movie_app/constants.dart';
import 'package:movie_app/models/movie.dart';
import 'package:http/http.dart' as http;
import 'package:movie_app/models/genre.dart';

class Api{
  static const _trendingUrl ='https://api.themoviedb.org/3/trending/movie/day?api_key=${Constants.apiKey}';
  static const _topRatedUrl ='https://api.themoviedb.org/3/movie/top_rated?api_key=${Constants.apiKey}';
  static const _upcomingUrl ='https://api.themoviedb.org/3/movie/upcoming?api_key=${Constants.apiKey}';
  static const _searchBaseUrl ='https://api.themoviedb.org/3/search/movie?api_key=${Constants.apiKey}&query=';

  Future<List<Movie>> getTrendingMovies() async {
  final response = await http.get(Uri.parse(_trendingUrl));
  if(response.statusCode == 200){
     final decodedData = json.decode(response.body)['results'] as List;
     // print(decodedData);
     return decodedData.map((movie)=>Movie.fromJson(movie)).toList();
  }else{
    throw Exception('Something Happened');
  }
  }

  Future<List<Movie>> getTopRatedMovies() async {
  final response = await http.get(Uri.parse(_topRatedUrl));
  if(response.statusCode == 200){
     final decodedData = json.decode(response.body)['results'] as List;
     // print(decodedData);
     return decodedData.map((movie)=>Movie.fromJson(movie)).toList();
  }else{
    throw Exception('Something Happened');
  }
  }

  Future<List<Movie>> getUpcomingMovies() async {
  final response = await http.get(Uri.parse(_upcomingUrl));
  if(response.statusCode == 200){
     final decodedData = json.decode(response.body)['results'] as List;
     // print(decodedData);
     return decodedData.map((movie)=>Movie.fromJson(movie)).toList();
  }else{
    throw Exception('Something Happened');
  }
  }
  Future<List<Genre>> getGenres() async {
    final url = 'https://api.themoviedb.org/3/genre/movie/list?api_key=${Constants.apiKey}&language=en-US';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List genres = data['genres'];
      return genres.map((g) => Genre.fromJson(g)).toList();
    } else {
      throw Exception('Failed to load genres');
    }
  }

  Future<List<Movie>> getMoviesByGenre(int genreId) async {
    final url = 'https://api.themoviedb.org/3/discover/movie?api_key=${Constants.apiKey}&with_genres=$genreId';

    final response = await http.get(Uri.parse(url));
    return _parseMovies(response);
  }

  List<Movie> _parseMovies(http.Response response) {
    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body)['results'] as List;
      return decodedData.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Something Happened');
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    final response = await http.get(Uri.parse(_searchBaseUrl + query));
    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body)['results'] as List;
      return decodedData.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to load search results');
    }
  }
}


