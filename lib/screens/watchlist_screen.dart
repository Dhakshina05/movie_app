import 'package:flutter/material.dart';
import 'package:movie_app/widgets/favorite_service.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/constants.dart';
import 'details_screen.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  late Future<List<Movie>> favorites;

  @override
  void initState() {
    super.initState();
    favorites = FavoriteService.getFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Watchlist'),
      ),
      body: FutureBuilder<List<Movie>>(
        future: favorites,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final movies = snapshot.data!;

          if (movies.isEmpty) {
            return const Center(
              child: Text('No favorite movies yet'),
            );
          }

          return ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];

              return ListTile(
                leading: Image.network(
                  '${Constants.imagePath}${movie.posterPath}',
                  width: 50,
                ),
                title: Text(movie.title),
                subtitle: Text(movie.releaseDate),
                trailing: const Icon(
                  Icons.favorite,
                  color: Colors.red,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          DetailsScreen(movie: movie),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}