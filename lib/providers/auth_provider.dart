import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

/// Listens to FirebaseAuth's auth state stream and exposes the
/// current user to the rest of the app. AuthGate (see main.dart)
/// watches [user] to decide whether to show the login flow or
/// the main app.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  User? _user;

  AuthProvider(this._authService) {
    _authService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  AuthService get service => _authService;
}
