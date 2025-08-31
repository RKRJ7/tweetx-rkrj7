import 'package:flutter/material.dart';
import 'package:rkrj7_tweetx/components/my_drawer_tile.dart';
import 'package:rkrj7_tweetx/pages/profile_page.dart';
import 'package:rkrj7_tweetx/pages/search_page.dart';
import 'package:rkrj7_tweetx/pages/settings_page.dart';
import 'package:rkrj7_tweetx/services/auth/auth_service.dart';

class MyDrawer extends StatelessWidget {
  MyDrawer({super.key});

  final _auth = AuthService();

  void logout() async {
    await _auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    final thcolor = Theme.of(context).colorScheme;
    return Drawer(
      backgroundColor: thcolor.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(50),
                child: Icon(Icons.person, size: 70, color: thcolor.primary),
              ),
              Divider(color: thcolor.secondary),
              const SizedBox(height: 10),
              MyDrawerTile(
                label: 'H O M E',
                icon: Icons.home,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              MyDrawerTile(
                label: 'P R O F I L E',
                icon: Icons.person,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProfilePage(uid: _auth.getCurrentUID()),
                    ),
                  );
                },
              ),
              MyDrawerTile(
                label: 'S E A R C H',
                icon: Icons.search,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchPage()),
                  );
                },
              ),
              MyDrawerTile(
                label: 'S E T T I N G S',
                icon: Icons.settings,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                },
              ),
              const Spacer(),
              MyDrawerTile(
                label: 'L O G O U T',
                icon: Icons.logout,
                onTap: logout,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
