import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:keep_note/auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Check if user is logged in
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null;

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Skip authentication (anonymous sign-in)
  Future<UserCredential?> skipAuth() async {
    try {
      // Create an anonymous user
      UserCredential userCredential = await _auth.signInAnonymously();

      // Optional: Save a flag in SharedPreferences to indicate skipped auth
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('skipped_auth', true);

      return userCredential;
    } catch (e) {
      debugPrint('Error in anonymous sign-in: $e');
      rethrow;
    }
  }

  // Logout method
  Future<void> logout(BuildContext context) async {
    try {
      // Sign out from Firebase
      await _auth.signOut();

      // Sign out from Google if it was a Google sign-in
      await _googleSignIn.signOut();

      // Optional: Clear any saved authentication-related preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('skipped_auth');

      // Navigate back to login screen
      // Assuming you're using Navigator 2.0
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    } catch (e) {
      // Consider using a more robust logging method
      debugPrint('Error logging out: $e');

      // Show an error dialog to the user
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Logout Error'),
          content: const Text('Unable to log out. Please try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // Listen to authentication state changes
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  // Check if the current authentication is anonymous
  bool isAnonymousUser() {
    return _auth.currentUser?.isAnonymous ?? false;
  }
}
