import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_note/models/note_model.dart';

class FirestoreHelper {
  final _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  late final _currentUserRef = FirebaseFirestore.instance
      .collection("users_note")
      .doc(_currentUserId)
      .collection("notes")
      .withConverter(
        fromFirestore: (snapshot, _) => NoteModel.fromJson(snapshot.data()!),
        toFirestore: (note, _) => note.toJson(),
      );

  // final noteRef = FirebaseFirestore.instance
  //     .collection("notes")
  //     .withConverter<NoteModel>(
  //       fromFirestore: (snapshot, _) {
  //         final data = snapshot.data()!;
  //         data["note_id"] ??= snapshot.id;
  //         return NoteModel.fromJson(data);
  //       },
  //       toFirestore: (note, _) => note.toJson(),
  //     );

  /// CREATE
  Future<String> insertItem(NoteModel note) async {
    final doc = await _currentUserRef.add(note);
    await doc.update({"note_id": doc.id});
    return doc.id;
  }

  /// READ - GET ALL
  Future<List<NoteModel>> fetchItem() async {
    final snapshot = await _currentUserRef
        .orderBy("created_at", descending: true)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// READ - GET BY ID
  Future<NoteModel?> getNoteById(String id) async {
    final doc = await _currentUserRef.doc(id).get();
    return doc.data();
  }

  /// UPDATE FULL
  Future<void> updateItem(NoteModel note) async {
    if (note.noteId == null || note.noteId.toString().isEmpty) {
      throw Exception("note_id is required");
    }
    await _currentUserRef.doc(note.noteId.toString()).set(note);
  }

  /// UPDATE PARTIAL
  Future<void> updateFields(String id, Map<String, dynamic> fields) async {
    await _currentUserRef.doc(id).update(fields);
  }

  /// DELETE
  Future<void> deleteItem(String id) async {
    await _currentUserRef.doc(id).delete();
  }

  // ---------------------------------------------------------
  // REALTIME STREAMS
  // ---------------------------------------------------------

  /// STREAM ALL NOTES (REALTIME)
  Stream<List<NoteModel>> streamAllNotes() {
    return _currentUserRef
        .orderBy("created_at", descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()).toList();
        });
  }

  /// STREAM SINGLE NOTE BY ID (REALTIME)
  Stream<NoteModel?> streamNoteById(String id) {
    return _currentUserRef.doc(id).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return snapshot.data();
    });
  }
}
