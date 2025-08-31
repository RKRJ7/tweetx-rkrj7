import 'package:flutter/material.dart';
import 'package:rkrj7_tweetx/components/loading_circle.dart';
import 'package:rkrj7_tweetx/components/my_button.dart';
import 'package:rkrj7_tweetx/components/my_textfield.dart';
import 'package:rkrj7_tweetx/services/auth/auth_service.dart';

class LoginPage extends StatefulWidget {
  final void Function() togglepage;
  const LoginPage({super.key, required this.togglepage});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailcont = TextEditingController();
  TextEditingController passcont = TextEditingController();

  final _auth = AuthService();

  void login() async {
    showLoadingCircle(context);
    try {
      await _auth.loginEmailPassword(emailcont.text, passcont.text);
      
      //hide loading circle
      if (mounted) {
      Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        hideLoadingCircle(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var thcolor = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: thcolor.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_open_rounded, color: thcolor.primary, size: 95),
                const SizedBox(height: 50),
                Text(
                  'You were missed, Welcome Back!',
                  style: TextStyle(color: thcolor.primary),
                ),
                const SizedBox(height: 20),
                MyTextfield(
                  controller: emailcont,
                  hint: 'Email',
                  obsecure: false,
                ),
                const SizedBox(height: 10),
                MyTextfield(
                  controller: passcont,
                  hint: 'Password',
                  obsecure: true,
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: thcolor.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                MyButton(label: 'Login', onTap: login),
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: () {
                    widget.togglepage();
                  },
                  child: Text(
                    'New to app? Register now',
                    style: TextStyle(color: thcolor.inversePrimary),
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
