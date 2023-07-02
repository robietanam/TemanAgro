import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/firebase_providers.dart';
import '../../../core/utils/helpers.dart';
import 'data_pegawai_source.dart';

class DataPresensiSource {
  DataPresensiSource(this._firebaseFirestore, this._firebaseStorage, this._ref);

  final FirebaseStorage _firebaseStorage;
  final FirebaseFirestore _firebaseFirestore;
  final Ref _ref;

  Future<Either<String, List<Map<String, dynamic>>>> getDataFormPresensiSemua({
    required String idAdmin,
    required DateTime hari,
  }) async {
    print("GET DATA Form Presensi RUNNNEDDD");
    final FirebaseFirestore db = _firebaseFirestore;
    List<Map<String, dynamic>> dataPresensi = [];
    String hariKey = '';
    // final todayDate = DateFormat('dd/MM/yyyy').format(hari);
    final todayDate = DateTime.now();
    if (hari.weekday == DateTime.sunday) {
      hariKey = 'minggu';
    } else if (hari.weekday == DateTime.monday) {
      hariKey = 'senin';
    } else if (hari.weekday == DateTime.tuesday) {
      hariKey = 'selasa';
    } else if (hari.weekday == DateTime.wednesday) {
      hariKey = 'rabu';
    } else if (hari.weekday == DateTime.thursday) {
      hariKey = 'kamis';
    } else if (hari.weekday == DateTime.friday) {
      hariKey = 'jumat';
    } else if (hari.weekday == DateTime.saturday) {
      hariKey = 'sabtu';
    }
    print("Hari : ${hariKey}");
    final data = await db
        .collection('formPresensi')
        .where('idAdmin', isEqualTo: idAdmin)
        .where('hari', arrayContains: hariKey)
        .where('tanggalDibuat', isLessThanOrEqualTo: hari)
        .get()
        .then((value) =>
            value.docs.map((e) => e.data() as Map<String, dynamic>).toList());
    dataPresensi.addAll(data);

    return right(dataPresensi);
  }

  Future<Either<String, List<Map<String, dynamic>>>>
      getDataFormPresensiPegawai({
    required String idPegawai,
    required DateTime hari,
  }) async {
    print("GET DATA Presensi Pegawai RUNNNEDDD");
    final FirebaseFirestore db = _firebaseFirestore;
    List<Map<String, dynamic>> dataPresensi = [];

    final data = await db
        .collection('formPresensi')
        .where('listPegawai', arrayContains: idPegawai)
        .where('tanggalDibuat', isLessThan: hari)
        .get()
        .then((value) =>
            value.docs.map((e) => e.data() as Map<String, dynamic>).toList());
    dataPresensi.addAll(data);
    print(dataPresensi);

    return right(dataPresensi);
  }

  Future<Either<String, String>> createFormPresensiPegawai({
    required List<DataPegawai> userIdPegawai,
    required List<String> hari,
    required String idAdmin,
    required String? idFormPresensi,
    required DateTime waktuAwal,
    required DateTime waktuAkhir,
    String? status = 'Aktif',
  }) async {
    print("====++++Create from Presensi +++=====");
    final DateTime now = DateTime.now();
    final FirebaseFirestore db = _firebaseFirestore;
    DocumentReference ref = db.collection('formPresensi').doc(idFormPresensi);
    List listPegawaiId = [];
    for (DataPegawai i in userIdPegawai) {
      listPegawaiId.add(i.idPegawai);
    }
    final waktuAwalString = DateFormat('HH:mm').format(waktuAwal);
    final waktuAkhirString = DateFormat('HH:mm').format(waktuAkhir);
    print("waktu to string ${waktuAwalString}");
    print("waktu to string ${waktuAkhirString}");
    print(
        "BACK TO TIME ${DateFormat('HH:mm').parse(waktuAkhirString.toString())}");
    try {
      await ref.set({
        'uid': ref.id,
        'idAdmin': idAdmin,
        'listPegawai': listPegawaiId,
        'waktuAwal': waktuAwalString,
        'waktuAkhir': waktuAkhirString,
        'hari': hari,
        'tanggalDibuat': DateTime(now.year, now.month, now.day),
        'status': status,
      }, SetOptions(merge: true));

      return right("Sukses");
    } on FirebaseException catch (e) {
      return left(e.message ?? 'Failed to Save Data.');
    }
  }

  Future<Either<String, String>> deleteFormPresensiPegawai({
    required String idFormPresensi,
    String? status = 'Aktif',
  }) async {
    print("====++++Create from Presensi +++=====");
    final DateTime now = DateTime.now();
    final FirebaseFirestore db = _firebaseFirestore;
    DocumentReference ref = db.collection('formPresensi').doc(idFormPresensi);
    List listPegawaiId = [];

    // DateFormat('dd/MM/yyyy').format(waktuAwal)
    try {
      await ref.delete();

      return right("Sukses Menghapus");
    } on FirebaseException catch (e) {
      return left(e.message ?? 'Failed to Save Data.');
    }
  }

  Future<Either<String, List<Map<String, dynamic>>>> getDataPresensiSehari({
    required String idPegawai,
    required DateTime hari,
  }) async {
    print("GET DATA Presensi RUNNNEDDD");
    final FirebaseFirestore db = _firebaseFirestore;
    String hariKey = '';
    // final todayDate = DateFormat('dd/MM/yyyy').format(hari);
    if (hari.weekday == DateTime.sunday) {
      hariKey = 'minggu';
    } else if (hari.weekday == DateTime.monday) {
      hariKey = 'senin';
    } else if (hari.weekday == DateTime.tuesday) {
      hariKey = 'selasa';
    } else if (hari.weekday == DateTime.wednesday) {
      hariKey = 'rabu';
    } else if (hari.weekday == DateTime.thursday) {
      hariKey = 'kamis';
    } else if (hari.weekday == DateTime.friday) {
      hariKey = 'jumat';
    } else if (hari.weekday == DateTime.saturday) {
      hariKey = 'sabtu';
    }
    print("Hari : ${hariKey}");
    final data = await db
        .collection('periodikPresensi')
        .where('idPegawai', isEqualTo: idPegawai)
        .where('tanggalPresensi',
            isEqualTo: DateFormat('dd/MM/yyyy').format(hari))
        .get()
        .then((value) =>
            value.docs.map((e) => e.data() as Map<String, dynamic>).toList());

    return right(data);
  }

  Future<Either<String, List<Map<String, dynamic>>>>
      getDataPresensiSehariAdmin({
    required String idAdmin,
    required DateTime hari,
  }) async {
    print("GET DATA Presensi RUNNNEDDD");
    final FirebaseFirestore db = _firebaseFirestore;
    String hariKey = '';
    // final todayDate = DateFormat('dd/MM/yyyy').format(hari);
    final todayDate = DateTime.now();
    if (hari.weekday == DateTime.sunday) {
      hariKey = 'minggu';
    } else if (hari.weekday == DateTime.monday) {
      hariKey = 'senin';
    } else if (hari.weekday == DateTime.tuesday) {
      hariKey = 'selasa';
    } else if (hari.weekday == DateTime.wednesday) {
      hariKey = 'rabu';
    } else if (hari.weekday == DateTime.thursday) {
      hariKey = 'kamis';
    } else if (hari.weekday == DateTime.friday) {
      hariKey = 'jumat';
    } else if (hari.weekday == DateTime.saturday) {
      hariKey = 'sabtu';
    }
    print("Hari : ${hariKey}");
    try {
      final data = await db
          .collection('periodikPresensi')
          .where('idAdmin', isEqualTo: idAdmin)
          .where('tanggalPresensi',
              isEqualTo: DateFormat('dd/MM/yyyy').format(hari))
          .get()
          .then((value) =>
              value.docs.map((e) => e.data() as Map<String, dynamic>).toList());

      return right(data);
    } on FirebaseException catch (e) {
      return left(e.message ?? 'Failed to Save Data.');
    }
  }

  Future<Either<String, Map<String, dynamic>>> getDataPresensiSemua({
    required String idPegawai,
  }) async {
    print("GET DATA Presensi semua RUNNNEDDD");
    final FirebaseFirestore db = _firebaseFirestore;
    try {
      final data = await db
          .collection('periodikPresensi')
          .where('idPegawai', isEqualTo: idPegawai)
          .get()
          .then((value) =>
              value.docs.map((e) => e.data() as Map<String, dynamic>).toList());

      print("GET DATA Presensi ${data}");

      final dataForm = await db
          .collection('formPresensi')
          .where('listPegawai', arrayContains: idPegawai)
          .get()
          .then((value) =>
              value.docs.map((e) => e.data() as Map<String, dynamic>).toList());

      print("GET DATA Form Presensi ${dataForm}");

      final dataReturn = {'dataPresensi': data, 'dataFormPresensi': dataForm};

      return right(dataReturn);
    } on FirebaseException catch (e) {
      return left(e.message ?? 'Failed to Save Data.');
    }
  }

  Future<Either<String, String>> createPresensiPegawai({
    required String idPegawai,
    required String idAdmin,
    required DateTime tanggalDipilih,
    required Map<String, dynamic> dataFormPresensi,
    required String? idPeriodikPresensi,
    String? status,
  }) async {
    print("====++++Create Data Presensi +++=====");
    DateTime now = DateTime.now();
    final FirebaseFirestore db = _firebaseFirestore;
    DocumentReference ref =
        db.collection('periodikPresensi').doc(idPeriodikPresensi);

    // DateFormat('dd/MM/yyyy').format(waktuAwal)
    print("DATA FORM PRESENSI NYE ${dataFormPresensi}");
    TimeOfDay waktuAwal =
        convertToTimeOfDay(string: dataFormPresensi['waktuAwal']);
    TimeOfDay waktuAkhir =
        convertToTimeOfDay(string: dataFormPresensi['waktuAkhir']);
    print(
        "DATA Waktu awal  ${waktuAwal} and ${waktuAkhir} is now is the time ${isValidTimeRange(waktuAwal, waktuAkhir)}");

    if (isValidTimeRange(waktuAwal, waktuAkhir) &&
        tanggalDipilih.weekday == now.weekday) {
      print("HARI YANG SAMA");
      try {
        await ref.set({
          'uid': ref.id,
          'idAdmin': idAdmin,
          'idPegawai': idPegawai,
          'idFormPresensi': dataFormPresensi['uid'],
          'tanggalPresensi': DateFormat('dd/MM/yyyy').format(now),
          'status': status ?? 'Absen',
          'waktuPresensi': now,
        }, SetOptions(merge: true));

        return right("Sukses");
      } on FirebaseException catch (e) {
        return left(e.message ?? 'Failed to Save Data.');
      }
    } else {
      print("TIDAK ADA ABSENSI nye");
      return left('Tidak ada absensi pada jadwal');
    }
  }
}

final dataFormPresensiSourceProvider = Provider<DataPresensiSource>(
  (ref) => DataPresensiSource(ref.read(firebaseFirestoreProvider),
      ref.read(firebaseStorageProvider), ref),
);
