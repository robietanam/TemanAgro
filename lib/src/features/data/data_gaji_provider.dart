import 'dart:collection';

import 'package:com.ppl.teman_agro_admin/src/features/data/state/data_user_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'data_source/data_gaji_source.dart';

class DataGajiNotifier extends StateNotifier<FetchDataState> {
  DataGajiNotifier(this._dataSource) : super(const FetchDataState.initial());

  final DataGajiSource _dataSource;

  Future<void> createDataGajiPegawai(
      {required Map<String, dynamic> dataPegawai,
      required Map<String, dynamic> dataAdmin,
      required DateTime waktuAwal,
      required DateTime waktuAkhir}) async {
    print("GET DATA Forms RUNNED !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    state = const FetchDataState.loading();
    final response = await _dataSource.createDataGajiPegawai(
        dataPegawai: dataPegawai,
        dataAdmin: dataAdmin,
        waktuAwal: waktuAwal,
        waktuAkhir: waktuAkhir);
    state = response.fold(
      (error) => FetchDataState.unFetch(message: error),
      (response) => const FetchDataState.success(),
    );
  }

  Future<void> createDataGajiPegawaiSemua(
      {required List<Map<String, dynamic>> dataPegawais,
      required Map<String, dynamic> dataAdmin,
      required DateTime waktuAwal,
      required DateTime waktuAkhir}) async {
    print("create DATA gaji RUNNED !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    state = const FetchDataState.loading();
    final response = await _dataSource.createDataGajiPegawaiSemua(
        dataPegawais: dataPegawais,
        dataAdmin: dataAdmin,
        waktuAwal: waktuAwal,
        waktuAkhir: waktuAkhir);
    state = response.fold(
      (error) => FetchDataState.unFetch(message: error),
      (response) => const FetchDataState.success(),
    );
  }

  Future<void> getDataGajiPegawai({
    required Map<String, dynamic> dataPegawai,
  }) async {
    print("GET DATA Gaji pegawai RUNNED !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    state = const FetchDataState.loading();
    final response =
        await _dataSource.getDataGajiPegawai(dataPegawai: dataPegawai);
    state = response.fold(
      (error) => FetchDataState.unFetch(message: error),
      (response) => FetchDataState.fetchedArray(dataFetchArray: response),
    );
  }
}

final dataGajiNotifierProvider =
    StateNotifierProvider<DataGajiNotifier, FetchDataState>(
  (ref) => DataGajiNotifier(ref.read(dataGajiSourceProvider)),
);
