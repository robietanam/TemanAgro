import 'dart:io';

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/props/main_paint.dart';
import '../../core/props/text_font.dart';
import '../../core/utils/helpers.dart';
import '../../core/widget/alert.dart';
import '../../core/widget/avatar.dart';
import '../../core/widget/custom_button.dart';
import '../../core/widget/field_login.dart';
import '../../features/auth/provider/auth_provider.dart';
import '../../features/avatar/avatar_provider.dart';
import '../homepage/homepage_view.dart';
import 'signup_pegawai_view.dart';
import 'vertifikasi_view.dart';

class SignupView extends HookConsumerWidget {
  SignupView({super.key});

  final _formSignUpKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = useTextEditingController();
    final password = useTextEditingController();
    final name = useTextEditingController();
    final phone = useTextEditingController();
    final namaUsaha = useTextEditingController();
    ref.listen(authNotifierProvider, (previous, next) {
      next.maybeWhen(
        orElse: () => null,
        notVerify: (user) {
          print("NOT VERIFY 1");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => VertifikasiView(
                      user: user,
                    )),
          );
        },
        authenticatedNotVerify: (user) {
          email.value = TextEditingValue(text: user.email);
          name.value = TextEditingValue(text: user.displayName ?? "");
        },
        unauthenticated: (message) =>
            ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.amber,
            content: Row(children: [
              Expanded(child: Text(message!)),
              Icon(color: Colors.red, Icons.warning_rounded)
            ]),
            behavior: SnackBarBehavior.floating,
          ),
        ),
      );
    });

    const String assetName = 'assets/images/app-icon.png';
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Color(0x00000000), elevation: 0),
      body: SingleChildScrollView(
        child: CustomPaint(
          painter: TargetPainter(),
          child: Container(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 60,
                ),
                AvatarIcon(),
                SizedBox(
                  height: 20,
                ),
                Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Form(
                        key: _formSignUpKey,
                        child: Column(children: [
                          const TextJudul(
                            text: "Daftar",
                            color: Colors.black,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          FieldTextLogin(
                            contoller: name,
                            hintText: "Nama",
                          ),
                          const SizedBox(height: 20),
                          FieldTextLogin(
                            contoller: email,
                            hintText: "Email",
                          ),
                          const SizedBox(height: 20),
                          Password(password: password),
                          const SizedBox(height: 20),
                          FieldTextLogin(
                            contoller: phone,
                            isPhone: true,
                            hintText: "No HP",
                          ),
                          const SizedBox(height: 20),
                          FieldTextLogin(
                            contoller: namaUsaha,
                            hintText: "Nama Usaha",
                          ),
                          const SizedBox(height: 30),
                          Center(
                            child: CustomButton(
                              title: 'Register',
                              isDisabled: false,
                              onPressed: () {
                                final filePath =
                                    ref.read(profileAvatarNotifierProvider);
                                if (_formSignUpKey.currentState!.validate()) {
                                  ref
                                      .read(authNotifierProvider.notifier)
                                      .signup(
                                          email: email.text,
                                          password: password.text,
                                          nama: name.text,
                                          phone: phone.text,
                                          filePath: filePath,
                                          namaUsaha: namaUsaha.text,
                                          role: 'Pemilik');
                                } else {
                                  myAlertError(context: context);
                                }
                              },
                              loading:
                                  ref.watch(authNotifierProvider).maybeWhen(
                                        orElse: () => false,
                                        loading: () => true,
                                      ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text('Punya akun?'),
                              TextButton(
                                style: TextButton.styleFrom(
                                    minimumSize: Size.zero,
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    alignment: Alignment.center),
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Login',
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Daftar sebagai pegawai?'),
                              TextButton(
                                style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    alignment: Alignment.center),
                                onPressed: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SignupViewPegawai(),
                                      ));
                                  ref.invalidate(passProvider);
                                },
                                child: const Text('Pegawai'),
                              ),
                            ],
                          ),
                          Center(
                            child: SignInButton(
                              Buttons.GoogleDark,
                              onPressed: () => ref
                                  .read(authNotifierProvider.notifier)
                                  .continueWithGoogle(role: "Pemilik"),
                            ),
                          ),
                        ]),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
