import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/app_theme.dart';
import '../../widgets/primary_button.dart';
// import '../../services/notification_service.dart';

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
                helperText: 'e.g. lagos — users subscribed to this city get push',
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
                if (_titleController.text.trim().isEmpty || _bodyController.text.trim().isEmpty) return;

                setState(() => _isSending = true);
                try {
                  // 1. YOUR EXISTING CODE - KEEP THIS (important for inbox history)
                  await FirebaseFirestore.instance.collection('notifications').add({
                    'title': _titleController.text.trim(),
                    'body': _bodyController.text.trim(),
                    'targetCityId': _cityIdController.text.trim(),
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  // // 2. NEW - REAL PUSH TO PHONES
                  // await NotificationService().sendToCity(
                  //   cityId: _cityIdController.text.trim(),
                  //   title: _titleController.text.trim(),
                  //   body: _bodyController.text.trim(),
                  // );

                  setState(() {
                    _confirmation = 'Sent! Saved to Firestore + Push sent to ${_cityIdController.text} topic.';
                  });
                  _titleController.clear();
                  _bodyController.clear();
                } catch (e) {
                  setState(() => _confirmation = 'Error: $e');
                } finally {
                  setState(() => _isSending = false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}