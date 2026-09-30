import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/app_theme.dart';
import 'models/city_model.dart';
import 'providers/auth_provider.dart';
import 'services/auth_service.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/city_select/city_select_screen.dart';
import 'widgets/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const _Bootstrap());
}

/// Shows Firebase initialization errors instead of a blank screen.
class _Bootstrap extends StatelessWidget {
  const _Bootstrap();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Firebase failed to initialize:\n${snapshot.error}',
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return const CityGuideApp();
      },
    );
  }
}

class CityGuideApp extends StatelessWidget {
  const CityGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            AuthService(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'City Guide',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AuthGate(),
      ),
    );
  }
}

/// Controls the main authentication/city flow:
///
/// Logged out
///     ↓
/// Splash → Login
///
/// Logged in + no city
///     ↓
/// City Select
///
/// Logged in + city selected
///     ↓
/// Main App
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  CityModel? _city;

  @override
  Widget build(BuildContext context) {
    final isLoggedIn =
        context.watch<AuthProvider>().isLoggedIn;

    // ------------------------------------------------------
    // LOGGED OUT
    // ------------------------------------------------------

    if (!isLoggedIn) {
      _city = null;

      return const SplashScreen();
    }

    // ------------------------------------------------------
    // LOGGED IN BUT NO CITY SELECTED
    // ------------------------------------------------------

    if (_city == null) {
      return CitySelectScreen(
        onCitySelected: (city) {
          setState(() {
            _city = city;
          });
        },
      );
    }

    // ------------------------------------------------------
    // LOGGED IN + CITY SELECTED
    // ------------------------------------------------------

    return MainShell(
      city: _city!,
      onChangeCity: () {
        setState(() {
          _city = null;
        });
      },
    );
  }
}