import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:keep_note/services/model.dart';
import 'package:keep_note/splash/splash_service.dart';

class FirebaseController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Model> detailList = <Model>[];

  // Get the current user's collection reference with proper type annotation
  CollectionReference<Map<String, dynamic>> get _userNotesCollection {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notes')
        .withConverter<Map<String, dynamic>>(
          fromFirestore: (snapshot, _) => snapshot.data()!,
          toFirestore: (data, _) => data,
        );
  }

  Future<int> getRecordCount() async {
    try {
      var snapshot = await _userNotesCollection.get();

      detailList = snapshot.docs.map((doc) {
        final data = doc.data();
        return Model(
          id: doc.id,
          title: data['Title'] ?? '',
          content: data['Content'] ?? '',
          pin: data['Pin'] ?? 0,
          archive: data['Archive'] ?? 0,
          bin: data['Bin'] ?? 0,
          date: data['Date'] ?? '',
          hide: data['Hide'] ?? 0,
        );
      }).toList();

      debugPrint('Total records: ${detailList.length}');
      return detailList.length;
    } catch (e) {
      debugPrint('Error reading notes: $e');
      rethrow;
    }
  }

  // CREATE Operation
  Future<String> insert(int pin, String title, String content, int bin,
      int archive, int hide) async {
    try {
      final current = DateTime.now();
      String id = _userNotesCollection.doc().id;
      await _userNotesCollection.doc(id).set({
        'Id': id,
        'Pin': pin,
        'Date': SplashService.formatDateTime(current),
        'Title': title,
        'Content': content,
        'Bin': bin,
        'Archive': archive,
        'Hide': hide
      });
      debugPrint('Insert successful');
      return 'Success';
    } catch (e) {
      debugPrint('Error inserting data: $e');
      return 'Failed';
    }
  }

  // UPDATE Operation
  Future<String> update(String docId, Map<String, dynamic> data) async {
    try {
      await _userNotesCollection.doc(docId).update(data);
      debugPrint('Update successful');
      return 'Success';
    } catch (e) {
      debugPrint('Error updating data: $e');
      return 'Failed';
    }
  }

  // SEARCH Operation
  Future<List<Model>> search(String query) async {
    try {
      final querySnapshot =
          await _userNotesCollection.where('Title', isEqualTo: query).get();

      if (querySnapshot.docs.isEmpty) {
        debugPrint('No data found');
        return [];
      }

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Model.fromFirestore(data);
      }).toList();
    } catch (e) {
      debugPrint('Error searching data: $e');
      throw Exception('Error searching data');
    }
  }

  Future<List<Model>> fetchNotesCategory(String category) async {
    try {
      // Create properly typed query
      Query<Map<String, dynamic>> query;

      debugPrint('Fetching notes for category: $category');

      // Initialize the base query
      query = _userNotesCollection;

      // Add the where clause based on category
      if (category == 'Pin') {
        query = query.where('Pin', isEqualTo: 1);
      } else if (category == 'Bin') {
        query = query.where('Bin', isEqualTo: 1);
      } else if (category == 'Archive') {
        query = query.where('Archive', isEqualTo: 1);
      } else if (category == 'Hide') {
        query = query.where('Hide', isEqualTo: 1);
      }

      final querySnapshot = await query.get();

      debugPrint('Query results count: ${querySnapshot.docs.length}');
      if (querySnapshot.docs.isNotEmpty) {
        debugPrint('First document data: ${querySnapshot.docs.first.data()}');
      }

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Model.fromFirestore(data);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching data: $e');
      rethrow;
    }
  }

  Future<List<Model>> fetchNotesWherePinBinArchiveZero() async {
    try {
      debugPrint('Fetching notes where Pin=0, Bin=0, Archive=0');

      final querySnapshot = await _userNotesCollection
          .where('Pin', isEqualTo: 0)
          .where('Bin', isEqualTo: 0)
          .where('Archive', isEqualTo: 0)
          .where('Hide', isEqualTo: 0)
          .get();

      debugPrint('Query results count: ${querySnapshot.docs.length}');
      if (querySnapshot.docs.isNotEmpty) {
        debugPrint('First document data: ${querySnapshot.docs.first.data()}');
      }

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Model.fromFirestore(data);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching data: $e');
      rethrow;
    }
  }

  Future<String> deleteRecord(String id) async {
    try {
      await _userNotesCollection.doc(id).delete();
      debugPrint('Delete successful');
      return 'Success';
    } catch (e) {
      debugPrint('Error deleting data: $e');
      return 'Failed';
    }
  }
}
