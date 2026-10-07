// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:provider/provider.dart';
//
// import '../../core/app_theme.dart';
// import '../../providers/auth_provider.dart';
// import 'manage_listings_screen.dart';
// import 'send_notification_screen.dart';
// import 'manage_reviews_screen.dart';
//
// /// Reachable only from Profile when the signed-in user's Firestore
// /// doc has isAdmin: true. Overview counts are live reads against
// /// Firestore's aggregate count API (cheap — one read per card, not
// /// one read per document).
// class AdminDashboardScreen extends StatelessWidget {
//   const AdminDashboardScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final db = FirebaseFirestore.instance;
//
//     return Scaffold(
//       backgroundColor: AppColors.primaryDark,
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryDark,
//         foregroundColor: Colors.white,
//         title: const Text('Admin Dashboard'),
//         iconTheme: const IconThemeData(color: Colors.white),
//         actions: [
//           IconButton(
//             tooltip: 'Log Out',
//             icon: const Icon(Icons.logout),
//             onPressed: () async {
//               await context.read<AuthProvider>().service.signOut();
//             },
//           ),
//         ],
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           color: AppColors.background,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//         ),
//         margin: const EdgeInsets.only(top: 8),
//         child: ListView(
//           padding: const EdgeInsets.all(AppSpacing.md),
//           children: [
//             GridView.count(
//               crossAxisCount: 2,
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               mainAxisSpacing: AppSpacing.md,
//               crossAxisSpacing: AppSpacing.md,
//               childAspectRatio: 1.6,
//               children: [
//                 _CountCard(
//                   icon: Icons.list_alt,
//                   label: 'Total Listings',
//                   future: db.collection('attractions').count().get(),
//                 ),
//                 _CountCard(
//                   icon: Icons.people_outline,
//                   label: 'Total Users',
//                   future: db.collection('users').count().get(),
//                 ),
//               ],
//             ),
//             const SizedBox(height: AppSpacing.lg),
//             const Text('Manage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//             const SizedBox(height: AppSpacing.sm),
//             Card(
//               child: Column(
//                 children: [
//                   ListTile(
//                     leading: const Icon(Icons.list_alt),
//                     title: const Text('Listings'),
//                     subtitle: const Text('Add, edit or remove attractions'),
//                     trailing: const Icon(Icons.chevron_right),
//                     onTap: () => Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const ManageListingsScreen()),
//                     ),
//                   ),
//                   const Divider(height: 1),
//                   ListTile(
//                     leading: const Icon(Icons.campaign_outlined),
//                     title: const Text('Notifications'),
//                     subtitle: const Text('Send an announcement to a city'),
//                     trailing: const Icon(Icons.chevron_right),
//                     onTap: () => Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const SendNotificationScreen()),
//                     ),
//                   ),
//                   const Divider(height: 1),
//                   ListTile(
//                     leading: const Icon(Icons.reviews_outlined),
//                     title: const Text('Reviews'),
//                     subtitle: const Text('Moderate reported reviews'),
//                     trailing: const Icon(Icons.chevron_right),
//                     onTap: () => Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const ManageReviewsScreen(),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _CountCard extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final Future<AggregateQuerySnapshot> future;
//
//   const _CountCard({required this.icon, required this.label, required this.future});
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(AppSpacing.md),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Icon(icon, color: AppColors.primary),
//             const Spacer(),
//             FutureBuilder<AggregateQuerySnapshot>(
//               future: future,
//               builder: (context, snapshot) {
//                 final count = snapshot.data?.count?.toString() ?? '—';
//                 return Text(count, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold));
//               },
//             ),
//             Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'manage_listings_screen.dart';
import 'send_notification_screen.dart';
import 'manage_reviews_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Column(
        children: [
          // DARK HEADER - Like your desired UI
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
            decoration: const BoxDecoration(
              color: AppColors.primaryDark,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.map, color: AppColors.primaryDark, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('City Guide', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Admin Dashboard', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Log Out',
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () async {
                        await context.read<AuthProvider>().service.signOut();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildNavItem(Icons.dashboard, 'Overview', true, () {}),
                _buildNavItem(Icons.list_alt, 'Listings', false, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageListingsScreen()));
                }),
                _buildNavItem(Icons.reviews_outlined, 'Reviews', false, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageReviewsScreen()));
                }),
                _buildNavItem(Icons.campaign_outlined, 'Notifications', false, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SendNotificationScreen()));
                }),
                _buildNavItem(Icons.article_outlined, 'Content', false, () {}),
              ],
            ),
          ),

          // WHITE BODY - No more overflow because of Expanded + SingleChildScrollView
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 4 STATS LIKE YOUR DESIRED IMAGE
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      childAspectRatio: 1.55,
                      children: [
                        _CountCard(
                          icon: Icons.list_alt,
                          label: 'Total Listings',
                          color: Colors.blue,
                          future: db.collection('attractions').count().get(),
                        ),
                        _CountCard(
                          icon: Icons.report_outlined,
                          label: 'Pending Reviews',
                          color: Colors.redAccent,
                          future: db.collection('reviews').where('isReported', isEqualTo: true).count().get(),
                        ),
                        _CountCard(
                          icon: Icons.notifications_active_outlined,
                          label: 'New Notifications',
                          color: Colors.blue,
                          future: db.collection('notifications').count().get(),
                        ),
                        _CountCard(
                          icon: Icons.people_outline,
                          label: 'Total Users',
                          color: Colors.blue,
                          future: db.collection('users').count().get(),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.lg),
                    const Text('Recent Listings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: AppSpacing.sm),

                    // RECENT LISTINGS - Live from Firestore
                    StreamBuilder<QuerySnapshot>(
                      stream: db.collection('attractions').orderBy('createdAt', descending: true).limit(3).snapshots(),
                      builder: (context, snap) {
                        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                        final docs = snap.data!.docs;
                        if (docs.isEmpty) return const Text('No listings yet', style: TextStyle(color: AppColors.textSecondary));
                        return Column(
                          children: docs.map((d) {
                            final data = d.data() as Map<String, dynamic>;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.place, color: AppColors.primary),
                                ),
                                title: Text(data['name'] ?? 'Unnamed', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                subtitle: Text(data['city'] ?? 'active', style: const TextStyle(fontSize: 11)),
                              ),
                            );
                          }).toList(),
                        );
                      },
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
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageListingsScreen())),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.campaign_outlined),
                            title: const Text('Notifications'),
                            subtitle: const Text('Send an announcement to a city'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SendNotificationScreen())),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.reviews_outlined),
                            title: const Text('Reviews'),
                            subtitle: const Text('Moderate reported reviews'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageReviewsScreen())),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildNavItem(IconData icon, String title, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1A4A8A) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? Colors.white : Colors.white70, size: 18),
            const SizedBox(width: 12),
            Text(title, style: TextStyle(color: selected ? Colors.white : Colors.white70, fontSize: 13, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Future<AggregateQuerySnapshot> future;

  const _CountCard({required this.icon, required this.label, required this.color, required this.future});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const Spacer(),
            FutureBuilder<AggregateQuerySnapshot>(
              future: future,
              builder: (context, snapshot) {
                final count = snapshot.data?.count?.toString() ?? '—';
                return Text(count, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold));
              },
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
