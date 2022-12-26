import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class PictureView extends StatelessWidget {
  final List<String> pictures;

  const PictureView({
    super.key,
    required this.pictures,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          iconTheme:
              IconThemeData(color: Theme.of(context).colorScheme.primary),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: GestureDetector(onTap: () {
          Navigator.pop(context);
        }, child: SizedBox.expand(
          child: LayoutBuilder(builder: (context, constraints) {
            return CarouselSlider(
              options: CarouselOptions(
                  viewportFraction: 0.90,
                  enlargeCenterPage: true,
                  enlargeStrategy: CenterPageEnlargeStrategy.height,
                  height: 0.8 * constraints.maxHeight),
              items: pictures.map((picture) {
                return Image.network(
                  picture,
                  width: 360,
                  fit: BoxFit.fitWidth,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Text('Failed to load image'),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!.toDouble()
                            : null,
                      ),
                    );
                  },
                );
              }).toList(),
            );
          }),
        )));
  }
}
