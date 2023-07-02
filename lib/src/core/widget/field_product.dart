import 'package:flutter/material.dart';

class FieldTextProduct extends StatelessWidget {
  const FieldTextProduct(
      {super.key,
      required this.contoller,
      required this.hintText,
      this.suffixText,
      this.besar = false,
      this.isNumber = false,
      this.isWajib = true});

  final TextEditingController contoller;
  final String hintText;
  final String? suffixText;
  final bool besar;
  final bool isNumber;
  final bool isWajib;

  @override
  Widget build(BuildContext context) {
    int minLines = 1;
    int maxLines = 1;
    TextInputType inputType = TextInputType.text;
    if (besar) {
      minLines = 2;
      maxLines = 3;
    }
    if (isNumber) {
      inputType = TextInputType.number;
    }
    return TextFormField(
        controller: contoller,
        keyboardType: inputType,
        cursorColor: const Color(0xFF7972E6),
        minLines: minLines,
        maxLines: maxLines,
        validator: (value) {
          if (!isWajib) {
            return null;
          }
          if (value == null || value.trim().isEmpty) {
            return 'Data harus diisi';
          }
          return null;
        },
        decoration: InputDecoration(
          suffix: (suffixText != null) ? Text(suffixText!) : null,
          label: Text(
            hintText,
            style: const TextStyle(fontSize: 14),
          ),
          hintText: hintText,
        ));
  }
}

class FieldAddTextProduct extends StatelessWidget {
  const FieldAddTextProduct(
      {super.key,
      required this.hintText,
      this.besar = "kecil",
      this.tipe = "Text"});

  final String hintText;
  final String? besar;
  final String tipe;

  @override
  Widget build(BuildContext context) {
    int minLines = 1;
    int maxLines = 1;
    if (besar == "besar") {
      minLines = 3;
      maxLines = 4;
    }
    return TextField(
        readOnly: true,
        cursorColor: Color(0xFF7972E6),
        minLines: minLines,
        maxLines: maxLines,
        decoration: InputDecoration(
          label: Text(hintText),
          hintText: hintText,
        ));
  }
}
