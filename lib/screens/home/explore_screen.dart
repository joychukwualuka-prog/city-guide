import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../models/attraction_model.dart';
import '../../models/city_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/compact_attraction_card.dart';
import '../detail/attraction_detail_screen.dart';
import '../detail/category_listing_screen.dart';

class ExploreScreen extends StatefulWidget {
  final CityModel city;

  const ExploreScreen({super.key, required this.city});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Good morning, Explorer!'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Discover amazing places in ${widget.city.name}',
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.md),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search attractions, restaurants...',
                prefixIcon: Icon(Icons.search),
              ),
              readOnly: true,
              onTap: () => _openCategory(context, null),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 84,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _CategoryIcon(icon: Icons.grid_view, label: 'All', onTap: () => _openCategory(context, null)),
                  _CategoryIcon(
                    icon: Icons.photo_camera_back_outlined,
                    label: 'Attractions',
                    onTap: () => _openCategory(context, AttractionCategory.attraction),
                  ),
                  _CategoryIcon(
                    icon: Icons.restaurant_outlined,
                    label: 'Restaurants',
                    onTap: () => _openCategory(context, AttractionCategory.restaurant),
                  ),
                  _CategoryIcon(
                    icon: Icons.hotel_outlined,
                    label: 'Hotels',
                    onTap: () => _openCategory(context, AttractionCategory.hotel),
                  ),
                  _CategoryIcon(
                    icon: Icons.event_outlined,
                    label: 'Events',
                    onTap: () => _openCategory(context, AttractionCategory.event),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _SectionHeader(
              title: 'Featured',
              onSeeAll: () => _openCategory(context, null),
            ),
            const SizedBox(height: AppSpacing.sm),
            _HorizontalAttractionList(
              stream: _firestoreService.attractionsForCity(widget.city.id),
              cardWidth: 240,
            ),
            const SizedBox(height: AppSpacing.lg),
            _SectionHeader(
              title: 'Popular Restaurants',
              onSeeAll: () => _openCategory(context, AttractionCategory.restaurant),
            ),
            const SizedBox(height: AppSpacing.sm),
            _HorizontalAttractionList(
              stream: _firestoreService.attractionsForCity(
                widget.city.id,
                categoryFilter: AttractionCategory.restaurant.name,
              ),
              cardWidth: 150,
            ),
          ],
        ),
      ),
    );
  }

  void _openCategory(BuildContext context, AttractionCategory? category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryListingScreen(city: widget.city, initialCategory: category),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CategoryIcon({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.chipUnselected,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryDark),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        TextButton(onPressed: onSeeAll, child: const Text('See all')),
      ],
    );
  }
}

class _HorizontalAttractionList extends StatelessWidget {
  final Stream<List<AttractionModel>> stream;
  final double cardWidth;

  const _HorizontalAttractionList({required this.stream, required this.cardWidth});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: StreamBuilder<List<AttractionModel>>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(child: Text('Nothing here yet.'));
          }
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final attraction = items[index];
              return CompactAttractionCard(
                attraction: attraction,
                width: cardWidth,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AttractionDetailScreen(attractionId: attraction.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
