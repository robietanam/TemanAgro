import 'package:com.ppl.teman_agro_admin/src/core/props/text_font.dart';
import 'package:flutter/material.dart';

class SettingPageView extends StatefulWidget {
  const SettingPageView({super.key});

  @override
  State<SettingPageView> createState() => _SettingPageViewState();
}

class _SettingPageViewState extends State<SettingPageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setting'),
      ),
      body: Center(
          child: TextJudul(
        text: 'Segera Hadir',
        color: Theme.of(context).colorScheme.onSecondary,
      )),
    );
  }
}
