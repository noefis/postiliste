import 'package:flutter/material.dart';

class PictureView extends StatelessWidget {
  final String picture;

  const PictureView({
    super.key,
    required this.picture,
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
        body: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: SizedBox.expand(
            child: Image.network(
              picture,
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
            ),
          ),
        ));
  }
}
