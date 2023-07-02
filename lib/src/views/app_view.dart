import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:flutter/material.dart';

import '../core/utils/app_theme.dart';
import '../features/auth/data_source/auth_data_source.dart';
import 'auth/loginpage_view.dart';
import 'homepage/homepage_view.dart';

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const RoutePage(),
      theme: AppTheme.lightTheme,
    );
  }
}

class RoutePage extends ConsumerStatefulWidget {
  const RoutePage({super.key});

  @override
  ConsumerState<RoutePage> createState() => _routePageState();
}

class _routePageState extends ConsumerState<RoutePage> {
  bool _isLoggedin = false;
  User? _user;

  @override
  Widget build(BuildContext context) {
    final user = ref.read(authDataSourceProvider).getCurrentUser();

    if (user != null) {
      setState(() {
        _user = user;
        _isLoggedin = true;
      });
    } else {
      setState(() {
        _isLoggedin = false;
      });
    }

    return _isLoggedin ? HomePageView(user: _user!) : LoginView();
  }
}
