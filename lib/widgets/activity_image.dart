import 'package:flutter/material.dart';

class ActivityImage extends StatelessWidget {
  const ActivityImage({super.key, required this.url, this.height = 140});

  final String url;
  final double height;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      height: height,
      width: double.infinity,
      color: Colors.grey.shade300,
      child: const Icon(Icons.image_outlined, size: 40, color: Colors.grey),
    );

    if (url.isEmpty) return placeholder;

    return Image.network(
      url,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => placeholder,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : placeholder,
    );
  }
}