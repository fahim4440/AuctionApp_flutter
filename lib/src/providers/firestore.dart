import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/auctionItem.dart';

class Firestore {
  final _cloudFirestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot> userFetch(String? uid) async {
    DocumentSnapshot documentSnapshot = await _cloudFirestore.collection('users').doc(uid).get();
    return documentSnapshot;
  }

  void createUser(UserModel user) async {
    await _cloudFirestore.collection('users').doc(user.uid).set({
      'name' : user.name,
      'username' : user.username,
      'photoUrl' : user.photoUrl,
      'uid' : user.uid,
    });
  }

  void createAuction(AuctionItem auctionItem) async {
    DocumentReference snapshot =  await _cloudFirestore.collection('auctions').add({
      'productName' : auctionItem.productName,
      'productDescription' : auctionItem.productDescription,
      'minBidPrice' : auctionItem.minBidPrice,
      'productPhotoUrl' : auctionItem.productPhotoUrl,
      'auctionEndDate' : auctionItem.auctionEndDate,
      'productOwner' : auctionItem.productOwner,
    });

    await _cloudFirestore.collection('auctionsPreview').doc(snapshot.id).set({
      'productName' : auctionItem.productName,
      'productDescription' : auctionItem.productDescription,
      'minBidPrice' : auctionItem.minBidPrice,
      'productOwner' : auctionItem.productOwner,
      'itemId' : snapshot.id,
    });
  }

  placeBid(int bidPrice, String bidItemId, String bidderUid, String bidderUsername, String bidderName) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await _cloudFirestore.collection('auctions').doc(bidItemId).collection('bids').doc(bidderUid).get();
    if(snapshot.data() == null) {
      await _cloudFirestore.collection('auctions').doc(bidItemId).collection('bids').doc(bidderUid).set({
        'bid' : bidPrice,
        'bidderName' : bidderName,
        'username' : bidderUsername,
      });
    } else {
      await _cloudFirestore.collection('auctions').doc(bidItemId).collection('bids').doc(bidderUid).update({
        'bid' : bidPrice,
      });
    }
  }

  //dashboard calculation
  Future<List<QueryDocumentSnapshot>> fetchCompletedBids() async {
    QuerySnapshot snapshot = await _cloudFirestore.collection('auctions').where('auctionEndDate', isLessThan: DateTime.now()).get();
    return snapshot.docs;
  }

  Future<int> fetchMaxBid(String bidId) async {
    int maxBid = 0;
    QuerySnapshot<Map<String, dynamic>> snapshot = await _cloudFirestore.collection('auctions').doc(bidId).collection('bids').get();
    snapshot.docs.forEach((element) {
      if(element.data()['bid'] > maxBid) {
        maxBid = element.data()['bid'];
      }
    });
    return maxBid;
  }
}