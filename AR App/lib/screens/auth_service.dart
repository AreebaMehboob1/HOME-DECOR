import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current user state
  User? _user;
  bool _initialized = false;

  AuthService() {
    // Listen to authentication state changes
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      _initialized = true;
      notifyListeners();
    });
  }

  // Getters
  User? get currentUser => _user;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _initialized;
  bool get isEmailVerified => _user?.emailVerified ?? false;

  // Check if user is verified and update Firestore
  Future<bool> checkAndUpdateVerificationStatus() async {
    if (_user == null) return false;

    // Reload user to get latest email verification status
    await _user!.reload();
    _user = _auth.currentUser;

    if (_user != null && _user!.emailVerified) {
      // Update user's Firestore record
      await _firestore.collection('users').doc(_user!.uid).update({
        'emailVerified': true,
        'lastLogin': FieldValue.serverTimestamp(),
      });
      return true;
    }
    return false;
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    if (_user != null && !_user!.emailVerified) {
      return await _user!.sendEmailVerification();
    }
  }

  // Sign out
  Future<void> signOut() async {
    return await _auth.signOut();
  }

  // Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    return await _auth.sendPasswordResetEmail(email: email);
  }
}
