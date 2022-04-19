import 'package:flutter/material.dart';
//import 'package:nnotee/model/customer_model.dart';
import 'package:nnotee/screen/customer/col_customer.dart';
//import 'package:nnotee/screen/user_col.dart';
import 'package:nnotee/screen/home_chat.dart';
//import 'package:nnotee/screen/login_home.dart';
import 'package:nnotee/screen/map_home.dart';
import 'package:nnotee/screen/customer/profile_customer.dart';
//import 'package:nnotee/utility/my_style.dart';
//import 'package:nnotee/utility/signout_process.dart';
//import 'package:nnotee/widget/customer/information_customer.dart';
//import 'package:nnotee/widget/customer/card_require_cs.dart';
//import 'package:nnotee/widget/customer/tracking_customer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainCustomer extends StatefulWidget {
  @override
  _MainCustomerState createState() => _MainCustomerState();
}

class _MainCustomerState extends State<MainCustomer> {
  int pageIndex = 0;
  String usernameCustomer;
  bool information, require, product;
  List<Widget> pageList = <Widget>[
    HomeMap(),
    CusCol(),
    StChat(),
    ProfileCustomer(),
  ];

  @override
  void initState() {
    super.initState();
    findUser();
  }

  Future<Null> findUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      usernameCustomer = preferences.getString('usernamecus');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: showDrawer(),
      body: pageList[pageIndex],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: pageIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (value) {
            setState(() {
              pageIndex = value;
            });
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "หน้าแรก"),
            BottomNavigationBarItem(
                icon: Icon(Icons.bookmark_border_outlined),
                label: "ที่บักทึกไว้"),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat_outlined), label: "แชท"),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle_rounded), label: "ฉัน")
          ]),
    );
  }
}
