/// Represents a document in the top-level `users` collection.
/// The document id equals the Firebase Auth uid.
class AppUser {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final List<String> favoriteAttractionIds;
  final bool notificationsEnabled;
  final String role;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.favoriteAttractionIds = const [],
    this.notificationsEnabled = true,
    this.role = 'user',
  });

  bool get isAdmin => role == 'admin';
  bool get isUser => role == 'user';

  factory AppUser.fromMap(
      String uid,
      Map<String, dynamic> map,
      ) {
    // Supports your old isAdmin field while you migrate
    // existing users to the new role field.
    final role = map['role'] ??
        (map['isAdmin'] == true ? 'admin' : 'user');

    return AppUser(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      favoriteAttractionIds:
      List<String>.from(
        map['favoriteAttractionIds'] ?? const [],
      ),
      notificationsEnabled:
      map['notificationsEnabled'] ?? true,
      role: role,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'favoriteAttractionIds': favoriteAttractionIds,
      'notificationsEnabled': notificationsEnabled,
      'role': role,
    };
  }
}