import 'package:cloud_firestore/cloud_firestore.dart';

/// One category field covers attractions, restaurants, hotels and
/// events, per the spec's "Attraction Listings" requirement, so we
/// don't need four near-identical collections.
enum AttractionCategory { attraction, restaurant, hotel, event }

AttractionCategory categoryFromString(String value) {
  return AttractionCategory.values.firstWhere(
        (c) => c.name == value,
    orElse: () => AttractionCategory.attraction,
  );
}

class AttractionModel {
  final String id;
  final String cityId;
  final String name;
  final AttractionCategory category;
  final String description;
  final List<String> imageUrls;
  final GeoPoint location;
  final String address;
  final String contact;
  final String openingHours;
  final double avgRating;
  final int ratingCount;

  AttractionModel({
    required this.id,
    required this.cityId,
    required this.name,
    required this.category,
    required this.description,
    required this.imageUrls,
    required this.location,
    required this.address,
    required this.contact,
    required this.openingHours,
    this.avgRating = 0,
    this.ratingCount = 0,
  });

  factory AttractionModel.fromMap(String id, Map<String, dynamic> map) {
    return AttractionModel(
      id: id,
      cityId: map['cityId'] ?? '',
      name: map['name'] ?? '',
      category: categoryFromString(map['category'] ?? 'attraction'),
      description: map['description'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? const []),
      location: map['location'] ?? const GeoPoint(0, 0),
      address: map['address'] ?? '',
      contact: map['contact'] ?? '',
      openingHours: map['openingHours'] ?? '',
      avgRating: (map['avgRating'] ?? 0).toDouble(),
      ratingCount: map['ratingCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cityId': cityId,
      'name': name,
      'category': category.name,
      'description': description,
      'imageUrls': imageUrls,
      'location': location,
      'address': address,
      'contact': contact,
      'openingHours': openingHours,
      'avgRating': avgRating,
      'ratingCount': ratingCount,
    };
  }
}
