import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart'
    show CachedNetworkImageProvider;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:teachr/globals.dart' as globals;
import 'package:teachr/helpers/cookie_helper.dart';
import 'package:teachr/language/localizations.dart';
import 'package:teachr/profile/settings_page.dart';
// import 'package:teachr/helpers/storage_helper.dart' as StorageHelper;

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => new _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  bool isEditing = false;
  FloatingActionButton editFab;
  final emailController =
      TextEditingController(text: globals.currentUser.email);
  final firstnameController =
      TextEditingController(text: globals.currentUser.firstname);
  final lastnameController =
      TextEditingController(text: globals.currentUser.lastname);
  final descriptionController =
      TextEditingController(text: globals.currentUser.description);
  final skillsetController =
      TextEditingController(text: globals.currentUser.skillset);

  _printLatestValue() {
    debugPrint("firstname: ${firstnameController.text}, " +
        "lastname: ${lastnameController.text}, " +
        "description: ${descriptionController.text}" +
        "skillset: ${skillsetController.text}");
  }

  bool showFilter = false;
  List<String> currentSkills = [];
  List<String> newSkillList = [];

  @override
  void initState() {
    super.initState();

    readProfileData();

    /// Start listening to changes of the forms
    // emailController.addListener(_printLatestValue);
    firstnameController.addListener(_printLatestValue);
    lastnameController.addListener(_printLatestValue);
    descriptionController.addListener(_printLatestValue);
  }

  @override
  Widget build(BuildContext context) {
    final Text _appBarTitle =
        Text(LangLocalizations.of(context).trans('profile'));
    final TextStyle _formTextColor = TextStyle(color: Colors.black);
    return new Scaffold(
      appBar: AppBar(
        textTheme: Theme.of(context).textTheme,
        centerTitle: true,
        title: Text("Profile",style: TextStyle(
          fontFamily: "ReneBieder",color: Color(0xff8F00D2),
        ),),
        leading: new Container(),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.settings),
              color: Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.push(
                  context,
                  new MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              }),
        ],
      ),
      body: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(8.0),
            child: Form(
              onChanged: () {},
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 12)),
                  CircleAvatar(
                    backgroundImage:
                        CachedNetworkImageProvider(globals.currentUser.avatar),
                    backgroundColor: Theme.of(context).primaryColorLight,
                    radius: 64.0,
                  ),
                  Padding(padding: EdgeInsets.only(top: 16)),
                  TextFormField(
                    style: _formTextColor,
                    enabled: false,
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Email',
                    ),
                    validator: (value) {
                      value = emailController.text;
                      if (value.isEmpty) {
                        return 'Email cannot be empty.';
                      }
                    },
                  ),
                  Padding(padding: EdgeInsets.only(top: 16)),
                  TextFormField(
                    style: _formTextColor,
                    enabled: isEditing,
                    controller: firstnameController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText:
                          LangLocalizations.of(context).trans('firstnamelabel'),
                      hintText:
                          LangLocalizations.of(context).trans('firstnamehint'),
                    ),
                    validator: (value) {},
                  ),
                  Padding(padding: EdgeInsets.only(top: 16)),
                  TextFormField(
                    enabled: isEditing,
                    controller: lastnameController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText:
                          LangLocalizations.of(context).trans('lastnamelabel'),
                      hintText:
                          LangLocalizations.of(context).trans('lastnamehint'),
                    ),
                    validator: (value) {},
                  ),
                  Padding(padding: EdgeInsets.only(top: 16)),
                  Text(
                    LangLocalizations.of(context).trans('skillsetlabel'),
                    textAlign: TextAlign.left,
                  ),
                  getChipWidgets(),
                  Visibility(visible: isEditing, child: previewChips()),
                  Visibility(
                    visible: isEditing,
                    child: TypeAheadField(
                      textFieldConfiguration: TextFieldConfiguration(
                          autocorrect: true,
                          decoration: InputDecoration(
                            hintText: LangLocalizations.of(context)
                                .trans('newSkillhint'),
                            labelText: LangLocalizations.of(context)
                                .trans('newSkillhint'),
                          )),
                      suggestionsCallback: (searchString) async {
                        return await getFilteredList(searchString);
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          leading: Icon(Icons.playlist_add),
                          title: Text(suggestion),
                        );
                      },
                      onSuggestionSelected: (suggestion) {
                        if (currentSkills.contains(suggestion)) {
                          Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text(suggestion.toString() +
                                LangLocalizations.of(context)
                                    .trans('skillAlreadyExists')),
                          ));
                        } else {
                          newSkillList.add(suggestion);
                          setState(() {
                            previewChips();
                          });
                        }
                      },
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(top: 16, bottom: 16)),
                  TextFormField(
                    enabled: isEditing,
                    maxLines: 3,
                    controller: descriptionController,
                    autocorrect: true,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      labelText: LangLocalizations.of(context)
                          .trans('descriptionlabel'),
                      hintText: LangLocalizations.of(context)
                          .trans('descriptionhint'),
                    ),
                    validator: (value) {},
                  ),
                  Padding(padding: EdgeInsets.only(top: 16)),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: toggleFAB(),
    );
  }

  FloatingActionButton toggleFAB() {
    if (!isEditing) {
      return editFab = new FloatingActionButton(
        tooltip: "Edit",
        child: Icon(Icons.edit),
        elevation: 4,
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          setState(() {
            readProfileData();
            isEditing = true;
          });
        },
      );
    } else {
      return editFab = new FloatingActionButton.extended(
        icon: Icon(Icons.edit),
        label: Text(LangLocalizations.of(context).trans('saveFAB')),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 6.0,
        onPressed: () {
          setState(() {
            updateUserProfile();
            isEditing = false;
          });
        },
      );
    }
  }

  validateForm() {
    if (_formKey.currentState.validate()) {
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Form validation failed..."),
      ));
    }
  }

  updateUserProfile() async {
    validateForm();
    updateFirstName();
    updateLastName();
    updateDescription();
    updateSkillset(createDatabaseString(currentSkills, newSkillList));

    Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(LangLocalizations.of(context).trans('changesSaved'))));
  }

  Future<void> updateFirstName() async {
    if (globals.currentUser.firstname != firstnameController.text) {
      String _updateUrl =
          "https://teachrapp.nl/index.php/api/user/update_user_meta?cookie=" +
              CookieHelper.cookie.toString() +
              "&meta_key=firstname&meta_value=" +
              firstnameController.text;
      var res;
      try {
        res = await http.get(Uri.encodeFull(_updateUrl),
            headers: {"Accept": "application/json"});
        if (json.decode(res.body)['status'] == "error") {
          throw json.decode(res.body)['error'];
        }
      } catch (e) {
        return e;
      }
    }
  }

  Future<void> updateLastName() async {
    if (globals.currentUser.lastname != lastnameController.text) {
      String _updateUrl =
          "https://teachrapp.nl/index.php/api/user/update_user_meta?cookie=" +
              CookieHelper.cookie.toString() +
              "&meta_key=lastname&meta_value=" +
              lastnameController.text;
      var res;
      try {
        res = await http.get(Uri.encodeFull(_updateUrl),
            headers: {"Accept": "application/json"});
        if (json.decode(res.body)['status'] == "error") {
          throw json.decode(res.body)['error'];
        }
      } catch (e) {
        return e;
      }
    }
  }

  Future<void> updateDescription() async {
    if (globals.currentUser.description != descriptionController.text) {
      String _updateUrl =
          "https://teachrapp.nl/index.php/api/user/update_user_meta?cookie=" +
              CookieHelper.cookie.toString() +
              "&meta_key=description&meta_value=" +
              descriptionController.text;
      var res;
      try {
        res = await http.get(Uri.encodeFull(_updateUrl),
            headers: {"Accept": "application/json"});
        if (json.decode(res.body)['status'] == "error") {
          throw json.decode(res.body)['error'];
        }
      } catch (e) {
        return e;
      }
    }
  }

  Future getFilteredList(String pattern) async {
    await Future.delayed(Duration(seconds: 1));

    // Only start searching when there is at least 1 character.
    if (pattern.length > 0) {
      // API call
      String _readUrl = "https://teachrapp.nl/index.php/wp-json/filters/all";

      List filterList = [];

      try {
        var resp = await http.get(Uri.encodeFull(_readUrl),
            headers: {"Accept": "application/json"});
        var resultBody = json.decode(resp.body);

        if (resultBody['status'] == "error") {
          throw json.decode(resp.body)['error'];
        } else {
          resultBody["filterOptions"].forEach((item) {
            if (item.toLowerCase().startsWith(pattern.toLowerCase())) {
              filterList.add(item);
            }
          });

          return filterList;
        }
      } catch (e) {
        return e;
      }
    }
    return [];
  }

  List<String> getSkillList() {
    RegExp regex = new RegExp(r'"(.*?)"');
    List<String> skillList = [];

    if (globals.currentUser.skillset != null) {
      if (globals.currentUser.skillset.contains('"')) {
        Iterable<Match> matches =
            regex.allMatches(globals.currentUser.skillset);
        if (matches.length > 0) {
          for (var i = 0; i < matches.length; i++) {
            skillList.add(matches.elementAt(i).group(1));
          }
        }
      } else {
        // There is only a single value for the list.
        skillList.add(globals.currentUser.skillset.toString());
      }
    }
    return skillList;
  }

  Widget previewChips() {
    if (newSkillList.length > 0) {
      List<Widget> list = new List<Widget>();
      for (var i = 0; i < newSkillList.length; i++) {
        list.add(new ActionChip(
          label: Text(newSkillList[i]),
          avatar: Icon(Icons.close, size: 20.0),
          backgroundColor: Theme.of(context).chipTheme.backgroundColor,
          onPressed: () {
            // Remove from the new skill list.
            removePreviewSkill(newSkillList[i]);
          },
        ));
      }
      return new Wrap(
        children: list,
        spacing: 6,
      );
    }
    return new Container();
  }

  Widget getChipWidgets() {
    if (currentSkills.length > 0) {
      List<String> skillList = currentSkills;

      List<Widget> list = new List<Widget>();

      for (var i = 0; i < skillList.length; i++) {
        list.add(new ActionChip(
          label: Text(skillList[i]),
          onPressed: () {
            if (isEditing) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: new Text(LangLocalizations.of(context)
                          .trans('deleteSkillDialogTitle')),
                      content: new Text(LangLocalizations.of(context)
                              .trans('deleteSkillDialogBody') +
                          skillList[i] +
                          "?"),
                      actions: <Widget>[
                        new FlatButton(
                          child: Text(LangLocalizations.of(context)
                              .trans('deleteSkill')),
                          onPressed: () async {
                            updateSkillset(
                                removeFromSkills(skillList[i], currentSkills));
                            // Close prompt.
                            Navigator.of(context).pop();
                          },
                        ),
                        new FlatButton(
                          child: Text(
                              LangLocalizations.of(context).trans('close')),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  });
            }
          },
        ));
      }
      return new Wrap(
        children: list,
        spacing: 6,
      );
    }
    return new Container();
  }

  String createDatabaseString(
      List<String> currentSkills, List<String> newSkillList) {
    List<String> combinedList = new List.from(currentSkills)
      ..addAll(newSkillList);
    String databaseString = "";
    int counter = 1;
    // Put current skills in the string
    if (combinedList.length > 0) {
      combinedList.forEach((value) {
        if (counter != combinedList.length) {
          //add comma
          databaseString += value + ",";
        } else {
          databaseString += value;
        }
        counter++;
      });
    }
    return databaseString;
  }

  void removePreviewSkill(String skillName) {
    List<String> modifiedList = newSkillList;
    // Find the index of the skillname
    int index = modifiedList.indexOf(skillName);
    // Remove the value
    modifiedList.removeAt(index);
    newSkillList = modifiedList;
    setState(() {
      previewChips();
    });
  }

  String removeFromSkills(String skillName, List<String> currentSkillList) {
    List<String> modifiedList = currentSkillList;
    // Find the index of the skillname
    int index = modifiedList.indexOf(skillName);
    // Remove the value
    modifiedList.removeAt(index);
    currentSkills = modifiedList;
    return createDatabaseString(modifiedList, []);
  }

  Future<void> updateSkillset(String skillString) async {
    String _updateUrl =
        "https://teachrapp.nl/index.php/api/user/update_user_meta?cookie=" +
            CookieHelper.cookie.toString() +
            "&meta_key=skillset&meta_value=" +
            skillString;

    var res;
    try {
      res = await http.get(Uri.encodeFull(_updateUrl),
          headers: {"Accept": "application/json"});
      if (json.decode(res.body)['status'] == "error") {
        throw json.decode(res.body)['error'];
      }
      newSkillList = [];
    } catch (e) {
      return e;
    }
    readProfileData();
  }

  Future<void> readProfileData() async {
    String _readUrl =
        "https://teachrapp.nl/index.php/api/user/get_user_meta?cookie=" +
            CookieHelper.cookie.toString();

    String _firstname;
    String _lastname;
    String _description;
    String _skillset;

    try {
      var resp = await http.get(Uri.encodeFull(_readUrl),
          headers: {"Accept": "application/json"});
      var resultBody = json.decode(resp.body);

      if (resultBody['status'] == "error") {
        throw json.decode(resp.body)['error'];
      } else {
        _firstname = resultBody["firstname"].toString();
        _lastname = resultBody["lastname"].toString();
        _description = resultBody["description"].toString();
        _skillset = resultBody["skillset"];
        if (_firstname == "null") {
          _firstname = " ";
        }
        if (_lastname == "null") {
          _lastname = " ";
        }
        if (_description == "null") {
          _description = " ";
        }
        setProfileData(_firstname, _lastname, _description, _skillset);
        currentSkills = getSkillList();
      }
    } catch (e) {
      return e;
    }
  }

  setProfileData(
      String firstname, String lastname, String description, String skillset) {
    globals.currentUser.firstname = firstname;
    globals.currentUser.lastname = lastname;
    globals.currentUser.description = description;
    globals.currentUser.skillset = skillset;

    setState(() {
      firstnameController.text = firstname;
      lastnameController.text = lastname;
      descriptionController.text = description;
      // skillsetController.text = getSkillList().toString();
    });
  }
}

// TODO: generate cookie
// https://teachrapp.nl/index.php/api/user/generate_auth_cookie?email=carlodb@hotmail.com&password=Test1234
// get data with cookie
// https://teachrapp.nl/index.php/api/user/get_user_meta?cookie=COOKIE
// send data
// https://teachrapp.nl/index.php/api/user/update_user_meta?cookie=COOKIE&meta_key=META VELD UIT USER_META TABEL&meta_value=WAARDE
