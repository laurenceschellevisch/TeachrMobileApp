import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:teachr/Helpers/request_helper.dart';
import 'package:teachr/helpers/offers_helper.dart';
import 'package:teachr/helpers/snackbar_helper.dart';
import 'package:teachr/language/localizations.dart';
import 'package:teachr/offers/active_card.dart';
import 'package:teachr/offers/back_card.dart';
import 'package:teachr/offers/card_data.dart';
import 'package:teachr/globals.dart' as globals;
import 'package:teachr/models/card_model.dart';
import 'package:teachr/themes.dart';

class OffersPage extends StatefulWidget {
  final List<CardModel> list;
  final Text title;

  const OffersPage({this.list, this.title});

  @override
  _OffersPageState createState() =>
      new _OffersPageState(data: list, appBarTitle: title,);
}

class _OffersPageState extends State<OffersPage> with TickerProviderStateMixin {
  // variables
  static Color backgroundColor = Colors.white;
  Text appBarTitle;

  List<CardModel> data;

  AnimationController _buttonController;
  Animation<double> rotate;
  Animation<double> right;
  Animation<double> bottom;
  Animation<double> width;

  int flag = 0;
  int _dataLength;

  double _acceptButtonSize;
  double _saveButtonSize;
  double _declineButtonSize;
  double _initialBottom;
  double _backCardPosition;
  double _backCardWidth;
  double _footerButtonsWidth;
  double _footerButtonsHeight;

  bool _isSearchingForJobs = false;

  Widget buttonWidget;
  CardModel currentCardModel;
  Size screenSize;

  _OffersPageState({this.data, this.appBarTitle});

  acceptCard(CardModel cm) {
    if (globals.isLoggedIn) {
      OffersHelper.saveOfferStatus(
          offerStatus.accepted, cm.id.toString(), false);
    }
    setState(() {
      data.remove(cm);
    });
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 0.4;
    screenSize = MediaQuery.of(context).size;

    _acceptButtonSize = screenSize.height / 13;
    _saveButtonSize = screenSize.height / 20;
    _declineButtonSize = screenSize.height / 13;
    _initialBottom = 15.0;
    _dataLength = data.length;
    _backCardPosition = _initialBottom + (_dataLength - 1) * 10 + 10;
    _backCardWidth = screenSize.width / 90;
    _footerButtonsWidth = screenSize.width * 0.95;
    _footerButtonsHeight = screenSize.height / 10;

    return (new Scaffold(

      appBar: AppBar(
        textTheme: Theme.of(context).textTheme,
        centerTitle: true,
        title: Text("Available Offers",style:  TextStyle(
          fontFamily: "ReneBieder",color: Color(0xff8F00D2),
        ),),
        backgroundColor: Colors.white,


      ),
      body: new Container(
        height: screenSize.height,
        alignment: Alignment.center,
        child: _dataLength > 0
            ? new Stack(
                alignment: AlignmentDirectional.center,
                children: data.map((item) {
                  if (data.indexOf(item) == _dataLength - 1) {
                    currentCardModel = item;
                    return activeCard(
                        item,
                        bottom.value,
                        right.value,
                        0.0,
                        _backCardWidth + 10,
                        rotate.value,
                        rotate.value < -10 ? 0.1 : 0.0,
                        context,
                        declineCard,
                        flag,
                        acceptCard,
                        saveCard,
                        swipeRight,
                        swipeLeft);
                  } else {
                    _backCardPosition =
                        _backCardPosition - screenSize.height / 90;
                    _backCardWidth = _backCardWidth + screenSize.width / 50;

                    // if only 2 cards are left, set different width
                    if (_dataLength == 2) {
                      _backCardWidth = _backCardWidth - screenSize.width / 25;
                    }

                    return backCard(
                        item,
                        _backCardPosition,
                        0.0,
                        0.0,
                        _backCardWidth,
                        0.0,
                        0.0,
                        context,
                        swipeRight,
                        swipeLeft,
                        data);
                  }
                }).toList())
            : _searchForNewJobsWidget(),
      ),
      persistentFooterButtons: <Widget>[
        Container(
          height: _footerButtonsHeight,
          width: _footerButtonsWidth,
          //color: Colors.red,
          alignment: Alignment.topCenter,
          child: _footerButtons(),
        )
        // ),
      ],
    ));
  }

  declineCard(CardModel cm) {
    if (globals.isLoggedIn) {
      OffersHelper.saveOfferStatus(
          offerStatus.declined, cm.id.toString(), false);
    }
    setState(() {
      data.remove(cm);
    });
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  void initState() {
    super.initState();

    if (RequestHelper.user == null && availableOffers.length == 0) {
      _updateCardList();
    }

    _buttonController = new AnimationController(
        duration: new Duration(milliseconds: 1000), vsync: this);

    rotate = new Tween<double>(
      begin: -0.0,
      end: -40.0,
    ).animate(
      new CurvedAnimation(
        parent: _buttonController,
        curve: Curves.ease,
      ),
    );
    rotate.addListener(() {
      setState(() {
        if (rotate.isCompleted) {
          var i = data.removeLast();
          data.insert(0, i);

          _buttonController.reset();
        }
      });
    });

    right = new Tween<double>(
      begin: 0.0,
      end: 400.0,
    ).animate(
      new CurvedAnimation(
        parent: _buttonController,
        curve: Curves.ease,
      ),
    );
    bottom = new Tween<double>(
      begin: 15.0,
      end: 100.0,
    ).animate(
      new CurvedAnimation(
        parent: _buttonController,
        curve: Curves.ease,
      ),
    );
    width = new Tween<double>(
      begin: 20.0,
      end: 25.0,
    ).animate(
      new CurvedAnimation(
        parent: _buttonController,
        curve: Curves.bounceOut,
      ),
    );
  }

  saveCard(CardModel cm) {
    if (globals.isLoggedIn) {
      OffersHelper.saveOfferStatus(offerStatus.saved, cm.id.toString(), false);
      savedOffers.add(cm);
    }

    setState(() {
      data.remove(cm);
    });
  }

  swipeLeft(CardModel cm) {
    if (flag == 1)
      setState(() {
        flag = 0;
      });
    _swipeAnimation(cm, buttonType.decline);
  }

  swipeRight(CardModel cm) {
    if (flag == 0)
      setState(() {
        flag = 1;
      });
    _swipeAnimation(cm, buttonType.accept);
  }

  /// Build action buttons.
  RawMaterialButton _buildButton(IconData icon, Color iconColor,
      Color buttonColor, double buttonSize, buttonType type, CardModel card) {
    return new RawMaterialButton(
        onPressed: () {
          switch (type) {
            case buttonType.accept:
              {
                if (globals.isLoggedIn) {
                  swipeRight(card);
                } else {
                  Scaffold.of(context).showSnackBar(SnackBarHelper.snackbarText(
                      Text(LangLocalizations.of(context)
                          .trans('login to accept this offer'))));
                }
              }
              break;

            case buttonType.decline:
              {
                if (globals.isLoggedIn) {
                  swipeLeft(card);
                } else {
                  Scaffold.of(context).showSnackBar(SnackBarHelper.snackbarText(
                      Text(LangLocalizations.of(context)
                          .trans('login to decline this offer'))));
                }
              }
              break;

            case buttonType.save:
              {
                if (globals.isLoggedIn) {
                  Scaffold.of(context).showSnackBar(SnackBarHelper.snackbarText(
                      Text(
                          LangLocalizations.of(context).trans('offer saved'))));
                  saveCard(card);
                } else {
                  Scaffold.of(context).showSnackBar(SnackBarHelper.snackbarText(
                      Text(LangLocalizations.of(context)
                          .trans('login to save this offer'))));
                }
              }
              break;
          }
        },
        child: new Icon(
          icon,
          color: iconColor,
          size: buttonSize,
        ),
        shape: new CircleBorder(),
        elevation: 2.0,
        fillColor: buttonColor,
        padding: const EdgeInsets.only(bottom: 10, top: 10));
  }

  /// Method for returning buttons depending on active view and list length (Saved offers view won't have the save button).
  Widget _footerButtons() {
    Widget returnWidget;

    if (availableOffers.length > 0) {
      returnWidget = Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildButton(Icons.clear, Colors.red, Colors.white,
              _declineButtonSize, buttonType.decline, this.currentCardModel),
          _buildButton(Icons.playlist_add, Colors.grey, Colors.white,
              _saveButtonSize, buttonType.save, this.currentCardModel),
          _buildButton(Icons.check, Colors.green, Colors.white,
              _acceptButtonSize, buttonType.accept, this.currentCardModel),
        ],
      );
    } else {
      returnWidget = null;
    }

    return returnWidget;
  }

  /// Widget for searching new available jobs
  Widget _searchForNewJobsWidget() {
    if (_isSearchingForJobs) {
      return CircularProgressIndicator();
    }

    return new RefreshIndicator(
        onRefresh: _updateCardList,
        child: ListView(
          children: <Widget>[
            Center(
              child: Container(
                padding: const EdgeInsets.all(75),
                height: screenSize.height / 2,
                child: FlatButton(
                  onPressed: _updateCardList,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.refresh,
                        size: 100,
                      ),
                      new Text(LangLocalizations.of(context)
                          .trans('search for new offers')),
                    ],
                  ),
                ),
                alignment: Alignment(0.0, 0.0),
              ),
            )
          ],
        ));
  }

  Future<Null> _swipeAnimation(CardModel card, buttonType type) async {
    try {
      await _buttonController.forward();
      switch (type) {
        case buttonType.accept:
          {
            await acceptCard(card);
          }
          break;

        case buttonType.decline:
          {
            await declineCard(card);
          }
          break;

        case buttonType.save:
          {
            await saveCard(card);
          }
          break;
      }
    } on TickerCanceled {}
  }

  /// Update card list method.
  Future<void> _updateCardList() async {
    setState(() {
      _isSearchingForJobs = true;
    });

    OffersHelper.cardsAdded = 0;

    OffersHelper.userOffers().then((result) {
      OffersHelper.getCards().then((value) {
        setState(() {
          _isSearchingForJobs = false;
        });
      });
    });
  }
}
