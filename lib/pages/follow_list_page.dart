import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rkrj7_tweetx/components/my_profile_tile.dart';
import 'package:rkrj7_tweetx/models/user.dart';
import 'package:rkrj7_tweetx/services/database/database_provider.dart';

class FollowListPage extends StatefulWidget {
  final String uid;
  const FollowListPage({super.key, required this.uid});

  @override
  State<FollowListPage> createState() => _FollowListPageState();
}

class _FollowListPageState extends State<FollowListPage> {
  late final _dbListener = Provider.of<DatabaseProvider>(context);
  late final _dbProvider = Provider.of<DatabaseProvider>(
    context,
    listen: false,
  );

  Widget _buildFollowList(List<UserProfile> userList, String emptyMessage) {
    if (userList.isEmpty) {
      return Center(child: Text(emptyMessage));
    }
    return ListView.builder(
      itemCount: userList.length,
      itemBuilder: (context, index) {
        final user = userList[index];
        return MyProfileTile(user: user);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    loadProfiles();
  }

  Future<void> loadProfiles() async {
    await _dbProvider.loadFollowersProfiles(widget.uid);
    await _dbProvider.loadFollowingProfiles(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    final followers = _dbListener.getFollowerProfiles(widget.uid);
    final following = _dbListener.getFollowingProfiles(widget.uid);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          bottom: TabBar(
            dividerColor: Colors.transparent,
            indicatorColor: Theme.of(context).colorScheme.tertiary,
            unselectedLabelColor: Theme.of(context).colorScheme.primary,
            labelColor: Theme.of(context).colorScheme.inversePrimary,
            tabs: [
              Tab(text: 'Followers'),
              Tab(text: 'Following'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFollowList(followers, 'Nothing here / Loading...'),
            _buildFollowList(following, 'Nothing here / Loading...'),
          ],
        ),
      ),
    );
  }
}
