import 'package:flutter/material.dart';

class MessageContainer extends StatelessWidget {
  final String message;
  final bool isCurrentUser;

  const MessageContainer({
    super.key,
    required this.message,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),

      decoration: BoxDecoration(
        borderRadius:
            isCurrentUser
                ? BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                )
                : BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
        color:
            isCurrentUser
                ? Colors.purple[50]
                : Colors.blue[50], // You can change this dynamically too
      ),
      child: Text(message, style: TextStyle(fontSize: 20)),
    );
  }
}
