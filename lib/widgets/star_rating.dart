import 'package:flutter/material.dart';

/// Read-only when [onChanged] is null (supports half stars for averages),
/// tappable when [onChanged] is provided (whole stars, 1-5).
class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.rating,
    this.size = 20,
    this.onChanged,
  });

  final double rating;
  final double size;
  final ValueChanged<int>? onChanged;

  static const Color _starColor = Color(0xFFFFC107);

  IconData _iconFor(int index) {
    if (rating >= index + 1) return Icons.star;
    if (rating >= index + 0.5) return Icons.star_half;
    return Icons.star_border;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final icon = Icon(_iconFor(i), size: size, color: _starColor);
        if (onChanged == null) return icon;
        return IconButton(
          onPressed: () => onChanged!(i + 1),
          icon: icon,
          tooltip: '${i + 1} star${i == 0 ? '' : 's'}',
        );
      }),
    );
  }
}