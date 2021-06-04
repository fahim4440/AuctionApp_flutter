import 'package:auction_app/src/models/auctionItem.dart';
import 'package:auction_app/src/models/bid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/bidTile.dart';
import '../providers/repository.dart';

class AuctionShowScreen extends StatefulWidget{

  final String? itemId;
  AuctionShowScreen({this.itemId});

  @override
  State<StatefulWidget> createState() {
    return AuctionShowScreenState();
  }

}

class AuctionShowScreenState extends State<AuctionShowScreen> {

  final _repository = Repository();
  final TextEditingController _priceEditingController = TextEditingController();
  bool isPriceInput = false;
  int bidPrice = 0;
  String username = '';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('auctions').doc(widget.itemId).snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>snapshot) {
        if(!snapshot.hasData) {
          return LinearProgressIndicator();
        } else {
          AuctionItem auctionItem = AuctionItem(
            snapshot.data!.data()?['productName'],
            snapshot.data!.data()?['productDescription'],
            snapshot.data!.data()?['minBidPrice'],
            snapshot.data!.data()?['productPhotoUrl'],
            snapshot.data!.data()?['auctionEndDate'].toDate(),
            snapshot.data!.data()?['productOwner'],
          );
          bool isDateOver = true;
          DateTime presentDate = DateTime.now();
          if(presentDate.year < auctionItem.auctionEndDate!.year) {
            isDateOver = false;
          } else if(presentDate.month < auctionItem.auctionEndDate!.month && presentDate.year == auctionItem.auctionEndDate!.year) {
            isDateOver = false;
          } else if(presentDate.day < auctionItem.auctionEndDate!.day && presentDate.month == auctionItem.auctionEndDate!.month && presentDate.year == auctionItem.auctionEndDate!.year) {
            isDateOver = false;
          }
          return Scaffold(
            appBar: AppBar(
              title: Text(snapshot.data!.data()?['productName']),
            ),
            body: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height - 156.0 - MediaQuery.of(context).padding.top,
                    child: SingleChildScrollView(
                      child: buildAuction(context, auctionItem, isDateOver),
                    ),
                  ),
                  FutureBuilder(
                    future: _repository.fetchUsername(),
                    builder: (context, AsyncSnapshot<String>snapshot) {
                      if(snapshot.hasData) {
                        username = snapshot.data!;
                      }
                      return SizedBox(height: 0.0,);
                    },
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 100.0,
                    color: Colors.greenAccent[100],
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: TextField(
                            onChanged: (String value) {
                              if(int.parse(value.trim(), onError: (e) => -1) > auctionItem.minBidPrice!) {
                                setState(() {
                                  if(!isDateOver) {
                                    isPriceInput = true;
                                  }
                                });
                              } else {
                                setState(() {
                                  isPriceInput = false;
                                });
                              }
                            },
                            enabled: !isDateOver && username != auctionItem.productOwner,
                            keyboardType: TextInputType.number,
                            controller: _priceEditingController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0)
                              ),
                              hintText: "Bid your price",
                            ),
                          ),
                        ),
                        MaterialButton(
                          onPressed: !isPriceInput ? null : handleSubmit,
                          elevation: 5.0,
                          color: Colors.green,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.2,
                            margin: EdgeInsets.only(top: 15.0),
                            alignment: Alignment.center,
                            child: Column(
                              children: <Text>[
                                Text('Place', style: TextStyle(fontSize: 25.0),),
                                Text('Bid', style: TextStyle(fontSize: 25.0),),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Column buildAuction(BuildContext context, AuctionItem auctionItem, bool isDateOver) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        showPhoto(context, auctionItem.productPhotoUrl),
        SizedBox(height: 10.0,),
        buildName(context, auctionItem.productName),
        SizedBox(height: 5.0,),
        buildAuctionEndTime(context, auctionItem.auctionEndDate, isDateOver),
        SizedBox(height: 15.0,),
        buildDescription(context, auctionItem.productDescription),
        SizedBox(height: 10.0,),
        buildMinPrice(context, auctionItem.minBidPrice),
        SizedBox(height: 15.0,),
        buildBids(context, isDateOver),
        SizedBox(height: 5.0,),
      ],
    );
  }

  Container showPhoto(BuildContext context, String? productPhotoUrl) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 500.0,
      padding: EdgeInsets.only(bottom: 0.0, left: 10.0, right: 10.0, top: 0.0),
      child: Image.network(productPhotoUrl!),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
      ),
    );
  }

  Container buildName(BuildContext context, String? productName) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(bottom: 0.0, left: 10.0, right: 10.0, top: 0.0),
      child: Text(
        productName!,
        style: TextStyle(
          fontSize: 30.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  buildAuctionEndTime(BuildContext context, DateTime? auctionEndDate, bool isDateOver) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(bottom: 0.0, left: 10.0, right: 10.0, top: 0.0),
      child: Text(
        isDateOver ? 'Auction ended' : 'Auction will end before ' + auctionEndDate!.day.toString() + '/' + auctionEndDate.month.toString() + '/' + auctionEndDate.year.toString(),
        style: TextStyle(
          fontSize: 15.0,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          color: isDateOver ? Colors.red : Colors.black,
        ),
      ),
    );
  }

  buildDescription(BuildContext context, String? productDescription) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(bottom: 0.0, left: 10.0, right: 10.0, top: 0.0),
      child: Text(
        productDescription!,
        style: TextStyle(
          fontSize: 15.0,
        ),
      ),
    );
  }

  buildMinPrice(BuildContext context, int? minBidPrice) {
    return Column(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(bottom: 0.0, left: 10.0, right: 10.0, top: 0.0),
          child: Text(
            'Minimum Bid Price:',
            style: TextStyle(
              fontSize: 25.0,
            ),
          ),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.grey,
                width: 1.0,
              ),
            ),
          ),
        ),
        SizedBox(height: 5.0,),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(bottom: 0.0, left: 10.0, right: 10.0, top: 0.0),
          child: Text(
            '\$' + minBidPrice.toString(),
            style: TextStyle(
              fontSize: 30.0,
            ),
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey,
                width: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  buildBids(BuildContext context, bool isDateOver) {
    return Column(
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          child: Text(
            'BIDS',
            style: TextStyle(
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        StreamBuilder(
          stream: FirebaseFirestore.instance.collection('auctions').doc(widget.itemId).collection('bids').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>snapshot) {
            if(!snapshot.hasData) {
              return SizedBox(height: 0.0,);
            } else {
              if(snapshot.data!.docs.length == 0) {
                return !isDateOver ? Text('No bids yet') : SizedBox();
              } else {
                int maxBidPrice = 0;
                Bid? maxBid;
                snapshot.data!.docs.forEach((element) {
                  if(element.data()['bid'] > maxBidPrice) {
                    maxBidPrice = element.data()['bid'];
                    maxBid = Bid(element.data()['username'], element.data()['bid'], element.data()['bidderName']);
                  }
                });
                print(isDateOver);
                return Column(
                  children: <Widget>[
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, int index) {
                        Bid bid = Bid(snapshot.data!.docs[index].data()['username'], snapshot.data!.docs[index].data()['bid'], snapshot.data!.docs[index].data()['bidderName']);
                        return bidTile(context, bid);
                      },
                    ),
                    SizedBox(height: 10.0,),
                    isDateOver ? Text(
                      'Auction winner is ' + maxBid!.bidderName + ' at \$$maxBidPrice',
                      style: TextStyle(fontSize: 20.0, fontStyle: FontStyle.italic, color: Colors.red),
                    ) : SizedBox(height: 0.0,),
                  ],
                );
              }
            }
          },
        ),
      ],
    );
  }

  handleSubmit() {
    bidPrice = int.parse(_priceEditingController.text.trim());
    _repository.placeBid(bidPrice, widget.itemId!);
  }

}