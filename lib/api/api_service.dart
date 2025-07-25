import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _apiKey = 'd2104a2523e9a0f45e055a7e7b3398ba';

  static Future<String?> fetchTrailerVideoKey(int movieId) async {
    final url = '$_baseUrl/movie/$movieId/videos?api_key=$_apiKey';
    final response = await http.get(Uri.parse(url));


    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;

      for (var video in results) {
        if (video['site'] == 'YouTube' && video['type'] == 'Trailer') {
          return video['key'];
        }
      }
    }

    return null; // Trailer not found
  }
}
