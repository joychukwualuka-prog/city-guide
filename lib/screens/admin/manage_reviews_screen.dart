import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/app_theme.dart';

class ManageReviewsScreen extends StatelessWidget {
  const ManageReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        title: const Text('Manage Reviews'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: db.collectionGroup('reviews').where('isReported', isEqualTo: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Could not load reported reviews.\n${snapshot.error}', textAlign: TextAlign.center),
              ),
            );
          }
          final reviews = snapshot.data?.docs ?? [];
          if (reviews.isEmpty) {
            return const Center(
              child: Text('No reported reviews.', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final review = reviews[index];
              final data = review.data() as Map<String, dynamic>;
              final userName = data['userName'] ?? 'Unknown user';
              final text = data['text'] ?? '';
              final rating = (data['rating'] ?? 0).toDouble();
              final reportCount = data['reportCount'] ?? 0;
              final isFlagged = data['isFlagged'] ?? false;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                          Text('${rating.toStringAsFixed(1)} ★'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(text),
                      const SizedBox(height: 10),
                      Text('Reports: $reportCount', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                await review.reference.update({'isFlagged': !isFlagged});
                              },
                              icon: Icon(isFlagged ? Icons.flag_circle : Icons.outlined_flag),
                              label: Text(isFlagged ? 'Unflag' : 'Flag'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await review.reference.delete();
                              },
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Delete'),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}