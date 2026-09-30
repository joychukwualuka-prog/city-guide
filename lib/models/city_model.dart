class CityModel {
  final String id;
  final String name;
  final String country;
  final String description;
  final String imageUrl;

  CityModel({
    required this.id,
    required this.name,
    required this.country,
    required this.description,
    required this.imageUrl,
  });

  factory CityModel.fromMap(String id, Map<String, dynamic> map) {
    return CityModel(
      id: id,
      name: map['name'] ?? '',
      country: map['country'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'country': country,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}
