import 'package:flutter/material.dart';

showLoading(BuildContext context) {
  return showDialog(
    context: context,
    builder: (_) => loadingCart(),
  );
}

Widget loadingCart() {
  return AlertDialog(
    title: Text('Loading', textAlign: TextAlign.center,),
    backgroundColor: Colors.teal,
    content: Container(
      alignment: Alignment.center,
      height: 40.0,
      width: 40.0,
      child: CircularProgressIndicator(
        backgroundColor: Colors.white,
      ),
    ),
    elevation: 5.0,
  );
}