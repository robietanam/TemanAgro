import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print("LOADING SCREEN BUILD");
    return Stack(
      children: <Widget>[
        Container(
          color: Colors.white,
          child: const Center(child: CircularProgressIndicator()),
        ),
        ListView(),
      ],
    );
    // Center(
    //   child: ListView(shrinkWrap: true, children: [

    //   ]),
    // );
  }
}
