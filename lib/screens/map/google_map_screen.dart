// OpenStreetMap version using flutter_map (no API key, no billing).
// Class name kept as GoogleMapScreen so MainShell doesn't need to change.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_theme.dart';
import '../../core/directions_helper.dart';
import '../../models/attraction_model.dart';
import '../../models/city_model.dart';
import '../../services/firestore_service.dart';
import '../detail/attraction_detail_screen.dart';

class GoogleMapScreen extends StatefulWidget {
  final CityModel city;

  const GoogleMapScreen({super.key, required this.city});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  final _firestoreService = FirestoreService();
  final _mapController = MapController();

  bool _mapReady = false;
  Position? _userPosition;
  AttractionModel? _selected;

  // Fallback centers for the three supported cities.
  static const _cityCenters = {
    'lagos': LatLng(6.5244, 3.3792),
    'abuja': LatLng(9.0765, 7.3986),
    'calabar': LatLng(4.9757, 8.3417),
  };
  static const _nigeriaCenter = LatLng(9.0820, 8.6753);

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  /// Gets the user's position (asks permission if needed).
  /// Returns true when a position was obtained.
  Future<bool> _loadLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showMessage('Location services are turned off.');
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      _showMessage('Location permission denied.');
      return false;
    }
    if (permission == LocationPermission.deniedForever) {
      _showMessage('Location permission is permanently denied. Enable it in Settings.');
      return false;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return false;
      setState(() => _userPosition = position);
      return true;
    } catch (_) {
      _showMessage('Could not get your current location.');
      return false;
    }
  }

  Future<void> _goToMyLocation() async {
    if (_userPosition == null) {
      final ok = await _loadLocation();
      if (!ok) return;
    }
    if (_mapReady && _userPosition != null) {
      _mapController.move(
        LatLng(_userPosition!.latitude, _userPosition!.longitude),
        15,
      );
    }
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  LatLng _initialCenter(List<AttractionModel> attractions) {
    if (attractions.isNotEmpty) {
      final first = attractions.first.location;
      return LatLng(first.latitude, first.longitude);
    }
    return _cityCenters[widget.city.name.trim().toLowerCase()] ?? _nigeriaCenter;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.city.name} — Map')),
      body: StreamBuilder<List<AttractionModel>>(
        stream: _firestoreService.attractionsForCity(widget.city.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load places.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final attractions = snapshot.data!;

          final markers = attractions.map((a) {
            return Marker(
              point: LatLng(a.location.latitude, a.location.longitude),
              width: 44,
              height: 44,
              alignment: Alignment.topCenter,
              child: GestureDetector(
                onTap: () => setState(() => _selected = a),
                child: Icon(
                  Icons.location_pin,
                  size: 44,
                  color: _selected?.id == a.id ? Colors.blue : Colors.red,
                ),
              ),
            );
          }).toList();

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _initialCenter(attractions),
                  initialZoom: 12,
                  onMapReady: () => _mapReady = true,
                  onTap: (_, __) => setState(() => _selected = null),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    // Set this to your app's applicationId (android/app/build.gradle).
                    userAgentPackageName: 'com.example.city_guide',
                  ),
                  if (_userPosition != null)
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: LatLng(_userPosition!.latitude, _userPosition!.longitude),
                          radius: 9,
                          color: Colors.blue,
                          borderColor: Colors.white,
                          borderStrokeWidth: 3,
                        ),
                      ],
                    ),
                  MarkerLayer(markers: markers),
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution(
                        'OpenStreetMap contributors',
                        onTap: () => launchUrl(
                          Uri.parse('https://openstreetmap.org/copyright'),
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                right: 16,
                bottom: _selected != null ? 230 : 24,
                child: FloatingActionButton.small(
                  heroTag: 'my_location',
                  onPressed: _goToMyLocation,
                  child: const Icon(Icons.my_location),
                ),
              ),
              if (_selected != null) _buildSelectedCard(_selected!),
            ],
          );
        },
      ),
    );
  }

  /// Straight-line distance from the user to the place, in km.
  String? _distanceLabel(AttractionModel a) {
    final p = _userPosition;
    if (p == null) return null;
    final meters = Geolocator.distanceBetween(
      p.latitude,
      p.longitude,
      a.location.latitude,
      a.location.longitude,
    );
    return '${(meters / 1000).toStringAsFixed(1)} km away';
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.grey.shade300,
      child: const Icon(Icons.image_outlined, color: Colors.grey),
    );
  }

  Widget _buildSelectedCard(AttractionModel a) {
    final distance = _distanceLabel(a);
    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: a.imageUrls.isNotEmpty
                          ? CachedNetworkImage(
                        imageUrl: a.imageUrls.first,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _imagePlaceholder(),
                        errorWidget: (_, __, ___) => _imagePlaceholder(),
                      )
                          : _imagePlaceholder(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              a.avgRating > 0
                                  ? a.avgRating.toStringAsFixed(1)
                                  : 'No ratings yet',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            if (a.ratingCount > 0)
                              Text(
                                '  (${a.ratingCount})',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.near_me, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                distance ?? 'Tap the location button for distance',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                        if (a.address.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            a.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AttractionDetailScreen(attractionId: a.id),
                        ),
                      ),
                      child: const Text('Details'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.directions),
                      label: const Text('Directions'),
                      onPressed: () => openDirections(
                        context,
                        lat: a.location.latitude,
                        lng: a.location.longitude,
                        label: a.name,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}