import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/props/text_font.dart';
import '../../core/widget/alert.dart';
import '../../features/data/data_pegawai_provider.dart';
import '../../features/data/data_presensi_provider.dart';
import '../../features/data/state/data_user_state.dart';
import '../common/absensi_dashboard.dart';
import '../../core/widget/daftar_barang_view.dart';
import '../keuangan/keuangan_page_view.dart';
import '../presensi/presensi_pegawai.dart';

class HomePageContentView extends ConsumerStatefulWidget {
  const HomePageContentView(
      {Key? key, required User user, required Map<String, dynamic> userData})
      : _user = user,
        _userData = userData,
        super(key: key);

  final User _user;
  final Map<String, dynamic> _userData;

  @override
  ConsumerState<HomePageContentView> createState() => _HomePageContentState();
}

class _HomePageContentState extends ConsumerState<HomePageContentView> {
  late User _user;
  late Map<String, dynamic> _userData;

  List<Map<String, dynamic>> _dataPegawais = [];
  @override
  void initState() {
    print("HomePage init state");
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ref
          .read(dataFormPresensiNotifierProvider.notifier)
          .getDataFormPresensi(idAdmin: _user.uid, hari: DateTime.now());
      ref
          .read(dataPresensiNotifierProvider.notifier)
          .getDataPresensiSehariAdmin(idAdmin: _user.uid, hari: DateTime.now());
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

    ref.watch(dataPresensiNotifierProvider).maybeWhen(
          orElse: () {},
          fetchedArray: (dataFetchArray) {
            print("data presensi hari itu Admin ${dataFetchArray}");
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

    FetchDataState refWidget = ref.read(dataPegawaisNotifierProvider);
    bool fetchAgain = false;
    refWidget.maybeWhen(orElse: () {
      fetchAgain = true;
    }, fetchedArray: (dataPegawai) {
      print("DATA PEGAWAI IN INIT ${dataPegawai}");
      _dataPegawais = dataPegawai.toList();
    });
    if (fetchAgain) {
      print("DATA PEGAWAI REF : ${refWidget}");
      ref
          .read(dataPegawaisNotifierProvider.notifier)
          .getDataPegawai(userData: _userData);
    }

    List<Widget> pegawaisWidget = [];
    List<Map<String, dynamic>> _dataAbsensi = [];

    ref.watch(dataPegawaisNotifierProvider).maybeWhen(orElse: () {
      print("Data Pegawai edit or else");
      _isLoadingPegawai = false;
    }, loading: () {
      print("Data Pegawai Loading");
      _isLoadingPegawai = true;
    }, fetchedArray: (data) {
      print("Data Pegawai Fetched");
      _isLoadingPegawai = false;
      _dataPegawais = data.toList();
    });

    ref.watch(dataFormPresensiNotifierProvider).maybeWhen(
      orElse: () {
        print("DUDE ORELSE");
      },
      fetchedArray: (dataFetchArray) {
        print("Data presensi : ${dataFetchArray}");
        _dataAbsensi = dataFetchArray.toList();
      },
    );

    for (var x in _dataAbsensi) {
      List<Widget> pegawais = [];
      for (var i in x['listPegawai']) {
        Map<String, dynamic> dataPegawai = {};
        Map<String, dynamic> dataPresensi = {};

        for (var p in _dataPegawais) {
          if (p['uid'] == i) {
            dataPegawai = p;
          }
        }
        if (dataPegawai != {}) {
          for (var y in _dataPresensis) {
            if (x['uid'] == y['idFormPresensi'] &&
                y['idPegawai'] == dataPegawai['uid']) {
              dataPresensi = y;
            }
          }
        }
        print('DATA PRESENSI NYE ${dataPresensi}');
        pegawais.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextBody3(
                  text: "${dataPegawai['Nama']} ",
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
                (dataPresensi['status'] != 'Absen')
                    ? Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Colors.red[400],
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: TextBody4(text: 'Belum Presensi'),
                      )
                    : Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Colors.green[400],
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: TextBody4(text: 'Sudah Presensi'),
                      ),
              ],
            ),
          ),
        );
      }
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: pegawais,
              ),
            ],
          ),
        ),
      ));
    }

    print("DATA PEGAWAI di build ${_dataPegawais}");
    return RefreshIndicator(
        onRefresh: () async {
          print("Refressed");
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
          child: ListView(children: [
            AbsensiDashboard(userData: _userData),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(10),
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          onPressed: () {
                            if (_userData['premium'] > 0) {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      PresensiPegawaiView(
                                    userData: _userData,
                                    user: _user,
                                  ),
                                ),
                              );
                            } else {
                              myAlertError(
                                  context: context,
                                  text: 'Mohon upgrade akun anda dahulu');
                            }
                          },
                          child: const Icon(
                            size: 30,
                            Icons.list,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextBody_2(
                            text: "Tambah Presensi",
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(10),
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) => KeuanganView(
                                  userData: _userData,
                                  user: _user,
                                ),
                              ),
                            );
                          },
                          child: const Icon(
                            size: 30,
                            Icons.money,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextBody_2(
                            text: "Keuangan",
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            TextBody3(
              text: "Jadwal",
              color: Theme.of(context).colorScheme.onSecondary,
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
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
                child: TableCalendar(
                  locale: 'id_ID',
                  headerVisible: true,
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                    titleTextFormatter: (date, locale) {
                      return DateFormat('MMM', 'id_ID').format(date);
                    },
                  ),
                  calendarFormat: CalendarFormat.week,
                  firstDay: DateTime.utc(2010, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                  calendarBuilders: CalendarBuilders(
                    headerTitleBuilder: (context, day) {
                      return Container(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Theme.of(context).primaryColor,
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: TextBody3(
                                text: DateFormat('MMMM', 'id_ID').format(day),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child:
                                  Text(DateFormat('yyyy', 'id_ID').format(day)),
                            )
                          ],
                        ),
                      );
                    },
                    todayBuilder: (context, day, focusedDay) {
                      return Center(
                        child: Container(
                            height: width / 10,
                            width: width / 10,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(width)),
                                border: Border.all(
                                    width: 2,
                                    color: Theme.of(context).primaryColor)),
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(width / 47),
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
                    print("SELECTED DAY : ${selectedDay}");
                    ref
                        .read(dataPresensiNotifierProvider.notifier)
                        .getDataPresensiSehariAdmin(
                            idAdmin: _user.uid, hari: selectedDay);
                    ref
                        .read(dataFormPresensiNotifierProvider.notifier)
                        .getDataFormPresensiAdmin(
                            idAdmin: _user.uid, hari: selectedDay);
                    if (!isSameDay(_selectedDay, selectedDay)) {
                      setState(() {
                        _selectedDay = selectedDay;
                      });
                    }
                  },
                ),
              ),
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
            const SizedBox(
              height: 100,
            ),
          ]),
        ));
  }
}
