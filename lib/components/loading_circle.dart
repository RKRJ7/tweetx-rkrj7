import 'package:flutter/material.dart';

void showLoadingCircle(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return const AlertDialog.adaptive(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Center(child: CircularProgressIndicator()),
      );
    },
  );
}

void hideLoadingCircle(BuildContext context) {
  Navigator.pop(context);
}
