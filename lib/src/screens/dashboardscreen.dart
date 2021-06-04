import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../providers/repository.dart';

class DashboardScreen extends StatelessWidget {
  final _repository = Repository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('auctions').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>snapshot) {
          if(!snapshot.hasData) {
            return LinearProgressIndicator();
          } else {
            return FutureBuilder(
              future: _repository.dashboardCalculation(snapshot.data!.docs),
              builder: (context, AsyncSnapshot<List<int>>snapshot) {
                if(!snapshot.hasData) {
                  return LinearProgressIndicator();
                } else {
                  return SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 10.0,),
                        buildView(context, 'Running Bids', snapshot.data![0], false),
                        SizedBox(height: 10.0,),
                        buildView(context, 'Completed Bids', snapshot.data![1], false),
                        SizedBox(height: 10.0,),
                        buildView(context, 'Total Value of Bids', snapshot.data![2], true),
                        SizedBox(height: 10.0,),
                      ],
                    ),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }

  buildView(BuildContext context, String title, int number, bool isValue) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 10.0),
      height: 150.0,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 2.0)
      ),
      child: Column(
        children: <Widget>[
          Text(title, style: TextStyle(fontSize: 40.0),),
          SizedBox(height: 10.0,),
          Text(isValue ? '\$' + number.toString() : '' + number.toString(), style: TextStyle(fontSize: isValue ? 45.0 : 60.0),),
        ],
      ),
    );
  }

}