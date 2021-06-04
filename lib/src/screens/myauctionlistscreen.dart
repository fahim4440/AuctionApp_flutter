import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/auctionItemPreview.dart';
import '../widgets/auctionTile.dart';

class MyAuctionListShowScreen extends StatelessWidget {
  final UserModel user;

  MyAuctionListShowScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Auction Lists'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('auctionsPreview').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if(!snapshot.hasData) {
            return LinearProgressIndicator();
          } else {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, int index) {
                AuctionItemPreview auctionItemPreview = AuctionItemPreview(
                  snapshot.data!.docs[index].data()['productName'],
                  snapshot.data!.docs[index].data()['productDescription'],
                  snapshot.data!.docs[index].data()['minBidPrice'],
                  snapshot.data!.docs[index].data()['productOwner'],
                  snapshot.data!.docs[index].data()['itemId'],
                );
                if(user.username == auctionItemPreview.productOwner) {
                  return auctionTile(context, auctionItemPreview);
                } else {
                  return SizedBox(height: 0.0,);
                }
              },
            );
          }
        },
      ),
    );
  }
}