/*
 * Copyright (C) 2017, David PHAM-VAN <dev.nfet.net@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<Uint8List> generateDocument(
    PdfPageFormat format, List<Map<String, dynamic>> dataKeuangan) async {
  final doc = pw.Document(pageMode: PdfPageMode.outlines);

  final font1 = await PdfGoogleFonts.openSansRegular();
  final font2 = await PdfGoogleFonts.openSansBold();

  List<List<String>> dataTable = [];

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

  // Header
  List<String> headerTable = [
    'No.',
    'Tgl',
    'Keterangan',
    'Pemasukan',
    'Pengeluaran'
  ];
  int indexTable = 0;
  int jumlahPemasukan = 0;
  int jumlahPengeluaran = 0;
  int jumlahTotal = 0;
  int total = 0;
  for (var data in dataKeuangan) {
    indexTable += 1;
    List<String> toList = [];
    // body
    toList.add('${indexTable.toString()}.');
    toList.add(
        DateFormat('dd-MM-yyyy', 'id_ID').format(data['tanggal'].toDate()));
    toList.add(data['deskripsi']);
    if (data['tipe'] == 'Pengeluaran') {
      toList.add('');
      toList.add("Rp ${data['nominal']}");

      jumlahPengeluaran += int.parse(data['nominal'].replaceAll('.', ''));
    } else {
      toList.add("Rp ${data['nominal']}");
      toList.add('');

      jumlahPemasukan += int.parse(data['nominal'].replaceAll('.', ''));
    }
    dataTable.add(toList);
  }
  jumlahTotal = jumlahPemasukan - jumlahPengeluaran;

  dataTable.add(['-', ' ', ' ', ' ', ' ']);
  dataTable
      .add(['', '', 'Total', toRp(jumlahPemasukan), toRp(jumlahPengeluaran)]);
  dataTable.add(['', '', 'Rekap', '', toRp(jumlahTotal)]);

  doc.addPage(pw.MultiPage(
      theme: pw.ThemeData.withFont(
        base: font1,
        bold: font2,
      ),
      pageFormat: format.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
      orientation: pw.PageOrientation.portrait,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      header: (pw.Context context) {
        if (context.pageNumber == 1) {
          return pw.SizedBox();
        }
        return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            decoration: const pw.BoxDecoration(
                border: pw.Border(
                    bottom: pw.BorderSide(width: 0.5, color: PdfColors.grey))),
            child: pw.Text('Portable Document Format',
                style: pw.Theme.of(context)
                    .defaultTextStyle
                    .copyWith(color: PdfColors.grey)));
      },
      footer: (pw.Context context) {
        return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
            child: pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: pw.Theme.of(context)
                    .defaultTextStyle
                    .copyWith(color: PdfColors.grey)));
      },
      build: (pw.Context context) => <pw.Widget>[
            pw.Header(
              child: pw.Center(
                child: pw.Text(
                    textAlign: pw.TextAlign.center,
                    'Laporan Pemasukan dan Pengeluaran Aplikasi TemanAgro',
                    style: pw.Theme.of(context).header0),
              ),
            ),
            pw.Paragraph(
                text:
                    '${DateFormat('MMMM yyyy', 'id_ID').format(dataKeuangan[0]['tanggal'].toDate())}'),
            pw.TableHelper.fromTextArray(
                context: context,
                cellAlignments: {
                  3: pw.Alignment.centerRight,
                  4: pw.Alignment.centerRight,
                },
                columnWidths: {2: pw.FlexColumnWidth(4)},
                headers: headerTable,
                data: dataTable),
            pw.Padding(padding: const pw.EdgeInsets.all(10)),
          ]));

  return await doc.save();
}
