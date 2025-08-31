import 'package:flutter/widgets.dart';
import 'package:rkrj7_tweetx/models/comment.dart';
import 'package:rkrj7_tweetx/models/post.dart';
import 'package:rkrj7_tweetx/models/user.dart';
import 'package:rkrj7_tweetx/services/auth/auth_service.dart';
import 'package:rkrj7_tweetx/services/database/database_service.dart';

class DatabaseProvider extends ChangeNotifier {
  final _db = DatabaseService();
  final _auth = AuthService();

  Future<UserProfile?> userProfile(String uid) =>
      _db.getUserFromFirebase(uid: uid);

  Future<void> updateBio(String bioText) {
    return _db.updateUserBio(bioText: bioText);
  }

  /*
  POSTS
  */

  //local list
  List<Post> _allPosts = [];
  List<Post> _followingPosts = [];

  //post getter
  List<Post> get allPosts => _allPosts;
  List<Post> get followingPost => _followingPosts;

  //post a message
  Future<void> postMessage(String message) async {
    await _db.postMessageToFirebase(message);
    await loadAllPost();
  }

  //fetch all posts
  Future<void> loadAllPost() async {
    final allPosts = await _db.getAllPostsFromFirebase();

    _allPosts = allPosts;

    loadFollowingPosts();

    initialiseLocalLikes();

    notifyListeners();
  }

  //filter User Posts
  List<Post> filterUserPosts(String uid) {
    return _allPosts.where((element) => element.uid == uid).toList();
  }

  //delete a post
  Future<void> deleteUserPost(String postId) async {
    await _db.deletePostFromFirebase(postId);
    await loadAllPost();
  }

  Future<void> loadFollowingPosts() async {
    String currentUid = _auth.getCurrentUID();

    final followingUids = await _db.getFollowingList(currentUid);

    _followingPosts = _allPosts
        .where((element) => followingUids.contains(element.uid))
        .toList();

    notifyListeners();
  }

  //LIKES

  //local like count map
  Map<String, int> _likeCounts = {};

  //list of posts liked by user
  List<String> _likedPosts = [];

  //ui like getters
  bool isLikedByUser(String postId) => _likedPosts.contains(postId);
  int likeCountOnPost(String postId) => _likeCounts[postId] ?? 0;

  // initalise likes
  void initialiseLocalLikes() {
    final uid = _auth.getCurrentUID();
    _likedPosts.clear();
    for (var post in _allPosts) {
      _likeCounts[post.id] = post.likeCount;
      if (post.likedBy.contains(uid)) {
        _likedPosts.add(post.id);
      }
    }
  }

  Future<void> toggleLikes(String postId) async {
    final likedPostsOriginal = _likedPosts;
    final likeCountsOriginal = _likeCounts;

    if (_likedPosts.contains(postId)) {
      _likedPosts.remove(postId);
      _likeCounts[postId] = (_likeCounts[postId] ?? 0) - 1;
    } else {
      _likedPosts.add(postId);
      _likeCounts[postId] = (_likeCounts[postId] ?? 0) + 1;
    }

    notifyListeners();

    //databasework
    try {
      _db.toggleLikeInFirebase(postId);
    } catch (e) {
      _likeCounts = likeCountsOriginal;
      _likedPosts = likedPostsOriginal;
      notifyListeners();
    }
  }

  //COMMENTS

  //local comment list
  final Map<String, List<Comment>> _comments = {};

  //comment getter of a post
  List<Comment> getCommentList(String postId) {
    return _comments[postId] ?? [];
  }

  //fetch comments of a post from database
  Future<void> loadCommetsFromDB(String postId) async {
    final allComments = await _db.fetchCommentsFromFirebase(postId);
    _comments[postId] = allComments;
    notifyListeners();
  }

  //add a comment
  Future<void> addNewComment(String postId, String message) async {
    await _db.addCommentInFirebase(postId, message);
    await loadCommetsFromDB(postId);
  }

  //delete a comment
  Future<void> deleteComment(String commentId, String postId) async {
    await _db.deleteCommentInFirebase(commentId);
    await loadCommetsFromDB(postId);
  }

  //FOLLOWERS

  //local maps
  final Map<String, List<String>> _followersMap = {};
  final Map<String, List<String>> _followingMap = {};
  final Map<String, int> _followersCount = {};
  final Map<String, int> _followingCount = {};

  //get followers count
  int getFollowersCount(String uid) {
    return _followersCount[uid] ?? 0;
  }

  //get following count
  int getFollowingCount(String uid) {
    return _followingCount[uid] ?? 0;
  }

  //load followers
  Future<void> loadFollowers(String uid) async {
    final followers = await _db.getFollowersList(uid);
    _followersMap[uid] = followers;
    _followersCount[uid] = followers.length;
    notifyListeners();
  }

  //load following
  Future<void> loadFollowing(String uid) async {
    final following = await _db.getFollowingList(uid);
    _followingMap[uid] = following;
    _followingCount[uid] = following.length;
    notifyListeners();
  }

  //follow a user
  Future<void> followUser(String targetUID) async {
    final currentUID = _auth.getCurrentUID();

    //initialize if null
    _followersMap.putIfAbsent(targetUID, () => []);
    _followingMap.putIfAbsent(currentUID, () => []);

    //local updation
    if (!_followersMap[targetUID]!.contains(currentUID)) {
      _followersMap[targetUID]?.add(currentUID);
      _followersCount[targetUID] = (_followersCount[targetUID] ?? 0) + 1;

      _followingMap[currentUID]?.add(targetUID);
      _followersCount[currentUID] = (_followingCount[currentUID] ?? 0) + 1;
    }

    notifyListeners();

    //database updation
    try {
      await _db.followInFirebase(targetUID);
      await loadFollowers(targetUID);
      await loadFollowing(currentUID);
    } catch (e) {
      _followersMap[targetUID]?.remove(currentUID);
      _followersCount[targetUID] = (_followersCount[targetUID] ?? 0) - 1;

      _followingMap[currentUID]?.remove(targetUID);
      _followingCount[currentUID] = (_followingCount[currentUID] ?? 0) - 1;

      notifyListeners();
    }
  }

  //unfollow a user
  Future<void> unfollowUser(String targetUID) async {
    final currentUID = _auth.getCurrentUID();

    //initialize if null
    _followersMap.putIfAbsent(targetUID, () => []);
    _followingMap.putIfAbsent(currentUID, () => []);

    //local updation
    if (_followersMap[targetUID]!.contains(currentUID)) {
      _followersMap[targetUID]?.remove(currentUID);
      _followersCount[targetUID] = (_followersCount[targetUID] ?? 1) - 1;

      _followingMap[currentUID]?.remove(targetUID);
      _followingCount[currentUID] = (_followingCount[currentUID] ?? 1) - 1;
    }

    notifyListeners();

    //database updation
    try {
      await _db.unfollowInFirebase(targetUID);
      await loadFollowers(targetUID);
      await loadFollowing(currentUID);
    } catch (e) {
      _followersMap[targetUID]?.add(currentUID);
      _followersCount[targetUID] = (_followersCount[targetUID] ?? 0) + 1;

      _followingMap[currentUID]?.add(targetUID);
      _followersCount[currentUID] = (_followingCount[currentUID] ?? 0) + 1;

      notifyListeners();
    }
  }

  //check if current user follows target user
  bool isFollowing(String targetUID) {
    final currentUID = _auth.getCurrentUID();

    return _followersMap[targetUID]?.contains(currentUID) ?? false;
  }

  //followers and following user profile list

  final Map<String, List<UserProfile>> _followersUserProfiles = {};
  final Map<String, List<UserProfile>> _followingUserProfiles = {};

  //getters
  List<UserProfile> getFollowerProfiles(String uid) =>
      _followersUserProfiles[uid] ?? [];

  List<UserProfile> getFollowingProfiles(String uid) =>
      _followingUserProfiles[uid] ?? [];

  //load the profiles of follow

  Future<void> loadFollowersProfiles(String uid) async {
    try {
      final followIds = await _db.getFollowersList(uid);

      List<UserProfile> followList = [];

      for (var followId in followIds) {
        UserProfile? profile = await _db.getUserFromFirebase(uid: followId);

        if (profile != null) {
          followList.add(profile);
        }
      }

      _followersUserProfiles[uid] = followList;

      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> loadFollowingProfiles(String uid) async {
    try {
      final followingIds = await _db.getFollowingList(uid);

      List<UserProfile> followingList = [];

      for (var followId in followingIds) {
        UserProfile? profile = await _db.getUserFromFirebase(uid: followId);

        if (profile != null) {
          followingList.add(profile);
        }
      }

      _followingUserProfiles[uid] = followingList;

      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  //SEARCH USERS

  List<UserProfile> _searchResults = [];

  List<UserProfile> get searchResult => _searchResults;

  Future<void> searchUsers(String term) async {
    try {
      final results = await _db.searchUsersInFirebase(term);

      _searchResults = results;

      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
}
