import 'package:flutter/material.dart';
import '../model/word.dart';

class WordWidget extends StatefulWidget {
  final Word? word;
  final Color txtColor;

  const WordWidget({
    super.key,
    this.word,
    required this.txtColor,
  });

  @override
  State<WordWidget> createState() => _WordWidgetState();
}

class _WordWidgetState extends State<WordWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "${widget.word!.instead} yerine kullan",
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: widget.txtColor,
            ),
          ),
          Builder(
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: FittedBox(
                  child: Text(
                    widget.word!.use,
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 200,
                      fontWeight: FontWeight.w900,
                      color: widget.txtColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
            child: Text(
              widget.word!.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: widget.txtColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
