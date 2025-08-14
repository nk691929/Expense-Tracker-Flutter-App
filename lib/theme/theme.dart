import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary:Color(0xFF381244), // Primary color for buttons, app bar, etc.
    secondary:Color(0xFFF080CE), // Accent color
    tertiary:Color(0xFFF080CE),
    surface: Color(0xFFF080CE) ,// FF = 100% opacity
    onPrimary:Color(0xFFF080CE),
    onSecondary:Color(0xFFF080CE),
    onSurface: Color(0xFFFFFFFF),
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
   primary:Color(0xFF381244), // Primary color for buttons, app bar, etc.
    secondary:Color(0xFFF080CE), // Accent color
    tertiary:Color(0xFFF080CE),
    surface: Color(0xFFF080CE) ,// FF = 100% opacity
    onPrimary:Color(0xFFF080CE),
    onSecondary:Color(0xFFF080CE),
    onSurface: Color(0xFFFFFFFF),
  ),
);


