import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/city_model.dart';
import '../models/attraction_model.dart';
import '../models/review_model.dart';

/// All Firestore reads/writes for cities, attractions and reviews
/// live here so screens just call methods and don't know about
/// collection paths or query syntax.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---- Cities ----

  Stream<List<CityModel>> citiesStream() {
    return _db.collection('cities').orderBy('name').snapshots().map(
          (snap) => snap.docs
          .map((d) => CityModel.fromMap(d.id, d.data()))
          .toList(),
    );
  }

  // ---- Attractions ----

  Stream<List<AttractionModel>> attractionsForCity(
      String cityId, {
        String? categoryFilter,
      }) {
    Query<Map<String, dynamic>> query =
    _db.collection('attractions').where('cityId', isEqualTo: cityId);

    if (categoryFilter != null) {
      query = query.where('category', isEqualTo: categoryFilter);
    }

    return query.snapshots().map(
          (snap) => snap.docs
          .map((d) => AttractionModel.fromMap(d.id, d.data()))
          .toList(),
    );
  }

  Future<AttractionModel?> getAttraction(String attractionId) async {
    final doc = await _db.collection('attractions').doc(attractionId).get();
    if (!doc.exists) return null;
    return AttractionModel.fromMap(doc.id, doc.data()!);
  }

  /// Simple client-side search across name — fine for a student project's
  /// dataset size. At real scale this would move to a search index
  /// (e.g. Algolia) since Firestore has no native full-text search.
  Future<List<AttractionModel>> searchAttractions(String queryText) async {
    final snap = await _db
        .collection('attractions')
        .orderBy('name')
        .startAt([queryText]).endAt(['$queryText\uf8ff']).get();
    return snap.docs
        .map((d) => AttractionModel.fromMap(d.id, d.data()))
        .toList();
  }

  // ---- Reviews (subcollection under each attraction) ----

  Stream<List<ReviewModel>> reviewsForAttraction(String attractionId) {
    return _db
        .collection('attractions')
        .doc(attractionId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => ReviewModel.fromMap(d.id, d.data()))
        .toList());
  }

  Future<void> addReview({
    required String attractionId,
    required double rating,
    required String text,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Must be signed in to leave a review.');

    final attractionRef = _db.collection('attractions').doc(attractionId);

    await _db.runTransaction((tx) async {
      final reviewRef = attractionRef.collection('reviews').doc();
      tx.set(reviewRef, {
        'userId': user.uid,
        'userName': user.displayName ?? 'Anonymous',
        'rating': rating,
        'text': text,
        'likedByUserIds': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Recompute the attraction's running average rating.
      final attractionSnap = await tx.get(attractionRef);
      final data = attractionSnap.data() ?? {};
      final currentCount = (data['ratingCount'] ?? 0) as int;
      final currentAvg = (data['avgRating'] ?? 0).toDouble();
      final newCount = currentCount + 1;
      final newAvg = ((currentAvg * currentCount) + rating) / newCount;

      tx.update(attractionRef, {
        'ratingCount': newCount,
        'avgRating': newAvg,
      });
    });
  }

  Future<void> toggleReviewLike({
    required String attractionId,
    required String reviewId,
    required String userId,
    required bool alreadyLiked,
  }) {
    final reviewRef = _db
        .collection('attractions')
        .doc(attractionId)
        .collection('reviews')
        .doc(reviewId);

    return reviewRef.update({
      'likedByUserIds': alreadyLiked
          ? FieldValue.arrayRemove([userId])
          : FieldValue.arrayUnion([userId]),
    });
  }

  // ---- Favorites (stored on the user doc) ----

  Future<void> toggleFavorite({
    required String userId,
    required String attractionId,
    required bool alreadyFavorited,
  }) {
    final userRef = _db.collection('users').doc(userId);
    return userRef.update({
      'favoriteAttractionIds': alreadyFavorited
          ? FieldValue.arrayRemove([attractionId])
          : FieldValue.arrayUnion([attractionId]),
    });
  }
}