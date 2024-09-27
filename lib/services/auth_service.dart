// ignore_for_file: avoid_print

import 'package:chat_app/helper/helper_function.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future registerUserWithEmail(
      String fullName, String email, String password) async {
    try {
      User user = (await firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user!;
      await DatabaseService(uid: user.uid).saveUserData(fullName, email);
      return true;
    } on FirebaseAuthException catch (e) {
      print(e);
      return e.message;
    }
  }

  Future logInUserWithEmail(
       String email, String password) async {
    try {
      // ignore: unused_local_variable
      User user = (await firebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .user!;
      return true;
    } on FirebaseAuthException catch (e) {
      print(e);
      return e.message;
    }
  }

  Future logOutUser() async {
    try {
      await HelperFunction.saveUserLogedInStatus(false);
      await HelperFunction.saveUserEmail("");
      await HelperFunction.saveUserName("");
      firebaseAuth.signOut();
    } catch (e) {
      return null;
    }
  }
}
