import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rkrj7_tweetx/components/my_dialog.dart';
import 'package:rkrj7_tweetx/models/post.dart';
import 'package:rkrj7_tweetx/services/auth/auth_service.dart';
import 'package:rkrj7_tweetx/services/database/database_provider.dart';

class MyPostTile extends StatefulWidget {
  final Post post;
  final void Function()? onUserTap;
  final void Function()? onPostTap;
  const MyPostTile({
    super.key,
    required this.post,
    this.onUserTap,
    this.onPostTap,
  });

  @override
  State<MyPostTile> createState() => _MyPostTileState();
}

class _MyPostTileState extends State<MyPostTile> {
  late final dbListener = Provider.of<DatabaseProvider>(context);
  late final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);

  final commentCont = TextEditingController();
  void _onDelTap() async {
    dbProvider.deleteUserPost(widget.post.id);
    Navigator.pop(context);
  }

  void _onMoreTap(context) {
    final bool hasDelAcess = widget.post.uid == AuthService().getCurrentUID();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasDelAcess)
                ListTile(
                  onTap: _onDelTap,
                  leading: Icon(Icons.delete),
                  title: Text('Delete'),
                )
              else ...[
                ListTile(
                  onTap: _reportOrBlockNotice,
                  leading: Icon(Icons.flag),
                  title: Text('Report'),
                ),
                ListTile(
                  onTap: _reportOrBlockNotice,
                  leading: Icon(Icons.block),
                  title: Text('Block user'),
                ),
              ],
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                },
                leading: Icon(Icons.cancel),
                title: Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onLikeTap() async {
    await dbProvider.toggleLikes(widget.post.id);
  }

  void _onCommentTap() {
    showDialog(
      context: context,
      builder: (context) => MyDialog(
        hint: 'Add a comment',
        controller: commentCont,
        yesText: 'Post',
        onYes: _onPostTap,
      ),
    );
  }

  void _onPostTap() async {
    if (commentCont.text.trim().isEmpty) {
      return;
    }
    try {
      dbProvider.addNewComment(widget.post.id, commentCont.text.trim());
    } catch (e) {
      print(e);
    }
  }

  void _reportOrBlockNotice() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Feature under development'),
        content: const Text(
          'Report post and block user feature is still under development.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Okay'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _initialiseComments();
  }

  void _initialiseComments() async {
    await dbProvider.loadCommetsFromDB(widget.post.id);
  }

  @override
  Widget build(BuildContext context) {
    final thData = Theme.of(context).colorScheme;
    bool isLiked = dbListener.isLikedByUser(widget.post.id);
    int likeCount = dbListener.likeCountOnPost(widget.post.id);
    int commentCount = dbListener.getCommentList(widget.post.id).length;

    return GestureDetector(
      onTap: widget.onPostTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6),
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: thData.secondary,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: widget.onUserTap,
              child: Row(
                children: [
                  Icon(Icons.person, color: thData.primary),
                  SizedBox(width: 5),
                  Text(
                    widget.post.name,
                    style: TextStyle(color: thData.primary),
                  ),
                  SizedBox(width: 5),
                  Text(
                    '@${widget.post.username}',
                    style: TextStyle(color: thData.primary),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      _onMoreTap(context);
                    },
                    child: Icon(Icons.more_horiz, color: thData.primary),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text(widget.post.message),
            SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 55,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _onLikeTap,
                        child: isLiked
                            ? Icon(Icons.favorite, color: Colors.red)
                            : Icon(
                                Icons.favorite_border,
                                color: thData.primary,
                              ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        likeCount != 0 ? '$likeCount' : '',
                        style: TextStyle(color: thData.primary),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 55,
                  child: GestureDetector(
                    onTap: _onCommentTap,
                    child: Row(
                      children: [
                        Icon(Icons.comment, color: thData.primary),
                        SizedBox(width: 5),
                        Text(
                          commentCount != 0 ? commentCount.toString() : '',
                          style: TextStyle(color: thData.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
