import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'state/data_user_state.dart';
import 'data_source/data_user_source.dart';

class userDataNotifier extends StateNotifier<FetchDataState> {
  userDataNotifier(this._dataSource) : super(const FetchDataState.initial());

  final DataUserSource _dataSource;

  Future<void> getDataUser({required String userId}) async {
    print("GET DATA USER RUNNED !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    state = const FetchDataState.loading();
    final response = await _dataSource.getDataUser(userId);
    state = response.fold(
      (error) => FetchDataState.unFetch(message: error),
      (response) => FetchDataState.fetched(dataFetch: response),
    );
  }

  Future<void> saveDataUser({
    required String userId,
    String? filePath,
    String? firstname,
    String? phone,
    Map<String, dynamic>? userData,
  }) async {
    print("SAVE DATA USER RUNNED !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    state = const FetchDataState.loading();

    final response = await _dataSource.saveUser(
        userId: userId,
        firstname: firstname,
        phone: phone,
        filePath: filePath,
        oldUserData: userData);
    state = response.fold(
      (error) => FetchDataState.unFetch(message: error),
      (response) => const FetchDataState.success(),
    );
  }
}

// final profileFetchDataNotifierProvider =
//     StateNotifierProvider<userDataNotifier, FetchDataState>(
//   (ref) => userDataNotifier(ref.read(dataUserSourceProvider)),
// );

// final homeFetchDataNotifierProvider =
//     StateNotifierProvider<userDataNotifier, FetchDataState>(
//   (ref) => userDataNotifier(ref.read(dataUserSourceProvider)),
// );

final fetchDataNotifierProvider =
    StateNotifierProvider<userDataNotifier, FetchDataState>(
  (ref) => userDataNotifier(ref.read(dataUserSourceProvider)),
);
