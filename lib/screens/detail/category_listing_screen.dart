import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../models/attraction_model.dart';
import '../../models/city_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/attraction_card.dart';
import 'attraction_detail_screen.dart';

/// Full listing for a city, optionally pre-filtered to one category.
/// Reached from Explore's "See all" links and category icons.
class CategoryListingScreen extends StatefulWidget {
  final CityModel city;
  final AttractionCategory? initialCategory;

  const CategoryListingScreen({super.key, required this.city, this.initialCategory});

  @override
  State<CategoryListingScreen> createState() => _CategoryListingScreenState();
}

class _CategoryListingScreenState extends State<CategoryListingScreen> {
  final _firestoreService = FirestoreService();
  late AttractionCategory? _selectedCategory = widget.initialCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.city.name)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _CategoryChip(
                    label: 'All',
                    selected: _selectedCategory == null,
                    onTap: () => setState(() => _selectedCategory = null),
                  ),
                  for (final category in AttractionCategory.values)
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.sm),
                      child: _CategoryChip(
                        label: _labelFor(category),
                        selected: _selectedCategory == category,
                        onTap: () => setState(() => _selectedCategory = category),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<AttractionModel>>(
              stream: _firestoreService.attractionsForCity(
                widget.city.id,
                categoryFilter: _selectedCategory?.name,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final attractions = snapshot.data!;
                if (attractions.isEmpty) {
                  return const Center(child: Text('Nothing listed here yet.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: attractions.length,
                  itemBuilder: (context, index) {
                    final attraction = attractions[index];
                    return AttractionCard(
                      attraction: attraction,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AttractionDetailScreen(attractionId: attraction.id),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _labelFor(AttractionCategory category) {
    switch (category) {
      case AttractionCategory.attraction:
        return 'Attractions';
      case AttractionCategory.restaurant:
        return 'Restaurants';
      case AttractionCategory.hotel:
        return 'Hotels';
      case AttractionCategory.event:
        return 'Events';
    }
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textPrimary),
    );
  }
}
