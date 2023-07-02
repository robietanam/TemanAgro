import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/providers/firebase_providers.dart';

class DataPembayaranSource {
  DataPembayaranSource(
      this._firebaseFirestore, this._firebaseStorage, this._ref);

  final FirebaseStorage _firebaseStorage;
  final FirebaseFirestore _firebaseFirestore;
  final Ref _ref;

  Future<String> saveFile(String userId, String filePath) async {
    print("====++++Data save file+++=====");
    Reference? profileImagesRef;
    Reference storageRef = _firebaseStorage.ref();
    print(filePath);
    final fileImage = File(filePath);
    print("file image ${fileImage}");
    profileImagesRef = storageRef.child("bukti_pembayaran/users/${userId}.jpg");
    await profileImagesRef.putFile(fileImage);
    final downloadURL = await profileImagesRef.getDownloadURL();
    print(downloadURL);

    return downloadURL;
  }

  Future<Either<String, String>> createDataPembayaran({
    required Map<String, dynamic> userData,
    required int tipe,
    required String filePath,
  }) async {
    print("====++++Create data pemasukkan +++=====");
    final DateTime now = DateTime.now();
    final FirebaseFirestore db = _firebaseFirestore;
    DocumentReference ref = db.collection('dataPembayaran').doc();

    print("filePath ${filePath}");

    final photoURL = await saveFile(userData['uid'], filePath);

    try {
      await ref.set({
        'uid': ref.id,
        'idAdmin': userData['uid'],
        'image': photoURL,
        'tipe': tipe,
        'tanggal': DateTime.now(),
      }, SetOptions(merge: true));

      return right("Sukses");
    } on FirebaseException catch (e) {
      return left(e.message ?? 'Failed to Save Data.');
    }
  }
}

final dataPembayaranSourceProvider = Provider<DataPembayaranSource>(
  (ref) => DataPembayaranSource(ref.read(firebaseFirestoreProvider),
      ref.read(firebaseStorageProvider), ref),
);
