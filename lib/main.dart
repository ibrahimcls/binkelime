import 'package:binkelime/common/service/word-firebase-service.dart';
import 'package:binkelime/ui/MainPage.dart';
import 'package:binkelime/common/service/favorite_local_db_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'common/firebase/firebase_options.dart';
import 'dart:convert';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FavoriteLocalDBService.init();
  runApp(
    const MaterialApp(
      home: MainApp(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

Future<void> updateWidgetData() async {
  try {
    final firebaseService = WordFirebaseService();
    final word = await firebaseService.fetchCurrentWord();

    if (word != null) {
      final String jsonWord = jsonEncode({
        'use': word.use,
        'instead': word.instead,
        'description': word.description,
      });

      await HomeWidget.saveWidgetData('text_from_flutter', jsonWord);

      await HomeWidget.updateWidget(
        androidName: 'HomeWidget',
      );
    }
  } catch (e) {
    print('Widget güncellemesi başarısız: $e');
  }
}
