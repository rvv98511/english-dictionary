import 'package:flutter/material.dart';
import '../resources/themes.dart';
import '../views/dictionary_screen.dart';

void main() {
  runApp(const EnglishDictionary());
}

class EnglishDictionary extends StatelessWidget {
  const EnglishDictionary({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: AppTheme.textTheme,
        fontFamily: AppTheme.fontName
      ),
      home: DictionaryScreen(),
    );
  }
}
