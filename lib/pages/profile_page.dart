import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rkrj7_tweetx/components/my_bio_box.dart';
import 'package:rkrj7_tweetx/components/my_dialog.dart';
import 'package:rkrj7_tweetx/components/my_follow_button.dart';
import 'package:rkrj7_tweetx/components/my_post_tile.dart';
import 'package:rkrj7_tweetx/components/my_profile_stats.dart';
import 'package:rkrj7_tweetx/helper/navigate_pages.dart';
import 'package:rkrj7_tweetx/models/user.dart';
import 'package:rkrj7_tweetx/pages/follow_list_page.dart';
import 'package:rkrj7_tweetx/services/auth/auth_service.dart';
import 'package:rkrj7_tweetx/services/database/database_provider.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final dbListener = Provider.of<DatabaseProvider>(context);
  late final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
  bool isLoading = true;
  bool isFollowing = false;

  UserProfile? user;

  //bio controller
  TextEditingController biocont = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  loadUser() async {
    user = await dbProvider.userProfile(widget.uid);
    await dbProvider.loadFollowers(widget.uid);
    await dbProvider.loadFollowing(widget.uid);
    isFollowing = dbProvider.isFollowing(widget.uid);

    setState(() {
      isLoading = false;
    });
  }

  void _toggleFollow() async {
    if (isFollowing) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Unfollow'),
            content: Text('Are you sure want to unfollow?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),

              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await dbProvider.unfollowUser(widget.uid);
                },
                child: Text('Yes'),
              ),
            ],
          );
        },
      );
    } else {
      await dbProvider.followUser(widget.uid);
    }
  }

  void _openEditBioBox() {
    showDialog(
      context: context,
      builder: (context) => MyDialog(
        hint: 'Edit bio ...',
        controller: biocont,
        yesText: 'Save',
        onYes: () async {
          try {
            setState(() {
              isLoading = true;
            });
            await dbProvider.updateBio(biocont.text);
            await loadUser();
          } catch (e) {
            print(e);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userPosts = dbListener.filterUserPosts(widget.uid);
    final followersCount = dbListener.getFollowersCount(widget.uid);
    final followingCount = dbListener.getFollowingCount(widget.uid);
    isFollowing = dbListener.isFollowing(widget.uid);
    final thdata = Theme.of(context).colorScheme;
    final currentUserID = AuthService().getCurrentUID();

    return Scaffold(
      appBar: AppBar(
        title: Text(isLoading ? '' : user!.name),
        foregroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          onPressed: () => goHomePage(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            //username
            Center(
              child: Text(
                isLoading ? '@loading..' : '@${user!.username}',
                style: TextStyle(color: thdata.primary),
              ),
            ),
            const SizedBox(height: 15),

            //profile photo
            Center(
              child: Container(
                padding: EdgeInsets.all(21),
                decoration: BoxDecoration(
                  color: thdata.secondary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.person, color: thdata.primary, size: 70),
              ),
            ),

            //stats
            SizedBox(height: 20),
            MyProfileStats(
              postCount: userPosts.length,
              followersCount: followersCount,
              followingCount: followingCount,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FollowListPage(uid: widget.uid),
                  ),
                );
              },
            ),
            //follow button
            SizedBox(height: 20),

            if (user != null && user!.uid != currentUserID)
              MyFollowButton(
                onPressed: _toggleFollow,
                isFollowing: isFollowing,
              ),

            SizedBox(height: 20),
            //bio
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Bio', style: TextStyle(color: thdata.primary)),
                if (user != null && user!.uid == currentUserID)
                  GestureDetector(
                    onTap: _openEditBioBox,
                    child: Icon(Icons.settings, color: thdata.primary),
                  ),
              ],
            ),
            SizedBox(height: 10),
            MyBioBox(text: isLoading ? '...' : user!.bio),
            SizedBox(height: 10),
            Text('Posts', style: TextStyle(color: thdata.primary)),
            userPosts.isEmpty
                ? Center(child: Text('No Posts'))
                : ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: userPosts.length,
                    itemBuilder: (context, index) {
                      return MyPostTile(
                        post: userPosts[index],
                        onPostTap: () {
                          goPostPage(context, userPosts[index]);
                        },
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
