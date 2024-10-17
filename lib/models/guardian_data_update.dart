import 'package:cloud_firestore/cloud_firestore.dart';

class GuardianDataService {
  final CollectionReference guardianCollection =
      FirebaseFirestore.instance.collection('guardians');

  Future<void> updateGuardianData(String uid, String firstName, String lastName,
      String address, String phoneNumber) async {
    try {
      await guardianCollection.doc(uid).update({
        'Guardian FName': firstName,
        'Guardian LName': lastName,
        'Guardian Address': address,
        'Guardian PNumber': phoneNumber,
      });
      print('Guardian data updated successfully');
    } catch (e) {
      print("Error updating guardian data: ${e.toString()}");
      throw Exception('Failed to update guardian data');
    }
  }
}
