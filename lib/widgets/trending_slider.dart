import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart' as car;
import 'package:movie_app/constants.dart';
import 'package:movie_app/screens/details_screen.dart';

class TrendingSlider extends StatelessWidget {
  const TrendingSlider({
    super.key, required this.snapshot,
  });

  final AsyncSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double cardHeight = screenSize.height * 0.30;
    final double cardWidth = screenSize.width * 0.30;

    return SizedBox(
      width: double.infinity,
      child: car.CarouselSlider.builder(
        itemCount: snapshot.data!.length,
        options: car.CarouselOptions(
          height: cardHeight,
          autoPlay: true,
          viewportFraction: 0.55,
          enlargeCenterPage: true,
          pageSnapping: true,
          autoPlayCurve: Curves.fastOutSlowIn,
          autoPlayAnimationDuration: const Duration(seconds: 1),
        ),
        itemBuilder: (context, itemIndex, pageViewIndex) {
          return GestureDetector(
            onTap: (){
              Navigator.push(context,MaterialPageRoute(builder:
              (context)=> DetailsScreen(movie:snapshot.data
              [itemIndex],
              ),
              ),
              );
            },
          child:  ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: cardHeight,
              width:  cardWidth,
              child: Image.network(
                filterQuality: FilterQuality.high,
                fit: BoxFit.cover,
                '${Constants.imagePath}${snapshot.data[itemIndex].posterPath}'
              ),
            ),

          ),
          );

        },
      ),
    );
  }
}