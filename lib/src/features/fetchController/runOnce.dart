import 'package:hooks_riverpod/hooks_riverpod.dart';

final productPageOnceProvider = StateNotifierProvider<Counter, bool>((ref) {
  return Counter();
});

final pegawaiPageOnceProvider = StateNotifierProvider<Counter, bool>((ref) {
  return Counter();
});

class Counter extends StateNotifier<bool> {
  Counter() : super(false);
  void reset() => state = false;
  void done() => state = true;
}
