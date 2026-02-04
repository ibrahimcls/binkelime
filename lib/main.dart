import 'dart:io' show Platform;
import 'dart:ui';

import 'package:binkelime/FavoritesPage.dart';
import 'package:binkelime/SmoothInfiniteGradient.dart';
import 'package:binkelime/favorite_local_db_service.dart';
import 'package:binkelime/share_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import 'common/firebase/firebase_options.dart';
import 'model/word.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FavoriteLocalDBService.init(); // DB başlatıldı
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
  bool _isFavorited = false;
  final _favService = FavoriteLocalDBService();
  AnimationController? _animationController;
  Animation<double>? _animation;
  double starIconSize = 48;

  @override
  void initState() {
    super.initState();
    if (_supportsHomeWidget) {
      HomeWidget.setAppGroupId("com.example.binkelime");
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAsync();
    });
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _animation = Tween<double>(begin: 1, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.elasticOut,
      ),
    );
  }

  Future<void> _initAsync() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      if (kDebugMode) print('Firebase init error: $e');
    }
    await getDocument();
  }

  void onFavoritePressed(Word currentWord) async {
    await _favService.addFavorite(currentWord);
  }

  void onRemovePressed(String insteadText) async {
    await _favService.deleteFavorite(insteadText);
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

  void _showListBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Stack(
            children: [
              Positioned(
                right: 24,
                bottom: 80,
                child: Material(
                  color: Colors.transparent,
                  elevation: 20,
                  shadowColor: Colors.black.withOpacity(0.3),
                  child: _buildGlassBox(
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildOptionItem(
                          icon: Icons.favorite,
                          label: "Favori Kelimeler",
                          color: Colors.white,
                          onTap: () => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const FavoritesPage()),
                            )
                          },
                        ),
                        Divider(
                            height: 1, color: Colors.white.withOpacity(0.2)),
                        _buildOptionItem(
                          icon: Icons.share,
                          label: "Paylaş",
                          color: Colors.white,
                          onTap: () {
                            Navigator.pop(context); // Menüyü kapat
                            ShareService.shareWord(word!); // Kelimeyi paylaş
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildGlassBox(Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: 250,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white
                  .withOpacity(0.2), // İnce bir kenarlık şıklık katar
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.black87,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      hoverColor: Colors.grey[100],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('tr', ''),
      ],
      home: Builder(
        builder: (context) {
          return Scaffold(
            body: Stack(
              children: [
                Center(
                  child: SmoothInfiniteGradient(word: word),
                ),
                Positioned(
                  right: 24,
                  bottom: 24,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isFavorited = !_isFavorited;
                            _animationController?.forward(from: 0);
                            if (_isFavorited) {
                              onFavoritePressed(word!);
                            } else {
                              onRemovePressed(word!.instead);
                            }
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
                                  _isFavorited ? Icons.star : Icons.star_border,
                                  color: _isFavorited
                                      ? Colors.red
                                      : Colors.black54,
                                  size: starIconSize,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          _showListBottomSheet(context);
                        },
                        child: const Icon(
                          Icons.menu,
                          color: Colors.black54,
                          size: 48,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
