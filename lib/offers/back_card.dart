import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:teachr/language/localizations.dart';
import 'package:teachr/models/card_model.dart';

Positioned backCard(
    CardModel card,
    double bottom,
    double right,
    double left,
    double cardWidth,
    double rotation,
    double skew,
    BuildContext context,
    Function swipeRight,
    Function swipeLeft,
    List<CardModel> list) {
  // variables
  Size screenSize = MediaQuery.of(context).size;
  double _cardElevation = 4.0;
  double _cardWidth = screenSize.width - (list.length * 15) + cardWidth;
  double _cardHeight = screenSize.height / 1.6;
  double _cardImageHeight = screenSize.height / 2;
  double _constrainedMinHeight = screenSize.height / 25;
  double _constrainedMaxHeight = screenSize.height / 15;

  return new Positioned(
    bottom: bottom,
    child: new Card(
      color: Colors.transparent,
      elevation: _cardElevation,
      child: new Container(
        alignment: Alignment.center,
        width: _cardWidth,
        height: _cardHeight,
        decoration: new BoxDecoration(
          color: new Color.fromRGBO(255, 255, 255, 1.0),
          borderRadius: new BorderRadius.circular(8.0),
        ),
        child: new Column(
          children: <Widget>[
            new Container(
                height: _cardImageHeight,
                decoration: new BoxDecoration(
                  borderRadius: new BorderRadius.only(
                    topLeft: new Radius.circular(8.0),
                    topRight: new Radius.circular(8.0),
                  ),
                  image: card.schoolImage,
                ),
                child: new Stack(
                  alignment: AlignmentDirectional.topCenter,
                  children: <Widget>[
                    new Positioned(
                      bottom: 5.0,
                      left: 10.0,
                      child: Opacity(
                        opacity: 0.9,
                        child: Chip(
                          avatar: Icon(Icons.location_on, color: Colors.grey),
                          label: Text(card.distance,
                              style: TextStyle(color: Colors.grey)),
                          backgroundColor: Color.fromRGBO(250, 250, 250, 1.0),
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
                          avatar: Icon(Icons.euro_symbol, color: Colors.grey),
                          label: Text(card.salary + " " + LangLocalizations.of(context).trans('per lecture'),
                              style: TextStyle(color: Colors.grey)),
                          backgroundColor: Color.fromRGBO(250, 250, 250, 1.0),
                        ),
                      ),
                    ),
                  ],
                )),
            new Container(
                //height: screenSize.height / 10,
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
                                fontSize: 25.0, fontWeight: FontWeight.bold))),
                    ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: screenSize.width,
                          maxWidth: screenSize.width,
                          minHeight: _constrainedMinHeight,
                          maxHeight: _constrainedMaxHeight,
                        ),
                        child: AutoSizeText(card.schoolName,
                            style: TextStyle(fontSize: 15.0)))
                  ],
                )),
          ],
        ),
      ),
    ),
  );
}