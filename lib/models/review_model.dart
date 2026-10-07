import 'package:cloud_firestore/cloud_firestore.dart';

/// Lives at attractions/{attractionId}/reviews/{reviewId}.
class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final double rating;
  final String text;
  final List<String> likedByUserIds;
  final DateTime createdAt;

  final bool isReported;
  final bool isFlagged;
  final int reportCount;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.text,
    this.likedByUserIds = const [],
    required this.createdAt,
    this.isReported = false,
    this.isFlagged = false,
    this.reportCount = 0,
  });

  factory ReviewModel.fromMap(
      String id,
      Map<String, dynamic> map,
      ) {
    return ReviewModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      text: map['text'] ?? '',
      likedByUserIds: List<String>.from(
        map['likedByUserIds'] ?? const [],
      ),
      createdAt:
      (map['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      isReported: map['isReported'] ?? false,
      isFlagged: map['isFlagged'] ?? false,
      reportCount: map['reportCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'text': text,
      'likedByUserIds': likedByUserIds,
      'isReported': isReported,
      'isFlagged': isFlagged,
      'reportCount': reportCount,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}