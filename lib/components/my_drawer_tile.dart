import 'package:flutter/material.dart';

class MyDrawerTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final void Function()? onTap;
  const MyDrawerTile({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      iconColor: Theme.of(context).colorScheme.primary,
      textColor: Theme.of(context).colorScheme.inversePrimary,
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap,
    );
  }
}
