import 'dart:io';

import 'package:com.ppl.teman_agro_admin/src/features/auth/data_source/auth_data_source.dart';
import 'package:com.ppl.teman_agro_admin/src/views/auth/vertifikasi_view.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/props/main_paint.dart';
import '../../core/props/text_font.dart';
import '../../core/widget/alert.dart';
import '../../core/widget/avatar.dart';
import '../../core/widget/custom_button.dart';
import '../../core/widget/field_login.dart';
import '../../features/auth/provider/auth_provider.dart';
import '../../features/avatar/avatar_provider.dart';
import '../homepage/homepage_view.dart';

class SignupViewPegawai extends HookConsumerWidget {
  SignupViewPegawai({super.key});

  final _formSignUpPegawaiKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = useTextEditingController();
    final password = useTextEditingController();
    final name = useTextEditingController();
    final phone = useTextEditingController();
    final referral = useTextEditingController();
    ref.listen(authNotifierProvider, (previous, next) {
      next.maybeWhen(
        notVerify: (user) {
          print("NOT VERIFY 2");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => VertifikasiView(
                      user: user,
                    )),
          );
        },
        orElse: () => null,
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
    final filePath = ref.read(profileAvatarNotifierProvider);

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
                        key: _formSignUpPegawaiKey,
                        child: Column(children: [
                          const TextJudul(
                            text: "Daftar sebagai pegawai",
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
                            contoller: referral,
                            isNumber: true,
                            hintText: "Kode Refferal",
                          ),
                          const SizedBox(height: 30),
                          Center(
                            child: CustomButton(
                              title: 'Daftar',
                              isDisabled: false,
                              onPressed: () {
                                if (_formSignUpPegawaiKey.currentState!
                                    .validate()) {
                                  ref
                                      .read(authDataSourceProvider)
                                      .checkReferral(referral: referral.text)
                                      .then((value) {
                                    print('value : ${value}');
                                    if (value != null) {
                                      ref
                                          .read(authNotifierProvider.notifier)
                                          .signup(
                                              email: email.text,
                                              password: password.text,
                                              nama: name.text,
                                              phone: phone.text,
                                              filePath: filePath,
                                              referral: referral.text,
                                              role: 'Pegawai');
                                    } else {
                                      print("Kode Referral Salah");
                                      myAlertError(
                                          context: context,
                                          text: "Kode Referral Salah");
                                    }
                                  });
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
                          Center(
                            child: SignInButton(
                              Buttons.GoogleDark,
                              onPressed: () => ref
                                  .read(authNotifierProvider.notifier)
                                  .continueWithGoogle(role: "Pegawai"),
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
