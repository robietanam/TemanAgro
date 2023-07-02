import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/auth/provider/auth_provider.dart';

class FieldTextLogin extends StatelessWidget {
  const FieldTextLogin({
    super.key,
    required this.contoller,
    required this.hintText,
    this.isPhone = false,
    this.isNumber = false,
  });

  final TextEditingController contoller;
  final String hintText;
  final bool isPhone;
  final bool isNumber;

  @override
  Widget build(BuildContext context) {
    TextInputType tipe = TextInputType.text;

    if (isPhone) {
      tipe = TextInputType.phone;
    }
    if (isNumber) {
      tipe = TextInputType.number;
    }
    return TextFormField(
      keyboardType: tipe,
      controller: contoller,
      cursorColor: Color(0xFF7972E6),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Data harus diisi';
        }
        return null;
      },
      decoration: InputDecoration(
          hintText: hintText,
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(
            width: 2,
            color: Color(0xFF7972E6),
          )),
          border: const OutlineInputBorder(
              borderSide: BorderSide(
            width: 2,
            color: Color(0xFF7972E6),
          ))),
    );
  }
}

class Password extends ConsumerWidget {
  const Password({
    super.key,
    required this.password,
  });

  final TextEditingController password;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibility = ref.watch(passProvider);
    return TextFormField(
      controller: password,
      cursorColor: Color(0xFF7972E6),
      obscureText: !visibility,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Data harus diisi';
        }
        return null;
      },
      decoration: InputDecoration(
          hintText: 'Password',
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(
            width: 2,
            color: Color(0xFF7972E6),
          )),
          border: const OutlineInputBorder(
              borderSide: BorderSide(
            width: 2,
            color: Color(0xFF7972E6),
          )),
          suffixIcon: IconButton(
              onPressed: () {
                ref.read(passProvider.notifier).visibility();
              },
              icon:
                  Icon(visibility ? Icons.visibility : Icons.visibility_off))),
    );
  }
}
