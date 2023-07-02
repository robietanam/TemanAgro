import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:com.ppl.teman_agro_admin/src/features/auth/data_source/auth_data_source.dart';
import 'package:com.ppl.teman_agro_admin/src/views/profile/profile_view.dart';
import 'package:flutter/material.dart';

import 'package:flutter/rendering.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class NavBarList {
  NavBarList({
    this.labelName = '',
    this.index,
    this.icon,
  });

  String labelName;
  IconData? icon;
  NavbarIndex? index;
}

enum NavbarIndex {
  Home,
  Produk,
  Pegawai,
  Profil,
}

class MyNavBar extends ConsumerStatefulWidget {
  const MyNavBar({super.key});

  @override
  _MyNavBar createState() => _MyNavBar();
}

class _MyNavBar extends ConsumerState<MyNavBar> with TickerProviderStateMixin {
  var _bottomNavIndex = 0; //default index of a first screen

  late AnimationController _fabAnimationController;
  late AnimationController _borderRadiusAnimationController;
  late Animation<double> fabAnimation;
  late Animation<double> borderRadiusAnimation;
  late CurvedAnimation fabCurve;
  late CurvedAnimation borderRadiusCurve;
  late AnimationController _hideBottomBarAnimationController;

  final navBarList = [
    NavBarList(labelName: "Home", icon: Icons.home),
    NavBarList(labelName: "Produk", icon: Icons.ballot_outlined),
    NavBarList(labelName: "Pegawai", icon: Icons.people),
    NavBarList(labelName: "Profil", icon: Icons.person)
  ];

  @override
  void initState() {
    super.initState();

    _fabAnimationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _borderRadiusAnimationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    fabCurve = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );
    borderRadiusCurve = CurvedAnimation(
      parent: _borderRadiusAnimationController,
      curve: Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );

    fabAnimation = Tween<double>(begin: 0, end: 1).animate(fabCurve);
    borderRadiusAnimation = Tween<double>(begin: 0, end: 1).animate(
      borderRadiusCurve,
    );

    _hideBottomBarAnimationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    Future.delayed(
      Duration(seconds: 1),
      () => _fabAnimationController.forward(),
    );
    Future.delayed(
      Duration(seconds: 1),
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

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authDataSourceProvider).getCurrentUser();

    return AnimatedBottomNavigationBar.builder(
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
                    ? TextStyle(color: Theme.of(context).primaryColor)
                    : TextStyle(color: color),
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
        if (index == 3) {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => ProfilePageView(user: user!),
          //   ),
          // );
        }
      }),
      hideAnimationController: _hideBottomBarAnimationController,
      // shadow: BoxShadow(
      //   offset: Offset(0, 1),
      //   blurRadius: 12,
      //   spreadRadius: 0.5,
      //   color: Theme.of(context).primaryColor,
      // ),
    );
  }
}
