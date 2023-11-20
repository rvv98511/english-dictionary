import 'package:flutter/material.dart';

class DismissKeyboard {
  off(context) {
    FocusScope.of(context).unfocus();
  }
}