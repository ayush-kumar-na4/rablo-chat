import 'package:flutter/material.dart';
import 'package:rablo_chat/main.dart';
import 'package:rablo_chat/modules/chat/chat_page.dart';
import 'package:rablo_chat/services/auth_services.dart';
import 'package:rablo_chat/services/chat_service.dart';
import 'package:rablo_chat/widgets/user_tile.dart';
import 'package:rablo_chat/widgets/custom_drawer.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  void logOut(BuildContext context) async {
    final _auth = AuthServices();

    await _auth.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const EntryPoint()),
      (route) => false,
    );
  }

  final _chatService = ChatService();
  final _authservice = AuthServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("Chats")),
      drawer: CustomDrawer(),
      body: _usersList(),
    );
  }

  Widget _usersList() {
    return StreamBuilder(
      stream: _chatService.registeredUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading ...");
        }

        return ListView(
          children:
              snapshot.data!
                  .map<Widget>((userData) => _userListItem(userData, context))
                  .toList(),
        );
      },
    );
  }

  Widget _userListItem(Map<String, dynamic> userData, BuildContext context) {
    // display all users except current user
    if (userData["email"] != _authservice.currentUser()!.email) {
      return UserTile(
        text: userData["name"],
        onTap: () {
          // tapped on a user -> go to chat page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ChatPage(
                    receiverEmail: userData["name"],
                    receiverID: userData["uid"],
                  ),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }
}
