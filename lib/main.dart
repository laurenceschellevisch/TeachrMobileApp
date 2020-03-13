import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:teachr/globals.dart' as globals;
import 'package:teachr/helpers/tutorial_helper.dart';
import 'package:teachr/language/localizations.dart';
import 'package:teachr/navigation/bottom_navigation.dart';
import 'package:teachr/navigation/tab_navigator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teachr/themes.dart';

void main() => runApp(TeachrApp());

class TeachrApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(systemThemeLight());
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    // Check for unread messages.
    // ChatNotification().checkChatMessages();

    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      showSemanticsDebugger: false,
      title: 'Teachr',
      theme: teachrLightTheme,
      home: new Teachr(),

      /// The first locale is default
      localizationsDelegates: [
        const LangLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: [const Locale('nl', 'NL'), const Locale('en', 'US')],
      localeResolutionCallback:
          (Locale locale, Iterable<Locale> supportedLocales) {
        if (locale != null) {
          for (Locale supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode ||
                supportedLocale.countryCode == locale.countryCode) {
              return supportedLocale;
            }
          }
        }
        return supportedLocales.first;
      },
    );
  }
}

class Teachr extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TeachrState();
}

class TeachrState extends State<Teachr> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TabItem currentTab = TabItem.offers; // Opening tab.
  Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    TabItem.profile: GlobalKey<NavigatorState>(),
    TabItem.offers: GlobalKey<NavigatorState>(),
    TabItem.chat: GlobalKey<NavigatorState>(),
  };

  void _selectTab(TabItem tabItem) {
    setState(() {
      globals.currentTabIndex = tabItem.index;
      currentTab = tabItem;
    });
  }

  Future<FirebaseUser> _handleSignIn() async {
    final FirebaseUser user = await _auth.signInAnonymously();
    return user;
  }

  @override
  void initState() {
    super.initState();
    _handleSignIn();

    TutorialHelper.getTutorialStatus().then((result) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async =>
          !await navigatorKeys[currentTab].currentState.maybePop(),
      child: Scaffold(
          body: Stack(children: <Widget>[
            _buildOffstageNavigator(TabItem.profile),
            _buildOffstageNavigator(TabItem.offers),
            _buildOffstageNavigator(TabItem.chat),
          ]),
          bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(),
            child: new BottomNavigation(
              currentTab: currentTab,
              onSelectTab: _selectTab,
            ),
          )),
    );
  }

  Widget _buildOffstageNavigator(TabItem tabItem) {
    return Offstage(
      offstage: currentTab != tabItem,
      child: TabNavigator(
        navigatorKey: navigatorKeys[tabItem],
        tabItem: tabItem,
      ),
    );
  }
}
