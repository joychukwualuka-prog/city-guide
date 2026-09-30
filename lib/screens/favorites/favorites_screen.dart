import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/app_theme.dart';
import '../../models/attraction_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/attraction_card.dart';
import '../detail/attraction_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: currentUser == null
          ? const Center(child: Text('Log in to save favorites.'))
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .snapshots(),
        builder: (context, userSnap) {
          if (!userSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final ids = List<String>.from(
            userSnap.data!.data()?['favoriteAttractionIds'] ?? const [],
          );
          if (ids.isEmpty) {
            return const Center(child: Text('No favorites saved yet.'));
          }
          return FutureBuilder<List<AttractionModel?>>(
            future: Future.wait(ids.map(firestoreService.getAttraction)),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final attractions = snapshot.data!.whereType<AttractionModel>().toList();
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: attractions.length,
                itemBuilder: (context, index) {
                  final a = attractions[index];
                  return AttractionCard(
                    attraction: a,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AttractionDetailScreen(attractionId: a.id),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
