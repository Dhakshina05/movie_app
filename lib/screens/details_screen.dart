import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_app/constants.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/colors.dart';
import 'package:movie_app/widgets/trailer_player.dart';
import 'package:movie_app/api/api_service.dart';
import 'package:movie_app/widgets/favorite_service.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key, required this.movie});

  final Movie movie;

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  String? trailerKey;
  bool isLoadingTrailer = true;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    loadTrailer();
    loadFavoriteStatus();
  }

  Future<void> loadTrailer() async {
    setState(() {
      isLoadingTrailer = true;
    });

    final key = await ApiService.fetchTrailerVideoKey(widget.movie.id);

    if (!mounted) return;

    setState(() {
      trailerKey = key;
      isLoadingTrailer = false;
    });
  }

  Future<void> loadFavoriteStatus() async {
    final fav = await FavoriteService.isFavorite(widget.movie.id);

    if (!mounted) return;

    setState(() {
      isFavorite = fav;
    });
  }

  Future<void> toggleFavorite() async {
    if (isFavorite) {
      await FavoriteService.removeFavorite(widget.movie.id);
    } else {
      await FavoriteService.addFavorite(widget.movie);
    }

    setState(() {
      isFavorite = !isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite ? 'Added to Watchlist' : 'Removed from Watchlist',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            actions: [
              IconButton(
                onPressed: toggleFavorite,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                ),
              ),
            ],
            backgroundColor: Colours.scaffoldBgColor,
            expandedHeight: 500,
            pinned: true,
            floating: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.movie.title,
                style: GoogleFonts.belleza(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              background: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                child: Image.network(
                  '${Constants.imagePath}${widget.movie.backDropPath}',
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 100,
                      color: Colors.grey,
                    ),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Text(
                    'Overview',
                    style: GoogleFonts.openSans(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.movie.overview,
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.purple),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Release date:',
                              style: GoogleFonts.roboto(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.movie.releaseDate.isNotEmpty
                                  ? widget.movie.releaseDate
                                  : 'N/A',
                              style: GoogleFonts.roboto(
                                fontSize: 25,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.purple),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Rating:',
                              style: GoogleFonts.roboto(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Icon(Icons.star, color: Colors.amber),
                            Text(
                              '${widget.movie.voteAverage.toStringAsFixed(1)}/10',
                              style: GoogleFonts.roboto(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Trailer',
                    style: GoogleFonts.openSans(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ✅ TRAILER SECTION (FIXED)
                  if (isLoadingTrailer)
                    const CircularProgressIndicator()
                  else if (trailerKey != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: TrailerPlayer(
                          videoId: trailerKey!, // ✅ CORRECT
                        ),
                      ),
                    )
                  else
                    const Text(
                      'Trailer not available',
                      style: TextStyle(fontSize: 16),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
