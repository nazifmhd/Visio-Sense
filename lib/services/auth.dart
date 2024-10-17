import 'package:firebase_auth/firebase_auth.dart';
import 'package:visiosense/models/UserModel.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

class AuthServices {
  // firebase instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //create a user from firebase user with uid
  UserModel? _userWithFirebaseUserUId(User? user) {
    return user != null ? UserModel(uid: user.uid) : null;
  }

  //create the stream for checking the auth changes in the user
  Stream<UserModel?> get user {
    return _auth.authStateChanges().map(_userWithFirebaseUserUId);
  }

  //sign in anonymous
  Future signInAnonympusly() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return _userWithFirebaseUserUId(user);
    } catch (err) {
      print(err.toString());
      return null;
    }
  }

  //register using email and password
  Future
      registerWithfirstnamelastNameemailphoneeNumbercreatePasswordAndConfirmPassword(
          String firstName,
          String lastName,
          String email,
          String phoneNumber,
          String createPassword,
          String confirmPassword) async {
    if (createPassword != confirmPassword) {
      print("Passwords do not match");
      return null;
    }
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: createPassword);
      User? user = result.user;
      return _userWithFirebaseUserUId(user);
    } catch (err) {
      print(err.toString());
      return null;
    }
  }

  //sign in using email and password
  Future SignInWithEmailAndPassword(
    String Email,
    String Password,
  ) async {}
}
