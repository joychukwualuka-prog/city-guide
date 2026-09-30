import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../models/attraction_model.dart';
import '../../models/city_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/attraction_card.dart';
import '../detail/attraction_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final CityModel city;

  const SearchScreen({super.key, required this.city});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _firestoreService = FirestoreService();
  final _searchController = TextEditingController();
  String _query = '';
  AttractionCategory? _category;
  double _minRating = 0;
  bool _openNow = false; // UI only for now — no opening-hours-now logic yet

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search attractions, restaurants...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Categories', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    _chip('All', _category == null, () => setState(() => _category = null)),
                    for (final c in AttractionCategory.values)
                      _chip(_labelFor(c), _category == c, () => setState(() => _category = c)),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const Text('Rating', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    _chip('Any', _minRating == 0, () => setState(() => _minRating = 0)),
                    _chip('4+ ★', _minRating == 4, () => setState(() => _minRating = 4)),
                    _chip('3+ ★', _minRating == 3, () => setState(() => _minRating = 3)),
                    _chip('2+ ★', _minRating == 2, () => setState(() => _minRating = 2)),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Open Now', style: TextStyle(fontWeight: FontWeight.w600)),
                    Switch(value: _openNow, onChanged: (v) => setState(() => _openNow = v)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<List<AttractionModel>>(
              stream: _firestoreService.attractionsForCity(
                widget.city.id,
                categoryFilter: _category?.name,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final results = snapshot.data!
                    .where((a) => a.name.toLowerCase().contains(_query))
                    .where((a) => a.avgRating >= _minRating)
                    .toList();
                if (results.isEmpty) {
                  return const Center(child: Text('No matches. Try adjusting your filters.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final attraction = results[index];
                    return AttractionCard(
                      attraction: attraction,
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
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textPrimary),
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
