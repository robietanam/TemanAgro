import 'package:flutter/material.dart';

class TextJudul extends StatelessWidget {
  const TextJudul({super.key, required this.text, this.color});

  final String text;
  final Color? color;

  Color get _color => color != null ? color! : Colors.white;

  @override
  Widget build(BuildContext context) {
    return Text(
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      text,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: _color,
      ),
    );
  }
}

class TextPickTime extends StatelessWidget {
  const TextPickTime({super.key, required this.text, this.color});

  final String text;
  final Color? color;

  Color get _color => color != null ? color! : Colors.white;

  @override
  Widget build(BuildContext context) {
    return Text(
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      text,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: _color,
      ),
    );
  }
}

class TextPickTime2 extends StatelessWidget {
  const TextPickTime2({super.key, required this.text, this.color});

  final String text;
  final Color? color;

  Color get _color => color != null ? color! : Colors.white;

  @override
  Widget build(BuildContext context) {
    return Text(
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: _color,
      ),
    );
  }
}

class TextJudul2 extends StatelessWidget {
  const TextJudul2({super.key, required this.text, this.color});

  final String text;
  final Color? color;

  Color get _color => color != null ? color! : Colors.white;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
          TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _color),
    );
  }
}

class TextJudul3 extends StatelessWidget {
  const TextJudul3({super.key, required this.text, this.color});

  final String text;
  final Color? color;

  Color get _color => color != null ? color! : Colors.white;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
          TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: _color),
    );
  }
}

class TextJudul4 extends StatelessWidget {
  const TextJudul4({super.key, required this.text, this.color});

  final String text;
  final Color? color;

  Color get _color => color != null ? color! : Colors.white;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
          TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: _color),
    );
  }
}

class TextJudul5 extends StatelessWidget {
  const TextJudul5({super.key, required this.text, this.color});

  final String text;
  final Color? color;

  Color get _color => color != null ? color! : Colors.white;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
          TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _color),
    );
  }
}

class TextBody extends StatelessWidget {
  const TextBody({super.key, required this.text, this.color});

  final String text;
  final Color? color;

  Color get _color => color != null ? color! : Colors.white;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
          TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: _color),
    );
  }
}

class TextBody_2 extends StatelessWidget {
  const TextBody_2({super.key, required this.text, this.color});

  final String text;
  final Color? color;

  Color get _color => color != null ? color! : Colors.white;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
          TextStyle(fontSize: 11, fontWeight: FontWeight.normal, color: _color),
    );
  }
}

class TextBody2 extends StatelessWidget {
  const TextBody2({super.key, required this.text, this.color});

  final String text;
  final Color? color;

  Color get _color => color != null ? color! : Colors.white;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0, bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}

class TextBody3 extends StatelessWidget {
  const TextBody3({super.key, required this.text, this.color});

  final String text;
  final Color? color;

  Color get _color => color != null ? color! : Colors.white;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
          TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _color),
    );
  }
}

class TextBody4 extends StatelessWidget {
  const TextBody4({super.key, required this.text, this.color, this.maxLines});

  final String text;
  final Color? color;
  final int? maxLines;

  Color get _color => color != null ? color! : Colors.white;
  int get _maxLines => maxLines != null ? maxLines! : 2;

  @override
  Widget build(BuildContext context) {
    return Text(
      softWrap: true,
      text,
      maxLines: _maxLines,
      textAlign: TextAlign.left,
      style: TextStyle(
        overflow: TextOverflow.ellipsis,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: _color,
      ),
    );
  }
}

class TextBody4_2 extends StatelessWidget {
  const TextBody4_2({super.key, required this.text, this.color});

  final String text;
  final Color? color;

  Color get _color => color != null ? color! : Colors.white;

  @override
  Widget build(BuildContext context) {
    return Text(
      softWrap: true,
      text,
      maxLines: 2,
      style: TextStyle(
        overflow: TextOverflow.ellipsis,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: _color,
      ),
    );
  }
}

class TextDeskripsi extends StatelessWidget {
  const TextDeskripsi({super.key, required this.text, this.color});

  final String text;
  final Color? color;

  Color get _color => color != null ? color! : Colors.white;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
          TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _color),
    );
  }
}

class TextBody5 extends StatelessWidget {
  const TextBody5({super.key, required this.text, this.color});

  final String text;
  final Color? color;

  Color get _color => color != null ? color! : Colors.white;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
          TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: _color),
    );
  }
}

class TextBody6 extends StatelessWidget {
  const TextBody6({super.key, required this.text, this.color});

  final String text;
  final Color? color;

  Color get _color => color != null ? color! : Colors.white;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
          TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: _color),
    );
  }
}
