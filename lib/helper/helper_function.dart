import 'package:shared_preferences/shared_preferences.dart';

class HelperFunction {
  static String userLoginKey = 'LOGGEDINKEY';
  static String userNameKey = 'NAMEDKEY';
  static String userEmailKey = 'EMAILKEY';
  static const String themeStatus = 'themeStatus';
  static Future saveUserLoggedInStatus(bool isUserLogged) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    await sf.setBool(userLoginKey, isUserLogged);
  }

  static Future saveUsernameSf(String userName) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    await sf.setString(userNameKey, userName);
  }

  static Future saveEmailSf(String email) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    await sf.setString(userEmailKey, email);
  }

  static Future<bool?> getUserLoggedInStatus() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getBool(userLoginKey);
  }

  static Future<String?> getEmailFromSf() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userEmailKey);
  }

  static Future<String?> getUsernameFromSf() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userNameKey);
  }

  static Future clearLocalData() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    await sf.remove(userLoginKey);
    await sf.remove(userNameKey);
    await sf.remove(userEmailKey);
  }

  setDarkTheme(bool value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(themeStatus, value);
  }

  Future<bool> getTheme() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(themeStatus) ?? false;
  }
}
