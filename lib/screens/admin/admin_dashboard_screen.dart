import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/app_theme.dart';
import 'manage_listings_screen.dart';
import 'send_notification_screen.dart';

/// Reachable only from Profile when the signed-in user's Firestore
/// doc has isAdmin: true. Overview counts are live reads against
/// Firestore's aggregate count API (cheap — one read per card, not
/// one read per document).
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        title: const Text('Admin Dashboard'),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        margin: const EdgeInsets.only(top: 8),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.6,
              children: [
                _CountCard(
                  icon: Icons.list_alt,
                  label: 'Total Listings',
                  future: db.collection('attractions').count().get(),
                ),
                _CountCard(
                  icon: Icons.people_outline,
                  label: 'Total Users',
                  future: db.collection('users').count().get(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('Manage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.list_alt),
                    title: const Text('Listings'),
                    subtitle: const Text('Add, edit or remove attractions'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ManageListingsScreen()),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.campaign_outlined),
                    title: const Text('Notifications'),
                    subtitle: const Text('Send an announcement to a city'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SendNotificationScreen()),
                    ),
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    leading: Icon(Icons.reviews_outlined, color: AppColors.textSecondary),
                    title: Text('Reviews', style: TextStyle(color: AppColors.textSecondary)),
                    subtitle: Text('Moderation — not built yet'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Future<AggregateQuerySnapshot> future;

  const _CountCard({required this.icon, required this.label, required this.future});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary),
            const Spacer(),
            FutureBuilder<AggregateQuerySnapshot>(
              future: future,
              builder: (context, snapshot) {
                final count = snapshot.data?.count?.toString() ?? '—';
                return Text(count, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold));
              },
            ),
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
