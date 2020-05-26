import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:teachr/animations.dart';
import 'package:teachr/helpers/offers_helper.dart';
import 'package:teachr/language/localizations.dart';
import 'package:teachr/models/card_model.dart';
import 'package:teachr/offers/card_data.dart';
import 'package:teachr/offers/card_detail.dart';
import 'package:teachr/themes.dart';

class SavedOffersPage extends StatefulWidget {
  final Text title;

  const SavedOffersPage({this.title});

  @override
  SavedOffersPageState createState() => new SavedOffersPageState(appBarTitle: title);
      
}

class SavedOffersPageState extends State<SavedOffersPage> with TickerProviderStateMixin {
  final Text appBarTitle;
  Size screenSize;
  
  double _heightFactor; 
  double _cardHeight;
  double _cardTextHeight;
  double _cardListHeight;
  double _constrainedMinHeight;
  double _constrainedMaxHeight;

  List<Slidable> list = new List<Slidable>();

  SavedOffersPageState({this.appBarTitle});

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    screenSize = MediaQuery.of(context).size;
    _heightFactor = screenSize.height / 25;
    _cardHeight = screenSize.height / 4.5;
    _cardTextHeight = screenSize.height / 15;
    _cardListHeight = screenSize.height / 6.5;
    _constrainedMaxHeight = screenSize.height / 25;
    _constrainedMinHeight = screenSize.height / 50;

    return (new Scaffold(

        appBar: AppBar(
          textTheme: Theme.of(context).textTheme,
          centerTitle: true,
          title: Text("Saved Offers",style:  TextStyle(
            fontFamily: "ReneBieder",color: Color(0xff8F00D2),
          ),),
          backgroundColor: Colors.white,
        ),
        body: new Container(
            height: screenSize.height,
            alignment: Alignment.center,
            child: savedOffers.length > 0
                ? ListView(children: _getBuildList(), key: new ObjectKey(new Random().toString()))
                : new Center(child: Text(LangLocalizations.of(context).trans('no saved offers')),  
                    heightFactor: _heightFactor
                  ))));
  }

  /// Method for filling list with save card widgets
  List<Widget> _getBuildList() {
    list.clear();
    for (var i = 0; i < savedOffers.length; i++) {
      list.add(_getSavedCard(savedOffers[i], i));
    }

    return list;
  }

  /// Method for creating small cards for saved offers
  Widget _getSavedCard(CardModel offer, int index) {
    return new Slidable(
      key: new ObjectKey(new Random().toString()),
      direction: Axis.horizontal,
      delegate: new SlidableDrawerDelegate(),
      actionExtentRatio: 1,
      child: new GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              new MyCustomRoute(
                  builder: (context) => new DetailPage(
                        type: offer,
                        savedOffersPage: true,
                      )),
            );
          },
          child: new Card(
            color: Colors.transparent,
            elevation: 4.0,
            child: new Container(
              alignment: Alignment.center,
              width: screenSize.width,
              height: _cardHeight,
              decoration: new BoxDecoration(
                  color: new Color.fromRGBO(255, 255, 255, 1.0),
                  borderRadius: new BorderRadius.all(new Radius.circular(8.0))),
              child: new Column(
                children: <Widget>[
                  // image
                  new Container(
                      width: screenSize.width,
                      height: _cardListHeight,
                      decoration: new BoxDecoration(
                        borderRadius: new BorderRadius.only(
                          topLeft: new Radius.circular(8.0),
                          topRight: new Radius.circular(8.0),
                        ),
                        image: offer.schoolImage,
                      ),
                      child: new Stack(
                        alignment: AlignmentDirectional.bottomCenter,
                        children: <Widget>[
                          new Positioned(
                            left: 10.0,
                            child: Opacity(
                              opacity: 0.9,
                              child: Chip(
                                avatar:
                                    Icon(Icons.location_on, color: Color(0xffFFF200)),
                                label: Text(offer.distance,
                                    style: TextStyle(color: Colors.grey)),
                                backgroundColor:
                                    Color.fromRGBO(250, 250, 250, 1.0),
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
                            child: Opacity(
                              opacity: 0.9,
                              child: Chip(
                                avatar:
                                    Icon(Icons.euro_symbol, color: Color(0xffFFF200)),
                                label: Text(offer.salary,
                                    style: TextStyle(color: Colors.grey)),
                                backgroundColor:
                                    Color.fromRGBO(250, 250, 250, 1.0),
                              ),
                            ),
                          ),
                        ],
                      )),
                  new Container(
                      //color: Colors.red,
                      margin: const EdgeInsets.only(left: 10, right: 10),
                      width: screenSize.width,
                      height: _cardTextHeight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: screenSize.width,
                                maxWidth: screenSize.width,
                                minHeight: _constrainedMinHeight,
                                maxHeight: _constrainedMaxHeight,
                              ),
                              child: AutoSizeText(offer.jobTitle,
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold))),
                          ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: screenSize.width,
                                maxWidth: screenSize.width,
                                minHeight: _constrainedMinHeight,
                                maxHeight: _constrainedMaxHeight,
                              ),
                              child: AutoSizeText(offer.schoolName,
                                  style: TextStyle(fontSize: 10.0)))
                        ],
                      )),
                ],
              ),
            ),
          )),
      actions: <Widget>[
        new Container(
            margin: EdgeInsets.only(top: 5),
            child: new IconSlideAction(
              caption: LangLocalizations.of(context).trans('accept offer'),
              color: Colors.green,
              icon: Icons.check,
            )),
      ],
      secondaryActions: <Widget>[
        new Container(
            margin: EdgeInsets.only(top: 5, bottom: 5),
            child: new IconSlideAction(
              caption: LangLocalizations.of(context).trans('decline offer'),
              color: Colors.red,
              icon: Icons.clear,
            )),
      ],
      slideToDismissDelegate: new SlideToDismissDrawerDelegate(
        onDismissed: (actionType) {
          if (actionType == SlideActionType.primary) {
            OffersHelper.saveOfferStatus(offerStatus.accepted, offer.id.toString(), true);  
            setState(() {
              savedOffers.remove(offer);
              list.removeAt(index);
            });
          } else {
            OffersHelper.saveOfferStatus(offerStatus.declined, offer.id.toString(), true);         
            setState(() {
              savedOffers.remove(offer);
              list.removeAt(index);
            });
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
