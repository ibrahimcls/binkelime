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

class _MainAppState extends State<MainApp> with SingleTickerProviderStateMixin {
  Word? word;
  static final bool _supportsHomeWidget =
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  bool _isStarFilled = false;
  AnimationController? _animationController;
  Animation<double>? _animation;
  double starIconSize = 48;

  @override
  void initState() {
    super.initState();
    if (_supportsHomeWidget) {
      HomeWidget.setAppGroupId("com.example.binkelime");
    }
    getDocument();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 1, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
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
                    _animationController?.forward(from: 0);
                  });
                },
                child: SizedBox(
                  width: starIconSize,
                  height: starIconSize,
                  child: AnimatedBuilder(
                    animation: _animationController!,
                    builder: (context, child) {
                      final scale = _animation?.value ?? 1;
                      return Transform.scale(
                        scale: scale,
                        alignment: Alignment.center,
                        child: Icon(
                          _isStarFilled ? Icons.star : Icons.star_border,
                          color: _isStarFilled ? Colors.red : Colors.black54,
                          size: starIconSize,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
