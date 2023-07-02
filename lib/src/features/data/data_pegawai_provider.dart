import 'dart:async';
import 'dart:ffi';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'data_source/data_barang_source.dart';
import 'data_source/data_pegawai_source.dart';
import 'state/data_user_state.dart';

class DataPegawaiNotifier extends StateNotifier<FetchDataState> {
  DataPegawaiNotifier(this._dataSource) : super(const FetchDataState.initial());

  final DataPegawaiSource _dataSource;

  Future<void> getDataPegawai({
    required Map<String, dynamic> userData,
  }) async {
    print("GET DATA Pegawai RUNNED !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    state = const FetchDataState.loading();
    final response = await _dataSource.getDataPegawais(userData: userData);
    state = response.fold(
      (error) => FetchDataState.unFetch(message: error),
      (response) => FetchDataState.fetchedArray(dataFetchArray: response),
    );
  }

  Future<void> saveDataPegawai({
    required String userId,
    String? filePath,
    String? firstname,
    String? gajiPerAbsen,
    String? phone,
    String? status,
  }) async {
    print("GET DATA Pegawai RUNNED !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    state = const FetchDataState.loading();
    final response = await _dataSource.savePegawai(
        userId: userId,
        firstname: firstname,
        phone: phone,
        filePath: filePath,
        gajiPerAbsen: gajiPerAbsen,
        status: status);
    state = response.fold(
      (error) => FetchDataState.unFetch(message: error),
      (response) => FetchDataState.success(),
    );
  }
}

class DataPegawaiReferralNotifier extends StateNotifier<FetchDataState> {
  DataPegawaiReferralNotifier(this._dataSource)
      : super(const FetchDataState.initial());

  final DataPegawaiSource _dataSource;

  Future<void> getDataPegawaiReferral({
    required Map<String, dynamic> userData,
  }) async {
    print("GET DATA Pegawai RUNNED !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    state = const FetchDataState.loading();
    final response =
        await _dataSource.getDataPegawaisReferral(userData: userData);
    state = response.fold(
      (error) => FetchDataState.unFetch(message: error),
      (response) => FetchDataState.fetchedArray(dataFetchArray: response),
    );
  }
}

final dataPegawaisNotifierProvider =
    StateNotifierProvider<DataPegawaiNotifier, FetchDataState>(
  (ref) => DataPegawaiNotifier(ref.read(dataPegawaiSourceProvider)),
);

final dataPegawaisReferralNotifierProvider =
    StateNotifierProvider<DataPegawaiReferralNotifier, FetchDataState>(
  (ref) => DataPegawaiReferralNotifier(ref.read(dataPegawaiSourceProvider)),
);
