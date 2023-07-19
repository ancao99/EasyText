import 'package:firebase_auth/firebase_auth.dart';
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //sign up
  Future<UserCredential?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } catch (e) {
// Handle sign-up errors
      print(e.toString());
      return null;
    }
  }
  //log in
  Future<UserCredential?> signInWithEmailAndPassword(
      String email,
      String password,
      ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      print("Error during login: $e");
      return null;
    }
  }
}