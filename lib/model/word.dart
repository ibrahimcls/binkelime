import 'dart:convert';

class Word {
  final String instead;
  final String use;
  final String description;

  Word({
    required this.instead,
    required this.use,
    required this.description,
  });

  factory Word.fromFirestore(Map<String, dynamic> data) {
    return Word(
      instead: data['instead'] ?? '',
      use: data['use'] ?? '',
      description: data['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'instead': instead,
      'use': use,
      'description': description,
    };
  }

  String getJson() {
    return jsonEncode(toMap());
  }
}
