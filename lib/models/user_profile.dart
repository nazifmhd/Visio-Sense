import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  // Fetching the user profile data from Firestore
  Future<Map<String, dynamic>?> fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Fetch user data from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        return userDoc.data() as Map<String, dynamic>?;
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
    return null;
  }
}
