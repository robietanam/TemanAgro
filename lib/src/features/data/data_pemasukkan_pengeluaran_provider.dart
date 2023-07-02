import 'package:com.ppl.teman_agro_admin/src/features/data/state/data_user_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'data_source/data_pemasukkan_pengeluaran_source.dart';

class DataPemasukkanPengeluaranNotifier extends StateNotifier<FetchDataState> {
  DataPemasukkanPengeluaranNotifier(this._dataSource)
      : super(const FetchDataState.initial());

  final DataPemasukkanPengeluaranSource _dataSource;

  Future<void> saveDataPemasukkanPengeluaran({
    required Map<String, dynamic> userData,
    Map<String, dynamic>? oldData,
    required DateTime tanggal,
    required String nominal,
    required String deskripsi,
    required String tipe,
  }) async {
    print("GET DATA Pegawai RUNNED !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    state = const FetchDataState.loading();
    final response = await _dataSource.createAndSavePemasukkanPengeluaran(
        oldData: oldData,
        userData: userData,
        tanggal: tanggal,
        nominal: nominal,
        deskripsi: deskripsi,
        tipe: tipe);
    state = response.fold(
      (error) => FetchDataState.unFetch(message: error),
      (response) => FetchDataState.success(),
    );
  }

  Future<void> getPemasukkanPengeluaran({
    required Map<String, dynamic> userData,
    required DateTime tanggal,
  }) async {
    print("GET DATA Pegawai RUNNED !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    state = const FetchDataState.loading();
    final response = await _dataSource.getPemasukkanPengeluaran(
        userData: userData, tanggal: tanggal);
    state = response.fold(
      (error) => FetchDataState.unFetch(message: error),
      (response) => FetchDataState.fetchedArray(dataFetchArray: response),
    );
  }

  Future<void> deletePemasukkanPengeluaran({
    required Map<String, dynamic> dataPemasukkan,
  }) async {
    print("GET DATA Pegawai RUNNED !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    state = const FetchDataState.loading();
    final response = await _dataSource.deletePemasukkanPengeluaran(
        dataPemasukkan: dataPemasukkan);
    state = response.fold(
      (error) => FetchDataState.unFetch(message: error),
      (response) => FetchDataState.success(),
    );
  }
}

final dataPemasukkanPengeluaranNotifierProvider =
    StateNotifierProvider<DataPemasukkanPengeluaranNotifier, FetchDataState>(
  (ref) => DataPemasukkanPengeluaranNotifier(
      ref.read(dataPemasukkanPengeluaranSourceProvider)),
);
