import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/app_user.dart';

/// Handles Firebase Authentication and the matching
/// users/{uid} Firestore document.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // ----------------------------------------------------------
  // REGISTER
  // ----------------------------------------------------------

  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential =
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user?.updateDisplayName(name);

    await _db.collection('users').doc(credential.user!.uid).set({
      'name': name,
      'email': email,
      'photoUrl': null,
      'favoriteAttractionIds': <String>[],
      'notificationsEnabled': true,

      // Every normal registration starts as a user.
      'role': 'user',

      'createdAt': FieldValue.serverTimestamp(),
    });

    return credential;
  }

  // ----------------------------------------------------------
  // GOOGLE SIGN IN
  // ----------------------------------------------------------

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser =
    await _googleSignIn.signIn();

    if (googleUser == null) {
      return null;
    }

    final GoogleSignInAuthentication googleAuth =
    await googleUser.authentication;

    final OAuthCredential credential =
    GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential =
    await _auth.signInWithCredential(credential);

    final user = userCredential.user;

    if (user != null) {
      final userDoc =
      _db.collection('users').doc(user.uid);

      final snapshot = await userDoc.get();

      if (!snapshot.exists) {
        await userDoc.set({
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'photoUrl': user.photoURL,
          'favoriteAttractionIds': <String>[],
          'notificationsEnabled': true,

          // New Google accounts are also normal users.
          'role': 'user',

          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }

    return userCredential;
  }

  // ----------------------------------------------------------
  // LOGIN
  // ----------------------------------------------------------

  Future<UserCredential> login({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ----------------------------------------------------------
  // GET USER PROFILE FROM FIRESTORE
  // ----------------------------------------------------------

  Future<AppUser> getOrCreateAppUser(User user) async {
    final userRef =
    _db.collection('users').doc(user.uid);

    final snapshot = await userRef.get();

    if (snapshot.exists) {
      return AppUser.fromMap(
        user.uid,
        snapshot.data() ?? {},
      );
    }

    // Safety fallback if an authenticated user somehow
    // doesn't have a Firestore user document.
    final appUser = AppUser(
      uid: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      photoUrl: user.photoURL,
      role: 'user',
    );

    await userRef.set({
      ...appUser.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return appUser;
  }

  // ----------------------------------------------------------
  // PASSWORD RESET
  // ----------------------------------------------------------

  Future<void> sendPasswordResetEmail(
      String email,
      ) {
    return _auth.sendPasswordResetEmail(
      email: email,
    );
  }

  // ----------------------------------------------------------
  // SIGN OUT
  // ----------------------------------------------------------

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ----------------------------------------------------------
  // FRIENDLY AUTH ERRORS
  // ----------------------------------------------------------

  String friendlyError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No account found for that email.';

        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect email or password.';

        case 'email-already-in-use':
          return 'An account with that email already exists.';

        case 'weak-password':
          return 'Password should be at least 6 characters.';

        case 'invalid-email':
          return 'That email address looks invalid.';

        default:
          return error.message ??
              'Something went wrong. Please try again.';
      }
    }

    return 'Something went wrong. Please try again.';
  }
}