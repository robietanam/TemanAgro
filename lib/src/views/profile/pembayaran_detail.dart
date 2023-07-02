import 'dart:io';

import 'package:com.ppl.teman_agro_admin/src/core/props/text_font.dart';
import 'package:com.ppl.teman_agro_admin/src/core/widget/alert.dart';
import 'package:com.ppl.teman_agro_admin/src/core/widget/loading_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/data/data_pembayaran_provider.dart';

class DetailPembayaranView extends ConsumerStatefulWidget {
  const DetailPembayaranView(
      {Key? key,
      required User user,
      required Map<String, dynamic> userData,
      required int tipe})
      : _user = user,
        _userData = userData,
        _tipe = tipe,
        super(key: key);

  final User _user;
  final Map<String, dynamic> _userData;
  final int _tipe;

  @override
  ConsumerState<DetailPembayaranView> createState() =>
      _DetailPembayaranViewState();
}

class _DetailPembayaranViewState extends ConsumerState<DetailPembayaranView> {
  late User user;
  late Map<String, dynamic> userData;
  late int tipe;

  late double width;
  late double height;

  @override
  void initState() {
    user = widget._user;
    userData = widget._userData;
    tipe = widget._tipe;

    Size screenSize = WidgetsBinding.instance.window.physicalSize;
    width = screenSize.width;
    height = screenSize.height;

    super.initState();
    // dataPembayaranSourceProvider
  }

  @override
  void dispose() {
    ref.invalidate(dataPembayaranNotifierProvider);
    super.dispose();
  }

  File? file;
  List? path;

  Future<List<String?>?> chooseImage(ImageSource media) async {
    XFile? imagePick;
    File? image;

    imagePick = await ImagePicker().pickImage(source: media);

    if (imagePick != null) {
      print("image pick ${imagePick.path}");

      file = File(imagePick.path);

      String nameFile = imagePick.name;
      Directory tmpPath = await getTemporaryDirectory();

      String path = "${tmpPath.path}/tmp_pembayaran";

      await Directory(path).create(recursive: true);

      // if (Directory(path).existsSync()) {
      //   Directory(path).deleteSync(recursive: true);
      // }

      // copy the file to a new path
      image = await file?.copy('$path/$nameFile.png');
      print(image?.path);
      return [
        image?.path,
        basenameWithoutExtension(imagePick.path),
        imagePick.path
      ];
    }
  }

  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    ref.watch(dataPembayaranNotifierProvider).maybeWhen(orElse: () {
      _isLoading = false;
    }, loading: () {
      _isLoading = true;
    }, success: () {
      _isLoading = false;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        myAlertSuccess(
            context: context,
            text: 'Mohon tunggu email kami 1x24 jam untuk konfirmasi',
            fun: () {
              Navigator.pop(context);
              Navigator.pop(context);
            });
      });
    });

    if (_isLoading) {
      return const LoadingScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextJudul4(
                  text: "Nomor Rekening",
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 30),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: TextJudul3(
                      text: "20345 20312 21312312",
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                Row(
                  children: [
                    TextBody5(
                      text: 'Bukti pembayaran : ',
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    (path != null)
                        ? Expanded(
                            child: Text(
                              path![1],
                              style: const TextStyle(
                                  overflow: TextOverflow.ellipsis),
                            ),
                          )
                        : Container(),
                  ],
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                      onPressed: () {
                        chooseImage(ImageSource.gallery).then((value) {
                          setState(() {
                            path = value;
                          });
                        });
                      },
                      child: Text('Upload')),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 50)),
                      onPressed: () {
                        print(path);
                        if (path != null) {
                          print("path ${path}");
                          ref
                              .read(dataPembayaranNotifierProvider.notifier)
                              .saveDataPembayaran(
                                  userData: userData,
                                  tipe: tipe,
                                  filePath: path![0]);
                        } else {
                          myAlertError(
                              context: context,
                              text: 'Pilih gambar bukti pembayaran dahulu');
                        }
                      },
                      child: const TextJudul2(text: 'Simpan')),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
