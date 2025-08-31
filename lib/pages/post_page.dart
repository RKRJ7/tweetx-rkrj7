import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rkrj7_tweetx/components/my_comment_tile.dart';
import 'package:rkrj7_tweetx/components/my_post_tile.dart';
import 'package:rkrj7_tweetx/helper/navigate_pages.dart';
import 'package:rkrj7_tweetx/models/post.dart';
import 'package:rkrj7_tweetx/services/database/database_provider.dart';

class PostPage extends StatefulWidget {
  final Post post;
  const PostPage({super.key, required this.post});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  late final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
  late final dbListener = Provider.of<DatabaseProvider>(context);

  @override
  Widget build(BuildContext context) {
    final comments = dbListener.getCommentList(widget.post.id);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(foregroundColor: Theme.of(context).colorScheme.primary),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            children: [
              MyPostTile(
                post: widget.post,
                onUserTap: () {
                  goUserPage(context, widget.post.uid);
                },
              ),
              comments.isEmpty
                  ? Center(child: Text('No comments yet'))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return MyCommentTile(
                          comment: comment,
                          onUserTap: () {
                            goUserPage(context, comment.uid);
                          },
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
