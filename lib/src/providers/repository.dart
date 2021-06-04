import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebaseAuthentication.dart';
import 'firestore.dart';
import 'firebaseStorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/auctionItem.dart';

class Repository {
  final _firebaseAuthentication = FirebaseAuthentication();
  final _firestore = Firestore();
  final _firestorageApi = FirebaseStorageApi();

  //signin & signout
  Future<UserModel> signInWithGoogle() async {
    UserModel user = await _firebaseAuthentication.signinWithGoogle();
    final queryDocumentSnapshot = await _firestore.userFetch(user.uid);
    if(!queryDocumentSnapshot.exists) {
      _firestore.createUser(user);
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool('isLoggedIn', true);
    user.userSavedInSharedPrefs();
    return user;
  }

  Future<bool?> isLoggedIn() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool('isLoggedIn');
  }

  Future<UserModel> userFetch() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return UserModel(preferences.getString('username'), preferences.getString('name'), preferences.getString('photoUrl'), preferences.getString('uid'));
  }

  void signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool('isLoggedIn', false);
    await _firebaseAuthentication.signOut();
  }

  //createAuction
  createAuction(String productName, String productDescription, int minBidPrice, File file, DateTime auctionEndDate) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? productOwner = preferences.getString('username');
    String productPhotoUrl = await _firestorageApi.uploadImage(file, '$productName+$productOwner');
    AuctionItem auctionItem = AuctionItem(productName, productDescription, minBidPrice, productPhotoUrl, auctionEndDate, productOwner);
    _firestore.createAuction(auctionItem);
  }

  //placing bid
  placeBid(int bidPrice, String bidItemId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? bidderUid = preferences.getString('uid');
    String? bidderName = preferences.getString('name');
    String? bidderUsername = preferences.getString('username');
    _firestore.placeBid(bidPrice, bidItemId, bidderUid!, bidderUsername!, bidderName!);
  }

  Future<String> fetchUsername() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? username = await preferences.getString('username');
    return username!;
  }

  // dashboard works
  Future<List<int>> dashboardCalculation(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    List<int> list = [];
    int totalBids = docs.length;
    int totalValue = 0;
    int maxBid = 0;
    List<QueryDocumentSnapshot> snapshot = await _firestore.fetchCompletedBids();
    int completedBids = snapshot.length;
    list.insert(0, totalBids - completedBids);
    list.insert(1, completedBids);

    await Future.forEach(snapshot, (DocumentSnapshot element) async {
      maxBid = await _firestore.fetchMaxBid(element.id);
      totalValue = totalValue + maxBid;
    });
    list.insert(2, totalValue);
    return list;
  }
}