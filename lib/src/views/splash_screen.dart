import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  static const id = 'SplashScreen';

  const SplashScreen({
    Key? key,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    (() async {
      await Future.delayed(Duration.zero);
      // final isLoggedIn = Globals.firebaseUser != null;

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, 'the named'
          // isLoggedIn ? HomeScreen.id : AuthenticationScreen.id,
          );
    })();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(
        body: Text("Test"),
      ),
    );
  }
}
