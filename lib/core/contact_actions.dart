// lib/core/contact_actions.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void _showError(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

/// Opens the phone dialer with [phone] filled in.
/// Spaces, dashes and brackets are stripped, "+" is kept.
Future<void> callNumber(BuildContext context, String phone) async {
  final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
  if (cleaned.isEmpty) {
    _showError(context, 'No phone number available.');
    return;
  }

  bool opened = false;
  try {
    opened = await launchUrl(Uri(scheme: 'tel', path: cleaned));
  } catch (_) {
    opened = false;
  }
  if (!opened && context.mounted) {
    _showError(context, 'Could not open the phone app.');
  }
}

/// Opens [url] in the browser. Adds https:// if no scheme is given.
Future<void> openWebsite(BuildContext context, String url) async {
  var value = url.trim();
  if (value.isEmpty) {
    _showError(context, 'No website available.');
    return;
  }
  if (!value.startsWith('http://') && !value.startsWith('https://')) {
    value = 'https://$value';
  }

  final uri = Uri.tryParse(value);
  if (uri == null) {
    _showError(context, 'This website address looks invalid.');
    return;
  }

  bool opened = false;
  try {
    opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    opened = false;
  }
  if (!opened && context.mounted) {
    _showError(context, 'Could not open the website.');
  }
}