import 'package:flutter/material.dart';

abstract class Constants {
  static Color? barsBackgroundColor = Colors.grey[100];
  static Color? textFormColor = Colors.grey[300];
  static Color? buttonTextColor = Colors.blue[700];

  static const double modalSizeMin = 0;
  static const double modalSizeInitial = 0;
  static const double modalSizeClosed = 0.1;
  static const double modalSizeHalf = 0.5;
  static const double modalSizeFull = 1.0;

  static OutlineInputBorder outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey[100]!));
}
