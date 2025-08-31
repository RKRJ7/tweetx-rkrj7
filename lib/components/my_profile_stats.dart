import 'package:flutter/material.dart';

class MyProfileStats extends StatelessWidget {
  final int postCount;
  final int followersCount;
  final int followingCount;
  final void Function()? onTap;
  const MyProfileStats({super.key, required this.followersCount, required this.followingCount, required this.postCount, this.onTap});

  @override
  Widget build(BuildContext context) {
    final numberTextStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );
    final labelTextStyle = TextStyle(
      fontSize: 14,
      color: Theme.of(context).colorScheme.primary,
    );
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Column(
              children: [
                Text(postCount.toString(), style: numberTextStyle),
                Text('Posts', style: labelTextStyle),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            child: Column(
              children: [
                Text(followersCount.toString(), style: numberTextStyle),
                Text('Followers', style: labelTextStyle),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            child: Column(
              children: [
                Text(followingCount.toString(), style: numberTextStyle),
                Text('Following', style: labelTextStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
