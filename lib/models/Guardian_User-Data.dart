import 'package:cloud_firestore/cloud_firestore.dart';

class GuardianUserDataService {
  final CollectionReference guardianUserCollection =
      FirebaseFirestore.instance.collection('Guardian_User-Data');

  Future<void> addGuardianUserData(
      String uid,
      String firstName,
      String lastName,
      String email,
      String phoneNumber,
      String password,
      String gfirstName,
      String glastName,
      String gaddress,
      String gphoneNumber) async {
    try {
      await guardianUserCollection.doc(uid).set({
        'User FName': firstName,
        'User LName': lastName,
        'Email': email,
        'User PNumber': phoneNumber,
        'Password': password,
        'Guardian FName': gfirstName,
        'Guardian LName': glastName,
        'Guardian Address': gaddress,
        'Guardian PNumber': gphoneNumber,
        // Store only the hashed password in production
      });
      print('user and guardian data added successfully');
    } catch (e) {
      print("Error adding user and guardian data: ${e.toString()}");
      throw e;
    }
  }
}
