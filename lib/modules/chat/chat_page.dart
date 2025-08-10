import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rablo_chat/services/auth_services.dart';
import 'package:rablo_chat/services/chat_service.dart';
import 'package:rablo_chat/widgets/custom_text_field.dart';
import 'package:rablo_chat/widgets/message_container.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;

  final String receiverID;

  const ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverID,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // text controller
  final TextEditingController _messageController = TextEditingController();

  // chat & auth services
  final ChatService _chatService = ChatService();
  final AuthServices _authService = AuthServices();

  // send message
  void sendMessage() async {
    // if there is something inside the textfield
    if (_messageController.text.isNotEmpty) {
      // send the message
      await _chatService.sendMessage(
        widget.receiverID,
        _messageController.text,
      );
      _messageController.clear();
    }
  }

  bool isSelectionMode = false;
  Set<String> selectedMessages = {};

  // Enter selection mode
  void enterSelectionMode(String messageId) {
    setState(() {
      isSelectionMode = true;
      selectedMessages.add(messageId);
    });
  }

  // Exit selection mode
  void exitSelectionMode() {
    setState(() {
      isSelectionMode = false;
      selectedMessages.clear();
    });
  }

  // Toggle message selection
  void toggleMessageSelection(String messageId) {
    setState(() {
      if (selectedMessages.contains(messageId)) {
        selectedMessages.remove(messageId);
        if (selectedMessages.isEmpty) {
          isSelectionMode = false;
        }
      } else {
        selectedMessages.add(messageId);
      }
    });
  }

  // Delete selected messages
  void deleteSelectedMessages() async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Messages'),
            content: Text(
              'Are you sure you want to delete ${selectedMessages.length} message(s)?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  exitSelectionMode();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);

                  // Delete all selected messages
                  for (String messageId in selectedMessages) {
                    try {
                      await _chatService.deleteMessage(
                        _authService.currentUser()!.uid,
                        widget.receiverID,
                        messageId,
                      );
                    } catch (e) {
                      print('Error deleting message $messageId: $e');
                    }
                  }

                  exitSelectionMode();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Messages deleted successfully')),
                  );
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  // Edit selected message (only works when exactly one message is selected)
  void editSelectedMessage() async {
    if (selectedMessages.length != 1) return;

    String messageId = selectedMessages.first;

    // Find the current message text
    String currentMessage = await _getCurrentMessageText(messageId);

    TextEditingController editController = TextEditingController(
      text: currentMessage,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit Message'),
            content: TextField(
              controller: editController,
              decoration: InputDecoration(
                hintText: 'Enter new message',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  exitSelectionMode();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (editController.text.trim().isNotEmpty) {
                    Navigator.pop(context);

                    try {
                      await _chatService.updateMessage(
                        _authService.currentUser()!.uid,
                        widget.receiverID,
                        messageId,
                        editController.text.trim(),
                      );

                      exitSelectionMode();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Message updated successfully')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update message')),
                      );
                    }
                  }
                },
                child: Text('Save', style: TextStyle(color: Colors.green)),
              ),
            ],
          ),
    );
  }

  // Helper method to get current message text
  Future<String> _getCurrentMessageText(String messageId) async {
    try {
      List<String> ids = [_authService.currentUser()!.uid, widget.receiverID];
      ids.sort();
      String chatRoomID = ids.join('_');

      DocumentSnapshot doc =
          await _chatService.firestoreDatabase
              .collection("chat_rooms")
              .doc(chatRoomID)
              .collection("messages")
              .doc(messageId)
              .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['message'] ?? '';
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            isSelectionMode
                ? Text('${selectedMessages.length} selected')
                : Text(widget.receiverEmail),

        leading:
            isSelectionMode
                ? IconButton(
                  icon: Icon(Icons.close),
                  onPressed: exitSelectionMode,
                )
                : null,
        actions:
            isSelectionMode
                ? [
                  // Show edit button only when exactly one message is selected
                  if (selectedMessages.length == 1)
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: editSelectedMessage,
                    ),
                  // Always show delete button when in selection mode
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed:
                        selectedMessages.isNotEmpty
                            ? deleteSelectedMessages
                            : null,
                  ),
                ]
                : [],
      ),
      body: Column(
        children: [
          // display all messages
          Expanded(child: _buildMessageList()),

          // user input (hide in selection mode)
          if (!isSelectionMode) _buildUserInput(),
          if (!isSelectionMode) SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderID = _authService.currentUser()!.uid;

    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverID, senderID),
      builder: (context, snapshot) {
        // errors
        if (snapshot.hasError) {
          return const Text("Error");
        }

        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading..");
        }

        // return list view
        return ListView(
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  // build message item
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    String messageId = doc.id;

    // is current user
    bool isCurrentUser = data['senderID'] == _authService.currentUser()!.uid;

    // align message to the right if sender is the current user, otherwise left
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    bool isSelected = selectedMessages.contains(messageId);

    return GestureDetector(
      onLongPress:
          isCurrentUser && !isSelectionMode
              ? () => enterSelectionMode(messageId)
              : null,
      onTap:
          isSelectionMode && isCurrentUser
              ? () => toggleMessageSelection(messageId)
              : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        alignment: alignment,
        child: Stack(
          children: [
            Container(
              decoration:
                  isSelected
                      ? BoxDecoration(
                        color: const Color.fromARGB(93, 33, 149, 243),
                        borderRadius: BorderRadius.circular(20),
                      )
                      : null,
              child: MessageContainer(
                message: data['message'],
                isCurrentUser: isCurrentUser,
              ),
            ),
            if (isSelected)
              Positioned(
                right: isCurrentUser ? 5 : null,
                left: !isCurrentUser ? 5 : null,
                top: 5,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ),
          ],
        ),
      ),
    ); // Container
  }

  // build message input
  Widget _buildUserInput() {
    return Row(
      children: [
        // textfield should take up most of the space
        Expanded(
          child: CustomTextField(
            controller: _messageController,
            hintText: "Type a message",
            obscureText: false,
          ),
        ),
        // send button
        IconButton(onPressed: sendMessage, icon: Icon(Icons.arrow_upward)),
      ],
    );
  }
}

class AuthService {}
