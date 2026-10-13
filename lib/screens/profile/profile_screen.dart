// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:provider/provider.dart';
//
// import '../../core/app_theme.dart';
// import '../../providers/auth_provider.dart' as app_auth;
//
// class ProfileScreen extends StatelessWidget {
//   final VoidCallback onChangeCity;
//
//   const ProfileScreen({
//     super.key,
//     required this.onChangeCity,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//
//     final name =
//     user?.displayName?.trim().isNotEmpty == true
//         ? user!.displayName!
//         : 'Explorer';
//
//     final email = user?.email ?? '';
//
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         backgroundColor: AppColors.background,
//         title: const Text(
//           'My Profile',
//           style: TextStyle(
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.fromLTRB(
//           AppSpacing.md,
//           AppSpacing.sm,
//           AppSpacing.md,
//           32,
//         ),
//         children: [
//           // --------------------------------------------------
//           // PROFILE HEADER
//           // --------------------------------------------------
//
//           Container(
//             padding: const EdgeInsets.all(18),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(
//                 color: const Color(0xFFE5EAF0),
//               ),
//             ),
//             child: Row(
//               children: [
//                 CircleAvatar(
//                   radius: 30,
//                   backgroundColor: AppColors.chipUnselected,
//                   backgroundImage:
//                   user?.photoURL != null
//                       ? NetworkImage(user!.photoURL!)
//                       : null,
//                   child: user?.photoURL == null
//                       ? const Icon(
//                     Icons.person,
//                     color: AppColors.primary,
//                     size: 30,
//                   )
//                       : null,
//                 ),
//
//                 const SizedBox(width: 14),
//
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment:
//                     CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         name,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w700,
//                           color: AppColors.textPrimary,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         email,
//                         style: const TextStyle(
//                           fontSize: 13,
//                           color: AppColors.textSecondary,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 24),
//
//           // --------------------------------------------------
//           // EXPLORE
//           // --------------------------------------------------
//
//           const _SectionTitle(
//             title: 'Explore',
//           ),
//
//           const SizedBox(height: 8),
//
//           _ProfileGroup(
//             children: [
//               _ProfileRow(
//                 icon: Icons.favorite_border,
//                 title: 'My Favorites',
//                 subtitle: 'Places you saved',
//                 onTap: () {
//                   // Favorites is already available
//                   // through the bottom navigation.
//                 },
//               ),
//
//               _ProfileRow(
//                 icon: Icons.notifications_none,
//                 title: 'Notifications',
//                 subtitle: 'Manage your alerts',
//                 onTap: () {},
//               ),
//
//               _ProfileRow(
//                 icon: Icons.tune,
//                 title: 'Preferences',
//                 subtitle: 'City, categories and language',
//                 onTap: () {},
//               ),
//
//               _ProfileRow(
//                 icon: Icons.location_city_outlined,
//                 title: 'Change City',
//                 subtitle: 'Explore another city',
//                 onTap: onChangeCity,
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 24),
//
//           // --------------------------------------------------
//           // ACCOUNT
//           // --------------------------------------------------
//
//           const _SectionTitle(
//             title: 'Account',
//           ),
//
//           const SizedBox(height: 8),
//
//           _ProfileGroup(
//             children: [
//               _ProfileRow(
//                 icon: Icons.edit_outlined,
//                 title: 'Edit Profile',
//                 subtitle: 'Update your personal information',
//                 onTap: () {},
//               ),
//
//               _ProfileRow(
//                 icon: Icons.lock_outline,
//                 title: 'Change Password',
//                 subtitle: 'Update your account password',
//                 onTap: () {},
//               ),
//
//               _ProfileRow(
//                 icon: Icons.help_outline,
//                 title: 'Help & Support',
//                 subtitle: 'Get help with CityGuide',
//                 onTap: () {},
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 18),
//
//           // --------------------------------------------------
//           // LOG OUT
//           // --------------------------------------------------
//
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(18),
//               border: Border.all(
//                 color: const Color(0xFFE5EAF0),
//               ),
//             ),
//             child: ListTile(
//               contentPadding:
//               const EdgeInsets.symmetric(
//                 horizontal: 18,
//                 vertical: 5,
//               ),
//               leading: const Icon(
//                 Icons.logout,
//                 color: AppColors.error,
//               ),
//               title: const Text(
//                 'Log Out',
//                 style: TextStyle(
//                   color: AppColors.error,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               onTap: () async {
//                 await context
//                     .read<app_auth.AuthProvider>()
//                     .service
//                     .signOut();
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ==========================================================
// // SECTION TITLE
// // ==========================================================
//
// class _SectionTitle extends StatelessWidget {
//   final String title;
//
//   const _SectionTitle({
//     required this.title,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       title,
//       style: const TextStyle(
//         fontSize: 15,
//         fontWeight: FontWeight.w700,
//         color: AppColors.textPrimary,
//       ),
//     );
//   }
// }
//
// // ==========================================================
// // PROFILE GROUP
// // ==========================================================
//
// class _ProfileGroup extends StatelessWidget {
//   final List<Widget> children;
//
//   const _ProfileGroup({
//     required this.children,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(
//           color: const Color(0xFFE5EAF0),
//         ),
//       ),
//       child: Column(
//         children: children,
//       ),
//     );
//   }
// }
//
// // ==========================================================
// // PROFILE ROW
// // ==========================================================
//
// class _ProfileRow extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String subtitle;
//   final VoidCallback onTap;
//
//   const _ProfileRow({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       contentPadding: const EdgeInsets.symmetric(
//         horizontal: 16,
//         vertical: 6,
//       ),
//       leading: Container(
//         width: 42,
//         height: 42,
//         decoration: BoxDecoration(
//           color: AppColors.chipUnselected,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Icon(
//           icon,
//           color: AppColors.primary,
//           size: 21,
//         ),
//       ),
//       title: Text(
//         title,
//         style: const TextStyle(
//           fontWeight: FontWeight.w600,
//           fontSize: 15,
//           color: AppColors.textPrimary,
//         ),
//       ),
//       subtitle: Text(
//         subtitle,
//         style: const TextStyle(
//           fontSize: 12,
//           color: AppColors.textSecondary,
//         ),
//       ),
//       trailing: const Icon(
//         Icons.chevron_right,
//         color: AppColors.textSecondary,
//       ),
//       onTap: onTap,
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../providers/auth_provider.dart' as app_auth;

class ProfileScreen extends StatefulWidget {
  final VoidCallback onChangeCity;
  final VoidCallback onOpenFavorites;

  const ProfileScreen({
    super.key,
    required this.onChangeCity,
    required this.onOpenFavorites,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _editProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final nameController = TextEditingController(text: user.displayName ?? '');
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: TextField(
            controller: nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Full name',
              hintText: 'Enter your name',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(dialogContext, name);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    nameController.dispose();
    if (newName == null || newName.trim().isEmpty) return;
    try {
      await user.updateDisplayName(newName.trim());
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {'name': newName.trim()},
        SetOptions(merge: true),
      );
      await user.reload();
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not update profile: $e')));
    }
  }

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;
    final shouldSend = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Text('A password reset link will be sent to ${user.email}.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Send Link')),
          ],
        );
      },
    );
    if (shouldSend != true) return;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password reset link sent to ${user.email}.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not send password reset email: $e')));
    }
  }

  void _openNotifications() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Notifications'),
          content: const Text('CityGuide notifications are enabled for updates related to your selected city.'),
          actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('OK'))],
        );
      },
    );
  }

  void _openPreferences() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Preferences'),
          content: const Text('You can change the city you want to explore from your profile.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                widget.onChangeCity();
              },
              child: const Text('Change City'),
            ),
          ],
        );
      },
    );
  }

  void _openHelpSupport() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Help & Support'),
          content: const Text('Need help using CityGuide?\n\nYou can explore attractions, search for places, view maps, save favorites, and manage your account from the app.'),
          actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close'))],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.trim().isNotEmpty == true ? user!.displayName! : 'Explorer';
    final email = user?.email ?? '';
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.background, title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.w700))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE5EAF0))),
            child: Row(
              children: [
                CircleAvatar(radius: 30, backgroundColor: AppColors.chipUnselected, backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null, child: user?.photoURL == null ? const Icon(Icons.person, color: AppColors.primary, size: 30) : null),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)), const SizedBox(height: 4), Text(email, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)])),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _SectionTitle(title: 'Explore'),
          const SizedBox(height: 8),
          _ProfileGroup(children: [
            _ProfileRow(icon: Icons.favorite_border, title: 'My Favorites', subtitle: 'Places you saved', onTap: widget.onOpenFavorites),
            _ProfileRow(icon: Icons.notifications_none, title: 'Notifications', subtitle: 'Manage your alerts', onTap: _openNotifications),
            _ProfileRow(icon: Icons.tune, title: 'Preferences', subtitle: 'City, categories and language', onTap: _openPreferences),
            _ProfileRow(icon: Icons.location_city_outlined, title: 'Change City', subtitle: 'Explore another city', onTap: widget.onChangeCity),
          ]),
          const SizedBox(height: 24),
          const _SectionTitle(title: 'Account'),
          const SizedBox(height: 8),
          _ProfileGroup(children: [
            _ProfileRow(icon: Icons.edit_outlined, title: 'Edit Profile', subtitle: 'Update your personal information', onTap: _editProfile),
            _ProfileRow(icon: Icons.lock_outline, title: 'Change Password', subtitle: 'Update your account password', onTap: _changePassword),
            _ProfileRow(icon: Icons.help_outline, title: 'Help & Support', subtitle: 'Get help with CityGuide', onTap: _openHelpSupport),
          ]),
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE5EAF0))),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Log Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
              onTap: () async => await context.read<app_auth.AuthProvider>().service.signOut(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) => Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary));
}

class _ProfileGroup extends StatelessWidget {
  final List<Widget> children;
  const _ProfileGroup({required this.children});
  @override
  Widget build(BuildContext context) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE5EAF0))), child: Column(children: children));
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ProfileRow({required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.chipUnselected, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.primary, size: 21)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textPrimary)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}