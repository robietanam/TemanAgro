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
import '../../fetchController/runOnce.dart';
import '../data_barang_provider.dart';

class DataBarangSource {
  DataBarangSource(this._firebaseFirestore, this._firebaseStorage, this._ref);

  final FirebaseStorage _firebaseStorage;
  final FirebaseFirestore _firebaseFirestore;
  final Ref _ref;

  Future<Either<String, Iterable<Map<String, dynamic>>>> getDataFormBarangs({
    required Map<String, dynamic> userData,
  }) async {
    print("====++++Data form barangs+++=====");
    try {
      final FirebaseFirestore db = _firebaseFirestore;
      Query refForm;
      if (userData['role'] == 'Pegawai') {
        refForm = db
            .collection('dataProduk')
            .where('idAdmin', isEqualTo: userData['idAdmin'])
            .where('idPegawai', arrayContains: userData['uid']);
      } else {
        refForm = db
            .collection('dataProduk')
            .where('idAdmin', isEqualTo: userData['uid'])
            .orderBy('namaProduk');
      }

      Iterable<Map<String, dynamic>> dataFormsBarangs = await refForm
          .get()
          .then((value) =>
              value.docs.map((e) => e.data() as Map<String, dynamic>));

      return right(dataFormsBarangs);
    } on FirebaseException catch (e) {
      return left(e.message ?? 'Failed to Get Data.');
    }
  }

  Future<Either<String, Map<String, dynamic>>> getDataFormBarang({
    required String idForm,
  }) async {
    print("====++++Data form barang+++=====");
    try {
      final FirebaseFirestore db = _firebaseFirestore;
      Query refForm;
      refForm = db.collection('dataProduk').where('idForm', isEqualTo: idForm);

      Map<String, dynamic> dataFormsBarang = await refForm.get().then((value) =>
          value.docs.map((e) => e.data() as Map<String, dynamic>).first);

      return right(dataFormsBarang);
    } on FirebaseException catch (e) {
      return left(e.message ?? 'Failed to Get Data.');
    }
  }

  Future<Either<String, Map<String, dynamic>>> getDataPeriodikBarang(
      {required String idFormData, required User user}) async {
    print("====++++Data periodik barang+++=====");
    try {
      var now = DateTime.now();

      final FirebaseFirestore db = _firebaseFirestore;
      Query refForm;
      Query refPeriodik;
      refPeriodik = db
          .collection('periodikProduk')
          .where('idForm', isEqualTo: idFormData)
          .where('lastUpdate',
              isGreaterThanOrEqualTo: DateTime(now.year, now.month, now.day));
      refForm =
          db.collection('dataProduk').where('idForm', isEqualTo: idFormData);

      Map<String, dynamic>? dataFormBarang = await refForm.get().then((value) {
        final docs = value.docs;
        if (docs.isNotEmpty) {
          print("TEST");
          print(docs);
          return docs.map((e) => e.data() as Map<String, dynamic>).first;
        }
      });
      if (dataFormBarang == null) {
        return left("Data tidak ditemukan");
      }

      if (user.uid != dataFormBarang['idAdmin']) {
        print("BUKAN DIADMIN");
        if (dataFormBarang['idPegawai'] != null) {
          List data = dataFormBarang['idPegawai'];
          if (!data.contains(user.uid)) {
            return left('Anda tidak memiliki izin untuk form ini');
          }
        } else {
          return left('Anda tidak memiliki izin untuk form ini');
        }
      }

      Map<String, dynamic>? dataPeriodikBarang =
          await refPeriodik.get().then((value) {
        final docs = value.docs;

        if (docs.isNotEmpty) {
          return docs.map((e) => e.data() as Map<String, dynamic>).first
            ..addEntries(dataFormBarang.entries);
        } else {
          return dataFormBarang;
        }
      });
      print("DATA AKHIR");
      print(dataPeriodikBarang);
      if (dataPeriodikBarang == null) {
        return left("Data tidak ditemukan");
      }
      return right(dataPeriodikBarang);
    } on FirebaseException catch (e) {
      return left(e.message ?? 'Failed to Get Data.');
    }
  }

  Future<Either<String, Iterable<Map<String, dynamic>>>> getDataPeriodikBarangs(
      {required String idFormData}) async {
    print("====++++Data form barangs+++=====");
    try {
      final FirebaseFirestore db = _firebaseFirestore;
      Query refPeriodik;
      refPeriodik = db
          .collection('periodikProduk')
          .where('idForm', isEqualTo: idFormData)
          .orderBy("lastUpdate");
      print("GET DATA PERIODIKSSS");
      final Iterable<Map<String, dynamic>> dataPeriodikBarangs =
          await refPeriodik.get().then((value) =>
              value.docs.map((e) => e.data() as Map<String, dynamic>));
      print("DATANYA");
      print(dataPeriodikBarangs);
      return right(dataPeriodikBarangs);
    } on FirebaseException catch (e) {
      return left(e.message ?? 'Failed to Get Data.');
    }
  }

  Future<String> saveFile(
      String idDataForm, String filePath, String dateIMG) async {
    print("====++++Data save file barang+++=====");
    Reference? profileImagesRef;
    Reference storageRef = _firebaseStorage.ref();

    final fileImage = File(filePath);
    final fileName = basenameWithoutExtension(fileImage.path);
    profileImagesRef = storageRef.child("barang_photo/${idDataForm}.jpg");
    await profileImagesRef.putFile(fileImage);
    final downloadURL = await profileImagesRef.getDownloadURL();
    print(downloadURL);

    return downloadURL;
  }

  Future<Either<String, String>> saveDataBarang({
    required Map<String, dynamic> userData,
    String? idDataForm,
    String? idDataPeriodik,
    String? namaProduk,
    String? stok,
    String? kode,
    String? deskripsiProduk,
    String? jumlahStok,
    String? jumlahBagus,
    String? jumlahKurangBagus,
    String? usiaProduk,
    String? kebutuhanPendukung,
    String? keterangan,
    String? filePath,
    List<String>? idPegawai,
  }) async {
    print("====++++Data save data barang+++=====");
    try {
      final FirebaseFirestore db = _firebaseFirestore;
      DocumentReference refForm;
      DocumentReference refData;
      Map<String, dynamic> toSaveForm;
      Map<String, dynamic> toSaveData;
      Map<String, dynamic> oldUPeriodikData;
      String? downloadURL;
      final String dateIMG = DateFormat('yyyy-MM-dd-kk').format(DateTime.now());

      // Reset state agar fetch data lagi
      _ref.read(productPageOnceProvider.notifier).reset();
      // _ref.invalidate(dataFormsNotifierProvider);

      if (filePath != null && idDataForm != null) {
        print("GET Image");
        downloadURL = await saveFile(idDataForm, filePath, dateIMG);
      } else {
        ErrorDescription("Gagal Save file");
      }
      print("LINK GAMBAR");
      print(downloadURL);

      if (idDataForm == null &&
          userData['role'] == 'Pemilik' &&
          idDataPeriodik == null) {
        print("====-----Data form new----=====");
        refForm = db.collection('dataProduk').doc();
        refData = db.collection('periodikProduk').doc();
        Iterable refKode;
        if (filePath != null) {
          downloadURL = await saveFile(refForm.id, filePath, dateIMG);
        }
        toSaveForm = {
          'idAdmin': userData['uid'],
          'idForm': refForm.id,
          'namaProduk': namaProduk,
          'kode': kode,
          'stok': stok,
          'deskripsi': deskripsiProduk,
          'photoURL': downloadURL,
          'lastUpdate': DateTime.now(),
        };
        toSaveData = {
          'idPeriodik': refData.id,
          'idForm': refForm.id,
          'jumlahStok': jumlahStok,
          'jumlahBagus': jumlahBagus,
          'jumlahKurangBagus': jumlahKurangBagus,
          'usia': usiaProduk,
          'kebutuhanPendukung': kebutuhanPendukung,
          'keterangan': keterangan,
          'lastUpdate': DateTime.now(),
        };
        refKode = await db
            .collection('dataProduk')
            .where('kode', isEqualTo: kode)
            .get()
            .then((value) => value.docs.map((e) => e.data()));
        print(refKode);
        print('KODE=========================Kode');
        print(refKode.isNotEmpty);
        if (refKode.isNotEmpty) {
          print("GAGAGGAGAGL");
          return left('Kode sudah digunakan');
        }
        await refForm.set(toSaveForm, SetOptions(merge: true));
        await refData.set(toSaveData, SetOptions(merge: true));
      }

      if (idDataPeriodik == null && idDataForm != null) {
        print("====-----Data barang new----=====");
        refData = db.collection('periodikProduk').doc();

        toSaveData = {
          'idPeriodik': refData.id,
          'idForm': idDataForm,
          'jumlahStok': jumlahStok,
          'jumlahBagus': jumlahBagus,
          'jumlahKurangBagus': jumlahKurangBagus,
          'usia': usiaProduk,
          'kebutuhanPendukung': kebutuhanPendukung,
          'keterangan': keterangan,
          'lastUpdate': DateTime.now(),
        };

        await refData.set(toSaveData, SetOptions(merge: true));
      }

      if (idDataPeriodik != null) {
        {
          print("====-----Data barang periodik----=====");
          refData = db.collection('periodikProduk').doc(idDataPeriodik);
          DocumentSnapshot doc = await refData.get();
          oldUPeriodikData = doc.data() as Map<String, dynamic>;
          toSaveData = {
            'jumlahStok': jumlahStok ?? oldUPeriodikData['jumlahStok'],
            'jumlahBagus': jumlahBagus ?? oldUPeriodikData['jumlahBagus'],
            'jumlahKurangBagus':
                jumlahKurangBagus ?? oldUPeriodikData['jumlahKurangBagus'],
            'usia': usiaProduk ?? oldUPeriodikData['usia'],
            'kebutuhanPendukung':
                kebutuhanPendukung ?? oldUPeriodikData['kebutuhanPendukung'],
            'keterangan': keterangan ?? oldUPeriodikData['keterangan'],
            'lastUpdate': DateTime.now(),
          };
          await refData.set(toSaveData, SetOptions(merge: true));
        }
      }

      if (idDataForm != null && userData['role'] == 'Pemilik') {
        print("====-----Data form ----=====");
        print(idDataForm);
        Query query =
            db.collection('dataProduk').where('idForm', isEqualTo: idDataForm);
        Map<String, dynamic> doc = await query.get().then((value) =>
            value.docs.map((e) => e.data() as Map<String, dynamic>).first);
        print(doc);
        toSaveForm = {
          'namaProduk': namaProduk ?? doc['namaProduk'],
          'kode': kode ?? doc['kode'],
          'stok': stok ?? doc['stok'],
          'deskripsi': deskripsiProduk ?? doc['deskripsi'],
          'photoURL': downloadURL ?? doc['photoURL'],
          'idPegawai': idPegawai,
          'lastUpdate': DateTime.now(),
        };

        refForm = db.collection('dataProduk').doc(doc['idForm']);
        await refForm.set(toSaveForm, SetOptions(merge: true));
      }

      return right("Sukses Menyimpan Form Data");
    } on FirebaseException catch (e) {
      return left(e.message ?? "Gagal Menyimpan");
    }
  }

  Future<Either<String, String>> deleteDataFormBarang({
    required String idForm,
    required Map<String, dynamic> dataUser,
  }) async {
    print("====++++Data form barang+++=====");
    try {
      final FirebaseFirestore db = _firebaseFirestore;
      QuerySnapshot refForm;
      refForm = await db
          .collection('dataProduk')
          .where('idForm', isEqualTo: idForm)
          .get();
      QuerySnapshot refPeriodik;
      refPeriodik = await db
          .collection('periodikProduk')
          .where('idForm', isEqualTo: idForm)
          .get();
      () async {
        for (var doc in refForm.docs) {
          await doc.reference.delete();
        }
        for (var doc in refPeriodik.docs) {
          await doc.reference.delete();
        }
      }()
          .then((value) => _ref
              .read(dataFormsNotifierProvider.notifier)
              .getDataForms(userData: dataUser));

      return right("DELETE SEMUA");
    } on FirebaseException catch (e) {
      return left(e.message ?? 'Failed to Get Data.');
    }
  }
}

final dataBarangSourceProvider = Provider<DataBarangSource>(
  (ref) => DataBarangSource(ref.read(firebaseFirestoreProvider),
      ref.read(firebaseStorageProvider), ref),
);
