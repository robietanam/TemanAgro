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

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:qr/qr.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CustomData {
  const CustomData({this.name = '[your name]'});

  final String name;
}

const PdfColor green = PdfColor.fromInt(0xff9ce5d0);
const PdfColor lightGreen = PdfColor.fromInt(0xffcdf1e7);
const sep = 120.0;

Future<Uint8List> exportQR() async {
  final painter = QrPainter(
    data: 'The painter is this thing',
    color: Colors.black,
    version: QrVersions.auto,
    gapless: true,
    errorCorrectionLevel: QrErrorCorrectLevel.L,
  );
  ByteData? imageData;
  imageData = await painter.toImageData(600.0);
  final imageBytes = imageData!.buffer.asUint8List();
  // var status = await Permission.storage.request();
  // var status2 = await Permission.manageExternalStorage.request();
  // print(status.isGranted);
  // print(status2.isGranted);

  // // final tempDir = (await getExternalStorageDirectory())!.path;
  // final tempDir = "/storage/emulated/0/QR";
  // print(tempDir);
  // final qrcodeFile = await File('$tempDir/qr_code.png').create(recursive: true);
  // await qrcodeFile.writeAsBytes(imageBytes);
  // print("Done");

  // final widget = Center(
  //   child: RepaintBoundary(
  //     child: Container(
  //       width: 600,
  //       height: 600,
  //       child: Image.memory(imageBytes),
  //     ),
  //   ),
  // );
  return imageBytes;
}

class CodePainter extends CustomPainter {
  CodePainter({required this.qrImage, this.margin = 10}) {
    _paint = Paint()
      ..color = Colors.white
      ..style = ui.PaintingStyle.fill;
  }

  final double margin;
  final ui.Image qrImage;
  Paint? _paint;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw everything in white.
    final rect = Rect.fromPoints(Offset.zero, Offset(size.width, size.height));
    canvas.drawRect(rect, _paint!);

    // Draw the image in the center.
    canvas.drawImage(qrImage, Offset(margin, margin), Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  ui.Picture toPicture(double size) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    paint(canvas, Size(size, size));
    return recorder.endRecording();
  }

  Future<ui.Image> toImage(double size,
      {ui.ImageByteFormat format = ui.ImageByteFormat.png}) async {
    return await toPicture(size).toImage(size.toInt(), size.toInt());
  }

  Future<ByteData?> toImageData(double originalSize,
      {ui.ImageByteFormat format = ui.ImageByteFormat.png}) async {
    final image = await toImage(originalSize + margin * 2, format: format);
    return image.toByteData(format: format);
  }
}

Future<String> exportQRImage(
    {required String idQR, required String namaQR}) async {
  try {
    final painter = QrPainter(
      data: idQR,
      emptyColor: Colors.white,
      color: Colors.black,
      version: QrVersions.auto,
      gapless: true,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );

    ByteData? imageData;
    imageData = await painter.toImageData(600.0);

    final imageQR = await painter.toImage(600);
    ByteData? data =
        await CodePainter(qrImage: imageQR, margin: 30).toImageData(600);
    final imageBytesPadding = data!.buffer.asUint8List();
    final imageBytes = imageData!.buffer.asUint8List();
    var status = await Permission.storage.request();
    var status2 = await Permission.manageExternalStorage.request();
    print(status.isGranted);
    print(status2.isGranted);

    // final tempDir = (await getExternalStorageDirectory())!.path;
    final tempDir = "/storage/emulated/0/QR";
    print(tempDir);
    final qrcodeFile =
        await File('$tempDir/${namaQR}_QR.png').create(recursive: true);
    await qrcodeFile.writeAsBytes(imageBytesPadding);
    print("Done");
    return "QR tersimpan di ${qrcodeFile.path}";
  } catch (e) {
    return "Terjadi kesalahan saat menyimpan";
  }
}
