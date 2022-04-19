import 'package:flutter/material.dart';
//import 'package:nnotee/screen/home_chat.dart';
import 'package:nnotee/screen/home_chat_st.dart';
import 'package:nnotee/screen/store/col_store.dart';
import 'package:nnotee/screen/store/profile_store.dart';
import 'package:nnotee/utility/banstore.dart';
//import 'package:nnotee/utility/my_style.dart';
//import 'package:nnotee/utility/signout_process.dart';
import 'package:nnotee/widget/store/information_store.dart';
//import 'package:nnotee/widget/store/product_store.dart';
//import 'package:nnotee/widget/customer/about_requirement_cs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainStore extends StatefulWidget {
  @override
  _MainStoreState createState() => _MainStoreState();
}

class _MainStoreState extends State<MainStore> {
  int pageIndex = 0;
  String usernameStore;
  List<Widget> pageList = <Widget>[
    InfotmationStore(),
    StoreCol(),
    CusChat(),
    ProfileStore(),
  ];

  @override
  void initState() {
    BanStore().readdataBan(context);
    super.initState();
    findUser();
  }

  Future<Null> findUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      usernameStore = preferences.getString('usernamest');
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
                icon: Icon(Icons.bookmark_outline), label: "ที่บันทึกไว้"),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat_outlined), label: "แชท"),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle_rounded), label: "ฉัน")
          ]),
    );
  }

  // Drawer showDrawer() => Drawer(
  //       child: ListView(
  //         children: <Widget>[
  //           showHead(),
  //           informationMenu(),
  //           requireMenu(),
  //           productMenu(),
  //           signoutMenu(),
  //         ],
  //       ),
  //     );

  // ListTile requireMenu() => ListTile(
  //       leading: Icon(Icons.list),
  //       title: Text('รายการความต้องการของลูกค้า'),
  //       onTap: () {
  //         setState(() {
  //           requireS();
  //           currentWidget = RequirementStore();
  //         });
  //         Navigator.pop(context);
  //       },
  //     );

  // ListTile productMenu() => ListTile(
  //       leading: Icon(Icons.widgets),
  //       title: Text('รายการสินค้า'),
  //       onTap: () {
  //         setState(() {
  //           productS();
  //           currentWidget = ProductStore();
  //         });
  //         Navigator.pop(context);
  //       },
  //     );

  // ListTile informationMenu() => ListTile(
  //       leading: Icon(Icons.add_business),
  //       title: Text('รายละเอียดร้านซ่อม'),
  //       onTap: () {
  //         setState(() {
  //           informationS();
  //           currentWidget = InfotmationStore();
  //         });
  //         Navigator.pop(context);
  //       },
  //     );

  // ListTile signoutMenu() => ListTile(
  //       leading: Icon(Icons.logout),
  //       title: Text('ออกจากระบบ'),
  //       onTap: () => signOutProcess(context),
  //     );

  // UserAccountsDrawerHeader showHead() {
  //   return UserAccountsDrawerHeader(
  //     decoration: MyStyle().myBoxDecoration('store.jpg'),
  //     currentAccountPicture: MyStyle().showUsericon(),
  //     accountName: Text(
  //       usernameStore == null ? 'No user' : '$usernameStore',
  //       style: TextStyle(color: MyStyle().darkColor),
  //       ),
  //     accountEmail: Text(
  //       'login',
  //       style: TextStyle(color: MyStyle().darkColor),
  //     ),
  //   );
  // }
}
