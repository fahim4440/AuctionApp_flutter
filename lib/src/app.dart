import 'package:flutter/material.dart';
import 'screens/homescreen.dart';
import 'screens/auctioncreatescreen.dart';
import 'screens/auctionshowscreen.dart';
import 'screens/myauctionlistscreen.dart';
import 'screens/dashboardscreen.dart';
import 'models/user.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: routes,
      theme: ThemeData(
        primaryColor: Colors.green,
        accentColor: Colors.greenAccent,
        canvasColor: Colors.white,
      ),
    );
  }


  Route routes(RouteSettings settings) {
    if(settings.name == '/auctioncreatescreen') {
      return MaterialPageRoute(
        builder: (context) {
          return AuctionCreateScreen();
        }
      );
    } else if(settings.name == '/myauctions') {
      return MaterialPageRoute(
          builder: (context) {
            UserModel user = settings.arguments as UserModel;
            return MyAuctionListShowScreen(user: user);
          }
      );
    } else if(settings.name == '/dashboard') {
      return MaterialPageRoute(
          builder: (context) {
            return DashboardScreen();
          }
      );
    }
    else if(settings.name == '/') {
      return MaterialPageRoute(
        builder: (context) {
          return HomeScreen();
        }
      );
    } else {
      String itemId = settings.name!.replaceFirst('/', '');
      return MaterialPageRoute(
        builder: (context) {
          return AuctionShowScreen(itemId: itemId,);
        }
      );
    }
  }
}