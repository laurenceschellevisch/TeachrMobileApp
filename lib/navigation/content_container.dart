import 'package:flutter/material.dart';
import 'package:teachr/Helpers/offers_helper.dart';
import 'package:teachr/Offers/card_data.dart';
import 'package:teachr/Offers/offers_page.dart';
import 'package:teachr/helpers/tutorial_helper.dart';
import 'package:teachr/language/localizations.dart';
import 'package:teachr/login/login_page.dart';
import 'package:teachr/offers/overview_page.dart';
import 'package:teachr/tutorial/tutorial.dart';
import 'package:teachr/profile/profile_page.dart';
import 'package:teachr/chat/chatroom.dart';
import 'package:teachr/globals.dart' as globals;
// import 'package:teachr/helpers/storage_helper.dart' as StorageHelper;

class ContentPage extends StatefulWidget {
  ContentPage({this.title, this.index, this.onPush});
  final String title;
  final int index;
  final ValueChanged<int> onPush;

  @override
  _ContentPageState createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(child: buildContainers(widget.index, context)));
  }

  Widget _loginChecker(int pageIndex) {
    if (!globals.isLoggedIn) {
      if (pageIndex == 0) {
        return LoginPage();
      } else if (pageIndex == 2) {
        return LoginPage();
      }
    }
    if (pageIndex == 0) {
      return ProfilePage();
    }

    return ChatOverview(globals.currentUser.id);
  }

  /// Check if user has already completed the tutorial.
  Widget _tutorialChecker() {
    Widget widget;

    if (!TutorialHelper.isTutorialFinished) {
      widget = Tutorial();
    } else {
      widget = OverviewPage();
    }

    return widget;
  }

  /// When starting the app, the 3 tabs get built in the switchcase below.
  Widget buildContainers(int index, BuildContext context) {
    switch (index) {
      case 0: // Profile
        return Container(
          child: _loginChecker(0),
        );
      case 1: // Offers
        return Container(
          child: _tutorialChecker(),
        );
      case 2: // Chat
        return Container(
          child: _loginChecker(2),
        );
    }
    return Container(
      child: Text(LangLocalizations.of(context).trans('basicerror')),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
