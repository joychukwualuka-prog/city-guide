import 'package:cloud_firestore/cloud_firestore.dart';

enum AttractionCategory { attraction, restaurant, hotel, event }

AttractionCategory categoryFromString(String value) {
  return AttractionCategory.values.firstWhere(
        (c) => c.name == value,
    orElse: () => AttractionCategory.attraction,
  );
}

double _toDouble(dynamic v) {
  if (v is num) return v.toDouble();
  return double.tryParse('$v') ?? 0;
}

int? _toIntOrNull(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toInt();
  return int.tryParse('$v');
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
  final String website;
  final int? priceLevel;
  final Map<String, String>? weeklyHours;

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
    this.website = '',
    this.priceLevel,
    this.weeklyHours,
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
      avgRating: _toDouble(map['avgRating']),
      ratingCount: _toIntOrNull(map['ratingCount']) ?? 0,
      website: map['website']?.toString() ?? '',
      priceLevel: _toIntOrNull(map['priceLevel']),
      weeklyHours: (map['weeklyHours'] as Map?)?.map((k, v) => MapEntry(k.toString(), v.toString())),
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
      'website': website,
      'priceLevel': priceLevel,
      'weeklyHours': weeklyHours,
    };
  }
}