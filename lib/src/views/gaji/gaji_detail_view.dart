import 'package:com.ppl.teman_agro_admin/src/views/gaji/pdf_slip_gaji.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../core/props/text_font.dart';

class GajiDetailView extends StatefulWidget {
  const GajiDetailView({
    Key? key,
    required User user,
    required Map<String, dynamic> userData,
    required Map<String, dynamic> pegawaiData,
    required Map<String, dynamic> gajiData,
  })  : _user = user,
        _userData = userData,
        _pegawaiData = pegawaiData,
        _gajiData = gajiData,
        super(key: key);

  final User _user;
  final Map<String, dynamic> _userData;
  final Map<String, dynamic> _pegawaiData;
  final Map<String, dynamic> _gajiData;

  @override
  State<GajiDetailView> createState() => _GajiDetailViewState();
}

class _GajiDetailViewState extends State<GajiDetailView> {
  late User _user;
  late Map<String, dynamic> _userData;
  late Map<String, dynamic> _pegawaiData;
  late Map<String, dynamic> _gajiData;

  late double width;
  late double height;

  @override
  void initState() {
    _user = widget._user;
    _userData = widget._userData;
    _pegawaiData = widget._pegawaiData;
    _gajiData = widget._gajiData;
    Size screenSize = WidgetsBinding.instance.window.physicalSize;

    width = screenSize.width;
    height = screenSize.height;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final perGaji = _gajiData['jumlahGaji'] / _gajiData['totalPresensi'];
    return Scaffold(
      appBar: AppBar(title: Text("Detail Gaji")),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(20),
                width: width / 3.2,
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(10.0)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextBody_2(text: "Bulan"),
                        TextBody2(
                          text: DateFormat('MMMM yyyy', 'id_ID')
                              .format(_gajiData['tanggalDibuat'].toDate()),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextBody_2(text: "Total Presensi"),
                        TextBody2(text: _gajiData['totalPresensi'].toString()),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextBody_2(text: "Gaji per absensi"),
                        TextBody2(
                            text:
                                "Rp ${NumberFormat('#,##0.00', 'ID').format(perGaji)}"),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextBody_2(text: "Total Gaji"),
                        TextBody2(
                            text:
                                "Rp ${NumberFormat('#,##0.00', 'ID').format(_gajiData['jumlahGaji'])}"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(30),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 50)),
                  onPressed: () async {
                    if (_gajiData.isNotEmpty &&
                        _userData.isNotEmpty &&
                        _pegawaiData.isNotEmpty) {
                      await Printing.layoutPdf(
                          onLayout: (format) => generateDocumentGaji(
                              format: PdfPageFormat.a4,
                              dataGaji: _gajiData,
                              dataAdmin: _userData,
                              dataPegawai: _pegawaiData));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Tidak ada data untuk di print')));
                    }
                  },
                  child: const TextJudul2(
                    text: "Export",
                  )),
            )
          ],
        ),
      ),
    );
  }
}
