import 'package:binkelime/model/word.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FavoriteLocalDBService {
  static const String _boxName = "favorite_words";

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  Future<void> addFavorite(Word word) async {
    final box = Hive.box(_boxName);

    if (!box.containsKey(word.instead)) {
      await box.put(word.instead, word.toMap());
      print("${word.instead} favorilere eklendi.");
    } else {
      print("Bu kelime zaten favorilerde mevcut.");
    }
  }

  Future<void> deleteFavorite(String insteadKey) async {
    final box = Hive.box(_boxName);

    if (box.containsKey(insteadKey)) {
      await box.delete(insteadKey);
      print("$insteadKey favorilerden silindi.");
    }
  }

  List<Word> getAllFavorites() {
    final box = Hive.box(_boxName);

    return box.values.map((data) {
      final Map<String, dynamic> wordMap = Map<String, dynamic>.from(data);
      return Word.fromFirestore(wordMap);
    }).toList();
  }
}
