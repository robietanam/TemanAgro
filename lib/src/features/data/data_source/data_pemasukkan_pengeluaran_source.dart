import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/providers/firebase_providers.dart';

class DataPemasukkanPengeluaranSource {
  DataPemasukkanPengeluaranSource(
      this._firebaseFirestore, this._firebaseStorage, this._ref);

  final FirebaseStorage _firebaseStorage;
  final FirebaseFirestore _firebaseFirestore;
  final Ref _ref;

  Future<Either<String, String>> createAndSavePemasukkanPengeluaran({
    required Map<String, dynamic> userData,
    Map<String, dynamic>? oldData,
    required DateTime tanggal,
    required String nominal,
    required String deskripsi,
    required String tipe,
  }) async {
    print("====++++Create data pemasukkan +++=====");
    final DateTime now = DateTime.now();
    final FirebaseFirestore db = _firebaseFirestore;
    DocumentReference ref = db
        .collection('dataKeuangan')
        .doc((oldData == null) ? null : oldData['uid']);

    try {
      await ref.set({
        'uid': ref.id,
        'idAdmin': userData['uid'],
        'nominal': nominal,
        'tanggal': DateTime(tanggal.year, tanggal.month, tanggal.day),
        'deskripsi': deskripsi,
        'tipe': tipe,
        'tanggalDibuat': DateTime(now.year, now.month, now.day),
      }, SetOptions(merge: true));

      return right("Sukses");
    } on FirebaseException catch (e) {
      return left(e.message ?? 'Failed to Save Data.');
    }
  }

  Future<Either<String, String>> deletePemasukkanPengeluaran({
    required Map<String, dynamic> dataPemasukkan,
  }) async {
    print("====++++Get data pemasukkan  +++=====");
    final FirebaseFirestore db = _firebaseFirestore;

    try {
      await db.collection('dataKeuangan').doc(dataPemasukkan['uid']).delete();

      return right("Sukses");
    } on FirebaseException catch (e) {
      return left(e.message ?? 'Failed to Save Data.');
    }
  }

  Future<Either<String, List<Map<String, dynamic>>>> getPemasukkanPengeluaran({
    required Map<String, dynamic> userData,
    required DateTime tanggal,
  }) async {
    print("====++++Get data pemasukkan  +++=====");
    final DateTime now = DateTime.now();
    final FirebaseFirestore db = _firebaseFirestore;
    final firstDayDateTime = DateTime(tanggal.year, tanggal.month, 0);

    final lastDayDateTime = DateTime(tanggal.year, tanggal.month + 1, 0);
    Query ref = db
        .collection('dataKeuangan')
        .where('idAdmin', isEqualTo: userData['uid'])
        .where('tanggal', isGreaterThanOrEqualTo: firstDayDateTime)
        .where('tanggal', isLessThanOrEqualTo: lastDayDateTime)
        .orderBy('tanggal');

    try {
      final data = await ref.get().then((value) =>
          value.docs.map((e) => e.data() as Map<String, dynamic>).toList());
      print("Data pemasukkan pengeluaran ${data}");
      return right(data);
    } on FirebaseException catch (e) {
      return left(e.message ?? 'Failed to Save Data.');
    }
  }
}

final dataPemasukkanPengeluaranSourceProvider =
    Provider<DataPemasukkanPengeluaranSource>(
  (ref) => DataPemasukkanPengeluaranSource(ref.read(firebaseFirestoreProvider),
      ref.read(firebaseStorageProvider), ref),
);
