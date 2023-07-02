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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<Uint8List> generateDocumentGaji(
    {required PdfPageFormat format,
    required Map<String, dynamic> dataGaji,
    required Map<String, dynamic> dataAdmin,
    required Map<String, dynamic> dataPegawai}) async {
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
                level: 1,
                child: pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Center(
                      child: pw.Text(
                    'Slip Gaji Aplikasi TemanAgro',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 20,
                    ),
                  )),
                )),
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 1),
              ),
              padding: const pw.EdgeInsets.all(1),
              child: pw.Column(
                children: [
                  pw.Column(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(2),
                        child: pw.Center(
                            child: pw.Text(
                          dataAdmin['namaUsaha'],
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 16,
                          ),
                        )),
                      ),
                      pw.Align(
                        alignment: pw.Alignment.center,
                        child: pw.Padding(
                            padding: pw.EdgeInsets.all(4),
                            child: pw.Text('Pemilik : ${dataAdmin['Nama']}')),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 20),
                  pw.Container(
                      width: double.infinity,
                      color: PdfColors.grey300,
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        'Slip Gaji ${DateFormat('dd MMMM yyyy', 'id_ID').format(dataGaji['tanggalAwal'].toDate())} - ${DateFormat('dd MMMM yyyy', 'id_ID').format(dataGaji['tanggalAkhir'].toDate())}',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 14,
                        ),
                      )),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Column(
                      children: [
                        pw.Row(children: [
                          pw.Expanded(
                            child: pw.Text(
                              'Nama',
                              textAlign: pw.TextAlign.left,
                              style: const pw.TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              ": ${dataPegawai['Nama']}",
                              textAlign: pw.TextAlign.left,
                              style: const pw.TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ]),
                        pw.Row(children: [
                          pw.Expanded(
                            child: pw.Text(
                              'Email',
                              textAlign: pw.TextAlign.left,
                              style: const pw.TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              ": ${dataPegawai['email']}",
                              textAlign: pw.TextAlign.left,
                              style: const pw.TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                  pw.Container(
                    width: double.infinity,
                    height: 30,
                    color: PdfColors.grey300,
                    padding: const pw.EdgeInsets.all(6),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Column(
                      children: [
                        pw.Row(children: [
                          pw.Expanded(
                            child: pw.Text(
                              'Gaji per absensi',
                              textAlign: pw.TextAlign.left,
                              style: const pw.TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              ": ${dataPegawai['gajiPerAbsen']}",
                              textAlign: pw.TextAlign.left,
                              style: const pw.TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ]),
                        pw.Row(children: [
                          pw.Expanded(
                            child: pw.Text(
                              'Jumlah absensi',
                              textAlign: pw.TextAlign.left,
                              style: const pw.TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              ": ${dataGaji['totalPresensi']}",
                              textAlign: pw.TextAlign.left,
                              style: const pw.TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                  pw.Container(
                    width: double.infinity,
                    color: PdfColors.grey300,
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Row(children: [
                      pw.Expanded(
                        child: pw.Text(
                          'Gaji diterima ',
                          textAlign: pw.TextAlign.left,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.only(right: 10),
                          child: pw.Text(
                            "Rp ${toRp(dataGaji['jumlahGaji'])}",
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(30),
                    alignment: pw.Alignment.centerRight,
                    child: pw.Column(children: [
                      pw.Text(
                          '..........., ${DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.now())}'),
                      pw.SizedBox(height: 40),
                      pw.Text('...................')
                    ]),
                  ),
                ],
              ),
            ),
          ]));

  return await doc.save();
}
