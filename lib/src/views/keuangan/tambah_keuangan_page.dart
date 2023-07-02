import 'package:com.ppl.teman_agro_admin/src/core/props/text_font.dart';
import 'package:com.ppl.teman_agro_admin/src/core/widget/alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../features/data/data_pemasukkan_pengeluaran_provider.dart';

class DetailKeuanganView extends ConsumerStatefulWidget {
  const DetailKeuanganView(
      {super.key,
      required this.user,
      required this.userData,
      this.dataKeuangan});

  final User user;
  final Map<String, dynamic> userData;
  final Map<String, dynamic>? dataKeuangan;

  @override
  ConsumerState<DetailKeuanganView> createState() => _DetailKeuanganViewState();
}

class _DetailKeuanganViewState extends ConsumerState<DetailKeuanganView> {
  late Map<String, dynamic> _userData;
  late Map<String, dynamic>? _dataKeuangan;
  late User _user;

  late DateTime tanggal;

  late TextEditingController nominalController;
  late TextEditingController keteranganController;

  String dropdownValue = 'Pemasukan';
  List<String> listOptionBulan = ['Pemasukan', 'Pengeluaran'];

  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _userData = widget.userData;
    _dataKeuangan = widget.dataKeuangan;

    if (_dataKeuangan != null) {
      tanggal = _dataKeuangan!['tanggal'].toDate();
    } else {
      tanggal = DateTime.now();
    }
    nominalController = TextEditingController(
        text: (_dataKeuangan != null) ? _dataKeuangan!['nominal'] : null);
    keteranganController = TextEditingController(
        text: (_dataKeuangan != null) ? _dataKeuangan!['deskripsi'] : null);
  }

  @override
  void dispose() {
    nominalController.dispose();
    keteranganController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Keuangan"),
        actions: [
          (_dataKeuangan != null)
              ? Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: IconButton(
                    onPressed: () {
                      ref
                          .read(dataPemasukkanPengeluaranNotifierProvider
                              .notifier)
                          .deletePemasukkanPengeluaran(
                              dataPemasukkan: _dataKeuangan!);
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.delete),
                  ),
                )
              : Container()
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10))),
                    child: DropdownButton<String>(
                      value: dropdownValue,
                      icon: const Padding(
                        padding: EdgeInsets.only(right: 4.0),
                        child: Icon(Icons.arrow_drop_down),
                      ),
                      iconDisabledColor: Colors.white,
                      iconEnabledColor: Colors.white,
                      elevation: 16,
                      isDense: true,
                      underline: Container(),
                      dropdownColor: Theme.of(context).primaryColor,
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      onChanged: (String? value) {
                        // This is called when the user selects an item.
                        setState(() {
                          dropdownValue = value!;
                        });
                      },
                      items: listOptionBulan
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Container(
                            padding: const EdgeInsets.only(right: 60, left: 20),
                            child: TextBody3(
                              text: value,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextBody6(
                            text: "Tanggal",
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                          Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                              color: Colors.black,
                              width: 1.0, // Underline thickness
                            ))),
                            child: InkWell(
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                child: TextPickTime2(
                                    text: DateFormat('dd/MM/yyyy')
                                        .format(tanggal),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary),
                              ),
                              onTap: () async {
                                showDatePicker(
                                  context: context,
                                  initialDate: tanggal,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2099),
                                ).then((date) {
                                  print(date);
                                  if (date != null) {
                                    setState(() {
                                      tanggal = date;
                                    });
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextBody6(
                                  text: "Nominal",
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: TextFormField(
                                    inputFormatters: [
                                      ThousandsSeparatorInputFormatter()
                                    ],
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                        prefixText: 'Rp '),
                                    controller: nominalController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Harus diisi';
                                      }
                                      if (int.tryParse(
                                              value.replaceAll(".", "")) ==
                                          null) {
                                        return 'Angka tidak valid';
                                      } else if (int.parse(
                                              value.replaceAll(".", "")) <=
                                          0) {
                                        return 'Masukkan nominal';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextBody6(
                                  text: "Keterangan",
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: TextFormField(
                                    controller: keteranganController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Harus diisi';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.center,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ref
                          .read(dataPemasukkanPengeluaranNotifierProvider
                              .notifier)
                          .saveDataPemasukkanPengeluaran(
                              userData: _userData,
                              oldData: _dataKeuangan,
                              tanggal: tanggal,
                              nominal: nominalController.text,
                              deskripsi: keteranganController.text,
                              tipe: dropdownValue)
                          .then((value) {
                        myAlertSuccess(
                            context: context,
                            text: 'Data berhasil dibuat',
                            fun: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            });
                      });
                    }
                  },
                  child: const TextJudul4(
                    text: 'Simpan',
                  ),
                ),
              )
            ],
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
