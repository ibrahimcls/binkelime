import 'package:binkelime/common/service/word-firebase-service.dart';
import 'package:binkelime/ui/MainPage.dart';
import 'package:binkelime/common/service/favorite_local_db_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'common/firebase/firebase_options.dart';
import 'package:workmanager/workmanager.dart';
import 'dart:convert';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

  await Workmanager().registerPeriodicTask(
    "daily_word_update",
    "fetchDailyWord",
    frequency: const Duration(hours: 24),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );

  await FavoriteLocalDBService.init();
  runApp(const MainApp());
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
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
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  });
}
