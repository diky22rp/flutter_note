import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_note/models/user_model.dart';

class FirestoreUserHelper {
  final _userRef = FirebaseFirestore.instance
      .collection("users_note")
      .withConverter(
        fromFirestore: (snapshot, _) => UserModel.fromJson(snapshot.data()!),
        toFirestore: (userMode, _) => userMode.toJson(),
      );

  Future addUser(UserModel user) async {
    await _userRef.doc(user.userId).set(user);
  }
}
