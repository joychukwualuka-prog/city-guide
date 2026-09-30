/// Represents a document in the top-level `users` collection.
/// The document id equals the Firebase Auth uid.
class AppUser {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final List<String> favoriteAttractionIds;
  final bool notificationsEnabled;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.favoriteAttractionIds = const [],
    this.notificationsEnabled = true,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      favoriteAttractionIds:
      List<String>.from(map['favoriteAttractionIds'] ?? const []),
      notificationsEnabled: map['notificationsEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'favoriteAttractionIds': favoriteAttractionIds,
      'notificationsEnabled': notificationsEnabled,
    };
  }
}
