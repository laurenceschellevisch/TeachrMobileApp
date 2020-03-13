import 'package:auto_size_text/auto_size_text.dart' show AutoSizeText;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_html/flutter_html.dart' show Html;
import 'package:teachr/helpers/offers_helper.dart';
import 'package:teachr/helpers/snackbar_helper.dart';
import 'package:teachr/language/localizations.dart';
import 'package:teachr/offers/active_card.dart';
import 'package:teachr/models/card_model.dart';
import 'package:url_launcher/url_launcher.dart' show canLaunch, launch;

import 'package:flutter/scheduler.dart' show timeDilation;

enum AppBarBehavior { normal, pinned, floating, snapping }

class DetailPage extends StatefulWidget {
  final CardModel type;
  final bool savedOffersPage;
  const DetailPage({Key key, this.type, this.savedOffersPage})
      : super(key: key);

  @override
  _DetailPageState createState() =>
      new _DetailPageState(card: type, savedOffersPage: savedOffersPage);
}

enum Url { schoolWebsite, googleMaps }

class _DetailPageState extends State<DetailPage> with TickerProviderStateMixin {
  AnimationController _containerController;
  Animation<double> width;
  Animation<double> heigth;
  CardModel card;
  final bool savedOffersPage;
  double _appBarHeight = 350.0;
  AppBarBehavior _appBarBehavior = AppBarBehavior.normal;
  _DetailPageState({this.card, this.savedOffersPage});

  Size screenSize;

  double _acceptButtonSize;
  double _declineButtonSize;
  double _buttonContainerHeight;
  double _jobTitleMinHeight;
  double _jobTitleMaxHeigth;
  double _schoolNameMinHeigth;
  double _schoolNameMaxHeigth;

  @override
  Widget build(BuildContext context) {
    timeDilation = 0.7;
    screenSize = MediaQuery.of(context).size;

    _acceptButtonSize = _declineButtonSize = screenSize.height / 15;
    _buttonContainerHeight = screenSize.height / 7.5;
    _jobTitleMinHeight = screenSize.height / 50;
    _jobTitleMaxHeigth = screenSize.height / 10;
    _schoolNameMinHeigth = screenSize.height / 20;
    _schoolNameMaxHeigth = screenSize.height / 10;

    return new Theme(
      data: new ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color.fromRGBO(237, 238, 239, 1.0),
        platform: Theme.of(context).platform,
      ),
      child: new Container(
        width: width.value,
        height: heigth.value,
        color: const Color.fromRGBO(237, 238, 239, 1.0),
        child: new Hero(
          tag: "img",
          child: new Card(
            color: Colors.transparent,
            child: new Container(
              alignment: Alignment.center,
              width: width.value,
              height: heigth.value,
              decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: new BorderRadius.circular(10.0),
              ),
              child: new Stack(
                alignment: AlignmentDirectional.bottomCenter,
                children: <Widget>[
                  new CustomScrollView(
                    shrinkWrap: false,
                    slivers: <Widget>[
                      new SliverAppBar(
                        elevation: 0.0,
                        forceElevated: true,
                        leading: new Container(
                          padding: new EdgeInsets.only(left: 20.0),
                          child: new GestureDetector(
                            onTap: () {
                              Navigator.pop(context, true);
                            },
                            child: new Text('✕',
                                style: TextStyle(
                                    shadows: <Shadow>[
                                      Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 2.0,
                                        color: Color.fromRGBO(1, 1, 1, 1.0),
                                      ),
                                      Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 2.0,
                                        color: Color.fromRGBO(1, 1, 1, 1.0),
                                      ),
                                    ],
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        expandedHeight: _appBarHeight,
                        pinned: _appBarBehavior == AppBarBehavior.pinned,
                        floating: _appBarBehavior == AppBarBehavior.floating ||
                            _appBarBehavior == AppBarBehavior.snapping,
                        snap: _appBarBehavior == AppBarBehavior.snapping,
                        flexibleSpace: new FlexibleSpaceBar(
                          background: new Stack(
                            fit: StackFit.expand,
                            children: <Widget>[
                              new Container(
                                width: width.value,
                                height: _appBarHeight,
                                decoration: new BoxDecoration(
                                  image: card.schoolImage,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      new SliverList(
                        delegate: new SliverChildListDelegate(<Widget>[
                          new Container(
                            width: screenSize.width,
                            color: Colors.white,
                            child: new Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  new Container(
                                    padding: const EdgeInsets.only(bottom: 0),
                                    width: screenSize.width,
                                    child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minWidth: screenSize.width,
                                          maxWidth: screenSize.width,
                                          minHeight: _jobTitleMinHeight,
                                          maxHeight: _jobTitleMaxHeigth,
                                        ),
                                        child: AutoSizeText(card.jobTitle,
                                            style: TextStyle(
                                                fontSize: 30.0,
                                                fontWeight: FontWeight.bold))),
                                  ),
                                  new Container(
                                      padding: new EdgeInsets.only(top: 10),
                                      child: new Column(
                                        children: <Widget>[
                                          ConstrainedBox(
                                              constraints: BoxConstraints(
                                                minWidth: screenSize.width,
                                                maxWidth: screenSize.width,
                                                minHeight: _schoolNameMinHeigth,
                                                maxHeight: _schoolNameMaxHeigth,
                                              ),
                                              child: AutoSizeText.rich(TextSpan(
                                                  text: card.schoolName + ", ",
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                        text: card.city,
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            color:
                                                                Color.fromRGBO(
                                                                    145,
                                                                    145,
                                                                    145,
                                                                    1.0),
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal)),
                                                  ]))),
                                        ],
                                      )),
                                  new Container(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Column(
                                        children: <Widget>[
                                          new Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              new Row(
                                                children: <Widget>[
                                                  new Icon(
                                                    Icons.location_on,
                                                    color: Color.fromRGBO(
                                                        145, 145, 145, 1.0),
                                                  ),
                                                  new Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: new Text(
                                                      card.distance,
                                                      style: new TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color.fromRGBO(
                                                              145,
                                                              145,
                                                              145,
                                                              1.0)),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              new Row(
                                                children: <Widget>[
                                                  new Icon(
                                                    Icons.access_time,
                                                    color: Color.fromRGBO(
                                                        145, 145, 145, 1.0),
                                                  ),
                                                  new Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: new Text(
                                                      card.jobTime + ' uur',
                                                      style: new TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color.fromRGBO(
                                                              145,
                                                              145,
                                                              145,
                                                              1.0)),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              new Row(
                                                children: <Widget>[
                                                  new Icon(
                                                    Icons.euro_symbol,
                                                    color: Color.fromRGBO(
                                                        145, 145, 145, 1.0),
                                                  ),
                                                  new Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: new Text(
                                                      card.salary,
                                                      style: new TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color.fromRGBO(
                                                              145,
                                                              145,
                                                              145,
                                                              1.0)),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      )),
                                  new Container(
                                    width: screenSize.width,
                                    decoration: new BoxDecoration(
                                        color: Colors.white,
                                        border: new Border(
                                          top: new BorderSide(
                                              color: Colors.black12),
                                        )),
                                    child: new Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        new Padding(
                                            padding: EdgeInsets.only(
                                                top: 10, bottom: 5),
                                            child: Text('Vacature',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: Color.fromRGBO(
                                                        145, 145, 145, 1.0)))),
                                        new Padding(
                                            padding: EdgeInsets.only(top: 10),
                                            child: Text(
                                                'Zoekt jou vanwege je expertise in:',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        _skillWidgets(card.skills),
                                        new Padding(
                                          padding: EdgeInsets.only(top: 10),
                                          child: Text(
                                            'Toelichting:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        new Html(
                                          data: card.explanation,
                                        ),
                                        new Padding(
                                            padding: EdgeInsets.only(top: 0),
                                            child: RichText(
                                              text: TextSpan(
                                                text: 'Plaatsingsdatum: ',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      text: card.jobCreateDate,
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .normal)),
                                                ],
                                              ),
                                            )),
                                        new Padding(
                                            padding: EdgeInsets.only(
                                                top: 10, bottom: 10),
                                            child: RichText(
                                              text: TextSpan(
                                                text: 'Met ingang van: ',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      text: card.jobStartDate,
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .normal)),
                                                ],
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),
                                  new Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    width: screenSize.width,
                                    decoration: new BoxDecoration(
                                        color: Colors.white,
                                        border: new Border(
                                          top: new BorderSide(
                                              color: Colors.black12),
                                        )),
                                    child: new Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        new Padding(
                                            padding: EdgeInsets.only(
                                                top: 10, bottom: 5),
                                            child: Text(
                                                'Over ' + card.schoolName,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: Color.fromRGBO(
                                                        145, 145, 145, 1.0)))),
                                        new Padding(
                                            padding: EdgeInsets.only(top: 10),
                                            child: RichText(
                                              text: TextSpan(
                                                text: 'Contactpersoon: ',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      text: card.contactName,
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .normal)),
                                                ],
                                              ),
                                            )),
                                        new GestureDetector(
                                            onTap: () {
                                              _launchURL(Url.googleMaps);
                                            },
                                            child: Padding(
                                                padding:
                                                    EdgeInsets.only(top: 10),
                                                child: RichText(
                                                  text: TextSpan(
                                                    text: 'Plaats: ',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    children: <TextSpan>[
                                                      TextSpan(
                                                          text: card.city,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.blue,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal)),
                                                    ],
                                                  ),
                                                ))),
                                        new GestureDetector(
                                            onTap: () {
                                              _launchURL(Url.googleMaps);
                                            },
                                            child: new Padding(
                                                padding:
                                                    EdgeInsets.only(top: 10),
                                                child: RichText(
                                                  text: TextSpan(
                                                    text: 'Postcode: ',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    children: <TextSpan>[
                                                      TextSpan(
                                                          text: card.postalCode,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.blue,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal)),
                                                    ],
                                                  ),
                                                ))),
                                        new Padding(
                                            padding: EdgeInsets.only(top: 10),
                                            child: RichText(
                                              text: TextSpan(
                                                text: 'Sector: ',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      text: card.sector,
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .normal)),
                                                ],
                                              ),
                                            )),
                                        new GestureDetector(
                                          onTap: () {
                                            _launchURL(Url.schoolWebsite);
                                          },
                                          child: new Padding(
                                            padding: EdgeInsets.only(top: 10),
                                            child: Row(
                                              children: <Widget>[
                                                RichText(
                                                  text: TextSpan(
                                                    text: 'Website: ',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    children: <TextSpan>[
                                                      TextSpan(
                                                          text: card
                                                              .schoolWebsite,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              color:
                                                                  Colors.blue)),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  new Container(
                                      height: _buttonContainerHeight,
                                      decoration: new BoxDecoration(
                                          border: new Border(
                                        top: new BorderSide(
                                            color: Colors.black12),
                                      )),
                                      //color: Colors.red,
                                      child: _footerButtons())
                                ],
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _containerController.dispose();
    super.dispose();
  }

  void initState() {
    _containerController = new AnimationController(
        duration: new Duration(milliseconds: 2000), vsync: this);
    super.initState();
    width = new Tween<double>(
      begin: 200.0,
      end: 220.0,
    ).animate(
      new CurvedAnimation(
        parent: _containerController,
        curve: Curves.ease,
      ),
    );
    heigth = new Tween<double>(
      begin: 400.0,
      end: 400.0,
    ).animate(
      new CurvedAnimation(
        parent: _containerController,
        curve: Curves.ease,
      ),
    );
    heigth.addListener(() {
      setState(() {
        if (heigth.isCompleted) {}
      });
    });
    _containerController.forward();
  }

  /// Method for creating buttons
  RawMaterialButton _buildButton(IconData icon, Color iconColor,
      Color buttonColor, double buttonSize, buttonType type, CardModel card) {
    return new RawMaterialButton(
      onPressed: () {
        switch (type) {
          case buttonType.accept:
            {
              OffersHelper.saveOfferStatus(
                  offerStatus.accepted, card.id.toString(), savedOffersPage,
                  context: context);
              Scaffold.of(context).showSnackBar(SnackBarHelper.snackbarText(
                  Text(LangLocalizations.of(context).trans('offer accepted'))));
            }
            break;

          case buttonType.decline:
            {
              OffersHelper.saveOfferStatus(
                  offerStatus.declined, card.id.toString(), savedOffersPage,
                  context: context);
              Scaffold.of(context).showSnackBar(SnackBarHelper.snackbarText(
                  Text(LangLocalizations.of(context).trans('offer declined'))));
            }
            break;

          case buttonType.save:
            {
              OffersHelper.saveOfferStatus(
                  offerStatus.saved, card.id.toString(), savedOffersPage,
                  context: context);
              Scaffold.of(context).showSnackBar(SnackBarHelper.snackbarText(
                  Text(LangLocalizations.of(context).trans('offer saved'))));
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
      padding: const EdgeInsets.all(15.0),
    );
  }

  /// Method for returning footer buttons on detail page
  Widget _footerButtons() {
    Widget returnWidget;

    if (savedOffersPage) {
      returnWidget = Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildButton(Icons.clear, Colors.red, Colors.white,
              _declineButtonSize, buttonType.decline, this.card),
          _buildButton(Icons.check, Colors.green, Colors.white,
              _acceptButtonSize, buttonType.accept, this.card),
        ],
      );
    }

    return returnWidget;
  }

  /// Method for opening the school website
  _launchURL(Url launchUrl) async {
    var url = card.schoolWebsite;

    switch (launchUrl) {
      case Url.schoolWebsite:
        {
          url = card.schoolWebsite;
        }
        break;

      case Url.googleMaps:
        {
          String postalCode = card.postalCode.replaceAll((new RegExp(r"\s+\b|\b\b")), "");
          url = ('https://www.google.com/maps/search/?api=1&query=' + postalCode);
        }
        break;
    }

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  /// Method for returning all job skills as chip widgets
  Widget _skillWidgets(List<String> skills) {
    List<Widget> list = new List<Widget>();
    for (var i = 0; i < skills.length; i++) {
      list.add(
        new Chip(
          label: Text(skills[i],
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Color.fromRGBO(145, 145, 145, 1.0),
        ),
      );
    }
    return new Wrap(
      children: list,
      spacing: 8,
    );
  }
}
