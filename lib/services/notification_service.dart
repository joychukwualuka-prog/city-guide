import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  Future<String?> initialize() async {
    final settings =
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus ==
        AuthorizationStatus.authorized ||
        settings.authorizationStatus ==
            AuthorizationStatus.provisional) {
      return await _messaging.getToken();
    }

    return null;
  }

  Future<void> subscribeToCity(
      String cityId,
      ) async {
    await _messaging.subscribeToTopic(
      'city_$cityId',
    );
  }

  Future<void> unsubscribeFromCity(
      String cityId,
      ) async {
    await _messaging.unsubscribeFromTopic(
      'city_$cityId',
    );
  }
}