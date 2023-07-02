import 'package:day_picker/model/day_in_week.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'data_source/data_pegawai_source.dart';
import 'data_source/data_presensi_source.dart';
import 'state/data_user_state.dart';

class DataPresensiFormNotifier extends StateNotifier<FetchDataState> {
  DataPresensiFormNotifier(this._dataSource)
      : super(const FetchDataState.initial());

  final DataPresensiSource _dataSource;

  Future<void> getDataFormPresensiAdmin({
    required String idAdmin,
    required DateTime hari,
  }) async {
    print("GET DATA Pegawai RUNNED !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    state = const FetchDataState.loading();
    final response = await _dataSource.getDataFormPresensiSemua(
        idAdmin: idAdmin, hari: hari);
    state = response.fold(
      (error) => FetchDataState.unFetch(message: error),
      (response) => FetchDataState.fetchedArray(dataFetchArray: response),
    );
  }

  Future<void> createDataFormPresensi({
    required List<DataPegawai> userId,
    required List<String> hari,
    required DateTime waktuAwal,
    required DateTime waktuAkhir,
    required String idAdmin,
    required String? idFormPresensi,
    String? status,
  }) async {
    print("GET DATA Pegawai RUNNED !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    state = const FetchDataState.loading();
    final response = await _dataSource.createFormPresensiPegawai(
        idAdmin: idAdmin,
        hari: hari,
        userIdPegawai: userId,
        idFormPresensi: idFormPresensi,
        waktuAwal: waktuAwal,
        waktuAkhir: waktuAkhir,
        status: status);
    state = response.fold(
      (error) => FetchDataState.unFetch(message: error),
      (response) => FetchDataState.success(),
    );
  }

  Future<void> getDataFormPresensi(
      {required String idAdmin, required DateTime hari}) async {
    state = const FetchDataState.loading();
    final response = await _dataSource.getDataFormPresensiSemua(
      idAdmin: idAdmin,
      hari: hari,
    );
    state = response.fold(
      (error) => FetchDataState.unFetch(message: error),
      (response) => FetchDataState.fetchedArray(dataFetchArray: response),
    );
  }

  Future<void> getDataFormPresensiPegawai(
      {required String idPegawai, required DateTime hari}) async {
    state = const FetchDataState.loading();
    final response = await _dataSource.getDataFormPresensiPegawai(
      idPegawai: idPegawai,
      hari: hari,
    );
    state = response.fold(
      (error) => FetchDataState.unFetch(message: error),
      (response) => FetchDataState.fetchedArray(dataFetchArray: response),
    );
  }

  Future<void> deleteDataFormPresensi({
    required String idFormPresensi,
  }) async {
    print("GET DATA Pegawai RUNNED !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    state = const FetchDataState.loading();
    final response = await _dataSource.deleteFormPresensiPegawai(
        idFormPresensi: idFormPresensi);
    state = response.fold(
      (error) => FetchDataState.unFetch(message: error),
      (response) => FetchDataState.success(),
    );
  }
}

final dataFormPresensiNotifierProvider =
    StateNotifierProvider<DataPresensiFormNotifier, FetchDataState>(
  (ref) => DataPresensiFormNotifier(ref.read(dataFormPresensiSourceProvider)),
);

class DataPresensiNotifier extends StateNotifier<FetchDataState> {
  DataPresensiNotifier(this._dataSource)
      : super(const FetchDataState.initial());

  final DataPresensiSource _dataSource;

  Future<void> getDataPresensiAdmin({
    required String idAdmin,
    required DateTime hari,
  }) async {
    print("GET DATA Pegawai RUNNED !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    state = const FetchDataState.loading();
    final response = await _dataSource.getDataFormPresensiSemua(
        idAdmin: idAdmin, hari: hari);
    state = response.fold(
      (error) => FetchDataState.unFetch(message: error),
      (response) => FetchDataState.fetchedArray(dataFetchArray: response),
    );
  }

  Future<void> createDataPresensi({
    required String idPegawai,
    required String idAdmin,
    required Map<String, dynamic> dataFormPresensi,
    required DateTime tanggalDipilih,
    String? idPeriodikPresensi,
    String? status,
  }) async {
    print("GET DATA Pegawai RUNNED !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    state = const FetchDataState.loading();
    final response = await _dataSource.createPresensiPegawai(
        idAdmin: idAdmin,
        dataFormPresensi: dataFormPresensi,
        tanggalDipilih: tanggalDipilih,
        idPegawai: idPegawai,
        idPeriodikPresensi: idPeriodikPresensi,
        status: status);
    state = response.fold(
      (error) => FetchDataState.unFetch(message: error),
      (response) => FetchDataState.success(),
    );
  }

  Future<void> getDataPresensiSehari(
      {required String idPegawai, required DateTime hari}) async {
    state = const FetchDataState.loading();
    final response = await _dataSource.getDataPresensiSehari(
      idPegawai: idPegawai,
      hari: hari,
    );
    state = response.fold(
      (error) => FetchDataState.unFetch(message: error),
      (response) => FetchDataState.fetchedArray(dataFetchArray: response),
    );
  }

  Future<void> getDataPresensiSehariAdmin(
      {required String idAdmin, required DateTime hari}) async {
    state = const FetchDataState.loading();
    final response = await _dataSource.getDataPresensiSehariAdmin(
      idAdmin: idAdmin,
      hari: hari,
    );
    state = response.fold(
      (error) => FetchDataState.unFetch(message: error),
      (response) => FetchDataState.fetchedArray(dataFetchArray: response),
    );
  }

  Future<void> getDataPresensiPegawai(
      {required String idPegawai, required DateTime hari}) async {
    state = const FetchDataState.loading();
    final response = await _dataSource.getDataFormPresensiPegawai(
      idPegawai: idPegawai,
      hari: hari,
    );
    state = response.fold(
      (error) => FetchDataState.unFetch(message: error),
      (response) => FetchDataState.fetchedArray(dataFetchArray: response),
    );
  }

  Future<void> getDataPresensiPegawaiSemua({required String idPegawai}) async {
    state = const FetchDataState.loading();
    final response = await _dataSource.getDataPresensiSemua(
      idPegawai: idPegawai,
    );
    state = response.fold(
      (error) => FetchDataState.unFetch(message: error),
      (response) => FetchDataState.fetched(dataFetch: response),
    );
  }
}

final dataPresensiNotifierProvider =
    StateNotifierProvider<DataPresensiNotifier, FetchDataState>(
  (ref) => DataPresensiNotifier(ref.read(dataFormPresensiSourceProvider)),
);

final dayProvider = StateNotifierProvider<DayState, List<DayInWeek>>((ref) {
  return DayState();
});

class DayState extends StateNotifier<List<DayInWeek>> {
  DayState()
      : super([
          DayInWeek("Sen", dayKey: "senin"),
          DayInWeek("Sel", dayKey: "selasa"),
          DayInWeek("Rab", dayKey: "rabu"),
          DayInWeek("Kam", dayKey: "kamis"),
          DayInWeek("Jum", dayKey: "jumat"),
          DayInWeek("Sab", dayKey: "sabtu"),
          DayInWeek("Min", dayKey: "minggu"),
        ]);
  void setDay({required List<DayInWeek> day}) {
    state = day;
  }

  void resetDay() {
    for (DayInWeek i in state) {
      i.isSelected = false;
    }
    print(state);
    print(state[0].isSelected);
    state = state;
  }

  void toggle({required String dayKey}) {
    for (DayInWeek i in state) {
      if (i.dayKey == dayKey) {
        i.isSelected = true;
      }
    }
    state = state;
  }
}
