import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_app/api/api.dart';
import '../models/movie.dart';
import '../widgets/trending_slider.dart';
import '../widgets/movies_slider.dart';
import '../screens/details_screen.dart';
import 'package:movie_app/main.dart';
import 'package:intl/intl.dart';
import 'package:movie_app/models/genre.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  late TextEditingController _searchController;
  late Future<List<Movie>> trendingMovies;
  late Future<List<Movie>> topRatedMovies;
  late Future<List<Movie>> upcomingMovies;

  final ScrollController _genreScrollController = ScrollController();

  List<Movie> _searchResults = [];

  late Future<List<Genre>> genres = Api().getGenres();
  int? selectedGenreId;
  Future<List<Movie>>? genreMovies;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    trendingMovies = Api().getTrendingMovies();
    topRatedMovies = Api().getTopRatedMovies();
    upcomingMovies = Api().getUpcomingMovies();
  }

  Future<void> _searchMovies(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    final results = await Api().searchMovies(query);
    setState(() {
      _searchResults = results;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _genreScrollController.dispose();
    super.dispose();
  }

  String _formatDate(String date) {
    try {
      return DateFormat.yMMMMd().format(DateTime.parse(date));
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = themeNotifier.value == ThemeMode.dark;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _isSearching
            ? Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search movies...',
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  onChanged: (query) async {
                    await _searchMovies(query);
                  },
                  onSubmitted: (query) async {
                    await _searchMovies(query);
                    FocusScope.of(context).unfocus();
                  },
                ),
              )
            : Image.asset(
                'assets/assets/love.jpg',
                fit: BoxFit.cover,
                height: 40,
                width: 40,
                filterQuality: FilterQuality.high,
              ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Row(
              children: [
                Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: Theme.of(context).iconTheme.color,
                ),
                const SizedBox(width: 6),
                Text(
                  isDark ? 'Dark' : 'Light',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
                const SizedBox(width: 6),
                Switch(
                  value: isDark,
                  onChanged: (value) {
                    setState(() {
                      themeNotifier.value = value
                          ? ThemeMode.dark
                          : ThemeMode.light;
                    });
                  },
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                _searchController.clear();
                _searchResults = [];
              });
              FocusScope.of(context).unfocus();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearching && _searchResults.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final movie = _searchResults[index];
                  return ListTile(
                    leading: movie.posterPath != null
                        ? Image.network(
                            'https://image.tmdb.org/t/p/w92${movie.posterPath}',
                            fit: BoxFit.cover,
                            width: 50,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image),
                          )
                        : Image.asset(
                            'assets/images/no_image.png',
                            width: 50,
                            fit: BoxFit.cover,
                          ),
                    title: Text(movie.title),
                    subtitle: Text(
                      (movie.releaseDate?.isNotEmpty ?? false)
                          ? _formatDate(movie.releaseDate!)
                          : 'No release date',
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsScreen(movie: movie),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder(
                        future: genres,
                        builder: (context, snapshot) {
                          if (snapshot.hasError)
                            return Text('Error loading genres');
                          if (!snapshot.hasData)
                            return CircularProgressIndicator();

                          final genreList = snapshot.data!;
                          return SizedBox(
                            height: 50,
                            child: Scrollbar(
                              thumbVisibility: true,
                              controller: _genreScrollController,
                              child: ListView.builder(
                                controller: _genreScrollController,
                                scrollDirection: Axis.horizontal,
                                itemCount: genreList.length,
                                itemBuilder: (context, index) {
                                  final genre = genreList[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    child: ChoiceChip(
                                      label: Text(genre.name),
                                      selected: selectedGenreId == genre.id,
                                      onSelected: (selected) {
                                        setState(() {
                                          selectedGenreId = genre.id;
                                          genreMovies = Api().getMoviesByGenre(
                                            genre.id,
                                          );
                                          _searchResults = [];
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Genre Movie List
                      if (genreMovies != null)
                        FutureBuilder(
                          future: genreMovies,
                          builder: (context, snapshot) {
                            if (genres == null) return SizedBox();
                            if (snapshot.hasError)
                              return Text('Error loading movies');
                            if (!snapshot.hasData)
                              return CircularProgressIndicator();

                            final movies = snapshot.data!;
                            return SizedBox(
                              height: 260,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: movies.length,
                                itemBuilder: (context, index) {
                                  final movie = movies[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              DetailsScreen(movie: movie),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 120,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Column(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              'https://image.tmdb.org/t/p/w185${movie.posterPath}',
                                              height: 180,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            movie.title,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.aBeeZee(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 16),
                      Text(
                        'Trending Movies',
                        style: GoogleFonts.aBeeZee(fontSize: 25),
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder(
                        future: trendingMovies,
                        builder: (context, snapshot) {
                          if (snapshot.hasError)
                            return Text(snapshot.error.toString());
                          if (snapshot.hasData)
                            return TrendingSlider(snapshot: snapshot);
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Top Rated Movies',
                        style: GoogleFonts.aBeeZee(fontSize: 25),
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder(
                        future: topRatedMovies,
                        builder: (context, snapshot) {
                          if (snapshot.hasError)
                            return Text(snapshot.error.toString());
                          if (snapshot.hasData)
                            return MoviesSlider(snapshot: snapshot);
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Upcoming Movies',
                        style: GoogleFonts.aBeeZee(fontSize: 25),
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder(
                        future: upcomingMovies,
                        builder: (context, snapshot) {
                          if (snapshot.hasError)
                            return Text(snapshot.error.toString());
                          if (snapshot.hasData)
                            return MoviesSlider(snapshot: snapshot);
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
