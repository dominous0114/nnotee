import 'package:flutter/material.dart';

class MyStyle {
  Color darkColor = Colors.blue.shade900;
  Color primaryColor = Colors.blue.shade600;

  Widget showProgess() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  SizedBox mySizebox() => SizedBox(
        width: 8.0,
        height: 16.0,
      );

  Text showTitle(String title) => Text(
        title,
        style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold),
      );

  Text showTitleH2(String title) => Text(
        title,
        style: TextStyle(
            fontSize: 18.0,
            color: Colors.blue,
            fontWeight: FontWeight.bold),
      );
  Container showUsericon() {
    return Container(
      width: 120.0,
      child: Image.asset('images/usericon.png'),
    );
  }

  Widget titleCenter(BuildContext context, String string) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        child: Text(
          string,
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  BoxDecoration myBoxDecoration(String namePic) {
    return BoxDecoration(
      image: DecorationImage(
          image: AssetImage('images/$namePic'), fit: BoxFit.cover),
    );
  }

  MyStyle();
}
