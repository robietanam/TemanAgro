import 'package:com.ppl.teman_agro_admin/src/core/props/text_font.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/widget/alert.dart';
import '../../features/data/data_gaji_provider.dart';
import '../../features/data/data_pegawai_provider.dart';
import 'gaji_detail_view.dart';

class GajiPegawaiAdminView extends ConsumerStatefulWidget {
  const GajiPegawaiAdminView(
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
  ConsumerState<GajiPegawaiAdminView> createState() => _GajiPegawaiViewState();
}

class _GajiPegawaiViewState extends ConsumerState<GajiPegawaiAdminView> {
  List<Map<String, dynamic>> listDataPegawai = [];
  late User _user;
  late Map<String, dynamic> _userData;
  late Map<String, dynamic> _pegawaiData;

  late DateTime tanggalAwal;
  late DateTime tanggalAkhir;

  late double width;
  late double height;

  @override
  void initState() {
    super.initState();
    _user = widget._user;
    _userData = widget._userData;
    _pegawaiData = widget._pegawaiData;
    Size screenSize = WidgetsBinding.instance.window.physicalSize;

    width = screenSize.width;
    height = screenSize.height;

    final now = DateTime.now();

    tanggalAwal = DateTime(now.year, now.month, now.day - 30);
    tanggalAkhir = DateTime(now.year, now.month, now.day);
    SchedulerBinding.instance.addPostFrameCallback(
      (_) {
        ref.read(dataPegawaisNotifierProvider).maybeWhen(
          orElse: () {
            ref
                .read(dataPegawaisNotifierProvider.notifier)
                .getDataPegawai(userData: _userData);

            ref
                .read(dataGajiNotifierProvider.notifier)
                .getDataGajiPegawai(dataPegawai: _pegawaiData);
          },
        );
      },
    );
  }

  bool checkValue = false;
  List<Map<String, dynamic>> dataGaji = [];
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> listWidgetNya = [];

    ref.watch(dataPegawaisNotifierProvider).maybeWhen(
          orElse: () {},
          fetchedArray: (dataFetchArray) {
            listDataPegawai = dataFetchArray.toList();
          },
        );

    ref.watch(dataGajiNotifierProvider).maybeWhen(
          orElse: () {},
          success: () {
            SchedulerBinding.instance.addPostFrameCallback(
              (_) {
                ref.read(dataPegawaisNotifierProvider).maybeWhen(
                  orElse: () {
                    ref
                        .read(dataGajiNotifierProvider.notifier)
                        .getDataGajiPegawai(dataPegawai: _pegawaiData);
                  },
                );
                myAlertSuccess(
                    context: context, text: 'Data gaji berhasil ditambahkan');
              },
            );
            ;
          },
          loading: () {},
          fetchedArray: (dataFetchArray) {
            dataGaji = dataFetchArray.toList();
          },
        );

    if (dataGaji.isNotEmpty) {
      for (Map<String, dynamic> gaji in dataGaji) {
        listWidgetNya.add(ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GajiDetailView(
                    user: _user,
                    userData: _userData,
                    pegawaiData: _pegawaiData,
                    gajiData: gaji),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            elevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    size: 40,
                    Icons.book,
                    color: Theme.of(context).colorScheme.secondaryContainer,
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextBody3(
                          text: DateFormat('yyyy/MM/')
                              .format(gaji['tanggalDibuat'].toDate()),
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                        TextBody4(
                          text:
                              "${DateFormat('dd/MM/yyyy').format(gaji['tanggalAwal'].toDate())} - ${DateFormat('dd/MM/yyyy').format(gaji['tanggalAkhir'].toDate())}",
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: TextBody4(
                  text: "Lihat detail >",
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ],
          ),
        ));
      }
    }

    print("List data pegawai : ${listDataPegawai}");
    print("Data pegawai : ${_pegawaiData}");

    print("DATA GAJI : ${dataGaji}");
    return Scaffold(
      appBar: AppBar(title: Text("Detail Pegawai")),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: TextBody3(
                    text: "Range tanggal",
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
                Container(
                    padding: const EdgeInsets.all(10),
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
                    child: Column(children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                color: Colors.black,
                                width: 2.0, // Underline thickness
                              ))),
                              child: TextPickTime(
                                  text: DateFormat('dd/MM/yyyy')
                                      .format(tanggalAwal),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondary),
                            ),
                            onTap: () async {
                              showDatePicker(
                                context: context,
                                initialDate: tanggalAwal,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2099),
                              ).then((date) {
                                print(date);
                                if (date != null) {
                                  setState(() {
                                    tanggalAwal = date;
                                  });
                                }
                              });
                            },
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextJudul(
                                text: "-",
                                color:
                                    Theme.of(context).colorScheme.onSecondary),
                          ),
                          InkWell(
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                color: Colors.black,
                                width: 2.0, // Underline thickness
                              ))),
                              child: TextPickTime(
                                  text: DateFormat('dd/MM/yyyy')
                                      .format(tanggalAkhir),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondary),
                            ),
                            onTap: () async {
                              showDatePicker(
                                context: context,
                                initialDate: tanggalAkhir,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2099),
                              ).then((date) {
                                print(date);
                                if (date != null) {
                                  setState(() {
                                    tanggalAkhir = date;
                                  });
                                }
                              });
                            },
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextBody6(
                            text: "Terapkan ke semua pegawai",
                            color: Theme.of(context).primaryColor,
                          ),
                          Checkbox(
                            value: checkValue,
                            onChanged: (value) {
                              setState(() {
                                checkValue = value ?? checkValue;
                              });
                            },
                          ),
                        ],
                      ), //Checkbox
                    ])),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: () {
                        if (_pegawaiData['gajiPerAbsen'] != null) {
                          if (checkValue) {
                            print("SEMUA DATA");
                            ref
                                .read(dataGajiNotifierProvider.notifier)
                                .createDataGajiPegawaiSemua(
                                    dataPegawais: listDataPegawai,
                                    dataAdmin: _userData,
                                    waktuAwal: tanggalAwal,
                                    waktuAkhir: tanggalAkhir);
                          } else {
                            ref
                                .read(dataGajiNotifierProvider.notifier)
                                .createDataGajiPegawai(
                                    dataPegawai: _pegawaiData,
                                    dataAdmin: _userData,
                                    waktuAwal: tanggalAwal,
                                    waktuAkhir: tanggalAkhir);
                          }
                        } else {
                          myAlertError(
                              context: context,
                              text:
                                  "Mohon tambah dan simpan data gaji per absen terlebih dahulu");
                        }
                      },
                      child: TextJudul2(
                        text: "Tambah Gaji Pegawai",
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: TextBody3(
                    text: "Riwayat Gaji",
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
                (dataGaji.isNotEmpty)
                    ? Column(
                        children: listWidgetNya,
                      )
                    : TextBody6(
                        text: "Riwayat kosong",
                        color: Theme.of(context).colorScheme.onSecondary)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
