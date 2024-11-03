import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:keep_note/Pages/home_screen.dart';
import 'package:keep_note/auth/firebase_auth.dart';
import 'package:keep_note/auth/login.dart';
import 'package:intl/intl.dart';

class SplashService {
  final auth = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;



  static String formatDateTime(DateTime dateTime) {
    // Define your custom format
    final DateFormat formatter = DateFormat('h:mm a d MMMM, y');
    return formatter.format(dateTime);
  }

  Future<void> initializeUserCollection(String userId) async {
    try {
      // Check if user document exists
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        // Create user document with initial metadata
        final current = DateTime.now();
        await _firestore.collection('users').doc(userId).set({
          'createdAt': DateTime.now(),
          'lastLogin': DateTime.now(),
        });

        // Create a welcome note in the user's notes collection
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('notes')
            .add({
          'Title': 'Welcome to Keep Notes!',
          'Content': 'This is your first note. You can create, edit, and organize your notes here.',
          'Pin': 0,
          'Date': formatDateTime(current),
          'Bin': 0,
          'Archive': 0,
          'Hide': 0,
        });
      } else {
        // Update last login time
        await _firestore.collection('users').doc(userId).update({
          'lastLogin': DateTime.now(),
        });
      }
    } catch (e) {
      debugPrint('Error initializing user collection: $e');
    }
  }

  Future<void> isUserLoggedIn(BuildContext context) async {
    if (auth.isUserLoggedIn()) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await initializeUserCollection(userId);
      }

      Timer(const Duration(seconds: 5), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      });
    } else {
      Timer(const Duration(seconds: 5), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      });
    }
  }
}