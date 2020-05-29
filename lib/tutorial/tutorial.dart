import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:teachr/animations.dart';
import 'package:teachr/helpers/tutorial_helper.dart';
import 'package:teachr/language/localizations.dart';
import 'package:teachr/offers/overview_page.dart';

class Tutorial extends StatefulWidget {
  Tutorial({Key key}) : super(key: key);

  @override
  TutorialState createState() => new TutorialState();
}

class TutorialState extends State<Tutorial> {
  List<Slide> slides = new List();
  Size screenSize;
  double buttonWidth;

  @override
  void initState() {
    super.initState();
  }

  /// When tutorial is done.
  void onDonePress() async {
    TutorialHelper.setTutorialStatus(true);
    Navigator.push(context, new MyCustomRoute(builder: (context) => OverviewPage())); 
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    buttonWidth = screenSize.width / 3;
    slides.clear();

    slides.add(
      new Slide(
          title: "TEACHR",
          marginTitle: EdgeInsets.all(40),
          description: LangLocalizations.of(context).trans('tutorial_teachr'),
          marginDescription: EdgeInsets.only(top: 30, left: 20, right: 20),
          pathImage: 'assets/img/icon.png',
          backgroundColor: Color.fromRGBO(48, 81, 255, 1.0)),
    );

    slides.add(
      new Slide(
          title: LangLocalizations.of(context).trans('OFFERS'),
          marginTitle: EdgeInsets.all(40),
          description: LangLocalizations.of(context).trans('tutorial_offers'),
          marginDescription: EdgeInsets.only(top: 30, left: 20, right: 20),
          pathImage: 'assets/img/offer.png',
          backgroundColor: Color.fromRGBO(51, 130, 255, 1.0)),
    );
    slides.add(
      new Slide(
          title: LangLocalizations.of(context).trans('AVAILABLE OFFERS'),
          maxLineTitle: 2,
          marginTitle: EdgeInsets.all(40),
          description: LangLocalizations.of(context).trans('tutorial_available_offers'),
          marginDescription: EdgeInsets.only(top: 30, left: 20, right: 20),
          pathImage: 'assets/img/available.png',
          backgroundColor: Color.fromRGBO(51, 130, 255, 1.0)),
    );
    slides.add(
      new Slide(
          title: LangLocalizations.of(context).trans('SAVED OFFERS'),
          maxLineTitle: 2,
          marginTitle: EdgeInsets.all(40),
          description: LangLocalizations.of(context).trans('tutorial_saved_offers'),
          marginDescription: EdgeInsets.only(top: 30, left: 20, right: 20),
          pathImage: 'assets/img/saved.png',
          backgroundColor: Color.fromRGBO(51, 130, 255, 1.0)),
    );
    slides.add(
      new Slide(
          title: LangLocalizations.of(context).trans('PROFILE'),
          marginTitle: EdgeInsets.all(40),
          description: LangLocalizations.of(context).trans('tutorial_profile'),
          marginDescription: EdgeInsets.only(top: 30, left: 20, right: 20),
          pathImage: 'assets/img/profile.png',
          backgroundColor: Color.fromRGBO(51, 160, 255, 1.0)),
    );
    slides.add(
      new Slide(
          title: LangLocalizations.of(context).trans('EDIT PROFILE'),
          marginTitle: EdgeInsets.all(40),
          description: LangLocalizations.of(context).trans('tutorial_edit_profile'),
          marginDescription: EdgeInsets.only(top: 30, left: 20, right: 20),
          pathImage: 'assets/img/edit.png',
          backgroundColor: Color.fromRGBO(51, 160, 255, 1.0)),
    );
    slides.add(
      new Slide(
          title: "CHAT",
          marginTitle: EdgeInsets.all(40),
          description: LangLocalizations.of(context).trans('tutorial_chat'),
          marginDescription: EdgeInsets.only(top: 30, left: 20, right: 20),
          pathImage: 'assets/img/chat.png',
          backgroundColor: Color.fromRGBO(132, 200, 255, 1.0)),

    );

    return new IntroSlider(
      isShowSkipBtn: true,
      slides: this.slides,
      onDonePress: this.onDonePress,
      nameNextBtn: LangLocalizations.of(context).trans('next'),
      nameDoneBtn: LangLocalizations.of(context).trans('done'),
      widthDoneBtn: buttonWidth,
      isScrollable: true,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
