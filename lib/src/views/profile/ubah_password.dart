import 'package:com.ppl.teman_agro_admin/src/core/widget/alert.dart';
import 'package:com.ppl.teman_agro_admin/src/core/widget/loading_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/props/text_font.dart';
import '../../features/data/data_source/data_user_source.dart';

class UbahPasswordView extends StatefulHookConsumerWidget {
  const UbahPasswordView({Key? key, required User user, required userData})
      : _user = user,
        _userData = userData,
        super(key: key);

  final User _user;
  final Map<String, dynamic> _userData;

  @override
  ConsumerState<UbahPasswordView> createState() => _UbahPasswordViewState();
}

class _UbahPasswordViewState extends ConsumerState<UbahPasswordView> {
  late TextEditingController passwordLama;
  late TextEditingController passwordBaru;
  late TextEditingController ulangiPassword;

  late User _user;
  late Map<String, dynamic> _userData;

  @override
  void initState() {
    passwordLama = TextEditingController();
    passwordBaru = TextEditingController();
    ulangiPassword = TextEditingController();

    _user = widget._user;
    _userData = widget._userData;

    super.initState();
  }

  List<bool> isVisible = [false, false, false];
  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ubah Password"),
      ),
      body: (_loading)
          ? const LoadingScreen()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextBody6(
                                text: "Password lama",
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      obscureText: !isVisible[0],
                                      controller: passwordLama,
                                      decoration: const InputDecoration(
                                        disabledBorder: InputBorder.none,
                                        isDense: true,
                                        hintText: 'Password lama',
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
                                        isVisible[0] = !isVisible[0];
                                      });
                                    },
                                    icon: isVisible[0]
                                        ? const Icon(Icons.visibility)
                                        : const Icon(Icons.visibility_off),
                                    color: Theme.of(context).primaryColor,
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextBody6(
                                text: "Password baru",
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      obscureText: !isVisible[1],
                                      controller: passwordBaru,
                                      decoration: const InputDecoration(
                                        disabledBorder: InputBorder.none,
                                        isDense: true,
                                        hintText: 'Password baru',
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
                                        isVisible[1] = !isVisible[1];
                                      });
                                    },
                                    icon: isVisible[1]
                                        ? const Icon(Icons.visibility)
                                        : const Icon(Icons.visibility_off),
                                    color: Theme.of(context).primaryColor,
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextBody6(
                                text: "Ulangi password baru",
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      obscureText: !isVisible[2],
                                      controller: ulangiPassword,
                                      decoration: const InputDecoration(
                                        disabledBorder: InputBorder.none,
                                        isDense: true,
                                        hintText: 'Ulangi password ',
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
                                        isVisible[2] = !isVisible[2];
                                      });
                                    },
                                    icon: isVisible[2]
                                        ? const Icon(Icons.visibility)
                                        : const Icon(Icons.visibility_off),
                                    color: Theme.of(context).primaryColor,
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 60)),
                        onPressed: () {
                          if (passwordBaru.text == ulangiPassword.text) {
                            setState(() {
                              _loading = true;
                            });
                            ref
                                .read(dataUserSourceProvider)
                                .ubahPasswordUser(
                                    passwordLama: passwordLama.text,
                                    passwordbaru: passwordBaru.text,
                                    userData: _userData)
                                .then((value) {
                              if (value == 'Sukses mengganti password') {
                                myAlertSuccess(context: context, text: value);
                              } else {
                                myAlertError(context: context, text: value);
                              }
                              setState(() {
                                _loading = false;
                              });
                            });
                          } else {
                            setState(() {
                              _loading = false;
                            });
                            myAlertError(
                                context: context,
                                text: 'Password baru tidak sama');
                          }
                        },
                        child: const TextJudul2(
                          text: 'Simpan',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
