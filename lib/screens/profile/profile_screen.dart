import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../providers/auth_provider.dart' as app_auth;

class ProfileScreen extends StatelessWidget {
  final VoidCallback onChangeCity;

  const ProfileScreen({
    super.key,
    required this.onChangeCity,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final name =
    user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!
        : 'Explorer';

    final email = user?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          32,
        ),
        children: [
          // --------------------------------------------------
          // PROFILE HEADER
          // --------------------------------------------------

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFE5EAF0),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.chipUnselected,
                  backgroundImage:
                  user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null
                      ? const Icon(
                    Icons.person,
                    color: AppColors.primary,
                    size: 30,
                  )
                      : null,
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --------------------------------------------------
          // EXPLORE
          // --------------------------------------------------

          const _SectionTitle(
            title: 'Explore',
          ),

          const SizedBox(height: 8),

          _ProfileGroup(
            children: [
              _ProfileRow(
                icon: Icons.favorite_border,
                title: 'My Favorites',
                subtitle: 'Places you saved',
                onTap: () {
                  // Favorites is already available
                  // through the bottom navigation.
                },
              ),

              _ProfileRow(
                icon: Icons.notifications_none,
                title: 'Notifications',
                subtitle: 'Manage your alerts',
                onTap: () {},
              ),

              _ProfileRow(
                icon: Icons.tune,
                title: 'Preferences',
                subtitle: 'City, categories and language',
                onTap: () {},
              ),

              _ProfileRow(
                icon: Icons.location_city_outlined,
                title: 'Change City',
                subtitle: 'Explore another city',
                onTap: onChangeCity,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // --------------------------------------------------
          // ACCOUNT
          // --------------------------------------------------

          const _SectionTitle(
            title: 'Account',
          ),

          const SizedBox(height: 8),

          _ProfileGroup(
            children: [
              _ProfileRow(
                icon: Icons.edit_outlined,
                title: 'Edit Profile',
                subtitle: 'Update your personal information',
                onTap: () {},
              ),

              _ProfileRow(
                icon: Icons.lock_outline,
                title: 'Change Password',
                subtitle: 'Update your account password',
                onTap: () {},
              ),

              _ProfileRow(
                icon: Icons.help_outline,
                title: 'Help & Support',
                subtitle: 'Get help with CityGuide',
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 18),

          // --------------------------------------------------
          // LOG OUT
          // --------------------------------------------------

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFE5EAF0),
              ),
            ),
            child: ListTile(
              contentPadding:
              const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 5,
              ),
              leading: const Icon(
                Icons.logout,
                color: AppColors.error,
              ),
              title: const Text(
                'Log Out',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () async {
                await context
                    .read<app_auth.AuthProvider>()
                    .service
                    .signOut();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// SECTION TITLE
// ==========================================================

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

// ==========================================================
// PROFILE GROUP
// ==========================================================

class _ProfileGroup extends StatelessWidget {
  final List<Widget> children;

  const _ProfileGroup({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5EAF0),
        ),
      ),
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
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.chipUnselected,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 21,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }
}