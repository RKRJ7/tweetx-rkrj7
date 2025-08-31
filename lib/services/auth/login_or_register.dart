import 'package:flutter/material.dart';
import 'package:rkrj7_tweetx/pages/login_page.dart';
import 'package:rkrj7_tweetx/pages/register_page.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  bool showLoginPage = true;

  void toggle() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return showLoginPage
        ? LoginPage(togglepage: toggle)
        : RegisterPage(togglepage: toggle);
  }
}
