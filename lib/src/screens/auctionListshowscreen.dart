import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/repository.dart';
import '../models/user.dart';
import '../models/auctionItemPreview.dart';
import '../widgets/auctionTile.dart';

class AuctionListShowScreen extends StatelessWidget {
  final _repository = Repository();
  final UserModel user;

  AuctionListShowScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auctions'),
        actions: [
          PopupMenuButton(
            onSelected: (String value) {
              handlePopUpMenuButton(context, value);
            },
            itemBuilder: (context) {
              return {'My Auctions', 'Dashboard', 'Signout'}.map((String selection) {
                return PopupMenuItem(
                  value: selection,
                  child: Text(selection),
                );
              }).toList();
            },
          ),
          // FlatButton(
          //   onPressed: () {
          //     _repository.signOut();
          //     Navigator.of(context).pushReplacementNamed('/');
          //   },
          //   child: Text('SignOut'),
          //   splashColor: Colors.green.withOpacity(0.25),
          //   highlightColor: Colors.greenAccent.withOpacity(0.12),
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.circular(30.0),
          //   ),
          // ),
        ],
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
                if(user.username != auctionItemPreview.productOwner) {
                  return auctionTile(context, auctionItemPreview);
                } else {
                  return SizedBox(height: 0.0,);
                }
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/auctioncreatescreen');
        },
        child: Icon(Icons.add),
      ),
    );
  }

  handlePopUpMenuButton(BuildContext context, String value) {
    switch(value) {
      case 'My Auctions' :
        Navigator.of(context).pushNamed('/myauctions', arguments: user);
        break;
      case 'Dashboard' :
        Navigator.of(context).pushNamed('/dashboard');
        break;
      case 'Signout' :
        _repository.signOut();
        Navigator.of(context).pushReplacementNamed('/');
        break;
    }
  }

}