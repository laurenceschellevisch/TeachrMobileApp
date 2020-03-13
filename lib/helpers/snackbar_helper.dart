import 'package:flutter/material.dart';

class SnackBarHelper {
//TODO: improve snackbarhelper so Scaffold.of(context).showSnackBar(...) doesn't need to be called and accepts String as input instead of Text.

  /// Snackbar helper.
  static SnackBar snackbarText(Text snackBarText) {
    var snackbar = SnackBar(
      content: snackBarText,
      duration: const Duration(seconds: 3),
    );
    return snackbar;
  }
}
