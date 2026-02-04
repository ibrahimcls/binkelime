import 'package:binkelime/WordWidget.dart';
import 'package:flutter/material.dart';
import 'model/word.dart';

class SmoothInfiniteGradient extends StatefulWidget {
  final Word? word;

  const SmoothInfiniteGradient({super.key, this.word});

  @override
  State<SmoothInfiniteGradient> createState() => _SmoothInfiniteGradientState();
}

class _SmoothInfiniteGradientState extends State<SmoothInfiniteGradient>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<Color> bgColors = [
    const Color(0xFFFF9F9F),
    const Color(0xFFFFCDA3),
    const Color(0xFFFFF6A3),
    const Color(0xFFC8FFB2),
    const Color(0xFFA3E8FF),
    const Color(0xFFAFA3FF),
  ];

  final List<Color> textColors = [
    const Color(0xFF3B0000),
    const Color(0xFF4B2C00),
    const Color(0xFF333300),
    const Color(0xFF003300),
    const Color(0xFF00334B),
    const Color(0xFF1A0033),
  ];

  int index = 0;

  Color startBgColor = Colors.red;
  Color endBgColor = Colors.blue;

  Color startTextColor = Colors.white;
  Color endTextColor = Colors.black;

  @override
  void initState() {
    super.initState();

    startBgColor = bgColors[0];
    endBgColor = bgColors[1];

    startTextColor = textColors[0];
    endTextColor = textColors[1];

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        index = (index + 1) % bgColors.length;

        startBgColor = endBgColor;
        endBgColor = bgColors[index];

        startTextColor = endTextColor;
        endTextColor = textColors[index];

        _controller.forward(from: 0);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  Widget wordWidget(Word word) {
    return WordWidget(word: word, txtColor: endTextColor);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        final bgColor = Color.lerp(startBgColor, endBgColor, _animation.value)!;
        final txtColor =
            Color.lerp(startTextColor, endTextColor, _animation.value)!;

        final hsv = HSVColor.fromColor(bgColor);
        final bgLight = hsv.withValue((hsv.value * 1.15).clamp(0, 1)).toColor();
        final bgDark = hsv.withValue((hsv.value * 0.85).clamp(0, 1)).toColor();

        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [bgLight, bgDark],
            ),
          ),
          child: widget.word != null
              ? Center(child: wordWidget(widget.word!))
              : Text(
                  "Yükleniyor...",
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: txtColor,
                  ),
                ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
