import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rkrj7_tweetx/components/my_dialog.dart';
import 'package:rkrj7_tweetx/components/my_drawer.dart';
import 'package:rkrj7_tweetx/components/my_post_tile.dart';
import 'package:rkrj7_tweetx/helper/navigate_pages.dart';
import 'package:rkrj7_tweetx/models/post.dart';
import 'package:rkrj7_tweetx/services/database/database_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final dbListener = Provider.of<DatabaseProvider>(context);
  late final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
  TextEditingController postcont = TextEditingController();

  void _showPostDialog() {
    showDialog(
      context: context,
      builder: (context) => MyDialog(
        hint: 'What\'s on your mind?',
        controller: postcont,
        yesText: 'Post',
        onYes: () async {
          await dbProvider.postMessage(postcont.text);
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadPosts();
  }

  void loadPosts() async {
    await dbProvider.loadAllPost();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('H O M E'),
          foregroundColor: Theme.of(context).colorScheme.primary,
          bottom: TabBar(
            dividerColor: Colors.transparent,
            indicatorColor: Theme.of(context).colorScheme.tertiary,
            unselectedLabelColor: Theme.of(context).colorScheme.primary,
            labelColor: Theme.of(context).colorScheme.inversePrimary,
            tabs: const [
              Tab(text: 'For You'),
              Tab(text: 'Following'),
            ],
          ),
        ),
        drawer: MyDrawer(),
        floatingActionButton: FloatingActionButton(
          onPressed: _showPostDialog,
          child: Icon(Icons.add),
        ),
        body: TabBarView(
          children: [
            _buildPostList(dbListener.allPosts),
            _buildPostList(dbListener.followingPost),
          ],
        ),
      ),
    );
  }

  Widget _buildPostList(List<Post> posts) {
    return posts.isEmpty
        ? const Center(child: Text('Nothing here ..'))
        : ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: MyPostTile(
                  post: post,
                  onUserTap: () {
                    goUserPage(context, post.uid);
                  },
                  onPostTap: () {
                    goPostPage(context, post);
                  },
                ),
              );
            },
          );
  }
}
