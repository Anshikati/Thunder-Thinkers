import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<AppUser?> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      final User? user = cred.user;
      if (user == null) return null;

      final DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      return AppUser.fromJson({...data, 'id': user.uid});
    } on FirebaseAuthException catch (e) {
      throw Exception(_errorMessage(e.code));
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<AppUser?> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    try {
      final UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      final User? user = cred.user;
      if (user == null) return null;

      // Ignore phone for task; use required fields only
      final userData = {
        'uid': user.uid,
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'role': role.name,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(user.uid).set(userData);

      return AppUser(
        id: user.uid,
        name: name.trim(),
        email: email.trim().toLowerCase(),
        phone: phone, // Keep for compatibility
        role: role,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_errorMessage(e.code));
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<AppUser?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>;
      return AppUser.fromJson({...data, 'id': user.uid});
    } catch (e) {
      throw Exception('Failed to fetch current user: $e');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  String _errorMessage(String code) {
    switch (code) {
      case 'invalid-email': return 'Invalid email address';
      case 'user-not-found': return 'No user found for that email';
      case 'wrong-password': return 'Wrong password';
      case 'email-already-in-use': return 'Email already in use';
      case 'weak-password': return 'Password too weak';
      case 'too-many-requests': return 'Too many requests';
      default: return 'Authentication error: $code';
    }
  }
}
