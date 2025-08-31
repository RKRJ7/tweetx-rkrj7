import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String uid;
  final String postId;
  final String name;
  final String username;
  final String message;
  final Timestamp timestamp;

  const Comment({
    required this.id,
    required this.uid,
    required this.postId,
    required this.name,
    required this.username,
    required this.message,
    required this.timestamp,
  });

  //firebase to comment
  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      id: doc.id,
      uid: doc['uid'],
      postId: doc['postId'],
      name: doc['name'],
      username: doc['username'],
      message: doc['message'],
      timestamp: doc['timestamp'],
    );
  }

  //comment to firebase
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'postId': postId,
      'name': name,
      'username': username,
      'message': message,
      'timestamp': timestamp,
    };
  }
}
