import 'package:flutter/material.dart';
import '../providers/repository.dart';
import 'signinscreen.dart';
import 'auctionListshowscreen.dart';
import '../models/user.dart';
import '../widgets/showLoading.dart';

class HomeScreen extends StatelessWidget {
  final _repository = Repository();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _repository.isLoggedIn(),
      builder: (context, AsyncSnapshot<bool?> snapshot) {
        if(snapshot.hasData) {
          if(snapshot.data!) {
            return FutureBuilder(
              future: _repository.userFetch(),
              builder: (context, AsyncSnapshot<UserModel> snapshot) {
                if(snapshot.hasData) {
                  return AuctionListShowScreen(user: snapshot.data!);
                } else {
                  return Text('');
                }
              },
            );
          } else {
            return SigninScreen();
          }
        } else {
          return SigninScreen();
        }
      },
    );
  }
}