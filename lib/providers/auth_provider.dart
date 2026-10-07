import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

/// Listens to Firebase Authentication and loads the
/// matching Firestore AppUser document.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  User? _user;
  AppUser? _appUser;

  bool _isLoadingUser = true;

  StreamSubscription<User?>? _authSubscription;

  AuthProvider(this._authService) {
    _authSubscription =
        _authService.authStateChanges.listen(
          _handleAuthState,
        );
  }

  User? get user => _user;

  AppUser? get appUser => _appUser;

  bool get isLoggedIn => _user != null;

  bool get isLoadingUser => _isLoadingUser;

  bool get isLoadingAppUser => _isLoadingUser;

  bool get isAdmin => _appUser?.isAdmin ?? false;

  bool get isUser => _appUser?.isUser ?? false;

  AuthService get service => _authService;

  Future<void> _handleAuthState(User? user) async {
    _user = user;
    _appUser = null;
    _isLoadingUser = true;

    notifyListeners();

    if (user == null) {
      _isLoadingUser = false;
      notifyListeners();
      return;
    }

    final uid = user.uid;

    try {
      final appUser =
      await _authService.getOrCreateAppUser(user);

      // Make sure the user didn't sign out while
      // Firestore was loading their profile.
      if (_user?.uid != uid) {
        return;
      }

      _appUser = appUser;
    } catch (e) {
      debugPrint(
        'Could not load user profile: $e',
      );
    }

    _isLoadingUser = false;

    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}