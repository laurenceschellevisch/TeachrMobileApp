import 'dart:math';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:teachr/animations.dart';
import 'package:teachr/globals.dart' as globals;
import 'package:teachr/helpers/offers_helper.dart';
import 'package:teachr/helpers/snackbar_helper.dart';
import 'package:teachr/language/localizations.dart';
import 'package:teachr/models/card_model.dart';
import 'package:teachr/offers/card_detail.dart';

enum buttonType { accept, decline, save }

Positioned activeCard(
    CardModel card,
    double bottom,
    double right,
    double left,
    double cardWidth,
    double rotation,
    double skew,
    BuildContext context,
    Function dismissCard,
    int flag,
    Function addCard,
    Function maybeCard,
    Function swipeRight,
    Function swipeLeft) {
  // variables
  Size screenSize = MediaQuery.of(context).size;
  double _crossAxisEndOffset =  -0.3;
  double _cardWidth = screenSize.width - 20;
  double _cardHeight= screenSize.height / 1.6;
  double _cardElevation = 4.0;
  double _cardImageHeigth = screenSize.height / 2.0;
  double _constrainedMinHeight = screenSize.height / 25;
  double _constrainedMaxHeight = screenSize.height / 15;

  DecorationImage check = new DecorationImage(
    image: AssetImage('assets/img/check.png'),
    colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.5), BlendMode.dstIn),
    fit: BoxFit.cover,
  );

  DecorationImage decline = new DecorationImage(
    image: AssetImage('assets/img/decline.png'),
    colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.5), BlendMode.dstIn),
    fit: BoxFit.cover,
  );

  DecorationImage save = new DecorationImage(
    image: AssetImage('assets/img/save.png'),
    colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.8), BlendMode.dstIn),
    fit: BoxFit.cover,
  );

  return new Positioned(
      bottom: bottom,
      right: flag == 0 ? right != 0.0 ? right : null : null,
      left: flag == 1 ? right != 0.0 ? right : null : null,
      child: new Column(
        children: <Widget>[
          new Dismissible(
              key: new Key(new Random().toString()),
              direction: DismissDirection.up,
              background: Container(
                  decoration: new BoxDecoration(
                image: save,
              )
                  ),
              onDismissed: (DismissDirection direction) {
                maybeCard(card);

                if (!globals.isLoggedIn && OffersHelper.isFirstSave) {
                  OffersHelper.isFirstSave = false;

                  Scaffold.of(context).showSnackBar(SnackBarHelper.snackbarText(
                      Text(LangLocalizations.of(context)
                          .trans('login to save this offer'))));
                }
              },
              child: new Dismissible(
                key: new Key(new Random().toString()),
                crossAxisEndOffset: _crossAxisEndOffset,
                background: Container(
                    decoration: new BoxDecoration(
                  image: check,
                )),
                secondaryBackground: Container(
                    decoration: new BoxDecoration(
                  image: decline,
                )),
                onDismissed: (DismissDirection direction) {
                  if (direction == DismissDirection.endToStart) {
                    dismissCard(card);

                    if (!globals.isLoggedIn && OffersHelper.isFirstDecline) {
                      OffersHelper.isFirstDecline = false;

                      Scaffold.of(context).showSnackBar(
                          SnackBarHelper.snackbarText(Text(
                              LangLocalizations.of(context)
                                  .trans('login to decline this offer'))));
                    }
                  } else if (direction == DismissDirection.startToEnd) {
                    addCard(card);

                    if (!globals.isLoggedIn && OffersHelper.isFirstAccept) {
                      OffersHelper.isFirstAccept = false;

                      Scaffold.of(context).showSnackBar(
                          SnackBarHelper.snackbarText(Text(
                              LangLocalizations.of(context)
                                  .trans('login to accept this offer'))));
                    }
                  }
                },
                child: new Transform(
                  alignment:
                      flag == 0 ? Alignment.bottomRight : Alignment.bottomLeft,
                  transform: new Matrix4.skewX(skew),
                  child: new RotationTransition(
                    turns: new AlwaysStoppedAnimation(
                        flag == 0 ? rotation / 360 : -rotation / 360),
                    child: new Hero(
                      tag: "img",
                      child: new GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            new MyCustomRoute(
                                builder: (context) => new DetailPage(type: card, savedOffersPage: false)),           
                          );
                        },
                        child: new Card(
                          color: Colors.transparent,
                          elevation: _cardElevation,
                          child: new Container(
                            alignment: Alignment.center,
                            width: _cardWidth,
                            height: _cardHeight,
                            decoration: new BoxDecoration(
                              color: new Color.fromRGBO(255, 255, 255, 1.0),
                              borderRadius:
                                  new BorderRadius.all(new Radius.circular(8)),
                            ),
                            child: new Column(
                              children: <Widget>[
                                new Container(
                                    height: _cardImageHeigth,
                                    decoration: new BoxDecoration(
                                      borderRadius: new BorderRadius.only(
                                        topLeft: new Radius.circular(8.0),
                                        topRight: new Radius.circular(8.0),
                                      ),
                                      image: card.schoolImage,
                                    ),
                                    child: new Stack(
                                      alignment:
                                          AlignmentDirectional.bottomCenter,
                                      children: <Widget>[
                                        new Positioned(
                                          bottom: 5.0,
                                          left: 10.0,
                                          child: Opacity(
                                            opacity: 0.9,
                                            child: Chip(
                                              avatar: Icon(Icons.location_on,
                                                  color: Colors.grey),
                                              label: Text(
                                                  card.distance.toString(),
                                                  style: TextStyle(
                                                      color: Colors.grey)),
                                              backgroundColor: Color.fromRGBO(
                                                  250, 250, 250, 1.0),
                                            ),
                                          ),
                                        ),
                                        new Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: new Icon(
                                            Icons.keyboard_arrow_down,
                                            color: Colors.white,
                                            size: 50,
                                          ),
                                        ),
                                        new Positioned(
                                          right: 10.0,
                                          bottom: 5.0,
                                          child: Opacity(
                                            opacity: 0.9,
                                            child: Chip(
                                              avatar: Icon(Icons.euro_symbol,
                                                  color: Colors.grey),
                                              label: Text(
                                                  card.salary +
                                                      " " +
                                                      LangLocalizations.of(
                                                              context)
                                                          .trans('per lecture'),
                                                  style: TextStyle(
                                                      color: Colors.grey)),
                                              backgroundColor: Color.fromRGBO(
                                                  250, 250, 250, 1.0),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                                new Container(
                                    margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      children: <Widget>[
                                        ConstrainedBox(
                                            constraints: BoxConstraints(
                                              minWidth: screenSize.width,
                                              maxWidth: screenSize.width,
                                              minHeight: _constrainedMinHeight,
                                              maxHeight: _constrainedMaxHeight,
                                            ),
                                            child: AutoSizeText(card.jobTitle,
                                                style: TextStyle(
                                                    fontSize: 25.0,
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        ConstrainedBox(
                                            constraints: BoxConstraints(
                                              minWidth: screenSize.width,
                                              maxWidth: screenSize.width,
                                              minHeight: _constrainedMinHeight,
                                              maxHeight: _constrainedMaxHeight,
                                            ),
                                            child: AutoSizeText(card.schoolName,
                                                style:
                                                    TextStyle(fontSize: 15.0)))
                                      ],
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ));
}

