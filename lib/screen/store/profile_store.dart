import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nnotee/model/store_model.dart';
import 'package:nnotee/screen/store/all_requireEst.dart';
import 'package:nnotee/screen/store/order_screen.dart';
import 'package:nnotee/screen/signin.dart';
import 'package:nnotee/utility/banstore.dart';
import 'package:nnotee/utility/my_constant.dart';
import 'package:nnotee/utility/my_style.dart';
import 'package:nnotee/utility/signout_process.dart';
import 'package:nnotee/widget/store/product_store.dart';
//import 'package:nnotee/widget/customer/about_requirement_cs.dart';
//import 'package:nnotee/widget/customer/card_require_cs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileStore extends StatefulWidget {
  @override
  _ProfileStoreState createState() => _ProfileStoreState();
}

class _ProfileStoreState extends State<ProfileStore> {
  StoreModel storeModel;
  bool loading;

  @override
  void initState() {
    BanStore().readdataBan(context);
    loading = false;
    readDataStore();
    super.initState();
  }

  void routeToRequirInfo() {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (context) => AllRequireEsSceen());
    Navigator.push(context, materialPageRoute);
  }

  void routeToProductInfo() {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (context) => ProductStore(),
    );
    Navigator.push(context, materialPageRoute);
  }

  void routeToOrder() {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (context) => OrderSceen(),
    );
    Navigator.push(context, materialPageRoute);
  }

  Future<Null> readDataStore() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.getString('idst');

    String url =
        '${MyConstant().domain}/mobile/getStoreWhereId.php?isAdd=true&id=$id';
    await Dio().get(url).then((value) {
      print('value = $value');
      var result = json.decode(value.data);
      for (var map in result) {
        setState(() {
          loading = true;
          storeModel = StoreModel.fromJson(map);
        });
        print('name =${storeModel.name}');
      }
    });
  }

  Future<Null> tokenClear() async {
    String urlStoreToken =
        '${MyConstant().domain}/mobile/editTokenSt.php?isAdd=true&token=&username=${storeModel.username}';
    print(urlStoreToken);
    await Dio().get(urlStoreToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'ฉัน',
            style: TextStyle(color: Colors.black38),
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
              child: loading == true
                  ? Column(
                      children: <Widget>[
                        MyStyle().mySizebox(),
                        Text(
                          'ร้าน ${storeModel.name}',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        MyStyle().mySizebox(),
                        CircleAvatar(
                          radius: 30.0,
                          backgroundImage: NetworkImage('${storeModel.pic}'),
                          backgroundColor: Colors.transparent,
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 20,
                            ),
                            Text('เมนู',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black38)),
                          ],
                        ),
                        orderMenu(),
                        requireMenu(),
                        productMenu(),
                        signoutMenu()
                      ],
                    )
                  : LinearProgressIndicator()),
        ));
  }

  requireMenu() => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
          ),
          TextButton.icon(
              onPressed: () {
                routeToRequirInfo();
              },
              icon: Icon(
                Icons.list_alt,
                color: Colors.black87,
              ),
              label: Text(
                'รายการความต้องการของลูกค้า',
                style: TextStyle(color: Colors.black87),
              ))
        ],
      );

  productMenu() => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
          ),
          TextButton.icon(
              onPressed: () {
                routeToProductInfo();
              },
              icon: Icon(
                Icons.widgets,
                color: Colors.black87,
              ),
              label: Text(
                'รายการสินค้า',
                style: TextStyle(color: Colors.black87),
              ))
        ],
      );
  orderMenu() => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
          ),
          TextButton.icon(
              onPressed: () {
                routeToOrder();
              },
              icon: Icon(
                Icons.addchart_outlined,
                color: Colors.black87,
              ),
              label: Text(
                'เพิ่มออเดอร์',
                style: TextStyle(color: Colors.black87),
              ))
        ],
      );

  settingMenu() => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
          ),
          TextButton.icon(
              onPressed: () {},
              icon: Icon(
                Icons.settings,
                color: Colors.black87,
              ),
              label: Text(
                'ตั้งค่า',
                style: TextStyle(color: Colors.black87),
              ))
        ],
      );

  signoutMenu() => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
          ),
          TextButton.icon(
              onPressed: () {
                signOutProcess(context);
                tokenClear();
              },
              icon: Icon(
                Icons.logout,
                color: Colors.black87,
              ),
              label: Text(
                'ออกจากระบบ',
                style: TextStyle(color: Colors.black87),
              ))
        ],
      );

  void routeToAppInfo() {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (context) => SignIn(),
    );
    Navigator.push(context, materialPageRoute);
  }
}
