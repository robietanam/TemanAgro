import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:com.ppl.teman_agro_admin/src/core/widget/alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/widget/loading_screen.dart';
import '../../features/data/data_source/data_pegawai_source.dart';
import '../../features/data/data_user_provider.dart';
import '../../features/data/search_barang_provider.dart';
import '../../features/fetchController/runOnce.dart';
import '../pegawai/pegawaipage_view.dart';
import '../pegawai/presensi_pegawai_view.dart';
import '../product/periodik_edit.dart';
import '../product/productform_view.dart';
import '../product/productpage_view.dart';
import '../profile/profile_view.dart';
import 'homepage_content.dart';

import 'pegawai_homepage_content.dart';
import 'scanner.dart';

class NavBarList {
  NavBarList({
    this.labelName = '',
    this.widget,
    this.icon,
  });

  String labelName;
  IconData? icon;
  Widget? widget;
}

class HomePageView extends StatefulHookConsumerWidget {
  const HomePageView({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  @override
  ConsumerState<HomePageView> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePageView>
    with TickerProviderStateMixin {
  late User _user;

  var _bottomNavIndex = 0; //default index of a first screen

  late AnimationController _fabAnimationController;
  late AnimationController _borderRadiusAnimationController;
  late Animation<double> fabAnimation;
  late Animation<double> borderRadiusAnimation;
  late CurvedAnimation fabCurve;
  late CurvedAnimation borderRadiusCurve;
  late AnimationController _hideBottomBarAnimationController;
  String? _qrCodeText;

  @override
  void initState() {
    super.initState();
    // Data Fetch
    print("HomePage init state");
    _user = widget._user;
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      print("HomePage init state post frame");

      ref
          .read(fetchDataNotifierProvider.notifier)
          .getDataUser(userId: _user.uid);
    });

    // Animataion
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _borderRadiusAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    fabCurve = CurvedAnimation(
      parent: _fabAnimationController,
      curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );
    borderRadiusCurve = CurvedAnimation(
      parent: _borderRadiusAnimationController,
      curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );

    fabAnimation = Tween<double>(begin: 0, end: 1).animate(fabCurve);
    borderRadiusAnimation = Tween<double>(begin: 0, end: 1).animate(
      borderRadiusCurve,
    );

    _hideBottomBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    Future.delayed(
      const Duration(seconds: 1),
      () => _fabAnimationController.forward(),
    );
    Future.delayed(
      const Duration(seconds: 1),
      () => _borderRadiusAnimationController.forward(),
    );
  }

  bool onScrollNotification(ScrollNotification notification) {
    if (notification is UserScrollNotification &&
        notification.metrics.axis == Axis.vertical) {
      switch (notification.direction) {
        case ScrollDirection.forward:
          _hideBottomBarAnimationController.reverse();
          _fabAnimationController.forward(from: 0);
          break;
        case ScrollDirection.reverse:
          _hideBottomBarAnimationController.forward();
          _fabAnimationController.reverse(from: 1);
          break;
        case ScrollDirection.idle:
          break;
      }
    }
    return false;
  }

  Future<void> _navigasiQRScanner(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BarcodeScannerWithScanWindow(),
      ),
    );
    if (result != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditPeriodikData(
            user: _user,
            userData: _userData,
            idFormProduct: result,
          ),
        ),
      );
    }
    setState(() {
      _qrCodeText = result;
    });
    if (!mounted) return;
  }

  bool _isLoading = true;

  Map<String, dynamic> _userData = {};
  @override
  Widget build(BuildContext context) {
    print("THIS USER DATA");

    ref.watch(fetchDataNotifierProvider).maybeWhen(orElse: () {
      print("Homepage OrElse");
    }, loading: () {
      print("Homepage loading");
      _isLoading = true;
      return const LoadingScreen();
    }, fetched: (data) {
      print("Homepage user fetched");
      _isLoading = false;
      _userData = data;
    });

    final navBarList = [
      NavBarList(
          labelName: "Home",
          icon: Icons.home,
          widget: (_userData['role'] == 'Pegawai')
              ? HomePageContentViewPegawai(
                  user: _user,
                  userData: _userData,
                )
              : HomePageContentView(
                  user: _user,
                  userData: _userData,
                )),
      NavBarList(
          labelName: "Produk",
          icon: Icons.ballot_outlined,
          widget: ProductPageView(
            user: _user,
            userData: _userData,
          )),
      (_userData['role'] == 'Pemilik')
          ? NavBarList(
              labelName: "Pegawai",
              icon: Icons.people,
              widget: PegawaiPageView(
                user: _user,
                userData: _userData,
              ))
          : NavBarList(
              labelName: "Kehadiran",
              icon: Icons.list_alt,
              widget: DetailPresensiPegawaiPage(
                user: _user,
                pegawaiData: _userData,
              )),
      NavBarList(
          labelName: "Profil",
          icon: Icons.person,
          widget: ProfilePageView(
            user: _user,
            userData: _userData,
          ))
    ];
    return Scaffold(
        extendBody: true,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
          height: 80,
          width: 80,
          child: _isLoading
              ? CircularProgressIndicator()
              : (_bottomNavIndex == 1 && _userData['role'] == 'Pemilik')
                  ? FloatingActionButton(
                      heroTag: "mainFAB",
                      child: const Icon(
                        size: 50,
                        Icons.add,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FormProduct(
                                      user: _user,
                                      dataUser: _userData,
                                    )));
                      },
                    )
                  : (_bottomNavIndex == 2 && _userData['role'] == 'Pemilik')
                      ? FloatingActionButton(
                          heroTag: "mainFAB",
                          child: const Icon(
                            size: 50,
                            Icons.add,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            int limit = 3;

                            if (_userData['premium'] == 1) {
                              limit = 10;
                            } else if (_userData['premium'] == 2) {
                              limit = 50;
                            }
                            print(ref
                                .read(postSearchProviderPegawai.notifier)
                                .state!
                                .toList());
                            if (ref
                                        .read(
                                            postSearchProviderPegawai.notifier)
                                        .state!
                                        .toList()
                                        .length <
                                    limit ||
                                _userData['premium'] == 3) {
                              ref
                                  .read(dataPegawaiSourceProvider)
                                  .tambahDataToken(userData: _userData)
                                  .then((value) => ref
                                      .read(pegawaiPageOnceProvider.notifier)
                                      .reset());
                            } else {
                              myAlertError(
                                  context: context,
                                  text:
                                      'Melebihi batas yang ditentukan, batas pegawai paket anda ${limit}');
                            }

                            ;
                          })
                      : FloatingActionButton(
                          heroTag: "mainFAB",
                          child: const Icon(
                            size: 40,
                            Icons.qr_code_scanner,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            print("QR CODE");
                            _navigasiQRScanner(context);
                          },
                        ),
        ),
        body: navBarList[_bottomNavIndex].widget,
        bottomNavigationBar: AnimatedBottomNavigationBar.builder(
          itemCount: navBarList.length,
          tabBuilder: (int index, bool isActive) {
            final color = Theme.of(context).iconTheme.color;
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  navBarList[index].icon as IconData,
                  size: 24,
                  color: color,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: (isActive)
                      ? BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.all(Radius.circular(3)))
                      : BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.all(Radius.circular(3))),
                  child: Text(
                    navBarList[index].labelName as String,
                    maxLines: 1,
                    style: (isActive)
                        ? TextStyle(
                            color: Theme.of(context).primaryColor, fontSize: 12)
                        : TextStyle(color: color, fontSize: 12),
                  ),
                )
              ],
            );
          },
          backgroundColor: Theme.of(context).primaryColor,
          activeIndex: _bottomNavIndex,
          splashColor: Theme.of(context).primaryColor,
          notchAndCornersAnimation: borderRadiusAnimation,
          splashRadius: 0,
          splashSpeedInMilliseconds: 100,
          notchSmoothness: NotchSmoothness.smoothEdge,
          gapLocation: GapLocation.center,
          height: 65,
          onTap: (index) => setState(() {
            _bottomNavIndex = index;
          }),
          hideAnimationController: _hideBottomBarAnimationController,
          // shadow: BoxShadow(
          //   offset: Offset(0, 1),
          //   blurRadius: 12,
          //   spreadRadius: 0.5,
          //   color: Theme.of(context).primaryColor,
          // ),
        ));
  }
}
