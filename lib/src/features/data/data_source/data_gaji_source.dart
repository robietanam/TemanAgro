import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/providers/firebase_providers.dart';

class DataGajiSource {
  DataGajiSource(this._firebaseFirestore, this._firebaseStorage, this._ref);

  final FirebaseStorage _firebaseStorage;
  final FirebaseFirestore _firebaseFirestore;
  final Ref _ref;

  Future<Either<String, String>> createDataGajiPegawai(
      {required Map<String, dynamic> dataPegawai,
      required Map<String, dynamic> dataAdmin,
      required DateTime waktuAwal,
      required DateTime waktuAkhir}) async {
    print("====++++Create from Presensi +++=====");
    final DateTime now = DateTime.now();
    final FirebaseFirestore db = _firebaseFirestore;
    print("Data PEGAWAI : ${dataPegawai}");
    print("Data Admin : ${dataAdmin}");
    print("Waktu awal : ${waktuAwal}");
    print("Waktu akhir : ${waktuAkhir}");

    AggregateQuery ref = db
        .collection('periodikPresensi')
        .where('idPegawai', isEqualTo: dataPegawai['uid'])
        .where('waktuPresensi', isGreaterThanOrEqualTo: waktuAwal)
        .where('waktuPresensi', isLessThanOrEqualTo: waktuAkhir)
        .count();
    int jumlahAbsensi = 0;
    await ref.get().then((value) => jumlahAbsensi = value.count);

    print("JUMLAH ABSENSI ${jumlahAbsensi}");
    final gaji = jumlahAbsensi *
        int.parse(dataPegawai['gajiPerAbsen'].replaceAll(".", ""));
    print(gaji);

    DocumentReference refGaji = db.collection('dataGaji').doc();

    final toSaveGaji = {
      'uid': refGaji.id,
      'idPegawai': dataPegawai['uid'],
      'idAdmin': dataAdmin['uid'],
      'jumlahGaji': gaji,
      'totalPresensi': jumlahAbsensi,
      'tanggalAwal': waktuAwal,
      'tanggalAkhir': waktuAkhir,
      'tanggalDibuat': DateTime.now(),
    };

    await refGaji.set(toSaveGaji, SetOptions(merge: true));
    print("DATANYA ${toSaveGaji}");

    return right("SUKSES");
  }

  Future<Either<String, String>> createDataGajiPegawaiSemua(
      {required List<Map<String, dynamic>> dataPegawais,
      required Map<String, dynamic> dataAdmin,
      required DateTime waktuAwal,
      required DateTime waktuAkhir}) async {
    print("====++++Create from Presensi semua +++=====");
    final DateTime now = DateTime.now();

    print("List DATA PEGAWAI ${dataPegawais} panjang ${dataPegawais.length}");

    for (Map<String, dynamic> dataPegawai in dataPegawais) {
      final FirebaseFirestore db = _firebaseFirestore;
      print("===========================================================");
      print("Data PEGAWAI : ${dataPegawai}");
      print("Data Admin : ${dataAdmin}");
      print("Waktu awal : ${waktuAwal}");
      print("Waktu akhir : ${waktuAkhir}");

      if (dataPegawai['gajiPerAbsen'] != null) {
        AggregateQuery ref = db
            .collection('periodikPresensi')
            .where('idPegawai', isEqualTo: dataPegawai['uid'])
            .where('waktuPresensi', isGreaterThanOrEqualTo: waktuAwal)
            .where('waktuPresensi', isLessThanOrEqualTo: waktuAkhir)
            .count();
        int jumlahAbsensi = 0;
        await ref.get().then((value) => jumlahAbsensi = value.count);

        print("JUMLAH ABSENSI ${jumlahAbsensi}");
        final gaji = jumlahAbsensi *
            int.parse((dataPegawai['gajiPerAbsen'] != null)
                ? dataPegawai['gajiPerAbsen'].replaceAll(".", "")
                : '0');
        print(gaji);

        DocumentReference refGaji = db.collection('dataGaji').doc();

        final toSaveGaji = {
          'uid': refGaji.id,
          'idPegawai': dataPegawai['uid'],
          'idAdmin': dataAdmin['uid'],
          'jumlahGaji': gaji,
          'totalPresensi': jumlahAbsensi,
          'tanggalAwal': waktuAwal,
          'tanggalAkhir': waktuAkhir,
          'tanggalDibuat': DateTime.now(),
        };

        await refGaji.set(toSaveGaji, SetOptions(merge: true));
        print("DATANYA ${toSaveGaji}");
      }
    }

    return right("SUKSES");
  }

  Future<Either<String, Iterable<Map<String, dynamic>>>> getDataGajiPegawai({
    required Map<String, dynamic> dataPegawai,
  }) async {
    print("====++++Data DATA Gaji PEgawai+++=====");
    print("DATA PEGAWAI ${dataPegawai}");
    try {
      final FirebaseFirestore db = _firebaseFirestore;
      Query refGaji = db
          .collection('dataGaji')
          .where('idPegawai', isEqualTo: dataPegawai['uid'])
          .orderBy("tanggalDibuat");
      print("GET DATA Gaji PEgawai");
      final Iterable<Map<String, dynamic>> dataGajiPegawai = await refGaji
          .get()
          .then((value) =>
              value.docs.map((e) => e.data() as Map<String, dynamic>));
      print("DATANYA");
      print(dataGajiPegawai);
      return right(dataGajiPegawai);
    } on FirebaseException catch (e) {
      print("ERROR ${e}");
      return left(e.message ?? 'Failed to Get Data.');
    }
  }
}

final dataGajiSourceProvider = Provider<DataGajiSource>(
  (ref) => DataGajiSource(ref.read(firebaseFirestoreProvider),
      ref.read(firebaseStorageProvider), ref),
);
