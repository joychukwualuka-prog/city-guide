import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openDirections(
    BuildContext context, {
      required double lat,
      required double lng,
      String? label,
    }) async {
  final uri = Uri.https(
    'www.openstreetmap.org',
    '/directions',
    {
      'to': '$lat,$lng',
    },
  );

  try {
    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open directions.'),
        ),
      );
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open directions.'),
        ),
      );
    }
  }
}