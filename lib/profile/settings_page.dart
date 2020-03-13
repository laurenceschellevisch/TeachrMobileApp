import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teachr/globals.dart' as globals;
import 'package:teachr/helpers/cookie_helper.dart';
import 'package:teachr/helpers/offers_helper.dart';
import 'package:teachr/helpers/storage_helper.dart' as StorageHelper;
import 'package:teachr/language/localizations.dart';
import 'package:teachr/login/login_page.dart';
import 'package:url_launcher/url_launcher.dart' as Url show launch;

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);

  @override
  _SettingsPageState createState() => new _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _currentLanguage = "en";
  Locale _dutch = Locale("nl", "NL");

  @override
  void initState() {
    super.initState(); // PreferencesHelper.getLanguage();
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> settingsList = [
      // TODO: reload app after changing language.
      ListTile(
        title: Text(LangLocalizations.of(context).trans('settingsLanguage'),
            style: Theme.of(context).textTheme.subhead.copyWith(
                  fontSize: 14.0,
                )),
      ),
      RadioListTile(
          title: Text('Dutch'),
          value: "nl",
          groupValue: _currentLanguage,
          onChanged: (value) {
            _currentLanguage = value;

            setState(() {
              new LangLocalizations(_dutch);
            });
          }),
      RadioListTile(
          title: Text('English'),
          value: "en",
          groupValue: _currentLanguage,
          onChanged: (value) {
            _currentLanguage = value;
            setState(() {});
          }),
      Divider(),
      ListTile(
        title: Text(LangLocalizations.of(context).trans('settingsAbout'),
            style: Theme.of(context).textTheme.subhead.copyWith(
                  fontSize: 14.0,
                )),
      ),
      ListTile(
        title: Text("Privacy Policy"),
        leading: Icon(Icons.short_text),
        onTap: () {
          Url.launch("https://www.teachrapp.nl/about/", forceSafariVC: true);
        },
      ),
      ListTile(
        leading: Icon(Icons.open_in_browser),
        title: Text("Website"),
        subtitle: Text(
          "www.teachrapp.nl",
          style: Theme.of(context).textTheme.subtitle,
        ),
        onTap: () {
          Url.launch("https://www.teachrapp.nl/", forceSafariVC: true);
        },
      ),
      Divider(),
      ListTile(
        leading: Icon(Icons.exit_to_app),
        isThreeLine: true,
        title: Text(LangLocalizations.of(context).trans('settingsLogout')),
        subtitle: Text(
          LangLocalizations.of(context).trans('settingsLogoutSubtitle'),
          style: Theme.of(context).textTheme.subtitle,
        ),
        onTap: () {
          _logOutDialog();
        },
      ),
    ];

    return (new Scaffold(
      appBar: AppBar(
        textTheme: Theme.of(context).textTheme,
        centerTitle: true,
        title: Text(LangLocalizations.of(context).trans('settings')),
        leading: BackButton(),
      ),
      body: ListView.builder(
        itemCount: settingsList.length,
        itemBuilder: (BuildContext context, int index) {
          return settingsList[index];
        },
      ),
    ));
  }

  AboutListTile aboutListTile() {
    return AboutListTile(
      aboutBoxChildren: <Widget>[],
    );
  }

  void _logOutDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(LangLocalizations.of(context).trans('settingsLogoutAlert')),
          content: Text(
              LangLocalizations.of(context).trans('settingsLogoutSubtitle')),
          actions: <Widget>[
            new FlatButton(
              child: Text(LangLocalizations.of(context).trans('close')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child:
                  Text(LangLocalizations.of(context).trans('settingsLogout')),
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    globals.userData = null;
    globals.currentUser = null;
    globals.isLoggedIn = false;
    StorageHelper.deleteKeyValue('email');
    StorageHelper.deleteKeyValue('password');
    StorageHelper.setSharedPref('rememberLogin', false);

    OffersHelper.clearLists();
    CookieHelper.setCookie("");
    OffersHelper.getCards();

    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}
