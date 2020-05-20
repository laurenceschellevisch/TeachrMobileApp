import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:teachr/helpers/request_helper.dart';
import 'package:teachr/globals.dart' as globals;
import 'package:teachr/helpers/cookie_helper.dart';
import 'package:teachr/helpers/offers_helper.dart';
import 'package:teachr/helpers/storage_helper.dart' as StorageHelper;
import 'package:teachr/language/Localizations.dart' as prefix0;
import 'package:teachr/language/localizations.dart';
import 'package:teachr/models/user_model.dart';
import 'package:teachr/themes.dart';
import 'package:teachr/utils/bubble_indication_painter.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key key}) : super(key: key);

  @override
  LoginPageState createState() => new LoginPageState();
}

class LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final FocusNode myFocusNodeEmailLogin = FocusNode();
  final FocusNode myFocusNodePasswordLogin = FocusNode();

  final FocusNode myFocusNodePassword = FocusNode();
  final FocusNode myFocusNodeEmail = FocusNode();
  final FocusNode myFocusNodeName = FocusNode();

  TextEditingController loginEmailController = new TextEditingController();
  TextEditingController loginPasswordController = new TextEditingController();

  bool _obscureTextLogin = true;
  bool _obscureTextSignup = true;
  bool _obscureTextSignupConfirm = true;

  TextEditingController signupEmailController = new TextEditingController();
  TextEditingController signupNameController = new TextEditingController();
  TextEditingController signupPasswordController = new TextEditingController();
  TextEditingController signupConfirmPasswordController =
      new TextEditingController();

  PageController _pageController;

  Color left = Colors.black;
  Color right = Colors.white;
  bool _isLoginRemembered = false;

  @override
  initState() {
    super.initState();
    _pageController = PageController();

    _getRememberLogin();
    _readStoredCredentials();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoginRemembered) {
      // build(context);
      loginUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(LangLocalizations.of(context).trans('login'),style: TextStyle(
          fontFamily: "ReneBieder",color: Color(0xff8F00D2),
        ),),
        leading: Container(),
      ),
      key: _scaffoldKey,
      body: ListView(
        children: <Widget> [
    NotificationListener<OverscrollIndicatorNotification>(
    onNotification: (overscroll) {
      overscroll.disallowGlow();
    },
          child: Container(
            color: TeachrColors.teachrBlue,
            width: MediaQuery.of(context).size.width,
             height: MediaQuery.of(context).size.height+150,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(56, 8, 56, 0),
                  child: new Image(
                      fit: BoxFit.fitWidth,
                      image: new AssetImage('assets/img/icon.png')),
                ),
                Padding(
                  padding: EdgeInsets.zero,
                  child: _buildMenuBar(context),
                ),
                Expanded(
                  flex: 2,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (i) {
                      if (i == 0) {
                        setState(() {
                          right = Colors.white;
                          left = Colors.black;
                        });
                      } else if (i == 1) {
                        setState(() {
                          right = Colors.black;
                          left = Colors.white;
                        });
                      }
                    },
                    children: <Widget>[
                      new ConstrainedBox(
                        constraints: const BoxConstraints.expand(),
                        child: _buildSignIn(context),
                      ),
                      new ConstrainedBox(
                        constraints: const BoxConstraints.expand(),
                        child: _buildSignUp(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),]
      ),
    );
  }

  // @override
  // void dispose() {
  //   myFocusNodePassword.dispose();
  //   myFocusNodeEmail.dispose();
  //   myFocusNodeName.dispose();
  //   _pageController?.dispose();
  //   super.dispose();
  // }

  /// Logs in the user by sending [loginloginEmailController.text] and [loginPasswordController.text] values over [apiUrl]

  Future<String> loginUser() async {
    String apiUrl =
        "https://teachrapp.nl/index.php/api/user/generate_auth_cookie?&username=" +
            loginEmailController.text +
            "&password=" +
            loginPasswordController.text;

    var res = await http
        .get(Uri.encodeFull(apiUrl), headers: {"Accept": "application/json"});

    try {
      setState(() {
        var resBody = json.decode(res.body);
        CookieHelper.cookie = resBody['cookie'];
        print(resBody);

        if (resBody
            .toString()
            .contains("You must include 'username'")) {
          showInSnackBar(
              LangLocalizations.of(context).trans('invalid login details'));
        } else if (resBody
            .toString()
            .contains("Your account is awaiting e-mail verification.")) {
          showInSnackBar(LangLocalizations.of(context).trans('verify email'));
        }

        if (resBody['status'] == "ok") {
          // RequestHelper.setUser().then((result) {
          //   OffersHelper.clearLists();
          //   OffersHelper.userOffers().then((result) {
          //     setState(() {
          //       OffersHelper.getCards();
          //     });
          //   });
          //   setState(() {});
          // });

          globals.userData = resBody;
          var user = new User(
              resBody['user']['id'],
              1, // TODO: USERROLE in database
              resBody['user']['email'],
              "",
              "",
              "",
              "",
              resBody['user']['avatar']);

          globals.currentUser = user;
          globals.isLoggedIn = true;

          StorageHelper.setSharedPref('isLoggedIn', true);

          /// Determine the page to redirect to.
          if (globals.currentTabIndex != null) {
            if (globals.currentTabIndex == 0) {
              Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
              // TODO: Als een vacature is geswiped naar die pagina.
            } else if (globals.currentTabIndex == 2) {
              //Chat page
              // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => ChatOverview(loggedInUser.id)), (Route<dynamic> route) => false);
              Navigator.pushNamedAndRemoveUntil(context, '/chat', (_) => false);
            }
          }
        }
      });
    } catch (e) {
      showInSnackBar(LangLocalizations.of(context).trans('login exception'));
      return e;
    }
    return "Success!";
  }

  Future<void> registerUser() async {
    String result = await getNonce();
    String registerResult;
    if (result != '600') {
      registerResult = await (registerAPI(json.decode(result)['nonce']));
      switch (registerResult) {
        case 'ok':
          {
            _onSignInButtonPress();
            emptyFields();
            showInSnackBar("Verificatie e-mail is verzonden!");
          }
          break;
        case 'Username already exists.':
          showInSnackBar('Gebruikersnaam is al in gebruik');
          break;
        case 'E-mail address is already in use.':
          showInSnackBar('E-mail adres is al in gebruik');
          break;
        case 'Passwords do not match.':
          showInSnackBar('Wachtwoorden komen niet overeen');
          break;
        default:
      }
    } else {
      showInSnackBar('Er is iets fout gegaan, probeer het later nog eens');
    }
  }

  Future<String> registerAPI(String nonce) async {
    String username = signupEmailController.text;
    String email = signupEmailController.text;
    String password = signupPasswordController.text;
    String passwordVerify = signupConfirmPasswordController.text;

    // Check password strength.
    // Password needs to have at least 1 small letter, 1 capital letter, 1 number and has to be at least 8 characters long.
    RegExp regex = new RegExp("^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}");

    String registerUrl =
        "https://teachrapp.nl/index.php/api/user/register?email=" +
            email +
            "&user_pass=" +
            password +
            "&nonce=" +
            nonce +
            "&display_name=" +
            username +
            "&username=" +
            username;
    var res;
    if (regex.hasMatch(password)) {
      if (password == passwordVerify) {
        try {
          res = await http.get(Uri.encodeFull(registerUrl),
              headers: {"Accept": "application/json"});
          if (json.decode(res.body)['status'] == "error") {
            throw json.decode(res.body)['error'];
          }
        } catch (e) {
          return e;
        }
      } else {
        showInSnackBar(
            LangLocalizations.of(context).trans('password no match'));
        return null;
      }
    } else {
      showInSnackBar(LangLocalizations.of(context).trans('password weak'));
      return null;
    }

    return json.decode(res.body)['status'];
  }

  Future<String> getNonce() async {
    String nonceUrl =
        "https://teachrapp.nl/index.php/api/get_nonce/?json=get_nonce&controller=user&method=register";
    var res;
    try {
      res = await http.get(Uri.encodeFull(nonceUrl),
          headers: {"Accept": "application/json"});
      if (json.decode(res.body)['status'] == "error") {
        throw new Error();
      }
    } catch (e) {
      return "600";
    }
    return res.body;
  }

  void emptyFields() {
    signupNameController.text = '';
    signupEmailController.text = '';
    signupPasswordController.text = '';
    signupConfirmPasswordController.text = '';
  }

  void showInSnackBar(String value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white, fontSize: 16.0, fontFamily: "RedHatDisplay"),
      ),
      backgroundColor: Colors.grey[850],
      duration: Duration(seconds: 3),
    ));
  }

  Widget _buildMenuBar(BuildContext context) {
    return Container(
      width: 300.0,
      height: 50.0,

      decoration: BoxDecoration(
        color: Color(0x552B2B2B),
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
      child: CustomPaint(
        painter: TabIndicationPainter(pageController: _pageController),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: _onSignInButtonPress,
                child: Text(
                  "Existing",
                  style: TextStyle(
                      color: left, fontSize: 16.0, fontFamily: "RedHatDisplay"),
                ),
              ),
            ),
            //Container(height: 33.0, width: 1.0, color: Colors.white),
            Expanded(
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: _onSignUpButtonPress,
                child: Text(
                  "New",
                  style: TextStyle(
                      color: right, fontSize: 16.0, fontFamily: "RedHatDisplay"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignIn(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 12.0),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            overflow: Overflow.visible,
            children: <Widget>[
//              Card(
//                elevation: 2.0,
//                color: Colors.white,
//                shape: RoundedRectangleBorder(
//                  borderRadius: BorderRadius.circular(8.0),
//                ),
//                child:
                  Container(
                  width: 300.0,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: myFocusNodeEmailLogin,
                          controller: loginEmailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                              fontFamily: "RedHatDisplay",
                              fontSize: 16.0,
                              color: Colors.white),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.mail_outline,
                              color: Colors.white,
                              size: 22.0,
                            ),
                            hintText: "Email Address",
                            hintStyle:
                                TextStyle(fontFamily: "RedHatDisplay", fontSize: 17.0,color: Colors.white,),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: myFocusNodePasswordLogin,
                          controller: loginPasswordController,
                          obscureText: _obscureTextLogin,
                          style: TextStyle(
                              fontFamily: "RedHatDisplay",
                              fontSize: 16.0,
                              color: Colors.white),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.lock,
                              size: 22.0,
                              color: Colors.white,
                            ),
                            hintText: "Password",
                            hintStyle:
                                TextStyle(fontFamily: "RedHatDisplay", fontSize: 17.0,color: Colors.white,),
                            suffixIcon: GestureDetector(
                              onTap: _toggleLogin,
                              child: Icon(
                                Icons.visibility,
                                size: 15.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: Row(
                          children: <Widget>[
                            Text(LangLocalizations.of(context)
                                .trans('rememberLogin'),style: TextStyle(
                              fontFamily: "RedHatDisplay",
                              color: Colors.white,

                            ),),
                            // BUG: The first click on the switch is unresponsive. Unknown cause.
                            Switch(
                                value: _isLoginRemembered,
                                onChanged: (bool _value) {
                                  if (_value) {
                                    _setRememberLogin(true);
                                  } else {
                                    _setRememberLogin(false);
                                  }
                                })
                          ],
                        ),
                      ),

                    ],
                  ),
                ),
//              ),
              Container(
                margin: EdgeInsets.only(top: 260.0),
                decoration: new BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(64.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Color(0xffFFF200),
                      offset: Offset(1.0, 6.0),
                      blurRadius: 20.0,
                    ),
                    BoxShadow(
                      color: TeachrColors.loginGradientEnd,
                      offset: Offset(1.0, 6.0),
                      blurRadius: 20.0,
                    ),
                  ],
                  gradient: new LinearGradient(
                      colors: [
                      Color(0xffFFF200),
                        Color(0xffFFF200)
                      ],
                      begin: const FractionalOffset(0.2, 0.2),
                      end: const FractionalOffset(1.0, 1.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
                child: MaterialButton(
                    highlightColor: Colors.transparent,
                    splashColor: TeachrColors.loginGradientEnd,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 42.0),
                      child: Text(
                        LangLocalizations.of(context)
                            .trans('login')
                            .toUpperCase(),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 25.0,
                          fontFamily: "RedHatDisplay",
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    onPressed: () async {
                      if (_isLoginRemembered == true) {
                        StorageHelper.storeKeyValue(
                            'email', loginEmailController.text);

                        StorageHelper.storeKeyValue(
                            'password', loginPasswordController.text);
                      }
                      setState(() {
                        loginUser();
                      });
                    }),
              ),
            ],
          ),
          //TODO: Implement 'Forgot Password'
           Padding(
             padding: EdgeInsets.only(top: 10.0),
             child: FlatButton(
               onPressed: _launchURL,
               child: Text(
                 "Forgot Password?",
                 style: TextStyle(
                     decoration: TextDecoration.underline,
                     color: Colors.white,
                     fontSize: 16.0,
                     fontFamily: "RedHatDisplay"),
               ),
             ),
           ),
        ],
      ),
    );
  }

  Widget _buildSignUp(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 23.0),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            overflow: Overflow.visible,
            children: <Widget>[
//              Card(
//                elevation: 2.0,
//                color: Colors.white,
//                shape: RoundedRectangleBorder(
//                  borderRadius: BorderRadius.circular(8.0),
//                ),
//                child:
                Container(
                  width: 300.0,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: myFocusNodeEmail,
                          controller: signupEmailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                              fontFamily: "RedHatDisplay",
                              fontSize: 16.0,
                              color: Colors.white),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.mail_outline,
                              color: Colors.white,
                            ),
                            hintText: "Email Address",
                            hintStyle:
                                TextStyle(fontFamily: "RedHatDisplay", fontSize: 16.0, color: Colors.white),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: myFocusNodePassword,
                          controller: signupPasswordController,
                          obscureText: _obscureTextSignup,
                          style: TextStyle(
                              fontFamily: "RedHatDisplay",
                              fontSize: 16.0,
                              color: Colors.white),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.lock,
                              color: Colors.white,
                            ),
                            hintText: "Password",
                            hintStyle:
                                TextStyle(fontFamily: "RedHatDisplay", fontSize: 16.0,color: Colors.white),
                            suffixIcon: GestureDetector(
                              onTap: _toggleSignup,
                              child: Icon(
                                Icons.visibility,
                                size: 15.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          controller: signupConfirmPasswordController,
                          obscureText: _obscureTextSignupConfirm,
                          style: TextStyle(
                              fontFamily: "RedHatDisplay",
                              fontSize: 16.0,
                              color: Colors.white),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.lock,
                              color: Colors.white,
                            ),
                            hintText: "Confirmation",
                            hintStyle:
                                TextStyle(fontFamily: "RedHatDisplay", fontSize: 16.0, color: Colors.white),
                            suffixIcon: GestureDetector(
                              onTap: _toggleSignupConfirm,
                              child: Icon(
                                Icons.visibility,
                                size: 15.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
//              ),
              Container(
                margin: EdgeInsets.only(top: 260.0),
                decoration: new BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(64.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Color(0xffFFF200),
                      offset: Offset(1.0, 6.0),
                      blurRadius: 20.0,
                    ),
                    BoxShadow(
                      color: TeachrColors.loginGradientEnd,
                      offset: Offset(1.0, 6.0),
                      blurRadius: 20.0,
                    ),
                  ],
                  gradient: new LinearGradient(
                      colors: [
                      Color(0xffFFF200),
                        Color(0xffFFF200)
                      ],
                      begin: const FractionalOffset(0.2, 0.2),
                      end: const FractionalOffset(1.0, 1.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
                child: MaterialButton(
                    highlightColor: Colors.transparent,
                    splashColor: TeachrColors.loginGradientEnd,
                    //shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 42.0),
                      child: Text(
                        "SIGN UP",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 25.0,
                            fontFamily: "RedHatDisplay",
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    onPressed: registerUser),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _readStoredCredentials() async {
    String _email = await StorageHelper.readValue('email');
    String _password = await StorageHelper.readValue('password');

    return [
      loginEmailController.text = _email,
      loginPasswordController.text = _password
    ];
  }

  _getRememberLogin() async {
    bool _storedValue =
        await StorageHelper.readSharedPref('rememberLogin') ?? false;
    setState(() {
      _isLoginRemembered = _storedValue;
    });
  }

  _setRememberLogin(bool rememberLogin) async {
    setState(() {
      _isLoginRemembered = rememberLogin;
    });
    StorageHelper.setSharedPref('rememberLogin', rememberLogin);
  }

  void _onSignInButtonPress() {
    _pageController.animateToPage(0,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _onSignUpButtonPress() {
    _pageController?.animateToPage(1,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _toggleLogin() {
    setState(() {
      _obscureTextLogin = !_obscureTextLogin;
    });
  }

  void _toggleSignup() {
    setState(() {
      _obscureTextSignup = !_obscureTextSignup;
    });
  }

  void _toggleSignupConfirm() {
    setState(() {
      _obscureTextSignupConfirm = !_obscureTextSignupConfirm;
    });
  }
  _launchURL() async {
    const url = 'https://teachrapp.nl/index.php/password-reset/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
