import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rkrj7_tweetx/components/my_profile_tile.dart';
import 'package:rkrj7_tweetx/services/database/database_provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final searchcont = TextEditingController();
  late final _dbProvider = Provider.of<DatabaseProvider>(
    context,
    listen: false,
  );
  late final _dbListener = Provider.of<DatabaseProvider>(context);

  @override
  void dispose() {
    super.dispose();
    searchcont.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: TextField(
          controller: searchcont,
          decoration: InputDecoration(
            hintText: "Search users..",
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
            border: InputBorder.none,
          ),

          onChanged: (value) {
            if (value.isNotEmpty) {
              _dbProvider.searchUsers(value);
            } else {
              _dbProvider.searchUsers("");
            }
          },
        ),
      ),
      body: ListView.builder(
        itemCount: _dbListener.searchResult.length,
        itemBuilder: (context, index) {
          final user = _dbListener.searchResult[index];
          return MyProfileTile(user: user);
        },
      ),
    );
  }
}
