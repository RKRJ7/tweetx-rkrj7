import 'package:flutter/material.dart';
import 'package:rkrj7_tweetx/components/loading_circle.dart';
import 'package:rkrj7_tweetx/components/my_button.dart';
import 'package:rkrj7_tweetx/components/my_textfield.dart';
import 'package:rkrj7_tweetx/services/auth/auth_service.dart';
import 'package:rkrj7_tweetx/services/database/database_service.dart';

class RegisterPage extends StatefulWidget {
  final void Function() togglepage;
  const RegisterPage({super.key, required this.togglepage});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _auth = AuthService();
  final _db = DatabaseService();

  TextEditingController namecont = TextEditingController();
  TextEditingController emailcont = TextEditingController();
  TextEditingController passcont = TextEditingController();
  TextEditingController cnfpasscont = TextEditingController();

  void register() async {
    if (passcont.text != cnfpasscont.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password and confirm password don\'t match.'),
        ),
      );
      return;
    } else {
      showLoadingCircle(context);
      try {
        await _auth.registerEmailPassword(emailcont.text, passcont.text);

        if (mounted) {
          //hide loading circle
          Navigator.pop(context);
        }

        await _db.saveUserInfoInFirebase(
          name: namecont.text,
          email: emailcont.text,
        );

      } catch (e) {
        if (mounted) {
          hideLoadingCircle(context);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        }
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
                  'Welcome to TweetX! Let\'s make your account.',
                  style: TextStyle(color: thcolor.primary),
                ),
                const SizedBox(height: 20),
                MyTextfield(
                  controller: namecont,
                  hint: 'Name',
                  obsecure: false,
                ),
                const SizedBox(height: 10),
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
                const SizedBox(height: 10),
                MyTextfield(
                  controller: cnfpasscont,
                  hint: 'Confirm Password',
                  obsecure: true,
                ),
                const SizedBox(height: 20),
                MyButton(label: 'Register', onTap: register),
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: () {
                    widget.togglepage();
                  },
                  child: Text(
                    'Already a user? Login Here',
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
