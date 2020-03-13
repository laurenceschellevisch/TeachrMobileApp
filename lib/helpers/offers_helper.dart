import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:teachr/helpers/cookie_helper.dart';
import 'package:teachr/offers/card_data.dart';

enum offerStatus { accepted, declined, saved }

class OffersHelper {
  static final String apiUrl =
      "https://teachrapp.nl/index.php/wp-json/wp/v2/vacature";
  // https://developer.wordpress.org/rest-api/using-the-rest-api/pagination/
  static var cards;
  static int cardsAdded = 0;
  static int numberOffersAtSameTime = 5;

  static bool isFirstDecline = true;
  static bool isFirstAccept = true;
  static bool isFirstSave = true;

  /// Clear all lists and reset cardsAdded int.
  static void clearLists() {
    cardsAdded = 0;
    availableOffers.clear();
    offersWithStatusList.clear();
    savedOffers.clear();
  }

  /// Get cards from the DB.
  static Future<void> getCards() async {
    cardsAdded = 0;
    availableOffers.clear();
    await userOffers();

    http.Response result = await http.get(
        Uri.encodeFull(apiUrl + "/?per_page=100"),
        headers: {"Accept": "application/json"});
    var resBody = json.decode(result.body);
    cards = resBody;

    // create card if it doesn't exist in the card list and if counter is 5 or less
    for (dynamic card in cards) {
      bool checkCardList = checkCard(card, availableOffers);
      if (!checkCardList) {
        cardsAdded++;
        if (cardsAdded <= numberOffersAtSameTime) {
          await createCardModel(card, availableOffers);
        }
      }
    }
  }

  /// Remove from saved offers when user accept/decline saved offer.
  static Future<void> removeFromSavedOffers(String offerId) async {
    if (CookieHelper.cookie != null) {
      savedOffers.removeWhere((item) => item.id.toString() == offerId);

      // Get available offers data in DB from the user
      String offersUrl =
          "https://teachrapp.nl/index.php/api/user/get_user_meta?cookie=" +
              CookieHelper.cookie.toString();

      http.Response offersResult = await http.get(Uri.encodeFull(offersUrl),
          headers: {"Accept": "application/json"});

      var offersResultBody = jsonDecode(offersResult.body);
      var getSavedOffers = offersResultBody['saved_offers'];
      var saveUrl;
      String savedIds = "";
      RegExp exp = new RegExp(r"\([^)]*\)");
      Iterable<Match> matches;

      // get saved ids and add them to the list, and remove the specific offer id
      try {
        matches = exp.allMatches(getSavedOffers);
        for (Match m in matches) {
          String match = m.group(0);
          savedIds = savedIds + "," + match.toString();
        }
        getSavedOffers = savedIds.replaceAll("(" + offerId + ")", "");
      } catch (exception) {
        print(exception);
      }

      saveUrl =
          "https://teachrapp.nl/index.php/api/user/update_user_meta?cookie=" +
              CookieHelper.cookie.toString() +
              "&meta_key=saved_offers" +
              "&meta_value=" +
              getSavedOffers;

      await http.post(Uri.decodeFull(saveUrl),
          headers: {"Accept": "application/json"});
    } else {
      print('Cookie is null');
    }
  }

  /// Save the status of the offer to the DB.
  static Future<String> saveOfferStatus(
      offerStatus status, String offerId, bool savedOffersPage,
      {context}) async {
    try {
      if (CookieHelper.cookie != null) {
        // Get available offers data in DB from the user
        String offersUrl =
            "https://teachrapp.nl/index.php/api/user/get_user_meta?cookie=" +
                CookieHelper.cookie.toString();

        http.Response offersResult = await http.get(Uri.encodeFull(offersUrl),
            headers: {"Accept": "application/json"});

        var offersResultBody = jsonDecode(offersResult.body);

        var offers;
        String saveUrl;
        String metaKey;
        String savedIds = "";
        RegExp exp = new RegExp(r"\([^)]*\)");
        Iterable<Match> matches;

        // When offer get a status from saved offers view, call remove from saved offers method
        if (savedOffersPage) {
          removeFromSavedOffers(offerId);
        }

        if (context != null) {
          Navigator.of(context).pop();
        }

        switch (status) {
          case offerStatus.accepted:
            {
              offers = offersResultBody['accepted_offers'];
              metaKey = "accepted_offers";
            }
            break;

          case offerStatus.declined:
            {
              offers = offersResultBody['declined_offers'];
              metaKey = "declined_offers";
            }
            break;

          case offerStatus.saved:
            {
              offers = offersResultBody['saved_offers'];
              metaKey = "saved_offers";
            }
            break;
        }

        // Check if user has already offer data with the specific meta key in the DB
        try {
          matches = exp.allMatches(offers);
          for (Match m in matches) {
            String match = m.group(0);
            savedIds = savedIds + "," + match.toString();
          }
          offers = savedIds + ",(" + offerId.toString() + ")";
        } catch (exception) {
          offers = "(" + offerId.toString() + ")";
        }
        saveUrl =
            "https://teachrapp.nl/index.php/api/user/update_user_meta?cookie=" +
                CookieHelper.cookie.toString() +
                "&meta_key=" +
                metaKey +
                "&meta_value=" +
                offers;

        // post offer ids to DB
        await http.post(Uri.decodeFull(saveUrl),
            headers: {"Accept": "application/json"});
      } else {
        print('Cookie is null!');
      }
    } catch (e) {
      print(e.toString());
      return "Error!";
    }

    return "Success";
  }

  /// Get offers from the logged in user with already a status (accepted, declined or saved).
  static Future<void> userOffers() async {
    //savedOffers.clear();
    //offersWithStatusList.clear();
    clearLists();
    String offersUrl =
        "https://teachrapp.nl/index.php/api/user/get_user_meta?cookie=" +
            CookieHelper.cookie.toString();
    http.Response offersResult = await http.get(Uri.encodeFull(offersUrl),
        headers: {"Accept": "application/json"});
    var offersResultBody = jsonDecode(offersResult.body);
    var offers;
    var card;
    RegExp exp = new RegExp(r"\([^)]*\)");
    Iterable<Match> matches;
    int totalOfferStatuses = offerStatus.values.length;

    for (var i = 0; i < totalOfferStatuses; i++) {
      String statusName = offerStatus.values[i].toString();
      statusName = statusName.replaceAll("offerStatus.", "");
      bool isSavedOffers = statusName == "saved";

      try {
        offers = offersResultBody[statusName + '_offers'];
        // variable with values which match the regExp
        matches = exp.allMatches(offers);

        // get the ids of the offer with a status and add them to the list offerWithStatusList
        for (Match m in matches) {
          String match = m.group(0);
          // replace ( & ) so only the id will be saved to the list
          match = match.replaceAll("(", "");
          match = match.replaceAll(")", "");

          offersWithStatusList.add(match.toString());

          if (isSavedOffers) {
            http.Response result = await http.get(
                Uri.encodeFull(apiUrl + "/" + match.toString()),
                headers: {"Accept": "application/json"});
            var resBody = json.decode(result.body);
            card = resBody;
            bool check =
                savedOffers.any((x) => x.id.toString() == match.toString());

            if (match.isNotEmpty & !check) {
              await createCardModel(card, savedOffers);
            }
          }
        }
      } catch (exception) {
        print(exception.toString());
      }  
    }
  }
}
