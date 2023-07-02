import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'avatar_state.freezed.dart';

@freezed
class AvatarState with _$AvatarState {
  const factory AvatarState.initial() = _Initial;

  const factory AvatarState.loading() = _Loading;

  const factory AvatarState.unSet({String? message}) = _ImageUnloaded;

  const factory AvatarState.set({required File file}) = _ImageLoaded;
}
