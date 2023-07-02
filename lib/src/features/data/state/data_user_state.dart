import 'package:freezed_annotation/freezed_annotation.dart';

part "data_user_state.freezed.dart";

@freezed
class FetchDataState with _$FetchDataState {
  const factory FetchDataState.initial() = _Initial;

  const factory FetchDataState.loading() = _Loading;

  const factory FetchDataState.unFetch({String? message}) = _UnFetched;

  const factory FetchDataState.fetched(
      {required Map<String, dynamic> dataFetch}) = _Fetched;

  const factory FetchDataState.empty(
      {required Map<String, dynamic> dataFetch}) = _Empty;

  const factory FetchDataState.fetchedArray(
      {required Iterable<Map<String, dynamic>> dataFetchArray}) = _FetchedArray;

  const factory FetchDataState.success() = _Success;

  const factory FetchDataState.failed({String? message}) = _Failed;
}
