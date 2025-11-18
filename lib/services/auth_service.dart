import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? currentUser;

  AuthService() {
    // Listen to auth state changes (helps auto-login)
    _auth.authStateChanges().listen((user) {
      currentUser = user;
      notifyListeners();
    });
  }

  // ------------------------------
  // SIGNUP + Save User in Firestore
  // ------------------------------
  Future<User?> signup(String email, String password, String fullName) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    currentUser = credential.user;

    // Update display name in FirebaseAuth
    await currentUser?.updateDisplayName(fullName);

    // Create AppUser for Firestore
    final userModel = AppUser(
      uid: currentUser!.uid,
      fullName: fullName,
      email: email,
      profileImageUrl: null, // default → no image
      monthlyBudget: null,
      currency: "AUD",
      darkModeEnabled: false,
      createdAt: DateTime.now(),
    );

    // Save to Firestore
    await _firestore.collection("users").doc(currentUser!.uid).set(
          userModel.toMap(),
        );

    notifyListeners();
    return currentUser;
  }

  // ------------------------------
  // LOGIN
  // ------------------------------
  Future<User?> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    currentUser = credential.user;
    notifyListeners();
    return currentUser;
  }

  // ------------------------------
  // LOGOUT
  // ------------------------------
  Future<void> signOut() async {
    await _auth.signOut();
    currentUser = null;
    notifyListeners();
  }

  // ------------------------------
  // RESET PASSWORD
  // ------------------------------
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ------------------------------
  // FETCH USER PROFILE (FOR PROFILE PAGE)
  // ------------------------------
  Future<AppUser?> getCurrentUserProfile() async {
    if (currentUser == null) return null;

    final doc =
        await _firestore.collection("users").doc(currentUser!.uid).get();

    if (!doc.exists) return null;

    return AppUser.fromMap(doc.data()!);
  }
}