import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/app_theme.dart';
import '../../models/attraction_model.dart';
import '../../models/review_model.dart';
import '../../services/firestore_service.dart';

class AttractionDetailScreen extends StatefulWidget {
  final String attractionId;

  const AttractionDetailScreen({super.key, required this.attractionId});

  @override
  State<AttractionDetailScreen> createState() => _AttractionDetailScreenState();
}

class _AttractionDetailScreenState extends State<AttractionDetailScreen> {
  final _firestoreService = FirestoreService();
  AttractionModel? _attraction;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final attraction = await _firestoreService.getAttraction(widget.attractionId);
    setState(() => _attraction = attraction);
  }

  @override
  Widget build(BuildContext context) {
    final attraction = _attraction;
    if (attraction == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(attraction.name),
              background: attraction.imageUrls.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: attraction.imageUrls.first,
                fit: BoxFit.cover,
              )
                  : Container(color: Colors.black12),
            ),
            actions: [
              if (currentUser != null)
                IconButton(
                  icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
                  onPressed: () {
                    setState(() => _isFavorite = !_isFavorite);
                    _firestoreService.toggleFavorite(
                      userId: currentUser.uid,
                      attractionId: attraction.id,
                      alreadyFavorited: !_isFavorite,
                    );
                  },
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.accent, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${attraction.avgRating.toStringAsFixed(1)} (${attraction.ratingCount} reviews)',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(attraction.description),
                  const SizedBox(height: AppSpacing.md),
                  if (attraction.address.isNotEmpty)
                    _InfoRow(icon: Icons.location_on, text: attraction.address),
                  if (attraction.openingHours.isNotEmpty)
                    _InfoRow(icon: Icons.schedule, text: attraction.openingHours),
                  if (attraction.contact.isNotEmpty)
                    _InfoRow(icon: Icons.phone, text: attraction.contact),
                  const Divider(height: AppSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Reviews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        icon: const Icon(Icons.rate_review_outlined),
                        label: const Text('Write a review'),
                        onPressed: currentUser == null
                            ? null
                            : () => _showWriteReviewSheet(context, attraction.id),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          StreamBuilder<List<ReviewModel>>(
            stream: _firestoreService.reviewsForAttraction(attraction.id),
            builder: (context, snapshot) {
              final reviews = snapshot.data ?? [];
              if (reviews.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Text('No reviews yet — be the first!'),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => _ReviewTile(
                    review: reviews[index],
                    attractionId: attraction.id,
                    currentUserId: currentUser?.uid,
                    firestoreService: _firestoreService,
                  ),
                  childCount: reviews.length,
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
        ],
      ),
    );
  }

  void _showWriteReviewSheet(BuildContext context, String attractionId) {
    double rating = 5;
    final textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            top: AppSpacing.md,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.md,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rate your experience', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: List.generate(5, (index) {
                      final starValue = index + 1;
                      return IconButton(
                        icon: Icon(
                          starValue <= rating ? Icons.star : Icons.star_border,
                          color: AppColors.accent,
                        ),
                        onPressed: () => setSheetState(() => rating = starValue.toDouble()),
                      );
                    }),
                  ),
                  TextField(
                    controller: textController,
                    maxLines: 3,
                    decoration: const InputDecoration(hintText: 'Share details of your experience'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () async {
                      await _firestoreService.addReview(
                        attractionId: attractionId,
                        rating: rating,
                        text: textController.text.trim(),
                      );
                      if (context.mounted) Navigator.pop(sheetContext);
                      _load(); // refresh avgRating shown above
                    },
                    child: const Text('Submit review'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final ReviewModel review;
  final String attractionId;
  final String? currentUserId;
  final FirestoreService firestoreService;

  const _ReviewTile({
    required this.review,
    required this.attractionId,
    required this.currentUserId,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    final liked = currentUserId != null && review.likedByUserIds.contains(currentUserId);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(review.userName, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: AppSpacing.sm),
              Row(
                children: List.generate(
                  5,
                      (i) => Icon(
                    i < review.rating.round() ? Icons.star : Icons.star_border,
                    size: 14,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(review.text),
          Row(
            children: [
              IconButton(
                iconSize: 18,
                icon: Icon(liked ? Icons.thumb_up : Icons.thumb_up_outlined),
                onPressed: currentUserId == null
                    ? null
                    : () => firestoreService.toggleReviewLike(
                  attractionId: attractionId,
                  reviewId: review.id,
                  userId: currentUserId!,
                  alreadyLiked: liked,
                ),
              ),
              Text('${review.likedByUserIds.length}'),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}
