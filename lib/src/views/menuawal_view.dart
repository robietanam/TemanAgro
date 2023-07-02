import 'package:com.ppl.teman_agro_admin/src/views/auth/vertifikasi_view.dart';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_hooks/flutter_hooks.dart';

import '../core/props/main_paint.dart';
import '../core/props/text_font.dart';

class MenuAwalView extends HookConsumerWidget {
  const MenuAwalView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const String assetName = 'assets/images/app-icon.png';

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(backgroundColor: Color(0xFF7972E6), elevation: 0),
      body: SingleChildScrollView(
        child: CustomPaint(
          painter: TargetPainter(),
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
                        ElevatedButton(
                          child: Text("Create Account"),
                          onPressed: () {},
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                          child: Text("Create Account"),
                          onPressed: () {},
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          child: Text("Create Account"),
                          onPressed: () {},
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
