import 'package:com.ppl.teman_agro_admin/src/views/auth/vertifikasi_view.dart';

import '../../core/props/main_paint.dart';
import '../../core/props/text_font.dart';
import '../../core/widget/custom_button.dart';
import '../../core/widget/field_login.dart';
import '../../features/auth/provider/auth_provider.dart';
import '../../features/avatar/avatar_provider.dart';
import '../homepage/homepage_view.dart';
import './signup_view.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../menuawal_view.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_hooks/flutter_hooks.dart';

class LoginView extends HookConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = useTextEditingController();
    final password = useTextEditingController();

    ref.listen(authNotifierProvider, (previous, next) {
      next.maybeWhen(
          orElse: () => null,
          authenticated: (user) {
            // Navigate to any screen
            print("Verify");
            if (!user.emailVerified) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VertifikasiView(user: user)));
            } else {
              print(user.emailVerified);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => HomePageView(
                    user: user,
                  ),
                ),
              );
            }
          },
          unauthenticated: (message) {
            print("Error");
            // SchedulerBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.amber,
              content: Row(children: [
                Expanded(child: Text(message!)),
                Icon(color: Colors.red, Icons.warning_rounded)
              ]),
              behavior: SnackBarBehavior.floating,
            ));
          });
    });

    const String assetName = 'assets/images/app-icon.png';

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(backgroundColor: Color(0xFF7972E6), elevation: 0),
      body: SingleChildScrollView(
        child: CustomPaint(
          painter: const TargetPainter(),
          child: Container(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  assetName,
                  width: 180,
                ),
                const TextJudul(text: "TEMAN AGRO"),
                const SizedBox(
                  height: 40,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const TextJudul(
                          text: "Login",
                          color: Colors.black,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        FieldTextLogin(
                          contoller: email,
                          hintText: "Email",
                        ),
                        const SizedBox(height: 20),
                        Password(password: password),
                        const SizedBox(height: 30),
                        Center(
                          child: CustomButton(
                              isDisabled: false,
                              title: 'Login',
                              loading: ref
                                  .watch(authNotifierProvider)
                                  .maybeWhen(
                                      orElse: () => false, loading: () => true),
                              onPressed: () {
                                ref.read(authNotifierProvider.notifier).login(
                                      email: email.text,
                                      password: password.text,
                                    );
                              }),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Tidak punya akun?'),
                            TextButton(
                              onPressed: () {
                                ref.invalidate(authNotifierProvider);
                                ref.invalidate(profileAvatarNotifierProvider);
                                ref.invalidate(passProvider);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignupView(),
                                  ),
                                );
                              },
                              child: const Text('Daftar'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
