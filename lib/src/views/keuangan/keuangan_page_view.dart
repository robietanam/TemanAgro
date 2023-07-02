import 'package:com.ppl.teman_agro_admin/src/core/props/text_font.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../core/widget/alert.dart';
import '../../features/data/data_pemasukkan_pengeluaran_provider.dart';
import 'pdf_laporan_keuangan.dart';
import 'tambah_keuangan_page.dart';

class KeuanganView extends ConsumerStatefulWidget {
  const KeuanganView({super.key, required this.user, required this.userData});

  final User user;
  final Map<String, dynamic> userData;

  @override
  ConsumerState<KeuanganView> createState() => _KeuanganViewState();
}

class _KeuanganViewState extends ConsumerState<KeuanganView> {
  late Map<String, dynamic> _userData;
  late User _user;

  late String dropdownValue;
  late List<String> listOptionBulan;

  late TextEditingController tahunController;

  List<Map<String, dynamic>> dataPemasukkanPengeluaran = [];

  String getMonth(int month) {
    return DateFormat('MMMM', 'id_ID').format(DateTime(2020, month, 1));
  }

  DateTime toMonth(String month, int year) {
    return DateTime(year, DateFormat('MMMM', 'id_ID').parse(month).month, 1);
  }

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _userData = widget.userData;
    dropdownValue = getMonth(DateTime.now().month);
    listOptionBulan = [
      getMonth(DateTime.january),
      getMonth(DateTime.february),
      getMonth(DateTime.march),
      getMonth(DateTime.april),
      getMonth(DateTime.may),
      getMonth(DateTime.june),
      getMonth(DateTime.july),
      getMonth(DateTime.august),
      getMonth(DateTime.september),
      getMonth(DateTime.october),
      getMonth(DateTime.november),
      getMonth(DateTime.december),
    ];
    tahunController = TextEditingController(text: "2023");

    SchedulerBinding.instance.addPostFrameCallback((_) {
      ref
          .read(dataPemasukkanPengeluaranNotifierProvider.notifier)
          .getPemasukkanPengeluaran(
              userData: _userData, tanggal: DateTime.now());
    });

    print(listOptionBulan);
  }

  @override
  void dispose() {
    tahunController.dispose();
    super.dispose();
  }

  String toRp(int newValueText) {
    bool isNeg = false;
    if (newValueText.isNegative) {
      newValueText = newValueText.abs();
      isNeg = true;
    }
    final chars = newValueText.toString().split('');
    const separator = '.';
    String newString = '';
    for (int i = chars.length - 1; i >= 0; i--) {
      if ((chars.length - 1 - i) % 3 == 0 && i != chars.length - 1) {
        newString = separator + newString;
      }
      newString = chars[i] + newString;
    }
    if (isNeg) {
      return ' -' + newString;
    }
    return newString;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(dataPemasukkanPengeluaranNotifierProvider).maybeWhen(
          orElse: () {},
          success: () {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              ref
                  .read(dataPemasukkanPengeluaranNotifierProvider.notifier)
                  .getPemasukkanPengeluaran(
                      userData: _userData, tanggal: DateTime.now());
            });
          },
          fetchedArray: (dataFetchArray) {
            dataPemasukkanPengeluaran = dataFetchArray.toList();
          },
        );

    print("DATA DI BUILD ${dataPemasukkanPengeluaran}");

    int jumlahPemasukkan = 0;
    int jumlahPengeluaran = 0;
    int jumlahTotal = 0;

    if (dataPemasukkanPengeluaran.isNotEmpty) {
      for (var data in dataPemasukkanPengeluaran) {
        if (data['tipe'] == 'Pengeluaran') {
          jumlahPengeluaran += int.parse(data['nominal'].replaceAll('.', ''));
        } else {
          jumlahPemasukkan += int.parse(data['nominal'].replaceAll('.', ''));
        }
      }
      jumlahTotal = jumlahPemasukkan - jumlahPengeluaran;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Keuangan"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
                onPressed: () async {
                  if (_userData['premium'] > 0) {
                    if (int.tryParse(tahunController.text) != null) {
                      if (dataPemasukkanPengeluaran.isNotEmpty) {
                        await Printing.layoutPdf(
                            onLayout: (format) => generateDocument(
                                PdfPageFormat.a4, dataPemasukkanPengeluaran));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Tidak ada data untuk di print')));
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Format tahun tidak benar')));
                    }
                  } else {
                    myAlertError(
                        context: context,
                        text: 'Mohon upgrade akun anda dahulu');
                  }
                },
                icon: const Icon(
                  Icons.print,
                )),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Row(
                      children: [
                        Text("Bulan : "),
                        Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10))),
                          child: DropdownButton<String>(
                            isDense: true,
                            value: dropdownValue,
                            icon: const Padding(
                              padding: EdgeInsets.only(right: 4.0),
                              child: Icon(Icons.arrow_drop_down),
                            ),
                            iconDisabledColor: Colors.white,
                            iconEnabledColor: Colors.white,
                            elevation: 16,
                            underline: Container(),
                            dropdownColor: Theme.of(context).primaryColor,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            onChanged: (String? value) {
                              setState(() {
                                dropdownValue = value!;
                              });
                            },
                            items: listOptionBulan
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      right: 20, left: 20),
                                  child: TextBody3(
                                    text: value,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        children: [
                          Text("Tahun"),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Container(
                              width: 50,
                              child: TextField(
                                controller: tahunController,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          if (int.tryParse(tahunController.text) != null) {
                            ref
                                .read(dataPemasukkanPengeluaranNotifierProvider
                                    .notifier)
                                .getPemasukkanPengeluaran(
                                    userData: _userData,
                                    tanggal: toMonth(dropdownValue,
                                        int.parse(tahunController.text)));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Format tahun tidak benar')));
                          }
                        },
                        icon: Icon(
                          Icons.search,
                          color: Theme.of(context).primaryColor,
                        ))
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 1.0), //(x,y)
                          blurRadius: 6.0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: Container(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      right: BorderSide(
                                          color: Colors.black, width: 0.5),
                                      bottom: BorderSide(
                                          color: Colors.black, width: 0.5),
                                    ),
                                  ),
                                  child: Center(
                                      child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      children: [
                                        TextBody4(
                                          text: "Pemasukkan",
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondaryContainer,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 4),
                                              child: Icon(
                                                size: 20,
                                                Icons.arrow_upward,
                                                color: Colors.green[300],
                                              ),
                                            ),
                                            Text(
                                                "Rp ${toRp(jumlahPemasukkan)}"),
                                          ],
                                        )
                                      ],
                                    ),
                                  ))),
                            ),
                            Expanded(
                              child: Container(
                                decoration: const BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                        color: Colors.black, width: 0.5),
                                    bottom: BorderSide(
                                        color: Colors.black, width: 0.5),
                                  ),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        TextBody4(
                                          text: "Pengeluaran",
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondaryContainer,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 4),
                                              child: Icon(
                                                size: 20,
                                                Icons.arrow_downward,
                                                color: Colors.red[300],
                                              ),
                                            ),
                                            Text(
                                                "Rp ${toRp(jumlahPengeluaran)}"),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Center(
                            child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              TextBody4(
                                text: "Total Pemasukkan Pengeluaran",
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Rp ${toRp(jumlahTotal)}"),
                                ],
                              )
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          (dataPemasukkanPengeluaran.isNotEmpty)
              ? Expanded(
                  child: ListView.builder(
                  itemCount: dataPemasukkanPengeluaran.length,
                  itemBuilder: (context, index) {
                    final dataPemasukkan = dataPemasukkanPengeluaran[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailKeuanganView(
                                user: _user,
                                userData: _userData,
                                dataKeuangan: dataPemasukkan,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          elevation: 0,
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  (dataPemasukkan['tipe'] == 'Pemasukan')
                                      ? Icon(
                                          size: 20,
                                          Icons.arrow_upward,
                                          color: Colors.green[300],
                                        )
                                      : Icon(
                                          size: 20,
                                          Icons.arrow_downward,
                                          color: Colors.red[300],
                                        ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextBody4(
                                            text: DateFormat(
                                                    'EEEE, dd MM yyyy', 'id_ID')
                                                .format(
                                                    dataPemasukkan['tanggal']
                                                        .toDate()),
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer,
                                          ),
                                          TextBody4(
                                            text: dataPemasukkan['deskripsi'],
                                            maxLines: 1,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSecondary,
                                          ),
                                          TextBody3(
                                            text: dataPemasukkan['nominal'],
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSecondary,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: TextBody4(
                                text: "Lihat detail >",
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ))
              : const Expanded(child: Text("Tidak Ada Data")),
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => DetailKeuanganView(
                        userData: _userData,
                        user: _user,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                ),
                child: const TextJudul4(
                  text: "Tambah",
                )),
          )
        ],
      ),
    );
  }
}
