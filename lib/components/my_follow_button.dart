import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MyFollowButton extends StatelessWidget {
  final void Function()? onPressed;
  final bool isFollowing;
  const MyFollowButton({super.key, this.onPressed, required this.isFollowing});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isFollowing
            ? Theme.of(context).colorScheme.primary
            : Colors.blue,
        padding: EdgeInsets.all(18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(12),
        ),
        elevation: isFollowing ? 0 : 3,
      ),
      child: Text(
        isFollowing ? 'Unfollow' : 'Follow',
        style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
      ),
    );
  }
}
