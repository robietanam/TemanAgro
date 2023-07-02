import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'data_source/data_pembayaran_source.dart';
import 'state/data_user_state.dart';

class DataPembayaranNotifier extends StateNotifier<FetchDataState> {
  DataPembayaranNotifier(this._dataSource)
      : super(const FetchDataState.initial());

  final DataPembayaranSource _dataSource;

  Future<void> saveDataPembayaran({
    required Map<String, dynamic> userData,
    required int tipe,
    required String filePath,
  }) async {
    print("GET DATA Pegawai RUNNED !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    state = const FetchDataState.loading();
    final response = await _dataSource.createDataPembayaran(
        userData: userData, tipe: tipe, filePath: filePath);
    state = response.fold(
      (error) => FetchDataState.unFetch(message: error),
      (response) => FetchDataState.success(),
    );
  }
}

final dataPembayaranNotifierProvider =
    StateNotifierProvider<DataPembayaranNotifier, FetchDataState>(
  (ref) => DataPembayaranNotifier(ref.read(dataPembayaranSourceProvider)),
);
