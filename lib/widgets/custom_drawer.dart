import 'package:flutter/material.dart';
import 'package:rablo_chat/main.dart';
import 'package:rablo_chat/services/auth_services.dart';

class CustomDrawer extends StatelessWidget {
  final AuthServices _authService = AuthServices();

  CustomDrawer({super.key});

  void logOut(BuildContext context) async {
    await _authService.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const EntryPoint()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          FutureBuilder<Map<String, dynamic>?>(
            future: _authService.getCurrentUserProfile(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return UserAccountsDrawerHeader(
                  accountName: Text('Loading...'),
                  accountEmail: Text(''),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 40,
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final userData = snapshot.data;
              final currentUser = _authService.currentUser();
              return UserAccountsDrawerHeader(
                accountName: Text(
                  userData?['name'] ?? currentUser?.displayName ?? 'User',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                accountEmail: Text(
                  userData?['email'] ?? currentUser?.email ?? 'No email',
                  style: TextStyle(fontSize: 14),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 40,
                  child: Icon(Icons.person, size: 50),
                ),
              );
            },
          ),

          FutureBuilder<Map<String, dynamic>?>(
            future: _authService.getCurrentUserProfile(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                final userData = snapshot.data!;
                return Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (userData['mobile'] != null)
                        ListTile(
                          title: Text('Mobile'),
                          subtitle: Text(userData['mobile']),
                          dense: true,
                        ),
                      if (userData['uid'] != null)
                        ListTile(
                          title: Text('User ID'),
                          subtitle: Text(
                            userData['uid'].toString(),
                            style: TextStyle(fontSize: 12),
                          ),
                          dense: true,
                        ),
                    ],
                  ),
                );
              }
              return SizedBox.shrink();
            },
          ),

          Divider(),

          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              logOut(context);
            },
          ),
        ],
      ),
    );
  }
}
