import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/props/text_font.dart';
import '../../core/widget/alert.dart';
import '../../core/widget/loading_screen.dart';
import '../../core/widget/pegawai_avatar.dart';
import '../../features/avatar/avatar_provider.dart';
import '../../features/data/data_pegawai_provider.dart';
import '../../features/fetchController/runOnce.dart';
import '../gaji/gaji_pegawai_admin_view.dart';
import '../presensi/detail_presensi_pegawai.dart';

class PegawaiDetailView extends ConsumerStatefulWidget {
  const PegawaiDetailView(
      {Key? key,
      required User user,
      required Map<String, dynamic> userData,
      required Map<String, dynamic> pegawaiData})
      : _user = user,
        _userData = userData,
        _pegawaiData = pegawaiData,
        super(key: key);

  final User _user;
  final Map<String, dynamic> _userData;
  final Map<String, dynamic> _pegawaiData;

  @override
  ConsumerState<PegawaiDetailView> createState() => _PegawaiDetailViewState();
}

class _PegawaiDetailViewState extends ConsumerState<PegawaiDetailView> {
  late User _user;
  late Map<String, dynamic> _userData;
  late Map<String, dynamic> _pegawaiData;

  late double width;
  late double height;

  late TextEditingController displayName;
  late TextEditingController phone;
  late TextEditingController nominal;

  late String dropdownValue;

  bool _isEditableNama = false;
  bool _isEditableNoHp = false;
  bool _isEditableNominal = false;

  @override
  void initState() {
    super.initState();

    _user = widget._user;
    _userData = widget._userData;
    _pegawaiData = widget._pegawaiData;
    Size screenSize = WidgetsBinding.instance.window.physicalSize;

    displayName = TextEditingController(text: _pegawaiData['displayName']);
    phone = TextEditingController(text: _pegawaiData['phone']);
    nominal = TextEditingController(text: _pegawaiData['gajiPerAbsen']);
    width = screenSize.width;
    height = screenSize.height;

    dropdownValue = _pegawaiData['status'];
  }

  @override
  void didChangeDependencies() {
    print("DID CHANGE DEPEDENCIES");
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    print("TERDISPOSE PEGAWAI DETAIL");

    super.dispose();
  }

  bool _isLoading = false;
  List<String> listOption = ['Aktif', 'Nonaktif'];
  @override
  Widget build(BuildContext context) {
    String? filePath = ref.read(pegawaiDetailAvatarNotifierProvider);

    ref.watch(dataPegawaisNotifierProvider).maybeWhen(orElse: () {
      _isLoading = false;
    }, loading: () {
      print("Saving loading");
      _isLoading = true;
    }, success: () {
      print("SUCCESS PEGAWAI DETAIL");
      myAlertSuccess(context: context);
      _isLoading = false;
    }, unFetch: (message) {
      _isLoading = false;
      myAlertError(
          context: context, text: message ?? "Terjadi Error saat menyimpan");
    });

    if (_isLoading) {
      return const LoadingScreen();
    }
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Pegawai")),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: PegawaiDetailAvatarIcon(
                  imageInheritURL: _pegawaiData['photoURL'],
                )),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: TextJudul(
                      text: (_userData['role'] == "Pemilik")
                          ? "PEMILIK"
                          : "PEGAWAI"),
                ),
                const SizedBox(
                  height: 40,
                ),
                Container(
                  padding: const EdgeInsets.only(top: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextBody6(
                        text: "Nama",
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: width / 3.5,
                            height: 20,
                            child: TextField(
                              enabled: _isEditableNama,
                              controller: displayName,
                              decoration: const InputDecoration(
                                disabledBorder: InputBorder.none,
                                isDense: true,
                                hintText: 'Nama',
                              ),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _isEditableNama = !_isEditableNama;
                              });
                            },
                            icon: _isEditableNama
                                ? const Icon(Icons.check)
                                : const Icon(Icons.edit),
                            color: Theme.of(context).primaryColor,
                          )
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextBody6(
                        text: "No HP",
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            height: 20,
                            width: width / 3.5,
                            child: TextField(
                              keyboardType: TextInputType.phone,
                              enabled: _isEditableNoHp,
                              controller: phone,
                              decoration: const InputDecoration(
                                disabledBorder: InputBorder.none,
                                isDense: true,
                                hintText: 'No Hp',
                              ),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            padding: const EdgeInsets.all(0),
                            style: IconButton.styleFrom(
                                padding: const EdgeInsets.all(0)),
                            onPressed: () {
                              setState(() {
                                _isEditableNoHp = !_isEditableNoHp;
                              });
                            },
                            icon: _isEditableNoHp
                                ? const Icon(Icons.check)
                                : const Icon(Icons.edit),
                            color: Theme.of(context).primaryColor,
                          )
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextBody6(
                        text: "Email",
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Row(
                          children: [
                            SizedBox(
                              width: width / 3.5,
                              child: TextBody4_2(
                                text: _pegawaiData['email'],
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8.0),
                Container(
                  padding: const EdgeInsets.only(top: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextBody6(
                        text: "Nominal gaji/absen",
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 15, right: 5),
                            child: Text('Rp.'),
                          ),
                          SizedBox(
                            height: 20,
                            width: width / 3.8,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              enabled: _isEditableNominal,
                              inputFormatters: [
                                ThousandsSeparatorInputFormatter()
                              ],
                              controller: nominal,
                              decoration: const InputDecoration(
                                prefixStyle:
                                    TextStyle(fontWeight: FontWeight.bold),
                                disabledBorder: InputBorder.none,
                                isDense: true,
                                hintText: 'Nominal',
                              ),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            padding: const EdgeInsets.all(0),
                            style: IconButton.styleFrom(
                                padding: const EdgeInsets.all(0)),
                            onPressed: () {
                              setState(() {
                                _isEditableNominal = !_isEditableNominal;
                              });
                            },
                            icon: _isEditableNominal
                                ? const Icon(Icons.check)
                                : const Icon(Icons.edit),
                            color: Theme.of(context).primaryColor,
                          )
                        ],
                      )
                    ],
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      print(_pegawaiData['gajiPerAbsen']);
                      if (_userData['premium'] == 3) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GajiPegawaiAdminView(
                                    user: _user,
                                    userData: _userData,
                                    pegawaiData: _pegawaiData)));
                      } else {
                        myAlertError(
                            context: context,
                            text: 'Mohon upgrade akun anda dahulu');
                      }
                    },
                    child: const Text("Gaji")),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DetailPresensiPegawai(
                                  user: _user,
                                  userData: _userData,
                                  pegawaiData: _pegawaiData)));
                    },
                    child: const Text("Data Presensi")),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    const Text("Status : "),
                    DropdownButton<String>(
                      value: dropdownValue,
                      icon: const Icon(Icons.arrow_drop_down),
                      elevation: 16,
                      style: const TextStyle(color: Colors.deepPurple),
                      underline: Container(
                        height: 2,
                        color: Colors.deepPurpleAccent,
                      ),
                      onChanged: (String? value) {
                        // This is called when the user selects an item.
                        setState(() {
                          dropdownValue = value!;
                        });
                      },
                      items: listOption
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                Container(
                  width: width,
                  height: 50,
                  padding: const EdgeInsets.only(top: 5),
                  child: GestureDetector(
                    onTap: () {
                      print("TEST");
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextJudul5(
                          text: "Ubah Password",
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                        Icon(
                          Icons.keyboard_arrow_right,
                          color: Theme.of(context).colorScheme.onSecondary,
                        )
                      ],
                    ),
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () {
                        _isLoading = true;
                        filePath = filePath =
                            ref.read(pegawaiDetailAvatarNotifierProvider);
                        // _isLoad = false;
                        ref
                            .read(dataPegawaisNotifierProvider.notifier)
                            .saveDataPegawai(
                                userId: _pegawaiData['uid'],
                                firstname: displayName.text,
                                phone: phone.text,
                                gajiPerAbsen: nominal.text,
                                filePath: filePath,
                                status: dropdownValue)
                            .then((value) {
                          ref.read(pegawaiPageOnceProvider.notifier).reset();
                          myAlertSuccess(context: context);
                        });
                      },
                      child: const TextJudul4(
                        text: 'Simpan',
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height / 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static const separator = '.'; // Change this to '.' for other locales

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Short-circuit if the new value is empty

    if (newValue.text.length == 0) {
      return newValue.copyWith(text: '');
    }

    // Handle "deletion" of separator character
    String oldValueText = oldValue.text.replaceAll(separator, '');
    String newValueText = newValue.text.replaceAll(separator, '');

    if (oldValue.text.endsWith(separator) &&
        oldValue.text.length == newValue.text.length + 1) {
      newValueText = newValueText.substring(0, newValueText.length - 1);
    }

    // Only process if the old value and new value are different
    if (oldValueText != newValueText) {
      int selectionIndex =
          newValue.text.length - newValue.selection.extentOffset;
      final chars = newValueText.split('');

      String newString = '';
      for (int i = chars.length - 1; i >= 0; i--) {
        if ((chars.length - 1 - i) % 3 == 0 && i != chars.length - 1)
          newString = separator + newString;
        newString = chars[i] + newString;
      }

      return TextEditingValue(
        text: newString.toString(),
        selection: TextSelection.collapsed(
          offset: newString.length - selectionIndex,
        ),
      );
    }

    // If the new value and old value are the same, just return as-is
    return newValue;
  }
}
