import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rkrj7_tweetx/models/comment.dart';
import 'package:rkrj7_tweetx/services/auth/auth_service.dart';
import 'package:rkrj7_tweetx/services/database/database_provider.dart';

class MyCommentTile extends StatefulWidget {
  final Comment comment;
  final void Function()? onUserTap;
  const MyCommentTile({super.key, required this.comment, this.onUserTap});

  @override
  State<MyCommentTile> createState() => _MyCommentTileState();
}

class _MyCommentTileState extends State<MyCommentTile> {
  late final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);

  void _onDelTap() async {
    try {
      await dbProvider.deleteComment(widget.comment.id, widget.comment.postId);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasDelAcess = widget.comment.uid == AuthService().getCurrentUID();

    final thData = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: thData.tertiary,
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
                  widget.comment.name,
                  style: TextStyle(color: thData.primary),
                ),
                SizedBox(width: 5),
                Text(
                  '@${widget.comment.username}',
                  style: TextStyle(color: thData.primary),
                ),
                Spacer(),
                if (hasDelAcess)
                  GestureDetector(
                    onTap: _onDelTap,
                    child: Icon(Icons.delete, color: thData.primary, size: 20),
                  ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Text(widget.comment.message),
        ],
      ),
    );
  }
}
