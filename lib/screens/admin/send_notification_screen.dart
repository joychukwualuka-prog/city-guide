import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/app_theme.dart';
import '../../widgets/primary_button.dart';

/// Writes a document to a top-level `notifications` collection.
/// NOTE: this writes the announcement to Firestore so it CAN be read
/// by the app (e.g. a future notifications inbox screen) — it does
/// NOT push an actual phone notification. Real push notifications
/// need Firebase Cloud Messaging wired up, which is a separate,
/// bigger piece of setup (server key, device tokens, a Cloud
/// Function to trigger the send) — flagging this now rather than
/// letting the button imply more than it does.
class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _cityIdController = TextEditingController();
  bool _isSending = false;
  String? _confirmation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Notification')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'This saves the announcement to Firestore. It does not yet '
                  'push a real phone notification — that needs Firebase Cloud '
                  'Messaging set up separately.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(labelText: 'Message'),
              maxLines: 4,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _cityIdController,
              decoration: const InputDecoration(
                labelText: 'Target city document ID',
                helperText: 'Must match an existing city doc ID in Firestore',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (_confirmation != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Text(_confirmation!, style: const TextStyle(color: AppColors.primary)),
              ),
            PrimaryButton(
              label: 'Send',
              isLoading: _isSending,
              onPressed: () async {
                setState(() => _isSending = true);
                await FirebaseFirestore.instance.collection('notifications').add({
                  'title': _titleController.text.trim(),
                  'body': _bodyController.text.trim(),
                  'targetCityId': _cityIdController.text.trim(),
                  'createdAt': FieldValue.serverTimestamp(),
                });
                setState(() {
                  _isSending = false;
                  _confirmation = 'Saved to Firestore.';
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
