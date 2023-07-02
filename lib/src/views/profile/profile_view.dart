import 'package:com.ppl.teman_agro_admin/src/core/props/text_font.dart';
import 'package:com.ppl.teman_agro_admin/src/views/profile/profile_edit_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/props/main_paint.dart';
import '../../core/widget/loading_screen.dart';
import '../../features/data/data_user_provider.dart';
import '../gaji/gaji_pegawai_view.dart';
import 'bantuan_view.dart';
import 'setting_view.dart';
import 'upgrade_akun_view.dart';

class ProfilePageView extends StatefulHookConsumerWidget {
  const ProfilePageView(
      {Key? key, required User user, required Map<String, dynamic> userData})
      : _user = user,
        _userData = userData,
        super(key: key);

  final User _user;
  final Map<String, dynamic> _userData;

  @override
  ConsumerState<ProfilePageView> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePageView> {
  late Map<String, dynamic> userData;

  late double width;
  late double height;

  @override
  void initState() {
    // ref.read(authDataSourceProvider).userSignOut();

    Size screenSize = WidgetsBinding.instance.window.physicalSize;
    width = screenSize.width;
    height = screenSize.height;
    print("ProfilePage init state");
    userData = widget._userData;
    super.initState();
  }

  @override
  void dispose() {
    // ref.invalidate(authNotifierProvider);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userData = widget._userData;
    final user = widget._user;
    ref.watch(fetchDataNotifierProvider).maybeWhen(
          orElse: () {},
          fetched: (dataFetch) {
            userData = dataFetch;
          },
        );

    if (userData == null) {
      return const LoadingScreen();
    } else {
      return CustomPaint(
        painter: const TargetPainter2(),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          child: RefreshIndicator(
            onRefresh: () async {
              print("Refressed");
            },
            child: ListView(
                padding: const EdgeInsets.only(left: 12, right: 12),
                children: [
                  const SizedBox(
                    height: 120,
                  ),
                  Center(
                      child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(4), // Border width
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(10.0)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7.0),
                          child: SizedBox.fromSize(
                            size: const Size.fromRadius(70),
                            child: (userData != null &&
                                    userData['photoURL'] != null)
                                ? Image.network(
                                    userData["photoURL"],
                                    height: 200,
                                    width: 200,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/images/noimage.png',
                                        height: 70,
                                        width: 70,
                                      );
                                    },
                                    frameBuilder: (context, child, frame,
                                        wasSynchronouslyLoaded) {
                                      print(frame);
                                      if (frame != null ||
                                          wasSynchronouslyLoaded) {
                                        return child;
                                      }
                                      return const Center(
                                        child: SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 5,
                                            color: Colors.white,
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Image.asset(
                                    'assets/images/noimage.png',
                                    height: 200,
                                    width: 200,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextJudul3(
                        text: userData['displayName'],
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ],
                  )),
                  const SizedBox(
                    height: 10,
                  ),
                  (userData['role'] == 'Pemilik')
                      ? Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10.0)),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 20, bottom: 20),
                          child: Row(children: [
                            Icon(
                              Icons.error,
                              color: Theme.of(context).primaryColor,
                              size: 40,
                            ),
                            Container(
                              width: 160,
                              height: 50,
                              padding: const EdgeInsets.only(left: 10),
                              child: const Text(
                                'Upgrade akun Anda untuk menikmati Fitur lengkap dari TemanAgro',
                                overflow: TextOverflow.clip,
                                softWrap: true,
                                style: TextStyle(fontSize: 11),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            PilihPaketPremiumView(
                                                user: user,
                                                userData: userData)));
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor),
                              child: const Text("Upgrade Akun",
                                  style: TextStyle(fontSize: 12)),
                            )
                          ]),
                        )
                      : Container(),
                  const SizedBox(
                    height: 30,
                  ),
                  MenuProfileWidget(
                      icon: Icons.account_circle,
                      judul: "Akun Saya",
                      deskripsi: "Nama, Email, No.Handphone, dll.",
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfilePageEditView(
                                    user: user, userData: userData)));
                      }),
                  const SizedBox(
                    height: 10,
                  ),
                  (userData['role'] == 'Pemilik')
                      ? MenuProfileWidget(
                          icon: Icons.settings,
                          judul: "Setting",
                          deskripsi: "Bahasa, privacy policy, tentang",
                          onPressed: () {
                            print("Setting");
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SettingPageView()));
                          })
                      : MenuProfileWidget(
                          icon: Icons.money,
                          judul: "Gaji",
                          deskripsi: "Nominal gaji yang diterima",
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => GajiPegawaiView(
                                        user: user, userData: userData)));
                            print("Setting");
                          }),
                  const SizedBox(
                    height: 10,
                  ),
                  MenuProfileWidget(
                      icon: Icons.help_rounded,
                      judul: "Bantuan",
                      onPressed: () {
                        print("Help ");
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BantuanPageView()));
                      }),
                  const SizedBox(
                    height: 10,
                  ),
                ]),
          ),
        ),
      );
    }
  }
}

class MenuProfileWidget extends StatelessWidget {
  const MenuProfileWidget(
      {super.key,
      required this.icon,
      required this.judul,
      this.deskripsi,
      this.onPressed});
  final IconData icon;
  final String judul;
  final String? deskripsi;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 1.0), //(x,y)
                  blurRadius: 6.0,
                )
              ]),
          alignment: Alignment.center,
          padding: (deskripsi != null)
              ? const EdgeInsets.only(left: 20, right: 20, top: 6, bottom: 6)
              : const EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
          child: Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 30,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                        left: 10, bottom: 5, top: 5, right: 10),
                    width: 200,
                    child: Text(
                      judul,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  (deskripsi != null)
                      ? Container(
                          padding: const EdgeInsets.only(
                              left: 10, bottom: 5, top: 5, right: 10),
                          width: 200,
                          child: Text(
                            deskripsi!,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          ),
                        )
                      : Container(),
                ],
              )
            ],
          ),
        ));
  }
}
