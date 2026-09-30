import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/app_theme.dart';
import '../models/attraction_model.dart';

class CompactAttractionCard extends StatelessWidget {
  final AttractionModel attraction;
  final VoidCallback onTap;
  final double width;

  const CompactAttractionCard({
    super.key,
    required this.attraction,
    required this.onTap,
    this.width = 160,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    attraction.imageUrls.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: attraction.imageUrls.first,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(color: Colors.black12),
                    )
                        : Container(color: Colors.black12, child: const Icon(Icons.image)),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white70,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.favorite_border, size: 14),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attraction.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 13, color: AppColors.accent),
                        const SizedBox(width: 2),
                        Text(
                          '${attraction.avgRating.toStringAsFixed(1)} · ${_categoryLabel(attraction.category)}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _categoryLabel(AttractionCategory category) {
    switch (category) {
      case AttractionCategory.attraction:
        return 'Nature & Wildlife';
      case AttractionCategory.restaurant:
        return 'Restaurant';
      case AttractionCategory.hotel:
        return 'Hotel';
      case AttractionCategory.event:
        return 'Event';
    }
  }
}
