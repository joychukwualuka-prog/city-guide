// Wired into MainShell as the Map tab, since google_maps_flutter is
// already in the project's pubspec.yaml.
//
// ONE thing is still required before this will run without crashing:
// a Google Maps API key.
//   1. Google Cloud Console -> enable "Maps SDK for Android" for
//      your project, create/copy an API key.
//   2. Add it to android/app/src/main/AndroidManifest.xml inside the
//      <application> tag:
//        <meta-data android:name="com.google.android.geo.API_KEY"
//                   android:value="YOUR_KEY_HERE" />
// Without step 2, this screen will show a blank gray map or crash
// with a Maps API error — that's a config issue, not a code bug, if
// it happens.

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  GoogleMapController? _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.city.name} — Map')),
      body: StreamBuilder<List<AttractionModel>>(
        stream: _firestoreService.attractionsForCity(widget.city.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final attractions = snapshot.data!;
          final markers = attractions
              .map((a) => Marker(
            markerId: MarkerId(a.id),
            position: LatLng(a.location.latitude, a.location.longitude),
            infoWindow: InfoWindow(
              title: a.name,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AttractionDetailScreen(attractionId: a.id),
                ),
              ),
            ),
          ))
              .toSet();

          final initialTarget = attractions.isNotEmpty
              ? LatLng(attractions.first.location.latitude, attractions.first.location.longitude)
              : const LatLng(0, 0);

          return GoogleMap(
            initialCameraPosition: CameraPosition(target: initialTarget, zoom: 12),
            markers: markers,
            onMapCreated: (controller) => _controller = controller,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
