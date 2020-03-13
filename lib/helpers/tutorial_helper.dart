import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;
    
class TutorialHelper {
  static bool isTutorialFinished = false;

  /// Get status of tutorial 
  static getTutorialStatus() async {
    final SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
    //_sharedPreferences.clear();
    return isTutorialFinished = _sharedPreferences.getBool('tutorial') ?? false;    
  }

  /// Set status of tutorial
  static setTutorialStatus(bool status) async {
    final SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
        
    _sharedPreferences.setBool('tutorial', status);
  }
}
