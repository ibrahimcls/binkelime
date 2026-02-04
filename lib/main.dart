import 'package:binkelime/ui/MainPage.dart';
import 'package:binkelime/common/service/favorite_local_db_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'common/firebase/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FavoriteLocalDBService.init(); // DB başlatıldı
  runApp(const MainApp() as Widget);
}
