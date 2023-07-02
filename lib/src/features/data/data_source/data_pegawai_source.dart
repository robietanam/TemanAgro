import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/firebase_providers.dart';
import '../../auth/data_source/auth_data_source.dart';
import '../data_pegawai_provider.dart';
import '../data_user_provider.dart';
import 'data_user_source.dart';
import 'dart:math';

class DataPegawaiSource {
  DataPegawaiSource(this._firebaseFirestore, this._firebaseStorage, this._ref);

  final FirebaseStorage _firebaseStorage;
  final FirebaseFirestore _firebaseFirestore;
  final Ref _ref;

  Future<Either<String, List<Map<String, dynamic>>>> getDataPegawais({
    required Map<String, dynamic> userData,
  }) async {
    print("GET DATA PEGAWAI RUNNNEDDD");
    print(userData);
    final FirebaseFirestore db = _firebaseFirestore;
    if (userData['role'] == 'Pemilik') {
      List<Map<String, dynamic>> dataPegawai = [];
      final pegawaisId = userData['idPegawai'];
      if (pegawaisId != null) {
        for (String pegawai in pegawaisId) {
          final data = await db
              .collection('users')
              .where('uid', isEqualTo: pegawai)
              .orderBy('Nama')
              .get()
              .then((value) => value.docs
                  .map((e) => e.data() as Map<String, dynamic>)
                  .first);
          dataPegawai.add(data);
        }
        print("DataPegawai ======================");
        print(dataPegawai);
      }

      return right(dataPegawai);
    } else
      return left("Bukan Admin");
  }

  // Future<Either<String, Iterable<Map<String, dynamic>>>> saveDataPegawais({
  //   required Map<String, dynamic> userData,
  // }) async {
  //   if (userData['role'] == 'Admin' )
  //   return
  // }

  Future<String> saveFile(
      String userId, String filePath, String dateIMG) async {
    print("====++++Data save file+++=====");
    Reference? profileImagesRef;
    Reference storageRef = _firebaseStorage.ref();

    final fileImage = File(filePath);
    profileImagesRef = storageRef.child("profile_photo/pegawai/${userId}.jpg");
    await profileImagesRef.putFile(fileImage);
    final downloadURL = await profileImagesRef.getDownloadURL();
    print(downloadURL);

    return downloadURL;
  }

  Future<Either<String, String>> savePegawai(
      {required String userId,
      String? filePath,
      String? firstname,
      String? phone,
      String? gajiPerAbsen,
      String? status,
      String? photoURL}) async {
    print("====++++Data save User+++=====");
    final String dateIMG = DateFormat('yyyy-MM-dd-kk').format(DateTime.now());
    final FirebaseFirestore db = _firebaseFirestore;
    DocumentReference ref = db.collection('users').doc(userId);
    Map<String, dynamic>? oldUserData;
    DocumentSnapshot doc = await ref.get();
    String? downloadURL;
    try {
      if (doc.exists) {
        print("Doc Exist");
        oldUserData = await ref
            .get()
            .then((value) => value.data() as Map<String, dynamic>);
      }

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
        'Nama': firstname ?? oldUserData?['Nama'],
        'displayName': firstname ?? oldUserData?['displayName'],
        'firstName': firstname ?? oldUserData?['firstName'],
        'phone': phone ?? oldUserData?['phone'],
        'gajiPerAbsen': gajiPerAbsen ?? oldUserData?['gajiPerAbsen'],
        'status': status,
        'lastUpdate': dateIMG
      }, SetOptions(merge: true));

      return right("Sukses");
    } on FirebaseException catch (e) {
      return left(e.message ?? 'Failed to Save Data.');
    }
  }

  Future<Either<String, List<Map<String, dynamic>>>> getDataPegawaisReferral({
    required Map<String, dynamic> userData,
  }) async {
    print("GET DATA Referall RUNNNEDDD");
    final FirebaseFirestore db = _firebaseFirestore;
    if (userData['role'] == 'Pemilik') {
      List<Map<String, dynamic>> dataReferral = [];
      final idAdmin = userData['uid'];
      dataReferral = await db
          .collection('kodeRef')
          .where('idAdmin', isEqualTo: idAdmin)
          .get()
          .then(
            (value) => value.docs.map((e) => e.data()).toList(),
          );

      print("Data Referral ======================");
      print(dataReferral);

      return right(dataReferral);
    } else
      return left("Bukan Admin");
  }

  bool validateDataToken(token) {
    return false;
  }

  Future<String> tambahDataToken({
    required Map<String, dynamic> userData,
  }) async {
    if (userData['role'] == 'Pemilik') {
      final FirebaseFirestore db = _firebaseFirestore;
      Map<String, dynamic> toSaveData;
      DocumentReference refData;
      Random random = new Random();
      int token = random.nextInt(1000000);

      print("Tambah Data Token RUNNED");
      refData = db.collection('kodeRef').doc();
      DocumentSnapshot doc = await refData.get();

      toSaveData = {
        'idAdmin': userData['uid'],
        'idToken': doc.id,
        'token': token,
        'lastUpdate': DateTime.now(),
      };
      await refData.set(toSaveData, SetOptions(merge: true));
      return "SUKSES Menyimpan token";
    }
    return "GAGAGAL";
  }

  Future<String> deleteToken({
    required String idToken,
  }) async {
    final FirebaseFirestore db = _firebaseFirestore;
    Map<String, dynamic> toSaveData;
    DocumentReference refData;

    print("Tambah Data Token RUNNED");
    refData = db.collection('kodeRef').doc(idToken);
    await refData.delete();

    return "SUKSES Menyimpan token";
  }
}

final dataPegawaiSourceProvider = Provider<DataPegawaiSource>(
  (ref) => DataPegawaiSource(ref.read(firebaseFirestoreProvider),
      ref.read(firebaseStorageProvider), ref),
);

const _uuid = Uuid();

/// A read-only description of a Data pegawai masseh
@immutable
class DataPegawai {
  const DataPegawai({
    required this.idPegawai,
    required this.dataPegawai,
    this.checked = false,
  });

  final String idPegawai;
  final Map<String, dynamic> dataPegawai;
  final bool checked;

  @override
  String toString() {
    return 'DataPegawai(data: $dataPegawai, checked: $checked)';
  }
}

class PegawaiList extends StateNotifier<List<DataPegawai>> {
  PegawaiList([List<DataPegawai>? initialTodos]) : super(initialTodos ?? []);

  void reset() {
    state = [];
  }

  void add(
    String idPegawai,
    Map<String, dynamic> dataPegawai,
  ) {
    state = [
      ...state,
      DataPegawai(
        idPegawai: idPegawai,
        dataPegawai: dataPegawai,
      ),
    ];
  }

  void toggle(String id) {
    state = [
      for (final todo in state)
        if (todo.idPegawai == id)
          DataPegawai(
              idPegawai: todo.idPegawai,
              dataPegawai: todo.dataPegawai,
              checked: !todo.checked)
        else
          todo,
    ];
  }
}

final pegawaiListProvider =
    StateNotifierProvider<PegawaiList, List<DataPegawai>>((ref) {
  return PegawaiList(const []);
});

class PegawaiListPresensi extends StateNotifier<List<DataPegawai>> {
  PegawaiListPresensi([List<DataPegawai>? initialTodos])
      : super(initialTodos ?? []);

  void reset() {
    state = [];
  }

  void add(
    String idPegawai,
    Map<String, dynamic> dataPegawai,
  ) {
    state = [
      ...state,
      DataPegawai(
        idPegawai: idPegawai,
        dataPegawai: dataPegawai,
      ),
    ];
  }

  void addAll(
    List<Map<String, dynamic>> dataPegawais,
  ) {
    for (Map<String, dynamic> data in dataPegawais) {
      state = [
        ...state,
        DataPegawai(
          idPegawai: data['uid'],
          dataPegawai: data,
        ),
      ];
    }
  }

  void toggle(String id) {
    state = [
      for (final todo in state)
        if (todo.idPegawai == id)
          DataPegawai(
              idPegawai: todo.idPegawai,
              dataPegawai: todo.dataPegawai,
              checked: !todo.checked)
        else
          todo,
    ];
  }
}

final pegawaiListPresensiProvider =
    StateNotifierProvider<PegawaiListPresensi, List<DataPegawai>>((ref) {
  return PegawaiListPresensi(const []);
});

final firstTimePicker = StateProvider((ref) => TimeOfDay(hour: 0, minute: 0));
final secondTimePicker = StateProvider((ref) => TimeOfDay(hour: 0, minute: 0));
