import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:nnotee/screen/customer/trackingCs.dart';
import 'package:nnotee/screen/user_col.dart';
import 'package:nnotee/screen/login_home.dart';
import 'package:nnotee/screen/customer/main_customer.dart';
import 'package:nnotee/screen/store/main_store.dart';
import 'package:nnotee/screen/map_home.dart';
import 'package:nnotee/utility/my_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int pageIndex = 0;
  List<Widget> pageList = <Widget>[
    HomeMap(),
    HomeLove(),
    HomeLogin(),
  ];
  @override
  void initState() {
    super.initState();
    checkPreference();
    aboutNotification();

    //checkPreferenceSt();
  }

  Future<Null> checkPreference() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String type = preferences.getString('type');
    try {
      // print(
      //     'token================================================================================$token');
      // String idLogincus = preferences.getString('idcus');
      // String idLoginst = preferences.getString('idst');
      print('typesss=======$type');
      // if (idLogincus != null && idLogincus.isNotEmpty) {
      //   // String urlCustomer =
      //   //     '${MyConstant().domain}/mobile/editTokenCus.php?isAdd=true&token=$token&id=$idLogincus';
      //   // await Dio().get(urlCustomer);
      // } else if (idLoginst != null && idLoginst.isNotEmpty) {
      //   // String urlStore =
      //   //     '${MyConstant().domain}/mobile/editTokenSt.php?isAdd=true&token=$token&id=$idLoginst';
      //   // await Dio().get(urlStore);
      // }
      if (type == 'customer') {
        routeToService(MainCustomer());
      } else if (type == 'store') {
        routeToService(MainStore());
      }
    } catch (e) {}
  }

  Future<Null> aboutNotification() async {
    //if (Platform.isAndroid) {
    FirebaseMessaging.instance.getInitialMessage();
    FirebaseMessaging.onMessage.listen((message) {
      print(message.notification.body);
      print(message.notification.title);
    });
    //FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //print('onresume');
    //});
    //}
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('test pass wa jarnnnnnnnnnnnnnnnnnnnnnnnnnn');
      // fetchRideInfo(getRideID(message), context);
      MaterialPageRoute materialPageRoute = MaterialPageRoute(
        builder: (context) => CsTracking(),
      );
      if (mounted) Navigator.push(context, materialPageRoute);
    });
  }

  void routeToService(Widget myWidget) {
    MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => myWidget,
    );
    Navigator.pushAndRemoveUntil(context, route, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pageList[pageIndex],
      // drawer: showDrawer(),
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
                icon: Icon(Icons.account_circle_outlined), label: "ฉัน")
          ]),
    );
  }

  // Drawer showDrawer() => Drawer(
  //       child: ListView(
  //         children: <Widget>[
  //           showHeadDrawer(),
  //           signInMenu(),
  //           registerMenu(),
  //           registerStMenu(),
  //         ],
  //       ),
  //     );

  // ListTile signInMenu() {
  //   return ListTile(
  //     leading: Icon(Icons.login),
  //     title: Text('Sign in'),
  //     onTap: () {
  //       Navigator.pop(context);
  //       MaterialPageRoute route =
  //           MaterialPageRoute(builder: (value) => SignIn());
  //       Navigator.push(context, route);
  //     },
  //   );
  // }

  // ListTile registerMenu() {
  //   return ListTile(
  //     leading: Icon(Icons.supervised_user_circle_rounded),
  //     title: Text('Register for customer'),
  //     onTap: () {
  //       Navigator.pop(context);
  //       MaterialPageRoute route =
  //           MaterialPageRoute(builder: (value) => Register());
  //       Navigator.push(context, route);
  //     },
  //   );
  // }

  // ListTile registerStMenu() {
  //   return ListTile(
  //     leading: Icon(Icons.store_mall_directory_rounded),
  //     title: Text('Register for store'),
  //     onTap: () {
  //       Navigator.pop(context);
  //       MaterialPageRoute route =
  //           MaterialPageRoute(builder: (value) => RegisterSt());
  //       Navigator.push(context, route);
  //     },
  //   );
  // }

  // UserAccountsDrawerHeader showHeadDrawer() {
  //   return UserAccountsDrawerHeader(
  //       decoration: MyStyle().myBoxDecoration('guset.png'),
  //       currentAccountPicture: MyStyle().showUsericon(),
  //       accountName: Text('Guest'),
  //       accountEmail: Text('Please login'));
  // }
}
