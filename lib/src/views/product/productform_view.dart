import 'package:com.ppl.teman_agro_admin/src/features/data/data_source/data_barang_source.dart';
import 'package:com.ppl.teman_agro_admin/src/features/fetchController/runOnce.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/props/text_font.dart';
import '../../core/widget/alert.dart';
import '../../core/widget/field_product.dart';
import '../../core/widget/product_avatar.dart';
import '../../features/avatar/avatar_provider.dart';
import '../../features/data/data_barang_provider.dart';

class FormProduct extends StatefulHookConsumerWidget {
  const FormProduct(
      {super.key, required this.user, this.idForm, required this.dataUser});

  final Map<String, dynamic> dataUser;
  final User user;
  final String? idForm;

  @override
  ConsumerState<FormProduct> createState() => _FormProductState();
}

class _FormProductState extends ConsumerState<FormProduct> {
  late double _width;
  late double _height;
  String? _idForm;
  late User _user;
  late Map<String, dynamic> _userData;
  Map<String, dynamic>? _dataForm;
  String? _imageInherit;
  final _formProductKey = GlobalKey<FormState>();
  // Data Form
  final namaController = TextEditingController();
  final stokController = TextEditingController();
  final kodeController = TextEditingController();
  final deskripsiController = TextEditingController();
  // Data Periodik
  final jumlahStokController = TextEditingController();
  final jumlahProdukBagusController = TextEditingController();
  final jumlahProdukKurangBagusController = TextEditingController();
  final usiaProdukController = TextEditingController();
  final kebutuhanPendukungController = TextEditingController();
  final keteranganController = TextEditingController();

  @override
  void initState() {
    _idForm = widget.idForm;
    _user = widget.user;
    _userData = widget.dataUser;
    if (_idForm != null) {
      print(_idForm);
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ref
            .read(dataFormNotifierProvider.notifier)
            .getDataForm(idForm: _idForm!);

        ref
            .read(dataPeriodikNotifierProvider.notifier)
            .getDataPeriodik(idFormData: _idForm!, user: _user);
      });
    }
    Size screenSize = WidgetsBinding.instance.window.physicalSize;
    _width = screenSize.width;
    _height = screenSize.height;
    if (_dataForm == null) {
      jumlahStokController.value = const TextEditingValue(text: "0");
      jumlahProdukBagusController.value = const TextEditingValue(text: "0");
      jumlahProdukKurangBagusController.value =
          const TextEditingValue(text: "0");
      usiaProdukController.value = const TextEditingValue(text: "0");
      kebutuhanPendukungController.value =
          const TextEditingValue(text: "Default");
      keteranganController.value = const TextEditingValue(text: "Default");
    }
    super.initState();
  }

  @override
  void dispose() {
    print("Product Dispose");
    if (_dataForm == null) {
      ref.invalidate(dataPeriodikNotifierProvider);
    }
    ref.invalidate(dataFormNotifierProvider);
    ref.invalidate(productAvatarNotifierProvider);
    // ref.invalidate(dataFormsNotifierProvider);
    super.dispose();
  }

  bool _loading = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? _dataPeriodik;
    String? filePath = ref.read(productAvatarNotifierProvider);
    // final formField2 = ref.watch(fieldProductListProvider);
    ref.watch(dataFormNotifierProvider).maybeWhen(orElse: () {
      _loading = false;
    }, loading: () {
      _loading = true;
    }, unFetch: (message) {
      _loading = false;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        //yourcode
        myAlertError(context: context, text: message!);
      });
    }, fetched: (dataFetch) {
      _loading = false;
      print("DATA FETCHED");
      _dataForm = dataFetch;
      print(_dataForm);
      namaController.text = dataFetch['namaProduk'];
      kodeController.text = dataFetch['kode'];
      stokController.text = dataFetch['stok'];
      deskripsiController.text = dataFetch['deskripsi'];
      _imageInherit = dataFetch['photoURL'];
      // jumlahProdukBagusController.text = dataFetch['jumlahBagus'];
      // jumlahProdukKurangBagusController.text = dataFetch['jumlahBagus'];
      // deskripsiController.text = dataFetch['deskripsi'];
    }, success: () {
      _loading = false;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        myAlertSuccess(
            context: context,
            fun: () {
              Navigator.pop(context);
              Navigator.pop(context);
            });
        ref
            .read(dataFormsNotifierProvider.notifier)
            .getDataForms(userData: _userData);
      });
    });
    print("REBUILDING");

    if (_dataForm == null) {
      ref.watch(dataPeriodikNotifierProvider).maybeWhen(
        unFetch: (message) {
          _isLoading = false;
          print("DATA TIDAK DITEMUKAN");
          SchedulerBinding.instance.addPostFrameCallback((_) {
            myAlertError(
                context: context,
                text: message.toString(),
                fun: () {
                  Navigator.pop(context);
                });
          });
        },
        loading: () {
          print("Periodik data loading");
          _isLoading = true;
        },
        fetched: (data) {
          print("Periodik data fetched");
          _isLoading = false;
          _dataPeriodik = data;
          jumlahStokController.text = data['jumlahStok'];
          jumlahProdukBagusController.text = data['jumlahBagus'];
          jumlahProdukKurangBagusController.text = data['jumlahKurangBagus'];
          usiaProdukController.text = data['usia'];
          kebutuhanPendukungController.text = data['kebutuhanPendukung'];
          keteranganController.text = data['keterangan'];
        },
        orElse: () {
          print("Periodik data OrElse");
          _isLoading = false;
        },
      );
    }
    print(_isLoading);

    return Scaffold(
      appBar: AppBar(
        title: Text((_dataForm == null) ? "Tambah Produk" : "Edit Produk"),
        actions: (_dataForm != null && _idForm != null)
            ? [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              content: SizedBox(
                                height: MediaQuery.of(context).size.height / 4,
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.error,
                                      color: Theme.of(context).primaryColor,
                                      size: 40,
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      "Apakah anda yakin, semua data periodik juga akan terhapus",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context, true);
                                              },
                                              child: const Text("Oke")),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context, false);
                                              },
                                              child: const Text("Batal")),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ).then((valueFromDialog) {
                          print("value ${valueFromDialog}");
                          if (valueFromDialog) {
                            print("id form ${_idForm}");
                            ref
                                .read(dataBarangSourceProvider)
                                .deleteDataFormBarang(
                                    idForm: _idForm!, dataUser: _userData);

                            Navigator.pop(context);
                          }
                        });
                      },
                      icon: Icon(Icons.delete)),
                )
              ]
            : [],
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          ProductAvatarIcon(imageInheritURL: _imageInherit),
          Container(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formProductKey,
              child: Column(
                children: [
                  FieldTextProduct(
                    contoller: namaController,
                    hintText: "Nama",
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: _width / 18,
                        child: FieldTextProduct(
                          contoller: stokController,
                          isNumber: true,
                          hintText: "Stok",
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      SizedBox(
                        width: _width / 4,
                        child: FieldTextProduct(
                          contoller: kodeController,
                          hintText: "Kode",
                        ),
                      ),
                    ],
                  ),
                  FieldTextProduct(
                    contoller: deskripsiController,
                    hintText: "Deskripsi Barang",
                    besar: true,
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  (_idForm == null)
                      ? Column(children: [
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
                                  suffixText: 'Item',
                                  isNumber: true,
                                  isWajib: false,
                                  contoller: jumlahProdukBagusController,
                                  hintText: "Jumlah produk bagus",
                                ),
                              ),
                              const SizedBox(
                                width: 30,
                              ),
                              SizedBox(
                                width: _width / 6.5,
                                child: FieldTextProduct(
                                  
                            suffixText: 'Item',
                                  isNumber: true,
                                  isWajib: false,
                                  contoller: jumlahProdukKurangBagusController,
                                  hintText: "Jumlah kurang produk bagus",
                                ),
                              ),
                            ],
                          ),
                          FieldTextProduct(
                            contoller: usiaProdukController,
                            
                            suffixText: 'Hari',
                            isNumber: true,
                            isWajib: false,
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
                        ])
                      : Container(),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 250,
            child: (_loading || (_isLoading && (_idForm == null)))
                ? ElevatedButton(
                    onPressed: () {},
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    ))
                : ElevatedButton(
                    onPressed: () {
                      if (_formProductKey.currentState!.validate()) {
                        print("KOCAK");
                        filePath = ref.read(productAvatarNotifierProvider);
                        ref
                            .read(dataFormNotifierProvider.notifier)
                            .saveDataBarang(
                              filePath: filePath,
                              idDataForm: _idForm,
                              userData: _userData,
                              deskripsiProduk: deskripsiController.text,
                              namaProduk: namaController.text,
                              jumlahStok: jumlahStokController.text,
                              kode: kodeController.text,
                              stok: stokController.text,
                              jumlahBagus: jumlahProdukBagusController.text,
                              jumlahKurangBagus:
                                  jumlahProdukKurangBagusController.text,
                              kebutuhanPendukung:
                                  kebutuhanPendukungController.text,
                              keterangan: keteranganController.text,
                              usiaProduk: usiaProdukController.text,
                            )
                            .then((value) {
                          if (_idForm != null) {
                            ref
                                .read(dataPeriodikNotifierProvider.notifier)
                                .getDataPeriodik(
                                    idFormData: _idForm!, user: _user);
                          }
                        });

                        print(filePath);
                      } else {
                        myAlertError(context: context);
                      }
                    },
                    child: TextJudul4(text: "Simpan")),
          ),
          SizedBox(
            height: _height / 8,
          )
        ]),
      ),
    );
  }
}
