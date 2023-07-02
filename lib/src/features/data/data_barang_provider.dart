import 'dart:async';
import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'data_source/data_barang_source.dart';
import 'state/data_user_state.dart';

class dataBarangNotifier extends StateNotifier<FetchDataState> {
  dataBarangNotifier(this._dataSource) : super(const FetchDataState.initial());

  final DataBarangSource _dataSource;

  Future<void> getDataForms({
    required Map<String, dynamic> userData,
  }) async {
    print("GET DATA Forms RUNNED !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    state = const FetchDataState.loading();
    final response = await _dataSource.getDataFormBarangs(userData: userData);
    state = response.fold(
      (error) => FetchDataState.unFetch(message: error),
      (response) => FetchDataState.fetchedArray(dataFetchArray: response),
    );
  }

  Future<void> getDataForm({
    required String idForm,
  }) async {
    print("GET DATA Forms RUNNED !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    state = const FetchDataState.loading();
    final response = await _dataSource.getDataFormBarang(idForm: idForm);
    state = response.fold(
      (error) => FetchDataState.unFetch(message: error),
      (response) => FetchDataState.fetched(dataFetch: response),
    );
  }

  Future<void> getDataPeriodiks({
    required String idForm,
  }) async {
    print("GET DATA Forms Periodik  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    state = const FetchDataState.loading();
    final response =
        await _dataSource.getDataPeriodikBarangs(idFormData: idForm);
    state = response.fold(
      (error) => FetchDataState.unFetch(message: error),
      (response) => FetchDataState.fetchedArray(dataFetchArray: response),
    );
  }

  Future<void> getDataPeriodik({
    required String idFormData,
    required User user,
  }) async {
    print("GET DATA Periodik RUNNED !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    state = const FetchDataState.loading();
    final response = await _dataSource.getDataPeriodikBarang(
        idFormData: idFormData, user: user);
    print("THE RESPONSE");
    print(response);
    state = response.fold(
      (error) {
        print(error);
        return FetchDataState.unFetch(message: error);
      },
      (response) {
        print(response);
        if (response.length < 9) {
          return FetchDataState.empty(dataFetch: response);
        }
        return FetchDataState.fetched(dataFetch: response);
      },
    );
  }

  Future<void> saveDataBarang({
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
    print("SAVE DATA Barang RUNNED !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    state = const FetchDataState.loading();
    final response = await _dataSource.saveDataBarang(
      userData: userData,
      idDataForm: idDataForm,
      idDataPeriodik: idDataPeriodik,
      deskripsiProduk: deskripsiProduk,
      idPegawai: idPegawai,
      jumlahBagus: jumlahBagus,
      jumlahKurangBagus: jumlahKurangBagus,
      jumlahStok: jumlahStok,
      kebutuhanPendukung: kebutuhanPendukung,
      keterangan: keterangan,
      kode: kode,
      namaProduk: namaProduk,
      stok: stok,
      usiaProduk: usiaProduk,
      filePath: filePath,
    );
    state = response.fold(
      (error) => FetchDataState.unFetch(message: error),
      (response) => const FetchDataState.success(),
    );
  }

  Future<void> deleteDataPeriodik(
      {required String idFormData,
      required Map<String, dynamic> dataUser}) async {
    print("Delete DATA Periodik RUNNED !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    state = const FetchDataState.loading();
    final response = await _dataSource.deleteDataFormBarang(
        idForm: idFormData, dataUser: dataUser);
    print(response);
    state = response.fold(
      (error) {
        print(error);
        return FetchDataState.unFetch(message: error);
      },
      (response) {
        return FetchDataState.success();
      },
    );
  }
}

// Fetch data Form di halaman produk
final dataFormsNotifierProvider =
    StateNotifierProvider<dataBarangNotifier, FetchDataState>(
  (ref) => dataBarangNotifier(ref.read(dataBarangSourceProvider)),
);

// Fetch data Form untuk edit form produk dan periodik
final dataFormNotifierProvider =
    StateNotifierProvider<dataBarangNotifier, FetchDataState>(
  (ref) => dataBarangNotifier(ref.read(dataBarangSourceProvider)),
);

// Fetch data periodik untuk isi form dataPeriodik
final dataPeriodikNotifierProvider =
    StateNotifierProvider<dataBarangNotifier, FetchDataState>(
  (ref) => dataBarangNotifier(ref.read(dataBarangSourceProvider)),
);

// Fetch data untuk history data
final dataPeriodiksNotifierProvider =
    StateNotifierProvider<dataBarangNotifier, FetchDataState>(
  (ref) => dataBarangNotifier(ref.read(dataBarangSourceProvider)),
);
