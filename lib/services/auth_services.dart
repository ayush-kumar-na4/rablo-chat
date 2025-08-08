import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  User? currentUser() {
    return _auth.currentUser;
  }

  // login / sign in
  Future<UserCredential> signInEnP(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<UserCredential> signUpEnP({
    required String name,
    required String email,
    required String password,
    required String mobile,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      _firestore.collection("Users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'name': name,
        'mobile': mobile,
      });
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> signOut() async {
    return await _auth.signOut();
  }

  // Get current user's complete profile data from Firestore
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      final user = currentUser();
      if (user != null) {
        final doc = await _firestore.collection("Users").doc(user.uid).get();
        if (doc.exists) {
          return doc.data();
        }
      }
      return null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }
}
