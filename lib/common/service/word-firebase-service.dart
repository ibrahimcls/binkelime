import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/word.dart';

class WordFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Word?> fetchCurrentWord() async {
    try {
      final querySnapshot =
          await _firestore.collection('current').limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        print("Document ID: ${doc.id}");
        return Word.fromFirestore(doc.data());
      }
      return null;
    } catch (e) {
      print("Firestore veri çekme hatası: $e");
      return null;
    }
  }
}
