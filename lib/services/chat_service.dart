import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rablo_chat/widgets/messages.dart';

class ChatService {
  final FirebaseFirestore _firestoreDatabse = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  FirebaseFirestore get firestoreDatabase => _firestoreDatabse;

  Stream<List<Map<String, dynamic>>> registeredUsersStream() {
    return _firestoreDatabse.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((users) {
        final user = users.data();

        return user;
      }).toList();
    });
  }

  // send message
  Future<void> sendMessage(String receiverID, String message) async {
    // get current user info
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    // create a new message
    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    // construct chat room ID for the two users (sorted to ensure uniqueness)
    List<String> ids = [currentUserID, receiverID];
    ids.sort(); // sort the ids (this ensures the chatRoomID is the same for any 2 people)
    String chatRoomID = ids.join('_');

    // add new message to database
    await _firestoreDatabse
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  // get messages
  Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
    // construct a chatroom ID for the two users
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestoreDatabse
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  Future<void> deleteMessage(
    String userID,
    String otherUserID,
    String messageID,
  ) async {
    //chatroom id
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    // delete message
    await _firestoreDatabse
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .doc(messageID)
        .delete();
  }

  Future<void> updateMessage(
    String userID,
    String otherUserID,
    String messageID,
    String newMessage,
  ) async {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    await _firestoreDatabse
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .doc(messageID)
        .update({
          'message': newMessage,
          'isEdited': true,
          'editedAt': Timestamp.now(),
        });
  }
}
