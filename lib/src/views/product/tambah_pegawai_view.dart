import 'package:com.ppl.teman_agro_admin/src/core/utils/nama_product.dart';
import 'package:com.ppl.teman_agro_admin/src/core/widget/loading_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../core/widget/alert.dart';
import '../../core/widget/field_product.dart';
import '../../core/widget/product_avatar.dart';
import '../../features/data/data_barang_provider.dart';
import '../../features/data/data_pegawai_provider.dart';
import '../../features/data/data_source/data_pegawai_source.dart';
import 'productform_view.dart';
import 'QR_gambar.dart';
import '../../core/props/text_font.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../features/avatar/avatar_provider.dart';

class TambahPegawai extends StatefulHookConsumerWidget {
  const TambahPegawai(
      {super.key,
      required this.user,
      required this.idFormProduct,
      required this.userData});

  final User user;
  final String idFormProduct;
  final Map<String, dynamic> userData;

  @override
  ConsumerState<TambahPegawai> createState() => _TambahPegawaiState();
}

class _TambahPegawaiState extends ConsumerState<TambahPegawai> {
  late User _user;
  late String _idFormProduct;
  late Map<String, dynamic> _userData;

  late Iterable<Map<String, dynamic>> _dataPegawai;
  String? _character = "1";
  late double _width;
  late double _height;

  @override
  void dispose() {
    print("Product Dispose");
    ref.invalidate(profileAvatarNotifierProvider);
    super.dispose();
  }

  @override
  void initState() {
    _user = widget.user;
    _idFormProduct = widget.idFormProduct;
    _userData = widget.userData;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ref
          .read(dataPegawaisNotifierProvider.notifier)
          .getDataPegawai(userData: _userData);
    });
    Size screenSize = WidgetsBinding.instance.window.physicalSize;
    _width = screenSize.width;
    _height = screenSize.height;
    super.initState();
  }

  // Data Periodik
  final jumlahStokController = TextEditingController();
  final jumlahProdukBagusController = TextEditingController();
  final jumlahProdukKurangBagusController = TextEditingController();
  final usiaProdukController = TextEditingController();
  final kebutuhanPendukungController = TextEditingController();
  final keteranganController = TextEditingController();

  bool _isLoading = false;
  bool _runOnce = false;
  @override
  Widget build(BuildContext context) {
    final filePath = ref.read(profileAvatarNotifierProvider);

    Map<String, dynamic>? _dataForm;
    final data = ref.watch(pegawaiListProvider);

    ref.watch(dataPegawaisNotifierProvider).maybeWhen(
        orElse: () {},
        loading: () {
          _isLoading = true;
        },
        fetchedArray: (data) {
          print("FETEHCH");
          _isLoading = false;
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

    if (_isLoading) {
      return LoadingScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Lihat Produk"),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                Navigator.pushReplacement(
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
                  final checkedData = ref
                      .read(pegawaiListProvider)
                      .where((element) => element.checked)
                      .toList();
                  print(checkedData);
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
              SizedBox(
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
                    Column(
                      children: [
                        for (DataPegawai i in data) ...[
                          ProviderScope(
                            overrides: [
                              _currentTodo.overrideWithValue(i),
                            ],
                            child: PilihPegawai(),
                          ),
                        ]
                      ],
                    )
                  ],
                ),
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

class PilihPegawai extends HookConsumerWidget {
  PilihPegawai({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todo = ref.watch(_currentTodo);
    bool checked = todo.checked;
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
                checked = !checked;
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
