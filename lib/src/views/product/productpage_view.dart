import 'package:com.ppl.teman_agro_admin/src/core/widget/loading_screen.dart';
import 'package:com.ppl.teman_agro_admin/src/features/data/data_barang_provider.dart';
import 'package:com.ppl.teman_agro_admin/src/features/data/state/data_user_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import '../../core/props/text_font.dart';
import 'package:iconify_flutter/icons/ph.dart';

import '../../core/utils/nama_product.dart';
import '../../core/widget/avatar.dart';
import '../../core/widget/product_avatar.dart';
import '../../core/widget/search_bar.dart';
import '../../features/data/search_barang_provider.dart';
import '../../features/fetchController/runOnce.dart';
import 'periodik_edit.dart';

class ProductPageView extends StatefulHookConsumerWidget {
  const ProductPageView(
      {Key? key, required User user, required Map<String, dynamic> userData})
      : _user = user,
        _userData = userData,
        super(key: key);

  final User _user;
  final Map<String, dynamic> _userData;

  @override
  ConsumerState<ProductPageView> createState() => _ProductPageState();
}

class _ProductPageState extends ConsumerState<ProductPageView> {
  late User _user;
  late Map<String, dynamic> _userData;

  @override
  void initState() {
    print("PRODUCT INIT");
    _user = widget._user;
    _userData = widget._userData;
    bool _runOnce = ref.read(productPageOnceProvider);
    print("Run Once ${_runOnce}");
    if (!_runOnce) {
      print("RUN ONCE");
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ref.read(dataFormsNotifierProvider.notifier).getDataForms(
              userData: _userData,
            );
        ref.read(productPageOnceProvider.notifier).done();
      });
    }

    if (ref.read(dataFormsNotifierProvider.notifier).state ==
        FetchDataState.initial()) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ref.read(dataFormsNotifierProvider.notifier).getDataForms(
              userData: _userData,
            );
        ref.read(productPageOnceProvider.notifier).done();
      });
    }

    super.initState();
  }

  // @override
  // void didChangeDependencies() {
  //   print("Product Page di change");
  //   SchedulerBinding.instance.addPostFrameCallback((_) {
  //     ref.read(dataFormsNotifierProvider.notifier).getDataForms(
  //           userData: _userData,
  //         );
  //   });
  //   super.didChangeDependencies();
  // }

  @override
  void dispose() {
    print("PRODUCT DISPOSE");
    // ref.invalidate(dataFormsNotifierProvider);
    searchController.dispose();
    super.dispose();
  }

  TextEditingController searchController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>>? _dataForm;

  Widget formWidget(
      {required Iterable<Map<String, dynamic>> dataForms, width, height}) {
    List<Widget> list = <Widget>[];

    for (Map<String, dynamic> dataForm in dataForms) {
      list.add(ProductCard(
          user: _user,
          userData: _userData,
          width: width,
          height: height,
          formData: dataForm,
          judul: dataForm['namaProduk'],
          deskripsi: dataForm['deskripsi'],
          stok: dataForm['stok'],
          photoURL: dataForm['photoURL']));
    }

    return Column(children: list);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    // bool _runOnce = ref.read(productPageOnceProvider);
    // print("Run Once ${_runOnce}");
    // if (!_runOnce) {
    //   print("RUN ONCE");
    //   SchedulerBinding.instance.addPostFrameCallback((_) {
    //     ref.read(dataFormsNotifierProvider.notifier).getDataForms(
    //           userData: _userData,
    //         );
    //     ref.read(productPageOnceProvider.notifier).done();
    //   });
    // }
    print("dataForm di Build : ${_dataForm}");

    ref.watch(dataFormsNotifierProvider).maybeWhen(orElse: () {
      print("Product Page OrElse");
      _isLoading = false;

      // _dataForm = ref.watch(postSearchProvider.notifier).state;

      // print(_dataForm);
      // if (_dataForm == null) {
      //   SchedulerBinding.instance.addPostFrameCallback((_) {
      //     print("MASUK");
      //     ref.watch(productPageOnceProvider.notifier).reset();
      //     print(ref.read(productPageOnceProvider));
      //   });
      // }
    }, unFetch: (message) {
      print("UnFETCH");
      // ref.watch(dataFormsNotifierProvider.notifier).getDataForms(
      //       userData: _userData,
      //     );
    }, loading: () {
      print("Product Page loading");
      _isLoading = true;
    }, fetchedArray: (dataForm) {
      _isLoading = false;
      _dataForm = dataForm.toList();
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

    _dataForm = ref.watch(postSearchProvider.notifier).state;
    print("SEARCH DATA FORM : ${_dataForm}");

    bool theValue = ref.read(sortProvider);
    return SafeArea(
      top: true,
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            ref.read(dataFormsNotifierProvider.notifier).getDataForms(
                  userData: _userData,
                );
            print("REFRESHED DATA PRODUK");
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
                          ref.read(sortProvider.notifier).state = !theValue;
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
                      provider: keyProvider,
                    )
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
                          _dataForm =
                              ref.watch(postSearchProvider.notifier).state;
                          return ProductCard(
                              user: _user,
                              userData: _userData,
                              width: width,
                              height: height,
                              formData: _dataForm![index],
                              judul: _dataForm![index]['namaProduk'],
                              deskripsi: _dataForm![index]['deskripsi'],
                              stok: _dataForm![index]['stok'],
                              photoURL: _dataForm![index]['photoURL']);
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

// ListView(
//                   children: [
//                     Padding(
//                       padding:
//                           const EdgeInsets.only(left: 12, right: 12, top: 20),
//                       child: Row(children: [
//                         IconButton(
//                             onPressed: () {
//                               print("Produk Sort");
//                             },
//                             icon: Iconify(
//                               Ph.sort_descending,
//                               size: 30,
//                               color: Theme.of(context).primaryColor,
//                             )),
//                         CustomSearchBar(
//                             width: width, searchController: searchController),
//                       ]),
//                     ),
//                     const SizedBox(
//                       height: 10,
//                     ),
//                     formWidget(
//                         dataForms: _dataForm!, height: height, width: width)
//                   ],
//                 )

class ProductCard extends StatelessWidget {
  const ProductCard(
      {super.key,
      required this.width,
      required this.height,
      required this.judul,
      required this.deskripsi,
      required this.stok,
      required this.user,
      required this.userData,
      required this.formData,
      this.photoURL});

  final User user;
  final Map<String, dynamic> userData;
  final double width;
  final double height;
  final String judul;
  final String deskripsi;
  final String stok;
  final String? photoURL;
  final Map<String, dynamic> formData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 1, bottom: 1),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EditPeriodikData(
                      user: user,
                      idFormProduct: formData['idForm'],
                      userData: userData)));
        },
        style: ElevatedButton.styleFrom(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          padding:
              const EdgeInsets.only(left: 25, right: 25, top: 8, bottom: 8),
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          ProductViewAvatar(
              name: InitialName.parseName(name: judul, letterLimit: 2),
              photoURL: photoURL),
          Container(
            padding: const EdgeInsets.all(10),
            width: width / 1.9,
            height: height / 9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextBody3(
                  text: judul,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
                TextBody4(
                  text: deskripsi,
                  color: Theme.of(context).colorScheme.secondaryContainer,
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            width: width / 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextBody4(
                  text: "Stok",
                  color: Theme.of(context).colorScheme.secondaryContainer,
                ),
                TextDeskripsi(
                  text: stok,
                  color: Theme.of(context).colorScheme.onSecondary,
                )
              ],
            ),
          )
        ]),
      ),
    );
  }
}
