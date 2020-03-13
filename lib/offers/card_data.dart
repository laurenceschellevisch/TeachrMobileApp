import 'dart:async';
import 'dart:async' show Future;
import 'dart:collection';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart'
    show CachedNetworkImageProvider;
import 'package:flutter/material.dart' show BoxFit, DecorationImage;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' show DateFormat;
import 'package:teachr/Helpers/request_helper.dart';
import 'package:teachr/models/card_model.dart';
import 'package:teachr/globals.dart' as globals;

List<CardModel> availableOffers = [];
List<dynamic> offersWithStatusList = [];
List<CardModel> savedOffers = [];

/// Check if list already contains the card and check if logged in user has the skill.
bool checkCard(card, List list) {
  int offerId = card['id'];
  var jobSkills = card['job_skills'];
  bool check = true;
  bool userHasSkill = false;
  bool offerHasStatus = offersWithStatusList.contains(offerId.toString());

  if (RequestHelper.user != null) {
    if (RequestHelper.user.skillset != null) {
      for (dynamic skill in jobSkills) {
        userHasSkill = RequestHelper.user.skillset.contains(skill['name']);
        if (userHasSkill) {
          break;
        }
      }
    } else {
      userHasSkill = true;
    }
  } else {
    userHasSkill = true;
  }

  if (!offerHasStatus && userHasSkill) {
    check = list.any((x) => x.id == offerId);
  }
  return check;
}

/// Method for creating a card object.
Future createCardModel(card, List list) async {
  DecorationImage image = new DecorationImage(
    image: new CachedNetworkImageProvider(card['school_picture']['guid']),
    fit: BoxFit.cover,
  );

  int id = card['id'];
  String schoolName = card['school_name'];
  String jobTitle = card['title']['rendered'].toString();
  String jobTime = card['job_hours'].toString();
  String salary = card['job_salary'].toString();
  String explanation = card['content']['rendered'].toString();
  String city = card['school_city'].toString();
  String postalCode = card['job_postal_code'].toString();
  var splittedstring = card['job_start_date'].toString().split("/");
  // get dates and format them.
  DateTime createDate = DateTime.parse(card['date_gmt']);
  DateTime startDate = DateTime.parse(splittedstring[2]+splittedstring[1]+splittedstring[0]);
  String jobCreateDate = DateFormat('dd-MM-yyyy').format(createDate);
  String jobStartDate = DateFormat('dd-MM-yyyy').format(startDate);

  String sector = card['school_sector']['name'].toString();
  String contactName = card['contact_name'].toString();
  String schoolWebsite = card['school_website'].toString();

  Map<String,dynamic> jobSkills = card['job_skills'];
  List<String> skillNames = [];

  // add the names of the selected skills in skillnames list.
  jobSkills.forEach((key, value) {if (key == "name") {skillNames.add(jobSkills[key]);} });


  // destination is hard coded atm, in the future this will be data from the logged in user.
  String destination = '4337KB, Middelburg';
  String origin =
      card['job_postal_code'] + "," + card['school_city'].toString();

  String distance = await _calculateDistance(origin, destination);

  CardModel cardModel = new CardModel(
      id,
      image,
      schoolName,
      jobTitle,
      skillNames,
      jobTime,
      salary,
      explanation,
      city,
      jobCreateDate,
      postalCode,
      distance,
      jobStartDate,
      sector,
      contactName,
      schoolWebsite);

  // extra check if list already contains a job with the same id.
  bool check = list.any((x) => x.id.toString() == id.toString());

  if (!check) {
    list.add(cardModel);
  }
}

/// Method for calculating distance between user location and job location.
Future<String> _calculateDistance(String origin, String destination) async {
  var distance;

  try {
    String mapsUrl =
        "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=" +
            origin +
            "&destinations=" +
            destination +
            "&key=AIzaSyD1TC6OT-N92ZIDc1CgNpClPDGFMaKAowQ";

    http.Response result = await http
        .get(Uri.encodeFull(mapsUrl), headers: {"Accept": "application/json"});
    var resBody = json.decode(result.body);
    distance = resBody['rows'][0]['elements'][0]['distance']['text'];
  } catch (exception) {
    distance = "N.V.T";
  }

  return distance.toString();
}
