import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

SystemUiOverlayStyle systemThemeLight() {
  final SystemUiOverlayStyle base = SystemUiOverlayStyle.light;
  return base.copyWith(
      statusBarColor: Colors.white,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: Colors.grey[300],
      systemNavigationBarIconBrightness: Brightness.dark);
}

/// BUG: systemnavbar turns white after minimizing and maximizing the app
/// (Can probably fix with AppLifecycleState)
/// https://github.com/flutter/flutter/issues/21265
class TeachrColors {
  static const Color loginGradientStart = const Color(0xFF30a0ff);
  static const Color loginGradientEnd = const Color(0xFF3051FF);

  // teachr colors
  static const Color teachrBlue = const Color(0xFF3051FF);
  static const Color teachrDarkBlue = const Color(0xFF0028ca);
  static const Color blueGrey = const Color(0xFF607D8B);

  // system related
  static const Color errorRed = const Color(0xFFf05545);
  static const primaryGradient = const LinearGradient(
    colors: const [loginGradientStart, loginGradientEnd],
    stops: const [0.0, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  const TeachrColors();
}

Color primaryColor = const Color(0xFF3051ff);
Color primaryColorLight = const Color(0xFF7b7beff);
Color accentColor = const Color(0xFF435fea);
Color primaryDarkColor = const Color(0xFF0028ca);
Color primaryLightTextColor = const Color(0xFFffffff);
Color primaryDarkTextColor = const Color(0xFF444444);
Color lightGrayColor = const Color(0xFFf4f4f4);
Color errorRed = const Color(0xFFf05545);

final Radius chatMessageBorderRadius = const Radius.circular(20.0);
final EdgeInsets chatMessageSpacing = const EdgeInsets.only(bottom: 5.0);

final ThemeData teachrLightTheme = _buildTeachrLightTheme();

ThemeData _buildTeachrLightTheme() {
  final ThemeData base = ThemeData.light();
  TextFormField(style: TextStyle(color: Colors.black));
  return base.copyWith(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    primaryColorLight: primaryColorLight,
    accentColor: primaryColor,
    primaryColorDark: TeachrColors.teachrDarkBlue,
    buttonColor: TeachrColors.teachrBlue,
    textSelectionColor: TeachrColors.blueGrey,
    errorColor: TeachrColors.errorRed,
    canvasColor: Colors.white,
    backgroundColor: Colors.white,
    appBarTheme: _buildAppBarTheme(base.appBarTheme),
    bottomAppBarTheme: base.bottomAppBarTheme.copyWith(
      elevation: 4.0,
      color: Colors.white,
    ),
    bottomAppBarColor: Colors.white,
    chipTheme: _buildChipThemeData(base.chipTheme),
    buttonTheme: base.buttonTheme.copyWith(
      minWidth: 32.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(64.0)),
      buttonColor: TeachrColors.teachrBlue,
      textTheme: ButtonTextTheme.normal,
    ),
    textTheme: _buildTextTheme(base.textTheme),
    primaryTextTheme: _buildTextTheme(base.primaryTextTheme),
    accentTextTheme: _buildTextTheme(base.accentTextTheme),
    iconTheme: IconThemeData(color: primaryColor),
    primaryIconTheme:
        base.iconTheme.copyWith(color: TeachrColors.teachrDarkBlue),
    inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder()),
  );
}

AppBarTheme _buildAppBarTheme(AppBarTheme base) {
  return base.copyWith(
    color: Colors.white,
    brightness: Brightness.light,
    elevation: 2.0,
    iconTheme: base.iconTheme,
    textTheme: base.textTheme,
  );
}

TextTheme _buildTextTheme(TextTheme base) {
  return base
      .copyWith(
        title: base.title.copyWith(
          fontSize: 18.0,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w600,
        ),
        headline: base.headline.copyWith(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w700,
        ),
        subtitle: base.subtitle.copyWith(
          color: Color(0xFF777777),
        ),
        subhead: base.subhead.copyWith(),
        body1: base.body1.copyWith(
          fontFamily: 'Roboto',
        ),
        body2: base.body2.copyWith(
          fontFamily: 'Roboto',
        ),
        caption: base.caption.copyWith(
          fontWeight: FontWeight.w400,
          fontSize: 14.0,
        ),
        button: base.button.copyWith(
          color: Colors.white,
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w600,
        ),
      )
      .apply(
        fontFamily: 'Nunito',
      );
}

ChipThemeData _buildChipThemeData(ChipThemeData base) {
  return base.copyWith(
    brightness: Brightness.light,
    backgroundColor: primaryColor,
    deleteIconColor: Colors.grey,
    labelStyle: TextStyle(fontFamily: 'Nunito', color: Colors.white),
    elevation: 4.0,
  );
}
