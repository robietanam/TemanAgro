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

class GajiPegawaiView extends ConsumerStatefulWidget {
  const GajiPegawaiView({
    Key? key,
    required User user,
    required Map<String, dynamic> userData,
  })  : _user = user,
        _userData = userData,
        super(key: key);

  final User _user;
  final Map<String, dynamic> _userData;

  @override
  ConsumerState<GajiPegawaiView> createState() => _GajiPegawaiViewState();
}

class _GajiPegawaiViewState extends ConsumerState<GajiPegawaiView> {
  List<Map<String, dynamic>> listDataPegawai = [];
  late User _user;
  late Map<String, dynamic> _userData;

  late DateTime tanggalAwal;
  late DateTime tanggalAkhir;

  late double width;
  late double height;

  @override
  void initState() {
    super.initState();
    _user = widget._user;
    _userData = widget._userData;
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
                .read(dataGajiNotifierProvider.notifier)
                .getDataGajiPegawai(dataPegawai: _userData);
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

    ref.watch(dataGajiNotifierProvider).maybeWhen(
          orElse: () {},
          unFetch: (message) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              ref.read(dataPegawaisNotifierProvider).maybeWhen(
                orElse: () {
                  ref
                      .read(dataGajiNotifierProvider.notifier)
                      .getDataGajiPegawai(dataPegawai: _userData);
                },
              );
            });
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
                    pegawaiData: _userData,
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

    print("DATA GAJI : ${dataGaji}");
    return Scaffold(
      appBar: AppBar(title: Text("Detail Pegawai")),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: (dataGaji.isNotEmpty)
                  ? Column(
                      children: listWidgetNya,
                    )
                  : TextBody6(
                      text: "Riwayat kosong",
                      color: Theme.of(context).colorScheme.onSecondary)),
        ),
      ),
    );
  }
}
