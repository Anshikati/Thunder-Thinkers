import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.setCustomParameters({
        'prompt': 'select_account',
      });

      return await _auth.signInWithPopup(googleProvider);
    } else {
      throw UnimplementedError(
        'Mobile Google Sign-In not added yet. Web popup flow only for now.',
      );
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
