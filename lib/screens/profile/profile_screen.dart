import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../admin/admin_dashboard_screen.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onChangeCity;

  const ProfileScreen({
    super.key,
    required this.onChangeCity,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // --------------------------------------------------
          // PROFILE HEADER
          // --------------------------------------------------
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.chipUnselected,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? const Icon(
                  Icons.person,
                  color: AppColors.primaryDark,
                  size: 28,
                )
                    : null,
              ),

              const SizedBox(width: AppSpacing.md),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? 'Explorer',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      user?.email ?? '',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // --------------------------------------------------
          // CITY & PREFERENCES
          // --------------------------------------------------
          _SectionCard(
            children: [
              _ProfileRow(
                icon: Icons.location_city,
                label: 'Change City',
                onTap: onChangeCity,
              ),

              _ProfileRow(
                icon: Icons.favorite_border,
                label: 'My Favorites',
                onTap: () {
                  // Favorites screen is already available
                  // through the bottom navigation.
                },
              ),

              _ProfileRow(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                onTap: () {
                  // Notifications settings can be added here later.
                },
              ),

              _ProfileRow(
                icon: Icons.tune,
                label: 'Preferences',
                onTap: () {
                  // Preferences can be added here later.
                },
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // --------------------------------------------------
          // ACCOUNT
          // --------------------------------------------------
          _SectionCard(
            children: [
              _ProfileRow(
                icon: Icons.edit_outlined,
                label: 'Edit Profile',
                onTap: () {
                  // Edit profile screen can be added later.
                },
              ),

              _ProfileRow(
                icon: Icons.lock_outline,
                label: 'Change Password',
                onTap: () {
                  // Password change can be added later.
                },
              ),

              _ProfileRow(
                icon: Icons.help_outline,
                label: 'Help & Support',
                onTap: () {
                  // Help & support can be added later.
                },
              ),

              _ProfileRow(
                icon: Icons.logout,
                label: 'Log Out',
                color: AppColors.error,
                onTap: () async {
                  await context
                      .read<app_auth.AuthProvider>()
                      .service
                      .signOut();
                },
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // --------------------------------------------------
          // ADMIN DASHBOARD
          // --------------------------------------------------
          if (user != null)
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                final data = snapshot.data?.data();

                final isAdmin = data?['isAdmin'] == true;

                if (!isAdmin) {
                  return const SizedBox.shrink();
                }

                return _SectionCard(
                  children: [
                    _ProfileRow(
                      icon: Icons.admin_panel_settings_outlined,
                      label: 'Admin Dashboard',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const AdminDashboardScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

// ==========================================================
// SECTION CARD
// ==========================================================

class _SectionCard extends StatelessWidget {
  final List<Widget> children;

  const _SectionCard({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: children,
      ),
    );
  }
}

// ==========================================================
// PROFILE ROW
// ==========================================================

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? AppColors.textPrimary,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: color,
        ),
      ),
      trailing: color == null
          ? const Icon(Icons.chevron_right)
          : null,
      onTap: onTap,
    );
  }
}