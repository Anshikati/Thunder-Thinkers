import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';

class FirestoreUserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create or fetch user profile after Google Sign-In
  /// Returns AppUser with role, or null if role incomplete
  /// Call this immediately after GoogleAuthService.signInWithGoogle()
  Future<AppUser?> createOrFetchGoogleUser({
    required UserCredential credential,
    UserRole? suggestedRole,  // Optional: from login screen selection
  }) async {
    final User? firebaseUser = credential.user;
    if (firebaseUser == null) return null;

    final String uid = firebaseUser.uid;
    final DocumentReference userRef = _firestore.collection('users').doc(uid);
    final DocumentSnapshot snapshot = await userRef.get();

    if (snapshot.exists) {
      // Existing user - fetch profile
      final data = snapshot.data() as Map<String, dynamic>;
      final AppUser user = AppUser.fromJson({...data, 'id': uid});
      
      // Check if role exists
      if (user.role != UserRole.volunteer && user.role != UserRole.ngoAdmin) {
        print('⚠️ User $uid has incomplete role, needs profile completion');
        return null;  // UI should show role selection
      }
      
      print('✅ Existing user loaded: ${user.name} (${user.roleLabel})');
      return user;
      
    } else {
      // New Google user - create minimal profile
      final userData = {
        'uid': uid,
        'name': firebaseUser.displayName ?? 'Google User',
        'email': firebaseUser.email ?? '',
        'photoUrl': firebaseUser.photoURL,
        // role added later via completeProfile()
        'createdAt': FieldValue.serverTimestamp(),
        'lastSignInAt': FieldValue.serverTimestamp(),
        'provider': 'google',
      };

      await userRef.set(userData);
      print('✅ New Google user created: ${firebaseUser.email}');
      
      // Return null to trigger role selection for new users
      return null;
    }
  }

  /// Complete new Google user profile with role
  /// Call after user selects role
  Future<AppUser?> completeGoogleUserProfile({
    required String uid,
    required UserRole role,
    String? name,
    String? phone,
  }) async {
    final userRef = _firestore.collection('users').doc(uid);
    final updates = {
      'role': role.name,
      'phone': phone ?? '',
      'name': name ?? _firestore.collection('users').doc(uid).get().then((doc) => doc['name']),
      'profileCompletedAt': FieldValue.serverTimestamp(),
    };

    await userRef.update(updates);
    
    // Fetch complete user
    final snapshot = await userRef.get();
    final data = snapshot.data() as Map<String, dynamic>;
    return AppUser.fromJson({...data, 'id': uid});
  }

  /// Get current user profile
  Future<AppUser?> getUserByUid(String uid) async {
    try {
      final snapshot = await _firestore.collection('users').doc(uid).get();
      if (!snapshot.exists) return null;
      
      final data = snapshot.data() as Map<String, dynamic>;
      return AppUser.fromJson({...data, 'id': uid});
    } catch (e) {
      print('Error fetching user $uid: $e');
      return null;
    }
  }

  /// Update user profile (safe partial updates)
  Future<void> updateUserProfile(String uid, Map<String, dynamic> updates) async {
    await _firestore.collection('users').doc(uid).update(updates);
  }
}
