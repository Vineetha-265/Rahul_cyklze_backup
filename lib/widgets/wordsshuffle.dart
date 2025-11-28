
import 'dart:async';

import 'package:flutter/material.dart';

class ShufflingWordsWidget extends StatefulWidget {
  const ShufflingWordsWidget({super.key});

  @override
  _ShufflingWordsWidgetState createState() => _ShufflingWordsWidgetState();
}

class _ShufflingWordsWidgetState extends State<ShufflingWordsWidget> {
  final List<String> words = ['plastic', 'paper', 'Iron', 'books', 'carton', 'bottle','Ac','fridge','copper','silver','wire','ewaste'];
  String displayedWord = '';
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _shuffleWords();
  }

  void _shuffleWords() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        displayedWord = (words..shuffle()).first; // Shuffle the list and pick the first word
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
    
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'What we buy?',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,color: Color(0xFF1D4D61)),
          ),
          SizedBox(height: 2),
          Text(
            displayedWord,
            style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}