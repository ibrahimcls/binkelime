import 'dart:io' show Platform;

import 'package:binkelime/SmoothInfiniteGradient.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import 'firebase_options.dart';
import 'model/word.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Word? word;
  static final bool _supportsHomeWidget =
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  bool _isStarFilled = false;

  @override
  void initState() {
    super.initState();
    if (_supportsHomeWidget) {
      HomeWidget.setAppGroupId("com.example.binkelime");
    }
    getDocument();
  }

  Future<void> getDocument() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('current').limit(1).get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;

      print("Document ID: ${doc.id}");
      print("Document data: ${doc.data()}");

      word = Word.fromFirestore(doc.data());
      if (_supportsHomeWidget) {
        await HomeWidget.saveWidgetData("text_from_flutter", word!.getJson());
        await HomeWidget.updateWidget(androidName: "HomeWidget");
      }
      setState(() {});
    } else {
      print("Belirtilen kriterde document yok!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            Center(
              child: SmoothInfiniteGradient(word: word),
            ),
            Positioned(
              right: 24,
              bottom: 24,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isStarFilled = !_isStarFilled;
                  });
                },
                child: Icon(
                  _isStarFilled ? Icons.star : Icons.star_border,
                  color: _isStarFilled ? Colors.red : Colors.black54,
                  size: 48,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
