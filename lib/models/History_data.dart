import 'package:cloud_firestore/cloud_firestore.dart';

class ItemDataService {
  final CollectionReference itemCollection =
      FirebaseFirestore.instance.collection('history');

  Future addItemData(String itemName, Timestamp dateAndTime) async {
    try {
      return await itemCollection.doc().set({
        'Item Name': itemName,
        'Date and Time': dateAndTime,
      });
    } catch (e) {
      print("Error adding item data: ${e.toString()}");
      return null;
    }
  }
}
