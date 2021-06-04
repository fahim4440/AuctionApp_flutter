import 'package:shared_preferences/shared_preferences.dart';

class UserModel {
  final String? username;
  final String? name;
  final String? photoUrl;
  final String? uid;

  UserModel(this.username, this.name, this.photoUrl, this.uid);

  Future<bool?> isLoggedIn() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool('isLoggedIn');
  }

  userSavedInSharedPrefs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('name', name!);
    preferences.setString('username', username!);
    preferences.setString('photoUrl', photoUrl!);
    preferences.setString('uid', uid!);
  }
}