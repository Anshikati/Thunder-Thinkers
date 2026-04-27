import '../models/app_user.dart';

class FirebaseAuthService {
  Future<AppUser?> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    // Authenticate with Firebase Auth signInWithEmailAndPassword,
    // fetch AppUser doc from users collection by uid, return AppUser
    return null;
  }

  Future<AppUser?> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    // Create Firebase Auth user with createUserWithEmailAndPassword,
    // create new doc in users collection with all AppUser fields,
    // return AppUser with generated uid as id
    return null;
  }

  Future<void> logout() async {
    // Call FirebaseAuth.instance.signOut()
  }
}
