import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

import '../../../core/providers/firebase_providers.dart';

class DataUserSource {
  DataUserSource(this._firebaseAuth, this._firebaseFirestore,
      this._firebaseStorage, this._ref);

  final FirebaseAuth _firebaseAuth;
  final FirebaseStorage _firebaseStorage;
  final FirebaseFirestore _firebaseFirestore;
  final Ref _ref;

  Future<Either<String, Map<String, dynamic>>> getDataUser(
    String userId,
  ) async {
    try {
      print("====++++Data user+++=====");
      final FirebaseFirestore db = _firebaseFirestore;
      DocumentReference ref = db.collection('users').doc(userId);

      Map<String, dynamic> userData =
          await ref.get().then((value) => value.data() as Map<String, dynamic>);
      print(userData);
      return right(userData);
    } on FirebaseException catch (e) {
      return left(e.message ?? 'Failed to Get Data.');
    }
  }

  Future<String> ubahPasswordUser({
    required String passwordLama,
    required String passwordbaru,
    required Map<String, dynamic> userData,
  }) async {
    print("====++++Data Password +++=====");
    final FirebaseFirestore db = _firebaseFirestore;
    final instance = FirebaseAuth.instance;
    DocumentReference ref = db.collection('users').doc(userData['uid']);
    UserCredential userCredential;
    print(passwordLama);
    print(userData['email']);
    try {
      userCredential = await instance.signInWithEmailAndPassword(
          email: userData['email'], password: passwordLama);
    } on FirebaseAuthException catch (e) {
      print(e.code);
      if (e.code == 'wrong-password') {
        return 'Password lama salah';
      } else if (e.code == "weak-password") {
        return 'Password terlalu simpel';
      } else {
        return 'Terjadi kesalahan';
      }
    }
    print("DOENEENENEN");

    if (userCredential.user != null) {
      try {
        await userCredential.user!.updatePassword(passwordbaru);
      } on FirebaseAuthException catch (e) {
        print(e.code);
        if (e.code == "weak-password") {
          return 'Password terlalu simpel';
        } else {
          return 'Terjadi kesalahan';
        }
      }
    }
    return 'Sukses mengganti password';
  }

  Future<String> saveFile(
      String userId, String filePath, String dateIMG) async {
    print("====++++Data save file+++=====");
    Reference? profileImagesRef;
    Reference storageRef = _firebaseStorage.ref();

    final fileImage = File(filePath);
    profileImagesRef = storageRef.child("profile_photo/users/${userId}.jpg");
    await profileImagesRef.putFile(fileImage);
    final downloadURL = await profileImagesRef.getDownloadURL();
    print(downloadURL);

    return downloadURL;
  }

  Future<Either<String, String>> saveUser(
      {required String userId,
      String? filePath,
      String? firstname,
      String? phone,
      String? photoURL,
      Map<String, dynamic>? oldUserData}) async {
    print("====++++Data save User+++=====");
    final String dateIMG = DateFormat('yyyy-MM-dd-kk').format(DateTime.now());
    final FirebaseFirestore db = _firebaseFirestore;

    DocumentReference ref = db.collection('users').doc(userId);
    try {
      // DocumentSnapshot doc = await ref.get();
      // if (doc.exists) {
      //   print("Doc Exist");
      //   oldUserData = await ref
      //       .get()
      //       .then((value) => value.data() as Map<String, dynamic>);
      // }

      if (filePath != null) {
        print("GET Image");
        photoURL = await saveFile(userId, filePath, dateIMG);
      } else {
        ErrorDescription("Gagal Save file");
      }

      print("Start Saving");
      print(firstname);
      print(photoURL);
      await ref.set({
        'uid': userId,
        'photoURL': photoURL ?? oldUserData?['photoURL'],
        'displayName': firstname ?? oldUserData?['displayName'],
        'firstName': firstname ?? oldUserData?['firstName'],
        'phone': phone ?? oldUserData?['phone'],
        'lastUpdate': dateIMG
      }, SetOptions(merge: true));

      return right("Sukses");
    } on FirebaseException catch (e) {
      return left(e.message ?? 'Failed to Save Data.');
    }
  }
}

final dataUserSourceProvider = Provider<DataUserSource>(
  (ref) => DataUserSource(
      ref.read(firebaseAuthProvider),
      ref.read(firebaseFirestoreProvider),
      ref.read(firebaseStorageProvider),
      ref),
);
