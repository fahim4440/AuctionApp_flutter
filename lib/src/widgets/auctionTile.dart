import 'package:flutter/material.dart';
import '../models/auctionItemPreview.dart';

auctionTile(BuildContext context, AuctionItemPreview auctionItemPreview) {
  return ListTile(
    title: Text(auctionItemPreview.productName!),
    subtitle: Text(auctionItemPreview.productDescription!),
    trailing: Text('\$'+ auctionItemPreview.minBidPrice.toString()),
    onTap: () {
      Navigator.of(context).pushNamed('/'+auctionItemPreview.itemId!);
    },
  );
}