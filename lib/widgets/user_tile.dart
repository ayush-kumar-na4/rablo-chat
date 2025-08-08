import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String text;
  final void Function()? onTap;

  const UserTile({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.purple[100],
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 20),
        padding: EdgeInsets.all(18),
        child: Row(
          children: [
            // icon
            Icon(Icons.person),

            SizedBox(width: 18),

            // user name
            Text(text),
          ],
        ),
      ),
    );
  }
}
