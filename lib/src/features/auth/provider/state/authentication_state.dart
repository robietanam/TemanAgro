import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_sign_in/google_sign_in.dart';

part "authentication_state.freezed.dart";

@freezed
class AuthenticationState with _$AuthenticationState {
  const factory AuthenticationState.initial() = _Initial;

  const factory AuthenticationState.loading() = _Loading;

  const factory AuthenticationState.unauthenticated({String? message}) =
      _UnAuthentication;

  const factory AuthenticationState.authenticated({required User user}) =
      _Authenticated;
  const factory AuthenticationState.authenticatedNotVerify(
      {required GoogleSignInAccount user}) = _AuthenticatedNotVerify;

  const factory AuthenticationState.notVerify({required User user}) =
      _NotVerify;

  const factory AuthenticationState.success({String? message}) = _Success;

  const factory AuthenticationState.failed({String? message}) = _Failed;
}
