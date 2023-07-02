import 'package:com.ppl.teman_agro_admin/src/core/widget/alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/props/text_font.dart';
import '../../features/data/data_pegawai_provider.dart';
import '../../features/data/data_presensi_provider.dart';
import '../../features/data/state/data_user_state.dart';
import '../common/absensi_dashboard.dart';
import '../../core/widget/daftar_barang_view.dart';

class HomePageContentViewPegawai extends ConsumerStatefulWidget {
  const HomePageContentViewPegawai(
      {Key? key, required User user, required Map<String, dynamic> userData})
      : _user = user,
        _userData = userData,
        super(key: key);

  final User _user;
  final Map<String, dynamic> _userData;

  @override
  ConsumerState<HomePageContentViewPegawai> createState() =>
      _HomePageContentState();
}

class _HomePageContentState extends ConsumerState<HomePageContentViewPegawai> {
  late User _user;
  late Map<String, dynamic> _userData;

  @override
  void initState() {
    print("HomePage init state");
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ref
          .read(dataFormPresensiNotifierProvider.notifier)
          .getDataFormPresensiPegawai(
              idPegawai: _user.uid, hari: DateTime.now());
      ref
          .read(dataPresensiNotifierProvider.notifier)
          .getDataPresensiSehari(idPegawai: _user.uid, hari: DateTime.now());
    });
    super.initState();
  }

  @override
  void dispose() {
    print("HomePage Disposed");
    // TODO: implement dispose
    super.dispose();
  }

  bool _isLoadingPegawai = false;

  List<Map<String, dynamic>> _dataPresensis = [];
  DateTime _selectedDay = DateTime.now();
  @override
  Widget build(BuildContext context) {
    _user = widget._user;
    _userData = widget._userData;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    print(_selectedDay);

    List<Widget> pegawaisWidget = [];
    List<Map<String, dynamic>?> _dataAbsensi = [];

    ref.watch(dataPresensiNotifierProvider).maybeWhen(
          orElse: () {},
          fetchedArray: (dataFetchArray) {
            print("data presensi hari itu ${dataFetchArray}");
            _dataPresensis = dataFetchArray.toList();
          },
          success: () {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              myAlertSuccess(context: context, text: "Presensi Terekam");
              ref
                  .read(dataPresensiNotifierProvider.notifier)
                  .getDataPresensiSehari(
                      idPegawai: _user.uid, hari: DateTime.now());
            });
          },
          unFetch: (message) {
            print("DAH MASUK :()");
            SchedulerBinding.instance.addPostFrameCallback((_) {
              myAlertError(context: context, text: message ?? "Data Tidak ada");
            });
          },
        );

    ref.watch(dataFormPresensiNotifierProvider).maybeWhen(
      orElse: () {
        print("DUDE ORELSE");
      },
      fetchedArray: (dataFetchArray) {
        print("Data form presensi : ${dataFetchArray}");

        DateTime hari = _selectedDay;
        String hariKey = '';
        // final todayDate = DateFormat('dd/MM/yyyy').format(hari);
        final todayDate = DateTime.now();
        if (hari.weekday == DateTime.sunday) {
          hariKey = 'minggu';
        } else if (hari.weekday == DateTime.monday) {
          hariKey = 'senin';
        } else if (hari.weekday == DateTime.tuesday) {
          hariKey = 'selasa';
        } else if (hari.weekday == DateTime.wednesday) {
          hariKey = 'rabu';
        } else if (hari.weekday == DateTime.thursday) {
          hariKey = 'kamis';
        } else if (hari.weekday == DateTime.friday) {
          hariKey = 'jumat';
        } else if (hari.weekday == DateTime.saturday) {
          hariKey = 'sabtu';
        }
        print("Hari : ${hariKey}");

        _dataAbsensi = dataFetchArray.map((e) {
          List haris = e['hari'];
          print("Harinye ${e['hari']}");
          if (haris.contains(hariKey)) {
            return e;
          }
        }).toList();
      },
    );

    for (var x in _dataAbsensi) {
      if (x != null) {
        Map<String, dynamic> dataPresensi = {};
        for (var y in _dataPresensis) {
          if (x['uid'] == y['idFormPresensi']) {
            dataPresensi = y;
          }
        }
        print('DATA PRESENSI NYE ${dataPresensi}');
        pegawaisWidget.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.0, 1.0), //(x,y)
                    blurRadius: 6.0,
                  ),
                ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    children: [
                      Icon(
                        size: width / 17,
                        Icons.access_time_sharp,
                        color: Colors.red,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: TextBody4(
                            text: "${x['waktuAwal']} - ${x['waktuAkhir']}",
                            color: Theme.of(context).colorScheme.onSecondary),
                      )
                    ],
                  ),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      (dataPresensi['status'] != 'Absen')
                          ? Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color: Colors.red[400],
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                              child: TextBody4(text: 'Belum Presensi'),
                            )
                          : Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color: Colors.green[400],
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                              child: TextBody4(text: 'Sudah Presensi'),
                            ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: const RoundedRectangleBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)))),
                          onPressed: () {
                            ref
                                .read(dataPresensiNotifierProvider.notifier)
                                .createDataPresensi(
                                    dataFormPresensi: x,
                                    idPeriodikPresensi: dataPresensi['uid'],
                                    tanggalDipilih: _selectedDay,
                                    idPegawai: _user.uid,
                                    idAdmin: _userData['idAdmin']);
                            print('DATA ABSENSI : $x');
                          },
                          child: const TextBody4(
                            text: "Presensi",
                          )),
                    ])
              ],
            ),
          ),
        ));
      }
    }

    return RefreshIndicator(
        onRefresh: () async {
          print("Refressed");
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 12),
          child: ListView(children: [
            AbsensiDashboard(userData: _userData),
            TableCalendar(
              locale: 'id_ID',
              headerVisible: false,
              calendarFormat: CalendarFormat.week,
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              calendarBuilders: CalendarBuilders(
                todayBuilder: (context, day, focusedDay) {
                  return Center(
                    child: Container(
                        height: width / 9.5,
                        width: width / 9.5,
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(width)),
                            border: Border.all(
                                width: 2,
                                color: Theme.of(context).primaryColor)),
                        child: Padding(
                          padding: EdgeInsets.all(width / 42),
                          child: Text(
                            day.day.toString(),
                          ),
                        )),
                  );
                },
              ),
              focusedDay: _selectedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                ref
                    .read(dataFormPresensiNotifierProvider.notifier)
                    .getDataFormPresensiPegawai(
                        idPegawai: _user.uid, hari: selectedDay);
                ref
                    .read(dataPresensiNotifierProvider.notifier)
                    .getDataPresensiSehari(
                        idPegawai: _user.uid, hari: selectedDay);
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                  });
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: TextBody3(
                text: "Data Presensi",
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: (pegawaisWidget.isNotEmpty)
                  ? Column(
                      children: pegawaisWidget,
                    )
                  : const Text("Tidak ada data presensi"),
            ),
          ]),
        ));
  }
}
