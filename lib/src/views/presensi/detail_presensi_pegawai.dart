import 'package:expandable/expandable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/props/text_font.dart';
import '../../core/widget/loading_screen.dart';
import '../../features/data/data_presensi_provider.dart';

class DetailPresensiPegawai extends ConsumerStatefulWidget {
  const DetailPresensiPegawai(
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
  ConsumerState<DetailPresensiPegawai> createState() =>
      _DetailPresensiPegawaiState();
}

class DataPresensi {
  const DataPresensi({
    required this.idPegawai,
    required this.dataPresensi,
    required this.tanggal,
    required this.dataForm,
    this.status = false,
  });

  final String idPegawai;
  final DateTime tanggal;
  final Map<String, dynamic> dataPresensi;
  final Map<String, dynamic> dataForm;
  final bool status;

  @override
  String toString() {
    return 'DataPegawai(data: $dataPresensi, checked: $status)';
  }
}

class _DetailPresensiPegawaiState extends ConsumerState<DetailPresensiPegawai> {
  late User _user;
  late Map<String, dynamic> _userData;
  late Map<String, dynamic> _pegawaiData;

  @override
  void initState() {
    super.initState();
    _user = widget._user;
    _userData = widget._userData;
    _pegawaiData = widget._pegawaiData;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ref
          .read(dataPresensiNotifierProvider.notifier)
          .getDataPresensiPegawaiSemua(idPegawai: _pegawaiData['uid']);
    });
  }

  Map<String, dynamic> dataPresensiPegawais = {};
  List<List<dynamic>> listWidgetPresensi = [];
  @override
  void dispose() {
    ref.invalidate(dataPresensiNotifierProvider);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("DATA PEGAWAI : ${_pegawaiData}");

    List<List<DataPresensi>> dataPresensiPegawaisToRead = [];
    ref.watch(dataPresensiNotifierProvider).maybeWhen(
          orElse: () {},
          fetched: (dataFetchArray) {
            dataPresensiPegawais = dataFetchArray;
            print("DATA SEMUA ABSENSI SI PEGAWAI ${dataFetchArray}");
          },
        );
    int count = 0;
    final now = DateTime.now();
    DateTime theDate = DateTime(now.year, now.month, now.day);
    // if (dataPresensiPegawais.isNotEmpty) {
    //   for (Map<String, dynamic> dataForm
    //       in dataPresensiPegawais['dataFormPresensi']) {
    //     print("DATA FORM ${dataForm}");
    //     List<DataPresensi> dataPresensiPegawaiToRead = [];

    //     for (Map<String, dynamic> dataPresensi
    //         in dataPresensiPegawais['dataPresensi']) {
    //       count += 1;

    //       print("DATA dataPresensi ${dataPresensi}");
    //       DateTime tanggal = dataForm['tanggalDibuat'].toDate();
    //       for (String hari in dataForm['hari']) {
    //         while (tanggal.isBefore(theDate) ||
    //             tanggal.isAtSameMomentAs(theDate)) {
    //           if (dataForm['uid'] == dataPresensi['idFormPresensi']) {
    //             print("BENER");
    //             String hariKey = '';
    //             final theDay = DateFormat('dd/MM/yyyy')
    //                 .parse(dataPresensi['tanggalPresensi']);
    //             if (theDay.weekday == DateTime.sunday) {
    //               hariKey = 'minggu';
    //             } else if (theDay.weekday == DateTime.monday) {
    //               hariKey = 'senin';
    //             } else if (theDay.weekday == DateTime.tuesday) {
    //               hariKey = 'selasa';
    //             } else if (theDay.weekday == DateTime.wednesday) {
    //               hariKey = 'rabu';
    //             } else if (theDay.weekday == DateTime.thursday) {
    //               hariKey = 'kamis';
    //             } else if (theDay.weekday == DateTime.friday) {
    //               hariKey = 'jumat';
    //             } else if (theDay.weekday == DateTime.saturday) {
    //               hariKey = 'sabtu';
    //             }
    //             // print("Hari : ${hariKey}");
    //             // print(
    //             //     "TANGGAL : ${DateFormat('dd/MM/yyyy').format(tanggal) == dataPresensi['tanggalPresensi']}");
    //             // print(
    //             //     "Tanggal iter ${DateFormat('dd/MM/yyyy').format(tanggal)}");
    //             // print(
    //             //     "Tanggal data presensi ${dataPresensi['tanggalPresensi']}");
    //             if (dataPresensi['status'] == 'Absen' &&
    //                 hariKey == hari &&
    //                 DateFormat('dd/MM/yyyy').format(tanggal) ==
    //                     dataPresensi['tanggalPresensi']) {
    //               dataPresensiPegawaiToRead.add(
    //                 DataPresensi(
    //                     tanggal: tanggal,
    //                     idPegawai: dataForm['idAdmin'],
    //                     dataForm: dataForm,
    //                     dataPresensi: dataPresensi,
    //                     status: true),
    //               );
    //             } else {
    //               dataPresensiPegawaiToRead.add(
    //                 DataPresensi(
    //                     tanggal: tanggal,
    //                     idPegawai: dataForm['idAdmin'],
    //                     dataForm: dataForm,
    //                     dataPresensi: dataPresensi,
    //                     status: false),
    //               );
    //             }
    //           } else {
    //             print("${dataForm['uid'] == dataPresensi['idFormPresensi']}");
    //             print("Data Form : ${dataForm['uid']}");
    //             print("Data Presensi : ${dataPresensi['idFormPresensi']}");
    //           }

    //           // print("The tanggal ${tanggal}");
    //           tanggal = DateTime(tanggal.year, tanggal.month, tanggal.day + 1);
    //         }
    //       }
    //     }

    //     dataPresensiPegawaisToRead.add(dataPresensiPegawaiToRead);
    //   }
    // } else {
    //   return const LoadingScreen();
    // }

    if (dataPresensiPegawais.isNotEmpty) {
      for (Map<String, dynamic> dataForm
          in dataPresensiPegawais['dataFormPresensi']) {
        Map<String, DataPresensi> dataPresensiPegawaiToRead = {};
        for (Map<String, dynamic> dataPresensi
            in dataPresensiPegawais['dataPresensi']) {
          count += 1;
          DateTime tanggal = dataForm['tanggalDibuat'].toDate();
          int minggu = 0;
          while (
              tanggal.isBefore(theDate) || tanggal.isAtSameMomentAs(theDate)) {
            String hariKey = '';
            if (tanggal.weekday == DateTime.sunday) {
              hariKey = 'minggu';
            } else if (tanggal.weekday == DateTime.monday) {
              hariKey = 'senin';
            } else if (tanggal.weekday == DateTime.tuesday) {
              hariKey = 'selasa';
            } else if (tanggal.weekday == DateTime.wednesday) {
              hariKey = 'rabu';
            } else if (tanggal.weekday == DateTime.thursday) {
              hariKey = 'kamis';
            } else if (tanggal.weekday == DateTime.friday) {
              hariKey = 'jumat';
            } else if (tanggal.weekday == DateTime.saturday) {
              hariKey = 'sabtu';
              minggu += 1;
            }

            for (String hari in dataForm['hari']) {
              if (dataForm['uid'] == dataPresensi['idFormPresensi'] &&
                  hari == hariKey) {
                // print("Hari : ${hariKey}");
                // print(
                //     "TANGGAL : ${DateFormat('dd/MM/yyyy').format(tanggal) == dataPresensi['tanggalPresensi']}");
                // print(
                //     "Tanggal iter ${DateFormat('dd/MM/yyyy').format(tanggal)}");
                // print(
                //     "Tanggal data presensi ${dataPresensi['tanggalPresensi']}");

                if (dataPresensi['status'] == 'Absen' &&
                    DateFormat('dd/MM/yyyy').format(tanggal) ==
                        dataPresensi['tanggalPresensi']) {
                  dataPresensiPegawaiToRead.addEntries({
                    "${dataForm['uid'].toString()} ${hari} $minggu":
                        DataPresensi(
                            tanggal: tanggal,
                            idPegawai: dataForm['idAdmin'],
                            dataForm: dataForm,
                            dataPresensi: dataPresensi,
                            status: true),
                  }.entries);
                } else {
                  if (!dataPresensiPegawaiToRead.containsKey(
                      "${dataForm['uid'].toString()} ${hari} $minggu")) {
                    dataPresensiPegawaiToRead.addEntries({
                      "${dataForm['uid'].toString()} ${hari} $minggu":
                          DataPresensi(
                              tanggal: tanggal,
                              idPegawai: dataForm['idAdmin'],
                              dataForm: dataForm,
                              dataPresensi: dataPresensi,
                              status: false),
                    }.entries);
                  }
                }
              }

              // print("The tanggal ${tanggal}");
            }

            tanggal = DateTime(tanggal.year, tanggal.month, tanggal.day + 1);
          }
        }
        dataPresensiPegawaisToRead
            .add(dataPresensiPegawaiToRead.values.toList());
      }
    } else {
      return const LoadingScreen();
    }

    print("total count : ${count}");
    print(dataPresensiPegawaisToRead);
    List<Widget> theWidget = [];
    if (dataPresensiPegawais.isNotEmpty) {
      for (List<DataPresensi> dataList in dataPresensiPegawaisToRead) {
        List<Widget> sangWidget = [];
        for (DataPresensi data in dataList) {
          final dataPresensi = data.dataPresensi;
          final dataForm = data.dataForm;
          final status = data.status;
          final tanggal = data.tanggal;
          sangWidget.add(
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.all(30),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "${DateFormat('EEEE, d-MM-yyyy', 'id_ID').format(tanggal)}"),
                        Text(
                            "Waktu : ${dataForm['waktuAwal']} - ${dataForm['waktuAkhir']} WIB"),
                        Text(
                            "Waktu Presensi: ${(status) ? DateFormat('HH:mm:ss').format(dataPresensi['waktuPresensi'].toDate()) : '-'}"),
                      ],
                    ),
                    (!status)
                        ? Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: Colors.red[400],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            child: TextBody4(text: 'Alpha'),
                          )
                        : Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: Colors.green[400],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            child: TextBody4(text: 'Hadir'),
                          ),
                  ],
                ),
              ),
            ),
          );
        }
        ExpandableController _controller = ExpandableController();

        theWidget.add(
          (dataList.isNotEmpty)
              ? StatefulBuilder(
                  builder: (context, setState) {
                    return ExpandablePanel(
                        controller: _controller,
                        collapsed: TextButton(
                            onPressed: () {
                              setState(() {
                                _controller.toggle();
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    "${DateFormat('EEEE, d-MM-yyyy', 'id_ID').format(dataList[0].dataForm['tanggalDibuat'].toDate())}"),
                                Row(
                                  children: [
                                    Text(
                                        "${dataList[0].dataForm['waktuAwal']} - ${dataList[0].dataForm['waktuAkhir']}"),
                                    const Icon(Icons.arrow_drop_down)
                                  ],
                                ),
                              ],
                            )),
                        expanded: (dataList.isNotEmpty)
                            ? Column(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _controller.toggle();
                                      });
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            "${DateFormat('EEEE, d-MM-yyyy', 'id_ID').format(dataList[0].dataForm['tanggalDibuat'].toDate())}"),
                                        Row(
                                          children: [
                                            Text(
                                                "${dataList[0].dataForm['waktuAwal']} - ${dataList[0].dataForm['waktuAkhir']}"),
                                            const Icon(Icons.arrow_drop_up)
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  ...sangWidget
                                ],
                              )
                            : Container());
                  },
                )
              : Container(),
        );
      }
    } else {
      print("NO DATA");
    }

    return Scaffold(
        appBar: AppBar(
          title: Text("Riwayat Presensi"),
        ),
        body: SingleChildScrollView(child: Column(children: theWidget)));
  }
}
