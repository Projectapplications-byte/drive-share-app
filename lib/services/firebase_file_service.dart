import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/app_config.dart';
import '../models/recent_file.dart';
import '../models/secure_detail.dart';

class FirebaseFileService {
  FirebaseFileService({
    this.config = const FirebaseDatabaseConfig(),
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance;

  final FirebaseDatabaseConfig config;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  Future<User> ensureSignedIn() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) return currentUser;

    try {
      final credential = await _auth.signInAnonymously();
      final user = credential.user;
      if (user == null) {
        throw StateError('Firebase did not return a user session.');
      }
      return user;
    } on FirebaseAuthException catch (error) {
      throw StateError(_authSetupMessage(error));
    }
  }

  Future<void> uploadRecentFile(RecentFile file) async {
    final user = await ensureSignedIn();
    final localFile = File(file.localPath);
    if (!await localFile.exists()) {
      throw StateError(
        'Cannot sync "${file.name}" because the local file is missing.',
      );
    }

    final storagePath = _storagePath(user.uid, file);
    await _saveFirestoreRecord(
      uid: user.uid,
      file: file,
      storagePath: storagePath,
      textContent: await _readTextContentForDatabase(file, localFile),
      storageSynced: false,
    );

    final storageRef = _storage.ref(storagePath);
    try {
      await storageRef.putFile(
        localFile,
        SettableMetadata(
          contentType: file.mimeType,
          customMetadata: <String, String>{
            'recentFileId': file.id,
            'source': 'drive2share',
          },
        ),
      );

      await _filesCollection(user.uid).doc(file.id).set(<String, Object?>{
        'storageSynced': true,
        'storageError': null,
        'storageUpdatedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (error) {
      await _filesCollection(user.uid).doc(file.id).set(<String, Object?>{
        'storageSynced': false,
        'storageError': _storageSetupMessage(error),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> _saveFirestoreRecord({
    required String uid,
    required RecentFile file,
    required String storagePath,
    required String? textContent,
    required bool storageSynced,
  }) async {
    try {
      await _filesCollection(uid).doc(file.id).set(<String, Object?>{
        'id': file.id,
        'name': file.name,
        'mimeType': file.mimeType,
        'storagePath': storagePath,
        'storageSynced': storageSynced,
        'storageError': null,
        'localPath': file.localPath,
        'sizeBytes': file.sizeBytes,
        'modifiedAtMillis': file.modifiedAtMillis,
        'importedAtMillis': file.importedAtMillis,
        'textContent': textContent,
        'platform': Platform.operatingSystem,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (error) {
      throw StateError(_firestoreSetupMessage(error));
    }
  }

  Future<String?> _readTextContentForDatabase(
    RecentFile file,
    File localFile,
  ) async {
    final isTextFile =
        file.mimeType.startsWith('text/') ||
        file.name.toLowerCase().endsWith('.txt');
    if (!isTextFile || await localFile.length() > 850000) return null;
    return localFile.readAsString();
  }

  Future<void> deleteRecentFile(RecentFile file) async {
    final user = await ensureSignedIn();
    final storageRef = _storage.ref(_storagePath(user.uid, file));

    try {
      await storageRef.delete();
    } on FirebaseException catch (error) {
      if (error.code != 'object-not-found') {
        await _filesCollection(user.uid).doc(file.id).set(<String, Object?>{
          'storageDeleteError': _storageSetupMessage(error),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    }

    try {
      await _filesCollection(user.uid).doc(file.id).delete();
    } on FirebaseException catch (error) {
      throw StateError(_firestoreSetupMessage(error));
    }
  }

  Future<void> saveSecureDetail(SecureDetail detail) async {
    final user = await ensureSignedIn();
    final row = <String, Object?>{
      ...detail.toFirestoreFields(),
      'userId': user.uid,
      'platform': Platform.operatingSystem,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      await _secureDetailsCollection(
        user.uid,
        detail.type,
      ).doc(detail.id).set(row, SetOptions(merge: true));

      if (config.enableTableCollections) {
        await _secureDetailsTableCollection(
          detail.type,
        ).doc(detail.id).set(row, SetOptions(merge: true));
      }
    } on FirebaseException catch (error) {
      throw StateError(_firestoreSetupMessage(error));
    }
  }

  Future<void> deleteSecureDetail(SecureDetail detail) async {
    final user = await ensureSignedIn();
    try {
      await _secureDetailsCollection(
        user.uid,
        detail.type,
      ).doc(detail.id).delete();
      if (config.enableTableCollections) {
        await _secureDetailsTableCollection(
          detail.type,
        ).doc(detail.id).delete();
      }
    } on FirebaseException catch (error) {
      throw StateError(_firestoreSetupMessage(error));
    }
  }

  CollectionReference<Map<String, dynamic>> _filesCollection(String uid) {
    return _firestore
        .collection(config.userCollection)
        .doc(uid)
        .collection('files');
  }

  CollectionReference<Map<String, dynamic>> _secureDetailsCollection(
    String uid,
    SecureDetailType type,
  ) {
    final collection = switch (type) {
      SecureDetailType.bank => config.bankDetailsCollection,
      SecureDetailType.aadhaar => config.aadhaarDetailsCollection,
      SecureDetailType.pan => config.panDetailsCollection,
      SecureDetailType.passport => config.passportDetailsCollection,
      SecureDetailType.drivingLicense => config.drivingLicenseDetailsCollection,
      SecureDetailType.voterId => config.voterIdDetailsCollection,
      SecureDetailType.upi => config.upiDetailsCollection,
      SecureDetailType.login => config.loginDetailsCollection,
      SecureDetailType.address => config.addressDetailsCollection,
    };
    return _firestore
        .collection(config.userCollection)
        .doc(uid)
        .collection(collection);
  }

  CollectionReference<Map<String, dynamic>> _secureDetailsTableCollection(
    SecureDetailType type,
  ) {
    final collection = switch (type) {
      SecureDetailType.bank => config.bankDetailsTableCollection,
      SecureDetailType.aadhaar => config.aadhaarDetailsTableCollection,
      SecureDetailType.pan => config.panDetailsTableCollection,
      SecureDetailType.passport => config.passportDetailsTableCollection,
      SecureDetailType.drivingLicense =>
        config.drivingLicenseDetailsTableCollection,
      SecureDetailType.voterId => config.voterIdDetailsTableCollection,
      SecureDetailType.upi => config.upiDetailsTableCollection,
      SecureDetailType.login => config.loginDetailsTableCollection,
      SecureDetailType.address => config.addressDetailsTableCollection,
    };
    return _firestore.collection(collection);
  }

  String _storagePath(String uid, RecentFile file) {
    return 'users/$uid/files/${file.id}/${file.name}';
  }

  String _authSetupMessage(FirebaseAuthException error) {
    if (error.code == 'operation-not-allowed') {
      return 'Firebase Anonymous Authentication is not enabled. Open Firebase Console > Authentication > Sign-in method > Anonymous, then enable it.';
    }
    return 'Firebase sign-in failed: ${error.code}. ${error.message ?? ''}'
        .trim();
  }

  String _firestoreSetupMessage(FirebaseException error) {
    if (error.code == 'permission-denied') {
      return 'Firestore permission denied. Publish Firestore rules that allow authenticated users to write users/{uid}/files.';
    }
    if (error.code == 'unavailable') {
      return 'Firestore is unavailable. Check internet connection and make sure Cloud Firestore is created in Firebase Console.';
    }
    return 'Firestore save failed: ${error.code}. ${error.message ?? ''}'
        .trim();
  }

  String _storageSetupMessage(FirebaseException error) {
    if (error.code == 'unauthorized') {
      return 'Storage permission denied. Publish Storage rules that allow authenticated users to write users/{uid}/files.';
    }
    if (error.code == 'bucket-not-found') {
      return 'Firebase Storage bucket was not found. Create/enable Storage in Firebase Console and download the latest google-services.json.';
    }
    if (error.code == 'quota-exceeded') {
      return 'Firebase Storage quota exceeded.';
    }
    return 'Storage upload failed: ${error.code}. ${error.message ?? 'Unknown error.'}';
  }
}
