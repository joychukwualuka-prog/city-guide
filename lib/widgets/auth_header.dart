import 'package:flutter/material.dart';
import '../core/app_theme.dart';

/// The circle logo + "City Guide" wordmark + screen title/subtitle
/// combo repeated at the top of Login, Register, and Forgot Password
/// in the mockup.
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryDark,
          ),
          child: const Icon(Icons.location_city, color: Colors.white, size: 30),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'City Guide',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.xs),
        Text(subtitle, style: const TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }
}
