import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rkrj7_tweetx/models/post.dart';
import 'package:rkrj7_tweetx/pages/home_page.dart';
import 'package:rkrj7_tweetx/pages/post_page.dart';
import 'package:rkrj7_tweetx/pages/profile_page.dart';

void goUserPage(BuildContext context, String uid) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ProfilePage(uid: uid)),
  );
}

void goPostPage(BuildContext context, Post post) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => PostPage(post: post)),
  );
}

void goHomePage(BuildContext context) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
}
