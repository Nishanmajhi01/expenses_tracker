import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? currentUser;

  // Signup method
  Future<User?> signup(String email, String password, String fullName) async {
    final credential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    // Update the display name of the user
    await credential.user?.updateDisplayName(fullName);

    currentUser = credential.user;
    notifyListeners(); // notify the UI
    return currentUser;
  }

  // Login method
  Future<User?> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);

    currentUser = credential.user;
    notifyListeners();
    return currentUser;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    currentUser = null;
    notifyListeners();
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
