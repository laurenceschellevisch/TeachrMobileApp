import 'dart:async';
import 'dart:convert';
import 'package:teachr/helpers/cookie_helper.dart';
import 'package:teachr/models/user_model.dart';
import 'package:http/http.dart' as http;

class RequestHelper {
  static User user;

  static Future<void> setUser() async {
    String _getUrl = "https://teachrapp.nl/index.php/api/user/get_user_meta?cookie=" +
            CookieHelper.cookie.toString();

    var res = await http.get(Uri.encodeFull(_getUrl), headers: {"Accept": "application/json"});
    var resBody = json.decode(res.body);

    user = new User(
        resBody['id'],
        1,
        resBody['email'],
        resBody['firstname'],
        resBody['lastname'],
        resBody['description'],
        resBody['skillset'],
        resBody['avatar']);
  }
}
