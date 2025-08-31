import 'package:flutter/material.dart';
import 'package:rkrj7_tweetx/models/user.dart';
import 'package:rkrj7_tweetx/pages/profile_page.dart';

class MyProfileTile extends StatelessWidget {
  final UserProfile user;
  const MyProfileTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 15, 20, 0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage(uid: user.uid)),
        ),
        title: Text(
          user.name,
          style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
        ),
        leading: Icon(Icons.person),
        iconColor: Theme.of(context).colorScheme.primary,
        subtitle: Text(
          '@${user.username}',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}
