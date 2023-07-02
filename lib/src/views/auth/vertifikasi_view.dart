import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/props/text_font.dart';
import '../../features/auth/provider/auth_provider.dart';
import '../homepage/homepage_view.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VertifikasiView extends StatefulWidget {
  const VertifikasiView({super.key, required User this.user});

  final User user;

  @override
  State<VertifikasiView> createState() => _VertifikasiViewState();
}

class _VertifikasiViewState extends State<VertifikasiView> {
  late User _user;
  bool _isButtonDisabled = false;
  int _remainingTime = 0;
  Timer? _timer;

  late Timer _timerConfirm;
  @override
  void initState() {
    super.initState();

    _timerConfirm = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      if (user?.emailVerified ?? false) {
        timer.cancel();
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.amber,
            content: Row(children: [
              Expanded(child: Text("Email Tervertivikasi")),
              Icon(color: Colors.red, Icons.warning_rounded)
            ]),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  void _handleButtonTap() {
    if (!_isButtonDisabled) {
      setState(() {
        _isButtonDisabled = true;
        _remainingTime = 60;
      });
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          if (_remainingTime > 0) {
            _remainingTime--;
          } else {
            _timer?.cancel();
            _isButtonDisabled = false;
          }
        });
      });
      if (_user.emailVerified) {
        _user.sendEmailVerification();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerConfirm.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF7972E6),
        elevation: 0,
        title: const TextJudul2(text: "Vertifikasi email"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 70),
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 100,
              ),
              TextJudul(
                text: "Email sudah dikirim",
                color: Theme.of(context).colorScheme.onSecondary,
              ),
              SizedBox(
                height: 30,
              ),
              SizedBox(
                width: 300,
                child: TextBody4(
                  text:
                      "Yuk cek inbox atau spam email kamu dan verifikasi email kamu dari sana",
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
              SizedBox(
                height: 120,
              ),
              Divider(
                color: Colors.black,
              ),
              SizedBox(
                width: 300,
                child: TextBody4(
                  text: "Belum menerima email verifikasi?",
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.center),
                onPressed: _isButtonDisabled ? null : _handleButtonTap,
                child: const Text('Kirim ulang'),
              ),
              Text(_isButtonDisabled ? "Coba lagi dalam $_remainingTime" : ""),
            ],
          ),
        ),
      ),
    );
  }
}
