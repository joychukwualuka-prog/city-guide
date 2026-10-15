import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/app_theme.dart';
import '../../core/contact_actions.dart';
import '../../core/directions_helper.dart';
import '../../models/attraction_model.dart';
import '../../models/review_model.dart';
import '../../services/firestore_service.dart';

class AttractionDetailScreen extends StatefulWidget {
  final String attractionId;

  const AttractionDetailScreen({
    super.key,
    required this.attractionId,
  });

  @override
  State<AttractionDetailScreen> createState() =>
      _AttractionDetailScreenState();
}

class _AttractionDetailScreenState
    extends State<AttractionDetailScreen> {
  final _firestoreService = FirestoreService();

  AttractionModel? _attraction;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final attraction = await _firestoreService.getAttraction(
      widget.attractionId,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _attraction = attraction;
    });
  }

  @override
  Widget build(BuildContext context) {
    final attraction = _attraction;

    if (attraction == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final currentUser =
        FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background:
              attraction.imageUrls.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl:
                attraction.imageUrls.first,
                fit: BoxFit.cover,
              )
                  : Container(
                color: Colors.black12,
              ),
            ),
            actions: [
              if (currentUser != null)
                IconButton(
                  icon: Icon(
                    _isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                  ),
                  onPressed: () {
                    setState(() {
                      _isFavorite =
                      !_isFavorite;
                    });

                    _firestoreService
                        .toggleFavorite(
                      userId:
                      currentUser.uid,
                      attractionId:
                      attraction.id,
                      alreadyFavorited:
                      !_isFavorite,
                    );
                  },
                ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding:
              const EdgeInsets.all(
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Text(
                    attraction.name,
                    style:
                    const TextStyle(
                      fontSize: 24,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height:
                    AppSpacing.sm,
                  ),

                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color:
                        AppColors.accent,
                        size: 20,
                      ),

                      const SizedBox(
                        width: 4,
                      ),

                      Text(
                        '${attraction.avgRating.toStringAsFixed(1)} '
                            '(${attraction.ratingCount} reviews)',
                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight
                              .w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height:
                    AppSpacing.md,
                  ),

                  // Action buttons
                  _ActionButtons(
                    attraction:
                    attraction,
                  ),

                  const SizedBox(
                    height:
                    AppSpacing.md,
                  ),

                  Text(
                    attraction.description,
                  ),

                  const SizedBox(
                    height:
                    AppSpacing.md,
                  ),

                  if (attraction
                      .address
                      .isNotEmpty)
                    _InfoRow(
                      icon:
                      Icons.location_on,
                      text:
                      attraction.address,
                    ),

                  if (attraction
                      .openingHours
                      .isNotEmpty)
                    _InfoRow(
                      icon: Icons.schedule,
                      text: attraction
                          .openingHours,
                    ),

                  if (attraction
                      .contact
                      .isNotEmpty)
                    _InfoRow(
                      icon: Icons.phone,
                      text:
                      attraction.contact,
                    ),

                  if (attraction
                      .website
                      .isNotEmpty)
                    _InfoRow(
                      icon:
                      Icons.language,
                      text:
                      attraction.website,
                    ),

                  const Divider(
                    height:
                    AppSpacing.xl,
                  ),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                    children: [
                      const Text(
                        'Reviews',
                        style:
                        TextStyle(
                          fontSize: 18,
                          fontWeight:
                          FontWeight
                              .bold,
                        ),
                      ),

                      TextButton.icon(
                        icon: const Icon(
                          Icons
                              .rate_review_outlined,
                        ),
                        label:
                        const Text(
                          'Write a review',
                        ),
                        onPressed:
                        currentUser ==
                            null
                            ? null
                            : () {
                          _showWriteReviewSheet(
                            context,
                            attraction.id,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          StreamBuilder<
              List<ReviewModel>>(
            stream: _firestoreService
                .reviewsForAttraction(
              attraction.id,
            ),
            builder:
                (context, snapshot) {
              final reviews =
                  snapshot.data ?? [];

              if (reviews.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding:
                    EdgeInsets.all(
                      AppSpacing.md,
                    ),
                    child: Text(
                      'No reviews yet — be the first!',
                    ),
                  ),
                );
              }

              return SliverList(
                delegate:
                SliverChildBuilderDelegate(
                      (context, index) =>
                      _ReviewTile(
                        review:
                        reviews[index],
                        attractionId:
                        attraction.id,
                        currentUserId:
                        currentUser?.uid,
                        firestoreService:
                        _firestoreService,
                        onReviewChanged:
                        _load,
                      ),
                  childCount:
                  reviews.length,
                ),
              );
            },
          ),

          const SliverToBoxAdapter(
            child: SizedBox(
              height:
              AppSpacing.xl,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // WRITE REVIEW
  // ==========================================================

  void _showWriteReviewSheet(
      BuildContext context,
      String attractionId,
      ) {
    double rating = 5;

    final textController =
    TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding:
          EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            top: AppSpacing.md,
            bottom: MediaQuery.of(
              sheetContext,
            )
                .viewInsets
                .bottom +
                AppSpacing.md,
          ),
          child: StatefulBuilder(
            builder: (
                context,
                setSheetState,
                ) {
              return Column(
                mainAxisSize:
                MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  const Text(
                    'Rate your experience',
                    style:
                    TextStyle(
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height:
                    AppSpacing.sm,
                  ),

                  Row(
                    children:
                    List.generate(
                      5,
                          (index) {
                        final starValue =
                            index + 1;

                        return IconButton(
                          icon: Icon(
                            starValue <=
                                rating
                                ? Icons.star
                                : Icons
                                .star_border,
                            color:
                            AppColors
                                .accent,
                          ),
                          onPressed: () {
                            setSheetState(
                                  () {
                                rating =
                                    starValue
                                        .toDouble();
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),

                  TextField(
                    controller:
                    textController,
                    maxLines: 3,
                    decoration:
                    const InputDecoration(
                      hintText:
                      'Share details of your experience',
                    ),
                  ),

                  const SizedBox(
                    height:
                    AppSpacing.md,
                  ),

                  ElevatedButton(
                    onPressed:
                        () async {
                      await _firestoreService
                          .addReview(
                        attractionId:
                        attractionId,
                        rating: rating,
                        text:
                        textController
                            .text
                            .trim(),
                      );

                      if (!sheetContext
                          .mounted) {
                        return;
                      }

                      Navigator.pop(
                        sheetContext,
                      );

                      await _load();
                    },
                    child:
                    const Text(
                      'Submit review',
                    ),
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

// ==========================================================
// ACTION BUTTONS
// ==========================================================

class _ActionButtons
    extends StatelessWidget {
  final AttractionModel attraction;

  const _ActionButtons({
    required this.attraction,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final hasPhone =
        attraction.contact
            .trim()
            .isNotEmpty;

    final hasWebsite =
        attraction.website
            .trim()
            .isNotEmpty;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        if (hasPhone)
          OutlinedButton.icon(
            onPressed: () {
              callNumber(
                context,
                attraction.contact,
              );
            },
            icon:
            const Icon(
              Icons.call,
            ),
            label:
            const Text(
              'Call',
            ),
          ),

        if (hasWebsite)
          OutlinedButton.icon(
            onPressed: () {
              openWebsite(
                context,
                attraction.website,
              );
            },
            icon:
            const Icon(
              Icons.language,
            ),
            label:
            const Text(
              'Website',
            ),
          ),

        ElevatedButton.icon(
          onPressed: () {
            openDirections(
              context,
              lat: attraction
                  .location.latitude,
              lng: attraction
                  .location.longitude,
              label:
              attraction.name,
            );
          },
          icon:
          const Icon(
            Icons.directions,
          ),
          label:
          const Text(
            'Directions',
          ),
        ),
      ],
    );
  }
}

// ==========================================================
// INFO ROW
// ==========================================================

class _InfoRow
    extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom:
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: AppColors
                .textSecondary,
          ),

          const SizedBox(
            width:
            AppSpacing.sm,
          ),

          Expanded(
            child: Text(
              text,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// REVIEW TILE
// ==========================================================

class _ReviewTile
    extends StatelessWidget {
  final ReviewModel review;
  final String attractionId;
  final String? currentUserId;
  final FirestoreService
  firestoreService;
  final Future<void> Function()
  onReviewChanged;

  const _ReviewTile({
    required this.review,
    required this.attractionId,
    required this.currentUserId,
    required this.firestoreService,
    required this.onReviewChanged,
  });

  // ==========================================================
  // REPORT REVIEW
  // ==========================================================

  Future<void> _reportReview(
      BuildContext context,
      ) async {
    try {
      await FirebaseFirestore.instance
          .collection(
        'attractions',
      )
          .doc(
        attractionId,
      )
          .collection(
        'reviews',
      )
          .doc(
        review.id,
      )
          .update({
        'isReported': true,
        'reportCount':
        FieldValue.increment(
          1,
        ),
      });

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Review reported to admin.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not report review. Please try again.',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // EDIT REVIEW
  // ==========================================================

  Future<void> _editReview(
      BuildContext context,
      ) async {
    final textController =
    TextEditingController(
      text: review.text,
    );

    double rating =
        review.rating;

    final shouldSave =
    await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) {
        return StatefulBuilder(
          builder: (
              context,
              setDialogState,
              ) {
            return AlertDialog(
              title:
              const Text(
                'Edit Review',
              ),
              content: Column(
                mainAxisSize:
                MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  const Text(
                    'Your rating',
                    style:
                    TextStyle(
                      fontWeight:
                      FontWeight
                          .w600,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Row(
                    children:
                    List.generate(
                      5,
                          (index) {
                        final starValue =
                            index + 1;

                        return IconButton(
                          padding:
                          EdgeInsets
                              .zero,
                          icon: Icon(
                            starValue <=
                                rating
                                ? Icons.star
                                : Icons
                                .star_border,
                            color:
                            AppColors
                                .accent,
                          ),
                          onPressed:
                              () {
                            setDialogState(
                                  () {
                                rating =
                                    starValue
                                        .toDouble();
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  TextField(
                    controller:
                    textController,
                    maxLines: 4,
                    decoration:
                    const InputDecoration(
                      labelText:
                      'Review',
                      hintText:
                      'Share your experience',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      false,
                    );
                  },
                  child:
                  const Text(
                    'Cancel',
                  ),
                ),

                ElevatedButton(
                  onPressed: () {
                    if (textController
                        .text
                        .trim()
                        .isEmpty) {
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      true,
                    );
                  },
                  child:
                  const Text(
                    'Save',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldSave != true) {
      textController.dispose();
      return;
    }

    final newText =
    textController.text.trim();

    textController.dispose();

    try {
      await firestoreService.editReview(
        attractionId:
        attractionId,
        reviewId:
        review.id,
        rating:
        rating,
        text:
        newText,
      );

      await onReviewChanged();

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Review updated successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Could not update review: $e',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // DELETE REVIEW
  // ==========================================================

  Future<void> _deleteReview(
      BuildContext context,
      ) async {
    final shouldDelete =
    await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) {
        return AlertDialog(
          title:
          const Text(
            'Delete Review?',
          ),
          content:
          const Text(
            'Are you sure you want to delete your review? This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child:
              const Text(
                'Cancel',
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child:
              const Text(
                'Delete',
                style:
                TextStyle(
                  color:
                  AppColors
                      .error,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete !=
        true) {
      return;
    }

    try {
      await firestoreService
          .deleteReview(
        attractionId:
        attractionId,
        reviewId:
        review.id,
      );

      await onReviewChanged();

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content:
          Text(
            'Review deleted.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Could not delete review: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final liked =
        currentUserId != null &&
            review.likedByUserIds
                .contains(
              currentUserId,
            );

    final isOwner =
        currentUserId != null &&
            currentUserId ==
                review.userId;

    return Padding(
      padding:
      const EdgeInsets.symmetric(
        horizontal:
        AppSpacing.md,
        vertical:
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment
            .start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        review
                            .userName,
                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight
                              .w600,
                        ),
                      ),
                    ),

                    const SizedBox(
                      width:
                      AppSpacing.sm,
                    ),

                    Row(
                      children:
                      List.generate(
                        5,
                            (i) => Icon(
                          i <
                              review
                                  .rating
                                  .round()
                              ? Icons.star
                              : Icons
                              .star_border,
                          size: 14,
                          color:
                          AppColors
                              .accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (isOwner)
                PopupMenuButton<
                    String>(
                  icon:
                  const Icon(
                    Icons.more_vert,
                  ),
                  onSelected:
                      (value) async {
                    if (value ==
                        'edit') {
                      await _editReview(
                        context,
                      );
                    }

                    if (value ==
                        'delete') {
                      await _deleteReview(
                        context,
                      );
                    }
                  },
                  itemBuilder:
                      (context) {
                    return const [
                      PopupMenuItem(
                        value:
                        'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons
                                  .edit_outlined,
                            ),
                            SizedBox(
                              width:
                              10,
                            ),
                            Text(
                              'Edit Review',
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value:
                        'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons
                                  .delete_outline,
                              color:
                              AppColors
                                  .error,
                            ),
                            SizedBox(
                              width:
                              10,
                            ),
                            Text(
                              'Delete Review',
                              style:
                              TextStyle(
                                color:
                                AppColors
                                    .error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
            ],
          ),

          const SizedBox(
            height:
            AppSpacing.xs,
          ),

          Text(
            review.text,
          ),

          Row(
            children: [
              IconButton(
                iconSize: 18,
                icon: Icon(
                  liked
                      ? Icons.thumb_up
                      : Icons
                      .thumb_up_outlined,
                ),
                onPressed:
                currentUserId ==
                    null
                    ? null
                    : () {
                  firestoreService
                      .toggleReviewLike(
                    attractionId:
                    attractionId,
                    reviewId:
                    review.id,
                    userId:
                    currentUserId!,
                    alreadyLiked:
                    liked,
                  );
                },
              ),

              Text(
                '${review.likedByUserIds.length}',
              ),

              const SizedBox(
                width: 8,
              ),

              if (currentUserId !=
                  null &&
                  !isOwner)
                TextButton.icon(
                  onPressed:
                      () async {
                    final shouldReport =
                    await showDialog<
                        bool>(
                      context:
                      context,
                      builder:
                          (dialogContext) {
                        return AlertDialog(
                          title:
                          const Text(
                            'Report review?',
                          ),
                          content:
                          const Text(
                            'This review will be sent to an admin for moderation.',
                          ),
                          actions: [
                            TextButton(
                              onPressed:
                                  () {
                                Navigator
                                    .pop(
                                  dialogContext,
                                  false,
                                );
                              },
                              child:
                              const Text(
                                'Cancel',
                              ),
                            ),
                            TextButton(
                              onPressed:
                                  () {
                                Navigator
                                    .pop(
                                  dialogContext,
                                  true,
                                );
                              },
                              child:
                              const Text(
                                'Report',
                              ),
                            ),
                          ],
                        );
                      },
                    );

                    if (shouldReport !=
                        true) {
                      return;
                    }

                    if (!context
                        .mounted) {
                      return;
                    }

                    await _reportReview(
                      context,
                    );
                  },
                  icon:
                  const Icon(
                    Icons
                        .flag_outlined,
                    size: 18,
                  ),
                  label:
                  const Text(
                    'Report',
                  ),
                ),
            ],
          ),

          const Divider(),
        ],
      ),
    );
  }
}