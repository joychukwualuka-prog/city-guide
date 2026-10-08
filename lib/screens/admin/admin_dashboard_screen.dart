import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../models/attraction_model.dart';
import '../../providers/auth_provider.dart';

import 'manage_listings_screen.dart';
import 'send_notification_screen.dart';
import 'manage_reviews_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ==================================================
            // ADMIN HEADER
            // ==================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                16,
                14,
                16,
                18,
              ),
              decoration: const BoxDecoration(
                color: AppColors.primaryDark,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ------------------------------------------------
                  // LOGO + TITLE + ADMIN MENU
                  // ------------------------------------------------
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(
                          Icons.location_city_rounded,
                          color: AppColors.primaryDark,
                          size: 21,
                        ),
                      ),

                      const SizedBox(width: 10),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'City Guide',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Admin Dashboard',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ------------------------------------------------
                      // ADMIN MENU
                      // ------------------------------------------------
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.person_outline_rounded,
                          color: Colors.white,
                          size: 23,
                        ),
                        color: Colors.white,
                        onSelected: (value) async {
                          if (value == 'logout') {
                            await context
                                .read<AuthProvider>()
                                .service
                                .signOut();
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem<String>(
                            value: 'logout',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.logout_rounded,
                                  color: AppColors.error,
                                  size: 20,
                                ),
                                SizedBox(width: 10),
                                Text('Log Out'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // ADMIN NAVIGATION
                  // ==================================================
                  _AdminNavItem(
                    icon: Icons.dashboard_rounded,
                    label: 'Overview',
                    selected: true,
                    onTap: () {},
                  ),

                  _AdminNavItem(
                    icon: Icons.list_alt_rounded,
                    label: 'Listings',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const ManageListingsScreen(),
                        ),
                      );
                    },
                  ),

                  _AdminNavItem(
                    icon: Icons.reviews_outlined,
                    label: 'Reviews',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const ManageReviewsScreen(),
                        ),
                      );
                    },
                  ),

                  _AdminNavItem(
                    icon: Icons.notifications_none_rounded,
                    label: 'Notifications',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const SendNotificationScreen(),
                        ),
                      );
                    },
                  ),

                  _AdminNavItem(
                    icon: Icons.article_outlined,
                    label: 'Content',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Content management will be added here.',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ==================================================
            // WHITE/OFF-WHITE DASHBOARD BODY
            // ==================================================
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(26),
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    20,
                    16,
                    30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ==================================================
                      // STATISTICS
                      // ==================================================
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics:
                        const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.55,
                        children: [
                          _CountCard(
                            icon: Icons.list_alt_rounded,
                            label: 'Total Listings',
                            color: AppColors.primary,
                            future: db
                                .collection('attractions')
                                .count()
                                .get(),
                          ),

                          _CountCard(
                            icon: Icons.flag_outlined,
                            label: 'Pending Reviews',
                            color: AppColors.error,
                            future: db
                                .collectionGroup('reviews')
                                .where(
                              'isReported',
                              isEqualTo: true,
                            )
                                .count()
                                .get(),
                          ),

                          _CountCard(
                            icon: Icons.notifications_none_rounded,
                            label: 'Notifications',
                            color: AppColors.accent,
                            future: db
                                .collection('notifications')
                                .count()
                                .get(),
                          ),

                          _CountCard(
                            icon: Icons.people_outline_rounded,
                            label: 'Total Users',
                            color: AppColors.primary,
                            future: db
                                .collection('users')
                                .count()
                                .get(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ==================================================
                      // RECENT LISTINGS
                      // ==================================================
                      const Text(
                        'Recent Listings',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 10),

                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: db
                            .collection('attractions')
                            .limit(3)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 25,
                              ),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return const _EmptyListings(
                              message:
                              'Unable to load listings.',
                            );
                          }

                          final docs = snapshot.data?.docs ?? [];

                          if (docs.isEmpty) {
                            return const _EmptyListings(
                              message: 'No listings yet.',
                            );
                          }

                          return Column(
                            children: docs.map((doc) {
                              final attraction =
                              AttractionModel.fromMap(
                                doc.id,
                                doc.data(),
                              );

                              return _RecentListingCard(
                                attraction: attraction,
                              );
                            }).toList(),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // ==================================================
                      // QUICK ACTION
                      // ==================================================
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                const ManageListingsScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.add_rounded,
                            size: 20,
                          ),
                          label: const Text(
                            'Manage Listings',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                            AppColors.primary,
                            side: const BorderSide(
                              color: AppColors.inputBorder,
                            ),
                            minimumSize:
                            const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(13),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// ADMIN NAVIGATION ITEM
// ================================================================

class _AdminNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AdminNavItem({
    required this.icon,
    required this.label,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.75)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected
                      ? Colors.white
                      : Colors.white70,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : Colors.white70,
                    fontSize: 13,
                    fontWeight: selected
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// STAT CARD
// ================================================================

class _CountCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Future<AggregateQuerySnapshot> future;

  const _CountCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.future,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE8E5DE),
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),

          const Spacer(),

          FutureBuilder<AggregateQuerySnapshot>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                );
              }

              if (snapshot.hasError) {
                return const Text(
                  '—',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                );
              }

              return Text(
                snapshot.data?.count.toString() ?? '0',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              );
            },
          ),

          const SizedBox(height: 2),

          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// RECENT LISTING CARD
// ================================================================

class _RecentListingCard extends StatelessWidget {
  final AttractionModel attraction;

  const _RecentListingCard({
    required this.attraction,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = attraction.imageUrls.isNotEmpty;
    final imageUrl =
    hasImage ? attraction.imageUrls.first : null;

    final category = _formatCategory(
      attraction.category,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFE8E5DE),
        ),
      ),
      child: Row(
        children: [
          // ------------------------------------------------
          // IMAGE
          // ------------------------------------------------
          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: SizedBox(
              width: 54,
              height: 54,
              child: imageUrl != null
                  ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) {
                  return _ListingPlaceholder();
                },
              )
                  : _ListingPlaceholder(),
            ),
          ),

          const SizedBox(width: 12),

          // ------------------------------------------------
          // DETAILS
          // ------------------------------------------------
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  attraction.name.isEmpty
                      ? 'Unnamed Listing'
                      : attraction.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  category,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                if (attraction.address.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    attraction.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 9.5,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }

  String _formatCategory(AttractionCategory category) {
    switch (category) {
      case AttractionCategory.attraction:
        return 'Attraction';
      case AttractionCategory.restaurant:
        return 'Restaurant';
      case AttractionCategory.hotel:
        return 'Hotel';
      case AttractionCategory.event:
        return 'Event';
    }
  }
}

// ================================================================
// LISTING IMAGE PLACEHOLDER
// ================================================================

class _ListingPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.chipUnselected,
      child: const Center(
        child: Icon(
          Icons.location_city_rounded,
          color: AppColors.primary,
          size: 24,
        ),
      ),
    );
  }
}

// ================================================================
// EMPTY LISTINGS
// ================================================================

class _EmptyListings extends StatelessWidget {
  final String message;

  const _EmptyListings({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 28,
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}