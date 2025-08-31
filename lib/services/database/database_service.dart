import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rkrj7_tweetx/models/comment.dart';
import 'package:rkrj7_tweetx/models/post.dart';
import 'package:rkrj7_tweetx/models/user.dart';
import 'package:rkrj7_tweetx/services/auth/auth_service.dart';

class DatabaseService {
  //get instace
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  //store data when new user registers
  Future<void> saveUserInfoInFirebase({
    required String name,
    required String email,
  }) async {
    String uid = _auth.currentUser!.uid;

    UserProfile user = UserProfile(
      uid: uid,
      name: name,
      email: email,
      username: email.split('@')[0],
      bio: '',
    );

    final userMap = user.toMap();

    await _db.collection('Users').doc(uid).set(userMap);
  }

  //get user info from firebase
  Future<UserProfile?> getUserFromFirebase({required String uid}) async {
    try {
      DocumentSnapshot doc = await _db.collection('Users').doc(uid).get();
      return UserProfile.fromDocument(doc);
    } catch (e) {
      print(e);
      return null;
    }
  }

  //update bio
  Future<void> updateUserBio({required String bioText}) async {
    final uid = AuthService().getCurrentUID();

    try {
      await _db.collection('Users').doc(uid).update({"bio": bioText});
    } catch (e) {
      print(e);
    }
  }

  /*
    POSTS
  */

  //post message
  Future<void> postMessageToFirebase(String message) async {
    String uid = AuthService().getCurrentUID();
    UserProfile? user = await getUserFromFirebase(uid: uid);

    Post newPost = Post(
      id: '',
      uid: uid,
      name: user!.name,
      username: user.username,
      message: message,
      timestamp: Timestamp.now(),
      likeCount: 0,
      likedBy: [],
    );

    Map<String, dynamic> newPostMap = newPost.toMap();

    await _db.collection('Posts').add(newPostMap);
  }

  //retrieve posts
  Future<List<Post>> getAllPostsFromFirebase() async {
    try {
      final snapshot = await _db
          .collection('Posts')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  //delete post
  Future<void> deletePostFromFirebase(String postId) async {
    try {
      await _db.collection('Posts').doc(postId).delete();
    } catch (e) {
      print(e);
    }
  }

  //like a post
  Future<void> toggleLikeInFirebase(String postId) async {
    final docRef = _db.collection('Posts').doc(postId);

    final uid = _auth.currentUser!.uid;

    await _db.runTransaction((transaction) async {
      final docSnap = await transaction.get(docRef);

      final likedBy = List<String>.from(docSnap['likedBy'] ?? []);
      int likeCount = docSnap['likeCount'];

      if (!likedBy.contains(uid)) {
        likedBy.add(uid);
        likeCount++;
      } else {
        likedBy.remove(uid);
        likeCount--;
      }

      transaction.update(docRef, {'likedBy': likedBy, 'likeCount': likeCount});
    });
  }

  /*
  COMMENTS
  */

  //add a comment
  Future<void> addCommentInFirebase(String postId, String message) async {
    try {
      final uid = _auth.currentUser!.uid;
      final user = await getUserFromFirebase(uid: uid);

      final newComment = Comment(
        id: '',
        uid: uid,
        postId: postId,
        name: user!.name,
        username: user.username,
        message: message,
        timestamp: Timestamp.now(),
      );

      final newCommentMap = newComment.toMap();

      await _db.collection('Comments').add(newCommentMap);
    } catch (e) {
      print(e);
    }
  }

  //delete a comment
  Future<void> deleteCommentInFirebase(String commentId) async {
    try {
      await _db.collection('Comments').doc(commentId).delete();
    } catch (e) {
      print(e);
    }
  }

  //fetch comments of a post
  Future<List<Comment>> fetchCommentsFromFirebase(String postId) async {
    try {
      final commSnap = await _db
          .collection('Comments')
          .where('postId', isEqualTo: postId)
          .get();

      return commSnap.docs.map((doc) {
        return Comment.fromDocument(doc);
      }).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  /*
    FOLLOWERS
  */

  //follow a person
  Future<void> followInFirebase(String targetUID) async {
    final currentUID = _auth.currentUser!.uid;
    final batch = _db.batch();

    //add target to current's following list

    final followingRef = _db
        .collection('Users')
        .doc(currentUID)
        .collection('Following')
        .doc(targetUID);

    batch.set(followingRef, <String, dynamic>{});

    //add current to target's followers list

    final followerRef = _db
        .collection('Users')
        .doc(targetUID)
        .collection('Followers')
        .doc(currentUID);

    batch.set(followerRef, <String, dynamic>{});

    //commit the batch
    await batch.commit();
  }

  //unfollow a person
  Future<void> unfollowInFirebase(String targetUID) async {
    final currentUID = _auth.currentUser!.uid;
    final batch = _db.batch();

    //remove target from current's following list

    final followingRef = _db
        .collection('Users')
        .doc(currentUID)
        .collection('Following')
        .doc(targetUID);

    batch.delete(followingRef);

    //remove current from target's followers list

    final followerRef = _db
        .collection('Users')
        .doc(targetUID)
        .collection('Followers')
        .doc(currentUID);

    batch.delete(followerRef);

    //commit the batch
    await batch.commit();
  }

  //get list of followers
  Future<List<String>> getFollowersList(String uid) async {
    final snap = await _db
        .collection('Users')
        .doc(uid)
        .collection('Followers')
        .get();

    return snap.docs.map((e) => e.id).toList();
  }

  //get list of following
  Future<List<String>> getFollowingList(String uid) async {
    final snap = await _db
        .collection('Users')
        .doc(uid)
        .collection('Following')
        .get();

    return snap.docs.map((e) => e.id).toList();
  }

  //SEARCH

  Future<List<UserProfile>> searchUsersInFirebase(String term) async {
    try {
      final snap = await _db
          .collection('Users')
          .where('username', isGreaterThanOrEqualTo: term)
          .where('username', isLessThanOrEqualTo: '$term\uf8ff')
          .get();

      return snap.docs.map((doc) => UserProfile.fromDocument(doc)).toList();
    } catch (e) {
      return [];
    }
  }
}
