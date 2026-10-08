
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

// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:provider/provider.dart';
//
// import 'firebase_options.dart';
// import 'core/app_theme.dart';
// import 'models/city_model.dart';
// import 'providers/auth_provider.dart';
// import 'services/auth_service.dart';
// import 'services/notification_service.dart';
//
// import 'screens/splash/splash_screen.dart';
// import 'screens/city_select/city_select_screen.dart';
// import 'screens/admin/admin_dashboard_screen.dart';
//
// import 'widgets/main_shell.dart';
//
// Future<void> main() async {
// WidgetsFlutterBinding.ensureInitialized();
// runApp(const _Bootstrap());
// }
//
// /// Shows Firebase initialization errors instead of a blank screen.
// class _Bootstrap extends StatelessWidget {
// const _Bootstrap();
//
// @override
// Widget build(BuildContext context) {
// return FutureBuilder(
// future: Firebase.initializeApp(
// options: DefaultFirebaseOptions.currentPlatform,
// ),
// builder: (context, snapshot) {
// if (snapshot.connectionState != ConnectionState.done) {
// return const MaterialApp(
// home: Scaffold(
// body: Center(
// child: CircularProgressIndicator(),
// ),
// ),
// );
// }
//
// if (snapshot.hasError) {
// return MaterialApp(
// home: Scaffold(
// body: Center(
// child: Padding(
// padding: const EdgeInsets.all(24),
// child: Text(
// 'Firebase failed to initialize:\n${snapshot.error}',
// style: const TextStyle(
// color: Colors.red,
// ),
// ),
// ),
// ),
// ),
// );
// }
//
// return const _NotificationBootstrap();
// },
// );
// }
// }
//
// // <-- MOVED OUTSIDE _Bootstrap
// class _NotificationBootstrap extends StatefulWidget {
// const _NotificationBootstrap();
//
// @override
// State<_NotificationBootstrap> createState() => _NotificationBootstrapState();
// }
//
// class _NotificationBootstrapState extends State<_NotificationBootstrap> {
// @override
// void initState() {
// super.initState();
// _initializeNotifications();
// }
//
// Future<void> _initializeNotifications() async {
// final token = await NotificationService().initialize();
// debugPrint('FCM Token: $token');
// }
//
// @override
// Widget build(BuildContext context) {
// return const CityGuideApp();
// }
// }
//
// class CityGuideApp extends StatelessWidget {
// const CityGuideApp({super.key});
//
// @override
// Widget build(BuildContext context) {
// return MultiProvider(
// providers: [
// ChangeNotifierProvider(
// create: (_) => AuthProvider(
// AuthService(),
// ),
// ),
// ],
// child: MaterialApp(
// title: 'City Guide',
// debugShowCheckedModeBanner: false,
// theme: AppTheme.light,
// home: const AuthGate(),
// ),
// );
// }
// }
//
// /// Controls the main authentication/city flow:
// ///
// /// Logged out -> Splash -> Login
// /// Logged in + no city -> City Select
// /// Logged in + city selected -> Main App
// class AuthGate extends StatefulWidget {
// const AuthGate({super.key});
//
// @override
// State<AuthGate> createState() => _AuthGateState();
// }
//
// class _AuthGateState extends State<AuthGate> {
// CityModel? _city;
//
// @override
// Widget build(BuildContext context) {
// final auth = context.watch<AuthProvider>();
//
// // ------------------------------------------------------
// // LOGGED OUT
// // ------------------------------------------------------
// if (!auth.isLoggedIn) {
// _city = null;
// return const SplashScreen();
// }
//
// // ------------------------------------------------------
// // LOGGED IN, BUT STILL LOADING FIRESTORE USER PROFILE
// // ------------------------------------------------------
// if (auth.isLoadingAppUser) {
// return const Scaffold(
// body: Center(
// child: CircularProgressIndicator(),
// ),
// );
// }
//
// // ------------------------------------------------------
// // ADMIN
// // ------------------------------------------------------
// if (auth.isAdmin) {
// _city = null;
//
// return const AdminDashboardScreen();
// }
//
// // ------------------------------------------------------
// // NORMAL USER — NO CITY SELECTED
// // ------------------------------------------------------
// if (_city == null) {
// return CitySelectScreen(
// onCitySelected: (city) {
// setState(() {
// _city = city;
// });
// },
// );
// }
//
// // ------------------------------------------------------
// // NORMAL USER — CITY SELECTED
// // ------------------------------------------------------
// return MainShell(
// city: _city!,
// onChangeCity: () {
// setState(() {
// _city = null;
// });
// },
// );
// }
// }
