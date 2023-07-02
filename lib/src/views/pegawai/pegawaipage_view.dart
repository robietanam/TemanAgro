import 'package:com.ppl.teman_agro_admin/src/core/widget/loading_screen.dart';
import 'package:com.ppl.teman_agro_admin/src/features/data/data_barang_provider.dart';
import 'package:com.ppl.teman_agro_admin/src/features/data/data_source/data_user_source.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import '../../core/props/text_font.dart';
import 'package:iconify_flutter/icons/ph.dart';

import '../../core/widget/avatar.dart';
import '../../core/widget/search_bar.dart';
import '../../features/data/data_pegawai_provider.dart';
import '../../features/data/data_source/data_pegawai_source.dart';
import '../../features/data/search_barang_provider.dart';
import '../../features/data/state/data_user_state.dart';
import '../../features/fetchController/runOnce.dart';
import 'pegawai_detail.dart';

class PegawaiPageView extends StatefulHookConsumerWidget {
  const PegawaiPageView(
      {Key? key, required User user, required Map<String, dynamic> userData})
      : _user = user,
        _userData = userData,
        super(key: key);

  final User _user;
  final Map<String, dynamic> _userData;

  @override
  ConsumerState<PegawaiPageView> createState() => _PegawaiPageState();
}

class _PegawaiPageState extends ConsumerState<PegawaiPageView> {
  late User _user;
  late Map<String, dynamic> _userData;
  late DateFormat formatter;

  late List<Map<String, dynamic>> _dataPegawais;

  @override
  void initState() {
    print("Pegawai INIT");
    _user = widget._user;
    _userData = widget._userData;
    initializeDateFormatting("id_ID", null);
    formatter = DateFormat('d-MM-yyyy', 'id_ID');
    bool _runOnce = ref.read(pegawaiPageOnceProvider);
    print("RUN ONCE STATUS ON INIT ${_runOnce}");
    if (!_runOnce) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        print("GET DATA AGAIN");
        FetchDataState refWidget = ref.read(dataPegawaisNotifierProvider);
        bool fetchAgain = false;
        refWidget.maybeWhen(orElse: () {
          fetchAgain = true;
        }, fetchedArray: (dataPegawai) {
          _dataPegawais = dataPegawai.toList();
        });
        if (fetchAgain) {
          print("DATA PEGAWAI REF : ${refWidget}");
          ref
              .read(dataPegawaisNotifierProvider.notifier)
              .getDataPegawai(userData: _userData);
        }
        ref
            .watch(dataPegawaisReferralNotifierProvider.notifier)
            .getDataPegawaiReferral(
              userData: _userData,
            );
        ref.read(pegawaiPageOnceProvider.notifier).done();
      });
    }

    super.initState();
  }

  @override
  void didChangeDependencies() {
    print("Pegawai Page di change");
    // SchedulerBinding.instance.addPostFrameCallback((_) {
    //   ref.read(dataPegawaisNotifierProvider.notifier).getDataPegawai(
    //         userData: _userData,
    //       );
    // });
    super.didChangeDependencies();
  }

  @override
  void deactivate() {
    print("DEACTIVED");
    super.deactivate();
  }

  @override
  void dispose() {
    print("Pegawai DISPOSE");
    searchController.dispose();
    super.dispose();
  }

  TextEditingController searchController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>>? _dataForm;
  List<Widget> list = <Widget>[];
  bool _pegawaiWidgetOnce = false;
  Widget pegawaiWidget(
      {required Iterable<Map<String, dynamic>> dataForms, width, height}) {
    if (!_pegawaiWidgetOnce) {
      for (Map<String, dynamic> dataForm in dataForms) {
        list.add(PegawaiCard(
          user: _user,
          userData: _userData,
          width: width,
          height: height,
          pegawaiData: dataForm,
        ));
        _pegawaiWidgetOnce = true;
      }
    }

    return Column(children: list);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    ref.listen(
      pegawaiPageOnceProvider,
      (previous, next) {
        print("RUN ONCE PEGAWAI next ${next}");
        print("RUN ONCE PEGAWAI previous ${previous}");
        if (!next) {
          ref.watch(dataPegawaisNotifierProvider.notifier).getDataPegawai(
                userData: _userData,
              );
          ref
              .watch(dataPegawaisReferralNotifierProvider.notifier)
              .getDataPegawaiReferral(
                userData: _userData,
              );
          ref.watch(pegawaiPageOnceProvider.notifier).done();
        }
      },
    );

    ref.watch(dataPegawaisNotifierProvider).maybeWhen(orElse: () {
      print("Pegawai Page OrElse");
      _isLoading = false;
      if (_dataForm == null) {
        ref.read(pegawaiPageOnceProvider.notifier).reset();
      }
    }, unFetch: (message) {
      print("ERROR ${message}");
    }, loading: () {
      print("Pegawai Page loading");
      _isLoading = true;
    }, fetchedArray: (data) {
      print("Pegawai Page user fetched");
      _isLoading = false;
      // _dataForm = data.toList();
    });

    // ref.watch(dataPegawaisNotifierProvider).maybeWhen(orElse: () {
    //   print("Product Page Pegawai OrElse");
    //   _isLoading = false;
    // }, loading: () {
    //   print("Product Page Pegawai loading");
    //   _isLoading = true;
    // }, fetchedArray: (data) {
    //   print("Product Page Pegawai user fetched");
    //   _isLoading = false;
    // });
    _dataForm = ref.watch(postSearchProviderPegawai.notifier).state;

    bool theValue = ref.read(keySortProvider);
    return SafeArea(
      top: true,
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            ref.read(dataPegawaisNotifierProvider.notifier).getDataPegawai(
                  userData: _userData,
                );
            ref
                .read(dataPegawaisReferralNotifierProvider.notifier)
                .getDataPegawaiReferral(
                  userData: _userData,
                );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
              ),
              Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed: () {
                          print("Produk Sort");
                          print(theValue);
                          ref.read(keySortProvider.notifier).state = !theValue;
                        },
                        icon: (theValue)
                            ? Iconify(
                                Ph.sort_descending,
                                size: 30,
                                color: Theme.of(context).primaryColor,
                              )
                            : Iconify(
                                Ph.sort_ascending,
                                size: 30,
                                color: Theme.of(context).primaryColor,
                              )),
                    CustomSearchBar(
                        width: width,
                        searchController: searchController,
                        provider: keyProviderPegawai)
                  ]),
              Expanded(
                child: (_dataForm != null && _isLoading == false)
                    ? ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        itemCount: _dataForm!.length,
                        itemBuilder: (ctx, index) {
                          // last element (progress bar, error or 'Done!' if reached to the last element)
                          // if (index == _dataForm!.length) {
                          //   // load more and get error

                          //   return LinearProgressIndicator();
                          // }
                          _dataForm = ref
                              .watch(postSearchProviderPegawai.notifier)
                              .state!
                              .toList();

                          if (_dataForm![index]['uid'] == null) {
                            return ReferralCard(
                              idToken: _dataForm![index]['idToken'],
                              token: _dataForm![index]['token'].toString(),
                              createdAt:
                                  _dataForm![index]['lastUpdate'].toDate(),
                              width: width,
                              height: height,
                              formatter: formatter,
                            );
                          }
                          return PegawaiCard(
                            user: _user,
                            userData: _userData,
                            width: width,
                            height: height,
                            pegawaiData: _dataForm![index],
                          );
                        })
                    : const LoadingScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReferralCard extends ConsumerWidget {
  const ReferralCard(
      {super.key,
      required this.token,
      required this.idToken,
      required this.createdAt,
      required this.width,
      required this.height,
      required this.formatter});

  final String token;
  final String idToken;
  final DateTime createdAt;
  final double width;
  final double height;
  final DateFormat formatter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> deleteRef() async {
      ref
          .read(dataPegawaiSourceProvider)
          .deleteToken(idToken: idToken)
          .then((value) {
        ref.read(pegawaiPageOnceProvider.notifier).reset();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.amber,
          content: Row(children: [
            Expanded(child: Text("Data berhasil dihapus")),
            Icon(color: Colors.red, Icons.warning_rounded)
          ]),
        ));
      });
    }

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(left: 25, right: 25, top: 5, bottom: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.zero,
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const PegawaiViewAvatar(),
          Container(
            padding: const EdgeInsets.all(10),
            width: width / 2.3,
            height: height / 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextBody3(
                  text: "Calon Pegawai",
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
                TextBody4(
                  text: "Dibuat : ${formatter.format(createdAt)}",
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextBody3(
                text: "Kode",
                color: Theme.of(context).colorScheme.onSecondary,
              ),
              TextBody4(
                text: token,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ],
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  child:
                      Icon(Icons.copy, color: Theme.of(context).primaryColor),
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: token));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      backgroundColor: Colors.amber,
                      content: Row(children: [
                        Expanded(child: Text("Kode di salin ke clipboard")),
                        Icon(color: Colors.red, Icons.warning_rounded)
                      ]),
                      behavior: SnackBarBehavior.floating,
                    ));
                    print("COPY");
                  },
                ),
              ),
              InkWell(
                child:
                    Icon(Icons.delete, color: Theme.of(context).primaryColor),
                onTap: () {
                  // ref.read(pegawaiPageOnceProvider.notifier).reset();
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Container(
                            height: height / 5,
                            width: width / 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
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
                                  "Apakah anda yakin?",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.red),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          deleteRef();
                                        },
                                        child: const Text("Oke"),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text("Batal")),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      });
                  print("Deleted");
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PegawaiCard extends StatelessWidget {
  const PegawaiCard(
      {super.key,
      required this.width,
      required this.height,
      required this.user,
      required this.userData,
      required this.pegawaiData,
      this.photoURL});

  final User user;
  final Map<String, dynamic> userData;
  final double width;
  final double height;
  final String? photoURL;
  final Map<String, dynamic> pegawaiData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 1, bottom: 1),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PegawaiDetailView(
                      user: user,
                      userData: userData,
                      pegawaiData: pegawaiData)));
        },
        style: ElevatedButton.styleFrom(
          alignment: Alignment.center,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          padding:
              const EdgeInsets.only(left: 25, right: 25, top: 4, bottom: 4),
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PegawaiViewAvatar(photoURL: pegawaiData['photoURL']),
            Container(
              padding: const EdgeInsets.all(10),
              width: width / 1.9,
              height: height / 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextBody3(
                    text: pegawaiData['Nama'] ?? "Text",
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                  TextBody4(
                    text: pegawaiData['role'] ?? "Text2",
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
