import 'package:flutter/material.dart';
import '../models/bid.dart';

bidTile(BuildContext context, Bid bid) {
  return Row(
    children: <Widget>[
      Container(
        width: MediaQuery.of(context).size.width * 0.6,
        height: 50.0,
        padding: EdgeInsets.only(left: 5.0),
        margin: EdgeInsets.only(left: 15.0),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.black,width: 1.0),
            bottom: BorderSide(color: Colors.black,width: 1.0),
            left: BorderSide(color: Colors.black,width: 1.0),
          ),
        ),
        alignment: Alignment.centerLeft,
        child: Text(bid.bidderName, style: TextStyle(fontSize: 20.0),),
      ),
      Container(
        width: MediaQuery.of(context).size.width * 0.3,
        height: 50.0,
        padding: EdgeInsets.only(left: 5.0),
        margin: EdgeInsets.only(right: 15.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1.0),
        ),
        alignment: Alignment.centerLeft,
        child: Text('\$' + bid.bidPrice.toString(), style: TextStyle(fontSize: 20.0),),
      ),
    ],
  );
}