import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data_barang_provider.dart';
import 'data_pegawai_provider.dart';

final keyProvider = StateProvider<String>((ref) {
  print("TEST1");
  return '';
});

final sortProvider = StateProvider<bool>((ref) {
  print("Sort");
  return false;
});

final postSearchProvider = StateProvider<List<Map<String, dynamic>>?>((ref) {
  print("TEST;;;");
  final postState = ref
      .watch(dataFormsNotifierProvider)
      .maybeWhen(orElse: () {}, fetchedArray: ((dataFetch) => dataFetch));
  final key = ref.watch(keyProvider);
  final sort = ref.watch(sortProvider);
  print('Key : ${key}');
  List<Map<String, dynamic>>? thePost =
      postState?.where((post) => post['namaProduk'].contains(key)).toList();
  print("Post : ${thePost}");
  if (sort && thePost != null) {
    thePost.sort((a, b) => b['namaProduk'].compareTo(a['namaProduk']));
  }
  print('THE POST NYE : ${thePost}');
  return thePost;
});

final keyProviderPegawai = StateProvider<String>((ref) {
  print("TEST1");
  return '';
});

final keySortProvider = StateProvider<bool>((ref) {
  print("Sort");
  return false;
});

final postSearchProviderPegawai =
    StateProvider<List<Map<String, dynamic>>?>((ref) {
  print("TEST PEGAWAI");
  final postState = ref
      .watch(dataPegawaisNotifierProvider)
      .maybeWhen(orElse: () {}, fetchedArray: ((dataFetch) => dataFetch));

  final referralState = ref
      .watch(dataPegawaisReferralNotifierProvider)
      .maybeWhen(orElse: () {}, fetchedArray: ((dataFetch) => dataFetch));

  final key = ref.watch(keyProviderPegawai);
  final sort = ref.watch(keySortProvider);
  print('Key : ${key}');
  List<Map<String, dynamic>>? thePost =
      postState?.where((post) => post['displayName'].contains(key)).toList();
  print("Refferal : ${referralState}");

  if (sort && thePost != null) {
    thePost.sort((a, b) => b['Nama'].compareTo(a['Nama']));
  }
  final ref2 =
      referralState?.where((post) => post['token'].toString().contains(key));
  if (ref2 != null) {
    thePost?.addAll(ref2);
  }
  // print(
  //     "Refferal after search : ${referralState?.toList()[0]['token'].toString().contains(key)}");
  print("Post : ${thePost}");
  return thePost;
});
