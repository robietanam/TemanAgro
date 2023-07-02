import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';
import 'globals.dart';

void showSnackBar(
  String text, {
  Duration duration = const Duration(seconds: 2),
}) {
  Globals.scaffoldMessengerKey.currentState
    ?..clearSnackBars()
    ..showSnackBar(
      SnackBar(content: Text(text), duration: duration),
    );
}

bool isNullOrBlank(String? data) => data?.trim().isEmpty ?? true;

void log(
  String screenId, {
  dynamic msg,
  dynamic error,
  StackTrace? stackTrace,
}) =>
    devtools.log(
      msg.toString(),
      error: error,
      name: screenId,
      stackTrace: stackTrace,
    );

DateTime convertToDateTime({required TimeOfDay t}) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day, t.hour, t.minute);
}

TimeOfDay convertToTimeOfDay({required String string, DateTime? time}) {
  final waktuString = string.split(":");
  final now = time ?? DateTime.now();
  TimeOfDay waktu = TimeOfDay(
      hour: int.parse(waktuString[0]), minute: int.parse(waktuString[1]));
  return waktu;
}

bool isValidTimeRange(TimeOfDay startTime, TimeOfDay endTime) {
  TimeOfDay now = TimeOfDay.now();
  return ((now.hour > startTime.hour) ||
          (now.hour == startTime.hour && now.minute >= startTime.minute)) &&
      ((now.hour < endTime.hour) ||
          (now.hour == endTime.hour && now.minute <= endTime.minute));
}
