import 'package:com.ppl.teman_agro_admin/src/core/utils/nama_product.dart';
import 'package:com.ppl.teman_agro_admin/src/core/widget/loading_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/widget/alert.dart';
import '../../core/widget/avatar.dart';
import '../../core/widget/field_product.dart';
import '../../features/data/data_barang_provider.dart';
import '../../features/data/data_pegawai_provider.dart';
import '../../features/data/data_source/data_pegawai_source.dart';
import 'history_product.dart';
import 'productform_view.dart';
import 'QR_gambar.dart';
import '../../core/props/text_font.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../features/avatar/avatar_provider.dart';

class EditPeriodikData extends StatefulHookConsumerWidget {
  const EditPeriodikData(
      {super.key,
      required this.user,
      required this.idFormProduct,
      required this.userData});

  final User user;
  final String idFormProduct;
  final Map<String, dynamic> userData;

  @override
  ConsumerState<EditPeriodikData> createState() => _EditPeriodikDataState();
}

class _EditPeriodikDataState extends ConsumerState<EditPeriodikData> {
  late User _user;
  late String _idFormProduct;
  String? _photoURL;
  // List<String> _idPegawai = [];
  late Map<String, dynamic> _userData;

  late Iterable<Map<String, dynamic>> _dataPegawai;
  String? _character = "1";
  late double _width;
  late double _height;

  @override
  void dispose() {
    print("Product Dispose");
    ref.invalidate(profileAvatarNotifierProvider);
    ref.invalidate(productAvatarNotifierProvider);
    ref.invalidate(dataPeriodikNotifierProvider);
    // ref.invalidate(dataPegawaisNotifierProvider);
    ref.invalidate(pegawaiListProvider);
    super.dispose();
  }

  @override
  void initState() {
    _user = widget.user;
    _idFormProduct = widget.idFormProduct;
    _userData = widget.userData;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ref
          .read(dataPeriodikNotifierProvider.notifier)
          .getDataPeriodik(idFormData: _idFormProduct, user: _user);
      ref
          .read(dataPegawaisNotifierProvider.notifier)
          .getDataPegawai(userData: _userData);
    });
    Size screenSize = WidgetsBinding.instance.window.physicalSize;
    _width = screenSize.width;
    _height = screenSize.height;
    super.initState();
  }

  Widget pegawaiWidget() {
    print("PEGAWAI WIDGET LIST");
    List<Widget> list = <Widget>[];
    final data = ref.read(pegawaiListProvider);
    print("XADADSADW : $data");
    for (DataPegawai i in data) {
      final dataPegawaiWidget = i.dataPegawai;
      print(dataPegawaiWidget);
      list.add(ProviderScope(
        overrides: [
          _currentTodo.overrideWithValue(i),
        ],
        child: PilihPegawai(),
      ));
    }

    return Column(
      children: list,
    );
  }

  void listPegawai(BuildContext context, double width, double height,
      Iterable<Map<String, dynamic>> dataPegawais, WidgetRef ref) {
    showModalBottomSheet(
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
                              color: Theme.of(context).colorScheme.onSecondary,
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
                    pegawaiWidget(),
                  ],
                ),
              );
            },
          );
        });
  }

  // Data Periodik
  final jumlahStokController = TextEditingController();
  final jumlahProdukBagusController = TextEditingController();
  final jumlahProdukKurangBagusController = TextEditingController();
  final usiaProdukController = TextEditingController();
  final kebutuhanPendukungController = TextEditingController();
  final keteranganController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingPegawai = false;
  bool _runOnce = false;
  bool _runOnce2 = false;
  bool _runOnce3 = false;
  @override
  Widget build(BuildContext context) {
    final filePath = ref.read(profileAvatarNotifierProvider);
    print("REBUIL");
    print(_runOnce2);
    Map<String, dynamic>? _dataForm;

    ref.watch(dataPegawaisNotifierProvider).maybeWhen(orElse: () {
      print("Data Pegawai edit or else");
      _isLoadingPegawai = false;
    }, loading: () {
      print("Data Pegawai Loading");
      _isLoadingPegawai = true;
    }, fetchedArray: (data) {
      print("Data Pegawai Fetched");
      _isLoadingPegawai = false;
      _dataPegawai = data;
      if (!_runOnce) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          ref.read(pegawaiListProvider.notifier).reset();
          for (Map<String, dynamic> i in data) {
            print(i);
            ref.read(pegawaiListProvider.notifier).add(i['uid'], i);
          }
        });
        _runOnce = true;
      }
    });

    ref.watch(dataPeriodikNotifierProvider).maybeWhen(
      orElse: () {
        print("Periodik data OrElse");
        _isLoading = false;
      },
      unFetch: (message) {
        print("DATA TIDAK DITEMUKAN");
        if (!_runOnce3) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            _runOnce3 = true;

            Navigator.pop(context);
            myAlertError(
              context: context,
              text: message.toString(),
            );
          });
        }
      },
      loading: () {
        print("Periodik data loading");
        _isLoading = true;
      },
      fetched: (data) {
        print("Periodik data fetched");
        _isLoading = false;
        _dataForm = data;
        print(data);
        _photoURL = data['photoURL'];
        if (data.length > 10) {
          jumlahStokController.text = data['jumlahStok'];
          jumlahProdukBagusController.text = data['jumlahBagus'];
          jumlahProdukKurangBagusController.text = data['jumlahKurangBagus'];
          usiaProdukController.text = data['usia'];
          kebutuhanPendukungController.text = data['kebutuhanPendukung'];
          keteranganController.text = data['keterangan'];
        }
        if (!_runOnce2) {
          if (data.containsKey('idPegawai') && data['idPegawai'] != null) {
            for (var d in data['idPegawai']) {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                print(data['idPegawai']);
                print("TERTOGGLE");
                ref.read(pegawaiListProvider.notifier).toggle(d);
              });
              _runOnce2 = true;
            }
          }
        }
      },
      empty: (data) {
        print("Periodik data empty ");
        _isLoading = false;
        _dataForm = data;
      },
      success: () {
        print("SUKSES SAVE");
        SchedulerBinding.instance.addPostFrameCallback((_) {
          myAlertSuccess(
              context: context,
              text: "Data Tersimpan",
              fun: () {
                Navigator.pop(context);
                Navigator.pop(context);
              });
        });
      },
    );

    if (_isLoading) {
      return LoadingScreen();
    }

    // final widget = Center(
    //   child: RepaintBoundary(
    //     child: Container(
    //       width: 600,
    //       height: 600,
    //       child: Image.memory(imageBytes),
    //     ),
    //   ),
    // );

    return Scaffold(
      appBar: AppBar(
        title: Text("Lihat Produk"),
        actions: <Widget>[
          (_userData['role'] == 'Pegawai')
              ? Container()
              : IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => FormProduct(
                            dataUser: _userData,
                            user: _user,
                            idForm: _dataForm!['idForm']),
                      ),
                    );
                  },
                  icon: Icon(Icons.edit)),
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => HistoryProduct(
                                idFormProduct: _idFormProduct,
                                user: _user,
                              ))));
                  // _idPegawai = [];
                  // final checkedData = ref
                  //     .read(pegawaiListProvider)
                  //     .where((element) => element.checked)
                  //     .toList();
                  // for (var data in checkedData) {
                  //   _idPegawai.add(data.idPegawai);
                  // }
                  // print('ID PEGAWAI');
                  // print(_idPegawai);
                },
                icon: Icon(Icons.history)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ProductViewAvatar(
                        name: InitialName.parseName(
                            name: (_dataForm != null)
                                ? _dataForm!['namaProduk']
                                : "A",
                            letterLimit: 1),
                        photoURL: _photoURL,
                        isBesar: true,
                      ),
                      IconButton(
                        iconSize: _width / 20,
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: Container(
                                    alignment: Alignment.center,
                                    height: MediaQuery.of(context).size.height /
                                        2.5,
                                    width:
                                        MediaQuery.of(context).size.height / 4,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          color: Colors.white,
                                          child: QrImageView(
                                            data: _idFormProduct,
                                            version: QrVersions.auto,
                                            size: 200,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        ElevatedButton(
                                            onPressed: () {
                                              exportQRImage(
                                                      idQR:
                                                          _dataForm!['idForm'],
                                                      namaQR:
                                                          (_dataForm != null)
                                                              ? _dataForm![
                                                                  'namaProduk']
                                                              : "A")
                                                  .then(
                                                (value) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      backgroundColor:
                                                          Colors.amber,
                                                      content: Row(children: [
                                                        Expanded(
                                                            child: Text(value)),
                                                        Icon(
                                                            color: Colors.red,
                                                            Icons
                                                                .warning_rounded)
                                                      ]),
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                    ),
                                                  );
                                                  Navigator.pop(context);
                                                },
                                              );
                                              // Printing.layoutPdf(
                                              //   format: PdfPageFormat.a4,
                                              //   // [onLayout] will be called multiple times
                                              //   // when the user changes the printer or printer settings
                                              //   onLayout:
                                              //       (PdfPageFormat format) {
                                              //     print("Jalan");
                                              //     // Any valid Pdf document can be returned here as a list of int
                                              //     return buildPdf(
                                              //       format,
                                              //     );
                                              //   },
                                              // );
                                            },
                                            child: const Text("Export")),
                                        ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text("Oke"))
                                      ],
                                    ),
                                  ),
                                );
                              });
                        },
                        icon: Icon(Icons.qr_code_scanner,
                            color: Theme.of(context).primaryColor),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 30),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextJudul3(
                            text: (_dataForm != null)
                                ? _dataForm!['namaProduk']
                                : "Loading",
                            color: Theme.of(context).colorScheme.onSecondary),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        width: _width / 13,
                        child: Column(
                          children: [
                            TextBody5(
                                text: "Stok",
                                color:
                                    Theme.of(context).colorScheme.onSecondary),
                            TextBody2(
                                text: (_dataForm != null)
                                    ? _dataForm!['stok']
                                    : "0",
                                color:
                                    Theme.of(context).colorScheme.onSecondary)
                          ],
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        width: _width / 5,
                        child: Column(
                          children: [
                            TextBody5(
                                text: "Kode",
                                color:
                                    Theme.of(context).colorScheme.onSecondary),
                            TextBody2(
                                text: (_dataForm != null)
                                    ? _dataForm!['kode']
                                    : "000",
                                color:
                                    Theme.of(context).colorScheme.onSecondary)
                          ],
                        ),
                      ),
                    ],
                  ),
                  (_userData['role'] == 'Pegawai')
                      ? Container()
                      : Container(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              TextBody5(
                                text: "Penanggung Jawab",
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    listPegawai(context, _width, _height,
                                        _dataPegawai, ref);
                                  },
                                  child: const Text(
                                      "Tambah Penanggung Jawab Produk"))
                            ],
                          ),
                        ),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: TextBody5(
                            text: "Deskripsi Barang",
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                        TextBody3(
                          text: (_dataForm != null)
                              ? _dataForm!['deskripsi']
                              : "deskripsi",
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              TextJudul2(
                  text: "Data Periodik",
                  color: Theme.of(context).colorScheme.onSecondary),
              const SizedBox(
                height: 10,
              ),
              FieldTextProduct(
                contoller: jumlahStokController,
                isWajib: false,
                isNumber: true,
                hintText: "Jumlah stok section",
              ),
              Row(
                children: [
                  SizedBox(
                    width: _width / 7,
                    child: FieldTextProduct(
                      isNumber: true,
                      isWajib: false,
                      contoller: jumlahProdukBagusController,
                      suffixText: 'Item',
                      hintText: "Jumlah produk bagus",
                    ),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  SizedBox(
                    width: _width / 6.5,
                    child: FieldTextProduct(
                      isNumber: true,
                      isWajib: false,
                      contoller: jumlahProdukKurangBagusController,
                      suffixText: 'Item',
                      hintText: "Jumlah kurang produk bagus",
                    ),
                  ),
                ],
              ),
              FieldTextProduct(
                contoller: usiaProdukController,
                isNumber: true,
                isWajib: false,
                suffixText: 'Hari',
                hintText: "Usia produk",
              ),
              FieldTextProduct(
                contoller: kebutuhanPendukungController,
                isWajib: false,
                hintText: "Kebutuhan pendukung",
              ),
              FieldTextProduct(
                contoller: keteranganController,
                isWajib: false,
                hintText: "Keterangan",
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                width: 250,
                child: _isLoading
                    ? ElevatedButton(
                        onPressed: () {},
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.white,
                        ))
                    : ElevatedButton(
                        onPressed: () {
                          print("KOCAK");
                          List<String> _idPegawai = [];
                          final checkedData = ref
                              .read(pegawaiListProvider)
                              .where((element) => element.checked)
                              .toList();
                          for (var data in checkedData) {
                            _idPegawai.add(data.idPegawai);
                          }
                          // print('ID PEGAWAI');
                          print(_idPegawai);

                          final filePath =
                              ref.read(profileAvatarNotifierProvider);
                          ref
                              .read(dataPeriodikNotifierProvider.notifier)
                              .saveDataBarang(
                                  userData: _userData,
                                  idDataPeriodik: (_dataForm != null &&
                                          _dataForm!.keys
                                              .contains('idPeriodik'))
                                      ? _dataForm!['idPeriodik']
                                      : null,
                                  idDataForm: _idFormProduct,
                                  jumlahStok: jumlahStokController.text,
                                  jumlahBagus: jumlahProdukBagusController.text,
                                  jumlahKurangBagus:
                                      jumlahProdukKurangBagusController.text,
                                  kebutuhanPendukung:
                                      kebutuhanPendukungController.text,
                                  keterangan: keteranganController.text,
                                  usiaProduk: usiaProdukController.text,
                                  idPegawai: _idPegawai);

                          print(filePath);
                        },
                        child: TextJudul4(text: "Simpan")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetailDataPeriodik extends StatelessWidget {
  const DetailDataPeriodik({
    super.key,
    required this.width,
  });

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
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
                    width: width, judul: "Jumlah stok section", value: "0"),
                DataPeriodikColumn(
                    width: width, judul: "Jumlah produk bagus", value: "0"),
                DataPeriodikColumn(
                  width: width,
                  judul: "Usia produk",
                  value: "0",
                ),
              ],
            ),
            Column(children: [
              DataPeriodikColumn(
                width: width,
                judul: "Jumlah produk tidak bagus",
                value: "0",
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
                      value: "Default"),
                  DataPeriodikColumn(
                      width: width, judul: "Keterangan", value: "Default"),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}

final _currentTodo = Provider<DataPegawai>((ref) => throw UnimplementedError());

class PilihPegawai extends ConsumerStatefulWidget {
  PilihPegawai({
    super.key,
  });

  @override
  ConsumerState<PilihPegawai> createState() => _PilihPegawaiState();
}

class _PilihPegawaiState extends ConsumerState<PilihPegawai> {
  late DataPegawai todo;
  late bool checked;
  @override
  void initState() {
    todo = ref.read(_currentTodo);

    checked = todo.checked;
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
              text: todo.dataPegawai['displayName'],
              color: Theme.of(context).colorScheme.onSecondary,
            ),
            trailing: Checkbox(
              value: checked,
              onChanged: (value) {
                ref.read(pegawaiListProvider.notifier).toggle(todo.idPegawai);
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

class DataPeriodikColumn extends StatelessWidget {
  const DataPeriodikColumn(
      {super.key,
      required this.width,
      required this.judul,
      required this.value});

  final double width;
  final String judul;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width / 2.55,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [TextBody(text: judul), TextBody2(text: value)],
      ),
    );
  }
}
