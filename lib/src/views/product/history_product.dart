import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.ppl.teman_agro_admin/src/core/widget/loading_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../../core/props/text_font.dart';
import '../../features/data/data_barang_provider.dart';

class HistoryProduct extends StatefulHookConsumerWidget {
  const HistoryProduct(
      {super.key, required this.idFormProduct, required this.user});

  final User user;
  final String idFormProduct;

  @override
  ConsumerState<HistoryProduct> createState() => _HistoryProductState();
}

class _HistoryProductState extends ConsumerState<HistoryProduct> {
  late double _width;
  late double _height;
  late User _user;
  late String _idFormProduct;
  late DateFormat formatter;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _idFormProduct = widget.idFormProduct;

    Size screenSize = WidgetsBinding.instance.window.physicalSize;
    _width = screenSize.width;
    _height = screenSize.height;

    initializeDateFormatting("id_ID", null);
    formatter = DateFormat('EEEE, d-MM-yyyy', 'id_ID');

    SchedulerBinding.instance.addPostFrameCallback((_) {
      ref
          .read(dataPeriodiksNotifierProvider.notifier)
          .getDataPeriodiks(idForm: _idFormProduct);
    });
  }

  @override
  void dispose() {
    ref.invalidate(dataPeriodiksNotifierProvider);
    super.dispose();
  }

  bool _isLoading = false;
  Iterable<Map<String, dynamic>>? _dataPeriodiks;

  Widget historyWidget(
      {required Iterable<Map<String, dynamic>> dataPeriodiks}) {
    List<Widget> list = <Widget>[];
    for (Map<String, dynamic> data in dataPeriodiks) {
      list.add(DetailDataPeriodik(
        dataPeriodik: data,
        width: _width,
        formatter: formatter,
      ));
    }
    return Column(
      children: list,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(dataPeriodiksNotifierProvider).maybeWhen(
      orElse: () {
        print("History data OrElse");
        _isLoading = false;
      },
      loading: () {
        print("History data loading");
        _isLoading = true;
      },
      fetchedArray: (data) {
        print("History data fetched");
        _isLoading = false;
        _dataPeriodiks = data;
      },
    );

    if (_isLoading && _dataPeriodiks == null) {
      return LoadingScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat produk"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: historyWidget(dataPeriodiks: _dataPeriodiks!),
        ),
      ),
    );
  }
}

class DetailDataPeriodik extends StatelessWidget {
  const DetailDataPeriodik(
      {super.key,
      required this.width,
      required this.dataPeriodik,
      required this.formatter});

  final double width;
  final Map<String, dynamic> dataPeriodik;
  final DateFormat formatter;

  @override
  Widget build(BuildContext context) {
    print("DATA PERIODIK NYA");
    print(dataPeriodik);
    DateTime dateTime = dataPeriodik['lastUpdate'].toDate();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: TextBody4(
            text: formatter.format(dateTime),
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
        Container(
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(10.0)),
          alignment: Alignment.center,
          child: Column(
            children: [
              Row(children: [
                Column(
                  children: [
                    DataPeriodikColumn(
                        width: width,
                        judul: "Jumlah stok section",
                        value: dataPeriodik['jumlahStok']),
                    DataPeriodikColumn(
                        width: width,
                        judul: "Jumlah produk bagus",
                        value: "${dataPeriodik['jumlahBagus'] ?? '-'} Item"),
                    DataPeriodikColumn(
                      width: width,
                      judul: "Usia produk",
                      value: "${dataPeriodik['usia'] ?? '-'} Hari",
                    ),
                  ],
                ),
                Column(children: [
                  DataPeriodikColumn(
                    width: width,
                    judul: "Jumlah produk tidak bagus",
                    value: "${dataPeriodik['jumlahKurangBagus'] ?? '-'} Item",
                  ),
                ]),
              ]),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DataPeriodikColumn(
                          width: width,
                          judul: "Kebutuhan pendukung",
                          value: dataPeriodik['kebutuhanPendukung']),
                      DataPeriodikColumn(
                          width: width,
                          judul: "Keterangan",
                          value: dataPeriodik['keterangan']),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}

class DataPeriodikColumn extends StatelessWidget {
  const DataPeriodikColumn({
    super.key,
    required this.width,
    required this.judul,
    required this.value,
  });

  final double width;
  final String judul;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width / 7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [TextBody_2(text: judul), TextBody2(text: value)],
      ),
    );
  }
}
