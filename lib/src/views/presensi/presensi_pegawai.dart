import 'package:com.ppl.teman_agro_admin/src/core/props/text_font.dart';
import 'package:com.ppl.teman_agro_admin/src/core/widget/alert.dart';
import 'package:day_picker/day_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/utils/helpers.dart';
import '../../features/data/data_pegawai_provider.dart';
import '../../features/data/data_presensi_provider.dart';
import '../../features/data/data_source/data_pegawai_source.dart';

class PresensiPegawaiView extends ConsumerStatefulWidget {
  const PresensiPegawaiView(
      {super.key, required this.user, required this.userData});

  final User user;
  final Map<String, dynamic> userData;

  @override
  ConsumerState<PresensiPegawaiView> createState() =>
      _PresensiPegawaiViewState();
}

class _PresensiPegawaiViewState extends ConsumerState<PresensiPegawaiView> {
  late Map<String, dynamic> _userData;
  late User _user;

  DateTime _selectedDay = DateTime.now();
  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _userData = widget.userData;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ref
          .read(dataPegawaisNotifierProvider.notifier)
          .getDataPegawai(userData: _userData);
      ref
          .read(dataFormPresensiNotifierProvider.notifier)
          .getDataFormPresensi(idAdmin: _user.uid, hari: DateTime.now());
    });
  }

  @override
  void dispose() {
    ref.invalidate(pegawaiListPresensiProvider);
    super.dispose();
  }

  bool _isLoadingPegawai = false;
  bool _runOnce = false;
  List<Map<String, dynamic>> _dataAbsensi = [];

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    List<Map<String, dynamic>> _dataPegawais = [];
    List<Widget> pegawaisWidget = [];

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
      if (!_runOnce) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          ref.read(pegawaiListPresensiProvider.notifier).addAll(_dataPegawais);
          _runOnce = true;
        });
      }
    });

    void tambahJadwal({
      Map<String, dynamic>? dataAbsensi,
    }) {
      bool _isEditing = false;
      ref.invalidate(firstTimePicker);
      ref.invalidate(secondTimePicker);
      ref.read(dayProvider.notifier).resetDay();
      if (dataAbsensi != null) {
        _isEditing = true;
        for (var x in dataAbsensi['hari']) {
          ref.read(dayProvider.notifier).toggle(dayKey: x);
        }

        for (var y in dataAbsensi['listPegawai']) {
          ref.read(pegawaiListPresensiProvider.notifier).toggle(y);
        }

        ref.read(firstTimePicker.notifier).state =
            convertToTimeOfDay(string: dataAbsensi['waktuAwal']);
        ref.read(secondTimePicker.notifier).state =
            convertToTimeOfDay(string: dataAbsensi['waktuAkhir']);
      }
      showModalBottomSheet(
          isDismissible: false,
          enableDrag: false,
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25.0),
            ),
          ),
          builder: (
            BuildContext context,
          ) {
            return Consumer(
              builder: (context, ref, _) {
                print("Data Pegawai di Consumer ${_dataPegawais}");
                final dataPegawai = ref.watch(pegawaiListPresensiProvider);
                print("Data Pegawai di Consumer dari provider ${dataPegawai}");
                List<Widget> theWidgetPegawai = [];

                for (DataPegawai data in dataPegawai) {
                  theWidgetPegawai.add(Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                width: 0.5,
                                color:
                                    Theme.of(context).colorScheme.onSecondary),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                          dense: true,
                          title: TextBody5(
                            text: data.dataPegawai['displayName'],
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                          trailing: Checkbox(
                            value: data.checked,
                            onChanged: (value) {
                              ref
                                  .read(pegawaiListPresensiProvider.notifier)
                                  .toggle(data.idPegawai);

                              print(value);
                            },
                          ),
                        ),
                      ),
                    ],
                  ));
                }

                final firstTime = ref.watch(firstTimePicker);
                final secondTime = ref.watch(secondTimePicker);
                final _dayList = ref.watch(dayProvider);

                double toDouble(TimeOfDay myTime) =>
                    myTime.hour + myTime.minute / 60.0;
                return SizedBox(
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                              icon: Icon(
                                Icons.close,
                                size: 40,
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              }),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(0),
                        child: Align(
                          alignment: Alignment.center,
                          child: TextJudul4(
                              text: "List Pegawai",
                              color: Theme.of(context).colorScheme.onSecondary),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(
                                      bottom: 3, left: 3, right: 3),
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                    color: Colors.black,
                                    width: 2.0, // Underline thickness
                                  ))),
                                  child: TextPickTime(
                                      text: firstTime.hour
                                          .toString()
                                          .padLeft(2, "0"),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary),
                                ),
                                TextJudul(
                                    text: ":",
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary),
                                Container(
                                  padding: const EdgeInsets.only(
                                      bottom: 3, left: 3, right: 3),
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                    color: Colors.black,
                                    width: 2.0, // Underline thickness
                                  ))),
                                  child: TextPickTime(
                                      text: firstTime.minute
                                          .toString()
                                          .padLeft(2, "0"),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary),
                                ),
                              ],
                            ),
                            onTap: () async {
                              showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(hour: 0, minute: 0),
                                builder: (context, child) {
                                  return MediaQuery(
                                      data: MediaQuery.of(context).copyWith(
                                          // Using 24-Hour format
                                          alwaysUse24HourFormat: true),
                                      // If you want 12-Hour format, just change alwaysUse24HourFormat to false or remove all the builder argument
                                      child: child!);
                                },
                              ).then((value) {
                                if (value != null) {
                                  print("the value : ${value}");
                                  ref.read(firstTimePicker.notifier).state =
                                      value;
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
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(
                                      bottom: 3, left: 3, right: 3),
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                    color: Colors.black,
                                    width: 2.0, // Underline thickness
                                  ))),
                                  child: TextPickTime(
                                      text: secondTime.hour
                                          .toString()
                                          .padLeft(2, "0"),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary),
                                ),
                                TextJudul(
                                    text: ":",
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary),
                                Container(
                                  padding: const EdgeInsets.only(
                                      bottom: 3, left: 3, right: 3),
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                    color: Colors.black,
                                    width: 2.0, // Underline thickness
                                  ))),
                                  child: TextPickTime(
                                      text: secondTime.minute
                                          .toString()
                                          .padLeft(2, "0"),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary),
                                ),
                              ],
                            ),
                            onTap: () async {
                              showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(hour: 0, minute: 0),
                                builder: (context, child) {
                                  return MediaQuery(
                                      data: MediaQuery.of(context).copyWith(
                                          // Using 24-Hour format
                                          alwaysUse24HourFormat: true),
                                      // If you want 12-Hour format, just change alwaysUse24HourFormat to false or remove all the builder argument
                                      child: child!);
                                },
                              ).then((value) {
                                if (value != null) {
                                  print(
                                      "THE VALUE convert ${convertToDateTime(t: value)}");
                                  ref.read(secondTimePicker.notifier).state =
                                      value;
                                }
                              });
                            },
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SelectWeekDays(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        days: _dayList,
                        border: false,
                        unSelectedDayTextColor: Colors.black,
                        padding: 4,
                        selectedDayTextColor: Theme.of(context).primaryColor,
                        boxDecoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        onSelect: (values) {
                          // <== Callback to handle the selected days
                          print(values);
                        },
                      ),
                      Column(
                        children: theWidgetPegawai,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: width / 3, vertical: 20),
                        child: Column(
                          children: [
                            ElevatedButton(
                                onPressed: () {
                                  List<DataPegawai> listCentang = [];
                                  double hasil = toDouble(secondTime) -
                                      toDouble(firstTime);

                                  List<String> _dayListSelected = [];
                                  print("LOLOLO");
                                  for (var i in dataPegawai) {
                                    if (i.checked) {
                                      listCentang.add(i);
                                    }
                                  }
                                  _dayListSelected = [];
                                  final value = ref.read(dayProvider);
                                  for (var i in value) {
                                    if (i.isSelected) {
                                      print("Nilai dari state : ${i.dayName}");
                                      _dayListSelected.add(i.dayKey);
                                    }
                                  }

                                  if (hasil <= 0.5) {
                                    print(
                                        "second time : ${toDouble(secondTime)}");
                                    print(
                                        'first time : ${toDouble(firstTime)}');
                                    print(hasil);
                                    myAlertError(
                                        context: context,
                                        text: "Jangka waktu minimal 30 menit");
                                  } else if (_dayListSelected.isEmpty) {
                                    myAlertError(
                                        context: context,
                                        text: "Mohon pilih hari dahulu");
                                  } else if (listCentang.isEmpty) {
                                    myAlertError(
                                        context: context,
                                        text: "Mohon pilih pegawai dahulu");
                                  } else {
                                    print("DONE START TAMBAh");
                                    ref
                                        .read(dataFormPresensiNotifierProvider
                                            .notifier)
                                        .createDataFormPresensi(
                                            idAdmin: _user.uid,
                                            hari: _dayListSelected,
                                            idFormPresensi: dataAbsensi?['uid'],
                                            userId: listCentang,
                                            waktuAwal:
                                                convertToDateTime(t: firstTime),
                                            waktuAkhir: convertToDateTime(
                                                t: secondTime))
                                        .then((value) {
                                      ref
                                          .read(dataFormPresensiNotifierProvider
                                              .notifier)
                                          .getDataFormPresensi(
                                              idAdmin: _user.uid,
                                              hari: DateTime.now());
                                      Navigator.pop(context);
                                      myAlertSuccess(context: context);
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(),
                                child: TextBody2(
                                  text: "Simpan",
                                )),
                            (_isEditing)
                                ? ElevatedButton(
                                    onPressed: () {
                                      ref
                                          .read(dataFormPresensiNotifierProvider
                                              .notifier)
                                          .deleteDataFormPresensi(
                                              idFormPresensi:
                                                  dataAbsensi?['uid'])
                                          .then((value) {
                                        ref
                                            .read(
                                                dataFormPresensiNotifierProvider
                                                    .notifier)
                                            .getDataFormPresensi(
                                                idAdmin: _user.uid,
                                                hari: DateTime.now());
                                        Navigator.pop(context);
                                        myAlertSuccess(
                                            context: context,
                                            text: "DATA BERHASIL DIHAPUS");
                                      }).catchError((onError) {
                                        Navigator.pop(context);
                                        myAlertError(
                                            context: context,
                                            text: onError.toString());
                                      });

                                      print("LOLOLO");
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red[400]),
                                    child: TextBody2(
                                      text: "Delete",
                                    ))
                                : Container(),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          }).then((value) {
        ref.invalidate(pegawaiListPresensiProvider);
        ref.read(pegawaiListPresensiProvider.notifier).addAll(_dataPegawais);
        _runOnce = true;
        print("IM DONE ${value}");
      });
    }

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
        for (var p in _dataPegawais) {
          if (p['uid'] == i) {
            dataPegawai = p;
          }
        }
        pegawais.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: TextBody3(
              text: "${dataPegawai['Nama']} ",
              color: Theme.of(context).colorScheme.onSecondary,
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
              Container(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)))),
                    onPressed: () {
                      tambahJadwal(dataAbsensi: x);
                      print('DATA ABSENSI : ${x}');
                    },
                    child: const TextBody4(
                      text: "Ubah",
                    )),
              )
            ],
          ),
        ),
      ));
    }

    print("Data Pegawai di build : ${_dataPegawais}");
    return Scaffold(
      appBar: AppBar(
        title: Text("Presensi"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(8),
                child: Text("Tanggal"),
              ),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 1.0), //(x,y)
                        blurRadius: 6.0,
                      ),
                    ]),
                child: TableCalendar(
                  locale: 'id_ID',
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                    titleTextFormatter: (date, locale) {
                      return DateFormat('MMM', 'id_ID').format(date);
                    },
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                      weekendStyle: TextStyle(fontWeight: FontWeight.w500),
                      weekdayStyle: TextStyle(fontWeight: FontWeight.w500)),
                  calendarFormat: CalendarFormat.month,
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
                            height: width / 11,
                            width: width / 11,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(width)),
                                border: Border.all(
                                    width: 2,
                                    color: Theme.of(context).primaryColor)),
                            child: Center(
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
              SizedBox(
                height: 20,
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: TextBody2(
                  text: "Jadwal Hari Ini",
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
              Column(
                children: pegawaisWidget,
              ),
              SizedBox(
                height: 20,
              ),
              (!_isLoadingPegawai)
                  ? ElevatedButton(
                      onPressed: () {
                        tambahJadwal();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: width / 3,
                        child: TextJudul4(
                          text: "Tambah",
                        ),
                      ))
                  : CircularProgressIndicator(),
              SizedBox(
                height: 100,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class PilihPegawai extends ConsumerStatefulWidget {
  PilihPegawai({
    super.key,
  });

  @override
  ConsumerState<PilihPegawai> createState() => _PilihPegawaiState();
}

class _PilihPegawaiState extends ConsumerState<PilihPegawai> {
  late DataPegawai dataPegawai;
  late bool checked;
  @override
  void initState() {
    checked = dataPegawai.checked;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("REBUILD!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                  width: 0.5, color: Theme.of(context).colorScheme.onSecondary),
            ),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            dense: true,
            title: TextBody5(
              text: dataPegawai.dataPegawai['displayName'],
              color: Theme.of(context).colorScheme.onSecondary,
            ),
            trailing: Checkbox(
              value: checked,
              onChanged: (value) {
                ref
                    .read(pegawaiListProvider.notifier)
                    .toggle(dataPegawai.idPegawai);
                setState(() {
                  checked = !checked;
                });
                print(value);
              },
            ),
          ),
        ),
      ],
    );
  }
}
