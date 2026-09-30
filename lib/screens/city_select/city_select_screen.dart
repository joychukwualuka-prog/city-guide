import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/app_theme.dart';
import '../../models/city_model.dart';
import '../../services/firestore_service.dart';

class CitySelectScreen extends StatefulWidget {
  final ValueChanged<CityModel> onCitySelected;

  const CitySelectScreen({super.key, required this.onCitySelected});

  @override
  State<CitySelectScreen> createState() => _CitySelectScreenState();
}

class _CitySelectScreenState extends State<CitySelectScreen> {
  final _firestoreService = FirestoreService();
  final _searchController = TextEditingController();

  String _query = '';
  CityModel? _selected;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Your City')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Choose the city you want to explore.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search for a city...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _query = value.trim().toLowerCase();
                });
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: StreamBuilder<List<CityModel>>(
                stream: _firestoreService.citiesStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cloud_off, size: 48, color: AppColors.textSecondary),
                            const SizedBox(height: AppSpacing.md),
                            const Text(
                              'Unable to load cities.',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              '${snapshot.error}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final cities = snapshot.data ?? [];
                  final filteredCities = cities.where((city) {
                    return city.name.toLowerCase().contains(_query) ||
                        city.country.toLowerCase().contains(_query);
                  }).toList();

                  if (filteredCities.isEmpty) {
                    return const Center(child: Text('No cities found.', textAlign: TextAlign.center));
                  }

                  return ListView.separated(
                    itemCount: filteredCities.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final city = filteredCities[index];
                      final isSelected = _selected?.id == city.id;
                      return _CityRow(
                        city: city,
                        isSelected: isSelected,
                        onTap: () => setState(() => _selected = city),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: _selected == null ? null : () => widget.onCitySelected(_selected!),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CityRow extends StatelessWidget {
  final CityModel city;
  final bool isSelected;
  final VoidCallback onTap;

  const _CityRow({required this.city, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFEBEFEF),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 56,
                height: 56,
                child: CachedNetworkImage(
                  imageUrl: city.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: Colors.black12,
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: Colors.black12,
                    child: const Icon(Icons.location_city),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(city.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(city.country, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.chevron_right,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
