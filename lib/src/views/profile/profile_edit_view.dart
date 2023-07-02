import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/widget/alert.dart';
import '../../core/widget/loading_screen.dart';
import '../../core/widget/avatar.dart';
import '../../core/props/text_font.dart';
import '../../features/auth/provider/auth_provider.dart';
import '../../features/avatar/avatar_provider.dart';
import '../../features/data/data_barang_provider.dart';
import '../../features/data/data_pegawai_provider.dart';
import '../../features/data/data_user_provider.dart';
import '../../features/data/search_barang_provider.dart';
import '../../features/fetchController/runOnce.dart';
import '../auth/loginpage_view.dart';
import 'ubah_password.dart';

class ProfilePageEditView extends StatefulHookConsumerWidget {
  const ProfilePageEditView({Key? key, required User user, required userData})
      : _user = user,
        _userData = userData,
        super(key: key);

  final User _user;
  final Map<String, dynamic> _userData;
  @override
  _ProfileEditPageViewState createState() => _ProfileEditPageViewState();
}

class _ProfileEditPageViewState extends ConsumerState<ProfilePageEditView> {
  late User _user;
  late Map<String, dynamic> _userData;
  late String? image;
  late double _width;
  late double _height;
  late TextEditingController displayName;
  late TextEditingController phone;
  late TextEditingController namaUsaha;

  @override
  void initState() {
    _user = widget._user;
    _userData = widget._userData;
    image = _userData['photoURL'];
    displayName = TextEditingController(text: _userData['displayName']);
    phone = TextEditingController(text: _userData['phone']);
    namaUsaha = TextEditingController(text: _userData['namaUsaha']);
    Size screenSize = WidgetsBinding.instance.window.physicalSize;
    _width = screenSize.width;
    _height = screenSize.height;
    // print("Profile View Init State");
    // SchedulerBinding.instance.addPostFrameCallback((_) {
    //   ref
    //       .read(profileFetchDataNotifierProvider.notifier)
    //       .getDataUser(userId: _user.uid);
    // });
    super.initState();
  }

  @override
  void dispose() {
    ref.invalidate(fetchDataNotifierProvider);
    ref.invalidate(profileAvatarNotifierProvider);
    print("DISPOSE");
    super.dispose();
  }

  Map<String, dynamic>? data;
  bool _isEditableNama = false;

  bool _isEditableNoHp = false;
  bool _isEditableNamaUsaha = false;
  bool _isLoad = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    String? filePath = ref.read(profileAvatarNotifierProvider);
    print("REBUILD");
    ref.watch(fetchDataNotifierProvider).maybeWhen(
      orElse: () {
        print("Profile orElse");
        _isLoading = false;
      },
      loading: () {
        print("Profile loading");
        _isLoading = true;
      },
      fetched: (fetched) {
        print("Profile user fetched");
        _isLoading = false;
        image = fetched['photoURL'];
        data = fetched;
      },
      success: () {
        _isLoading = false;
        print("Profile Save Sukses");
      },
    );

    if (_isLoading) {
      return LoadingScreen();
    }

    final Color primaryColor = Theme.of(context).primaryColor;
    double width = _width;
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Color(0x00000000),
        ),
        body: SingleChildScrollView(
          child: Stack(children: [
            SizedBox(
              width: 400,
              height: 550,
              child: CustomPaint(
                painter: OpenPainter(color: primaryColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 80,
                left: 16.0,
                right: 16.0,
                bottom: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                      child: AvatarIcon(
                    imageInheritURL: image,
                  )),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: TextJudul(
                        text: (_userData['role'] == "Pemilik")
                            ? "PEMILIK"
                            : "PEGAWAI"),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextBody6(
                          text: "Nama",
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: width / 3.5,
                              height: 20,
                              child: TextField(
                                enabled: _isEditableNama,
                                controller: displayName,
                                decoration: const InputDecoration(
                                  disabledBorder: InputBorder.none,
                                  isDense: true,
                                  hintText: 'Nama',
                                ),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _isEditableNama = !_isEditableNama;
                                });
                              },
                              icon: _isEditableNama
                                  ? const Icon(Icons.check)
                                  : const Icon(Icons.edit),
                              color: Theme.of(context).primaryColor,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextBody6(
                          text: "No HP",
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              height: 20,
                              width: width / 3.5,
                              child: TextField(
                                keyboardType: TextInputType.phone,
                                enabled: _isEditableNoHp,
                                controller: phone,
                                decoration: const InputDecoration(
                                  disabledBorder: InputBorder.none,
                                  isDense: true,
                                  hintText: 'No Hp',
                                ),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            IconButton(
                              padding: const EdgeInsets.all(0),
                              style: IconButton.styleFrom(
                                  padding: const EdgeInsets.all(0)),
                              onPressed: () {
                                setState(() {
                                  _isEditableNoHp = !_isEditableNoHp;
                                });
                              },
                              icon: _isEditableNoHp
                                  ? const Icon(Icons.check)
                                  : const Icon(Icons.edit),
                              color: Theme.of(context).primaryColor,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  (_userData['role'] == "Pemilik")
                      ? Container(
                          padding: EdgeInsets.only(top: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextBody6(
                                text: "Nama usaha",
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    height: 20,
                                    width: width / 3.5,
                                    child: TextField(
                                      keyboardType: TextInputType.text,
                                      enabled: _isEditableNamaUsaha,
                                      controller: namaUsaha,
                                      decoration: const InputDecoration(
                                        disabledBorder: InputBorder.none,
                                        isDense: true,
                                        hintText: 'Nama usaha',
                                      ),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    padding: const EdgeInsets.all(0),
                                    style: IconButton.styleFrom(
                                        padding: const EdgeInsets.all(0)),
                                    onPressed: () {
                                      setState(() {
                                        _isEditableNamaUsaha =
                                            !_isEditableNamaUsaha;
                                      });
                                    },
                                    icon: _isEditableNamaUsaha
                                        ? const Icon(Icons.check)
                                        : const Icon(Icons.edit),
                                    color: Theme.of(context).primaryColor,
                                  )
                                ],
                              )
                            ],
                          ),
                        )
                      : Container(),
                  Container(
                    padding: const EdgeInsets.only(top: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextBody6(
                          text: "Email",
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Row(
                            children: [
                              SizedBox(
                                width: width / 3.5,
                                child: TextBody4_2(
                                  text: _user.email!,
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        (_user.emailVerified)
                            ? const Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 5.0),
                                      child: Icon(
                                        Icons.check,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                    ),
                                    Text("Email Tervertifikasi",
                                        style: TextStyle(color: Colors.green)),
                                  ],
                                ),
                              )
                            : const Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 5.0),
                                      child: Icon(
                                        Icons.cancel,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                    ),
                                    Text("Email Belum Tervertifikasi",
                                        style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  (_userData['role'] == "Pemilik")
                      ? TextBody6(
                          text: "Status Premium",
                          color: Theme.of(context).colorScheme.onSecondary,
                        )
                      : Container(),
                  (_userData['role'] == "Pemilik")
                      ? Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Row(
                            children: [
                              SizedBox(
                                width: width / 3.5,
                                child: TextBody4_2(
                                  text: (_userData['premium'] == 0)
                                      ? 'Tidak Berlangganan'
                                      : (_userData['premium'] == 1)
                                          ? 'Basic'
                                          : (_userData['premium'] == 2)
                                              ? 'Premium'
                                              : (_userData['premium'] == 3)
                                                  ? 'Eksklusif'
                                                  : "",
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                  const SizedBox(height: 8.0),
                  Container(
                    width: width,
                    height: 50,
                    padding: const EdgeInsets.only(top: 5),
                    child: GestureDetector(
                      onTap: () {
                        print("TEST");
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UbahPasswordView(
                                    user: _user, userData: _userData)));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextJudul5(
                            text: "Ubah Password",
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                          Icon(
                            Icons.keyboard_arrow_right,
                            color: Theme.of(context).colorScheme.onSecondary,
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: SizedBox(
                            width: 250,
                            child: ElevatedButton(
                              onPressed: () {
                                filePath =
                                    ref.read(profileAvatarNotifierProvider);
                                _isLoad = false;
                                ref
                                    .read(fetchDataNotifierProvider.notifier)
                                    .saveDataUser(
                                      userId: _user.uid,
                                      userData: _userData,
                                      firstname: displayName.text,
                                      phone: phone.text,
                                      filePath: filePath,
                                    )
                                    .then((value) {
                                  myAlertSuccess(context: context);
                                  ref
                                      .read(fetchDataNotifierProvider.notifier)
                                      .getDataUser(userId: _user.uid);
                                }).catchError(() {
                                  myAlertError(context: context);
                                });
                              },
                              child: const TextJudul4(
                                text: 'Simpan',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Center(
                          child: SizedBox(
                            width: 250,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              onPressed: () async {
                                ref.invalidate(dataFormsNotifierProvider);
                                ref.invalidate(productPageOnceProvider);
                                ref.invalidate(pegawaiPageOnceProvider);
                                ref.invalidate(fetchDataNotifierProvider);
                                ref.invalidate(dataPeriodiksNotifierProvider);
                                ref.invalidate(dataPegawaisNotifierProvider);
                                ref.invalidate(postSearchProviderPegawai);
                                ref.invalidate(postSearchProvider);
                                ref
                                    .read(authNotifierProvider.notifier)
                                    .signOut();
                                ref
                                    .read(
                                        profileAvatarNotifierProvider.notifier)
                                    .state = null;
                                Navigator.pop(context);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginView()),
                                );
                              },
                              child: const TextJudul4(
                                text: 'Logout',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ));
  }
}

class OpenPainter extends CustomPainter {
  OpenPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    var paint1 = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final shape = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, width, height / 1.7),
      const Radius.circular(0),
    );
    final path = Path()..addRRect(shape);
    canvas.drawShadow(path, Colors.grey, 10, false);
    canvas.drawPath(path, paint1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
