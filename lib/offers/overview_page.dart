import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:teachr/Helpers/request_helper.dart';
import 'package:teachr/animations.dart';
import 'package:teachr/language/localizations.dart';
import 'package:teachr/offers/card_data.dart';
import 'package:teachr/offers/offers_page.dart';
import 'package:teachr/offers/savedOffers_page.dart';
import 'package:url_launcher/url_launcher.dart';

class OverviewPage extends StatefulWidget {
  @override
  _OverviewPageState createState() => new _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  DecorationImage availableOffersImage;
  DecorationImage savedOffersImage;
  DecorationImage stockImage = new DecorationImage(
    image: AssetImage('assets/img/stockImage.jpg'),
    fit: BoxFit.cover,
  );

  double _containerHeight;
  double _bottomNavigationHeight;
  double _bottomContainerWidth;
  double _bottomContainerHeight;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Text _appBarTitle =
        Text(LangLocalizations.of(context).trans('offers'));
    Size screenSize = MediaQuery.of(context).size;

    _containerHeight = screenSize.height / 2;
    _bottomNavigationHeight = screenSize.height / 4;
    _bottomContainerHeight = screenSize.height / 10;
    _bottomContainerWidth = screenSize.width / 5;

    try {
      availableOffersImage = availableOffers.last.schoolImage;
    } catch (exception) {
      availableOffersImage = stockImage;
    }

    try {
      savedOffersImage = savedOffers.last.schoolImage;
    } catch (exception) {
      savedOffersImage = stockImage;
    }

    return Scaffold(
        appBar: new AppBar(
          textTheme: Theme.of(context).textTheme,
          centerTitle: true,
          title: _appBarTitle,
          leading: new Container(),
          backgroundColor: Colors.white,
          actions: <Widget>[
            // action button
            IconButton(
              icon: Icon(Icons.info_outline,
                color: Colors.black,),
              onPressed:_launchURL,
    ),
  ]),
        body: Column(
          children: <Widget>[
            new Container(
                alignment: Alignment.center,
                height: _containerHeight,
                child: new Hero(
                    tag: "img",
                    child: new GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          new MyCustomRoute(
                              builder: (context) => OffersPage(
                                    list: availableOffers,
                                    title: Text(LangLocalizations.of(context)
                                        .trans('available offers')),
                                  )),
                        );
                      },
                      child: new Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          new Container(
                              margin: EdgeInsets.all(10),
                              alignment: Alignment.center,
                              height: _containerHeight,
                              width: screenSize.width,
                              decoration: new BoxDecoration(
                                borderRadius:
                                    new BorderRadius.all(Radius.circular(100)),
                                image: availableOffersImage,
                              ),
                              child: new BackdropFilter(
                                filter: new ImageFilter.blur(
                                    sigmaX: 2.0, sigmaY: 2.0),
                                child: new Container(
                                  decoration: new BoxDecoration(
                                      color: Colors.white.withOpacity(0.0)),
                                ),
                              )),
                          new Positioned(
                              bottom: 50,
                              child: new Text(
                                LangLocalizations.of(context)
                                    .trans('start swiping'),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 30),
                              )),
                        ],
                      ),
                    ))),
          ],
        ),
        bottomNavigationBar: new Container(
          height: _bottomNavigationHeight,
          child: new Hero(
            tag: "img",
            child: new GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  new MyCustomRoute(
                      builder: (context) => SavedOffersPage(
                          title: Text(LangLocalizations.of(context)
                              .trans('saved offers')))),
                );
              },
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Text(
                    LangLocalizations.of(context).trans('saved offers'),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Container(
                      margin: EdgeInsets.only(top: 10),
                      height: _bottomContainerHeight,
                      width: _bottomContainerWidth,
                      decoration: new BoxDecoration(
                        borderRadius: new BorderRadius.all(Radius.circular(10)),
                        image: savedOffersImage,
                      )),
                ],
              ),
            ),
          ),
        ));
  }

  @override
  void dispose() {
    super.dispose();
  }
  _launchURL() async {
    const url = 'https://teachrapp.nl/index.php/portret-van-een-hybride-docent/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
