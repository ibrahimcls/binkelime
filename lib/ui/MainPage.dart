import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:binkelime/common/service/word-firebase-service.dart';
import 'package:binkelime/common/service/share_service.dart';
import 'package:binkelime/ui/AllWordPages.dart';
import 'package:binkelime/ui/FavoritesPage.dart';
import 'package:binkelime/ui/WordPage.dart';
import 'package:flutter/foundation.dart';
import '../model/word.dart';
import 'package:binkelime/common/service/favorite_local_db_service.dart';

import 'dart:io' show Platform;
import 'dart:ui';

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
  final WordFirebaseService _wordService = WordFirebaseService();

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
      final fetchedWord = await _wordService.fetchCurrentWord();

      if (fetchedWord != null) {
        word = fetchedWord;
        if (_supportsHomeWidget) {
          await HomeWidget.saveWidgetData("text_from_flutter", word!.getJson());
          await HomeWidget.updateWidget(androidName: "HomeWidget");
        }
        _refreshFavorites();
        setState(() {});
      } else {
        print("Belirtilen kriterde document yok!");
      }
    } catch (e) {
      if (kDebugMode) print('Firebase init error: $e');
    }
  }

  void onFavoritePressed(Word currentWord) async {
    await _favService.addFavorite(currentWord);
  }

  void onRemovePressed(String insteadText) async {
    await _favService.deleteFavorite(insteadText);
  }

  void _refreshFavorites() {
    setState(() {
      _isFavorited = _favService.isFavorite(word!.instead);
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  void _showListBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          behavior: HitTestBehavior.opaque,
          child: BackdropFilter(
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
                              Navigator.pop(context),
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const FavoritesPage()),
                              ).then((value) => _refreshFavorites()),
                            },
                          ),
                          Divider(
                              height: 1, color: Colors.white.withOpacity(0.2)),
                          _buildOptionItem(
                            icon: Icons.book,
                            label: "Bütün Kelimeler",
                            color: Colors.white,
                            onTap: () => {
                              Navigator.pop(context),
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AllWordPage()),
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
                              Navigator.pop(context);
                              ShareService.shareWord(word!);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
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
              color: Colors.white.withOpacity(0.2),
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
