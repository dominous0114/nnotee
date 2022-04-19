import 'dart:convert';

import 'package:dio/dio.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:nnotee/model/customer_model.dart';
//import 'package:nnotee/model/store_model.dart';
import 'package:nnotee/screen/customer/edit_info_customer.dart';
import 'package:nnotee/screen/customer/estCustomer.dart';
import 'package:nnotee/screen/customer/requireCustomer.dart';
import 'package:nnotee/screen/signin.dart';
import 'package:nnotee/screen/customer/trackingCs.dart';
import 'package:nnotee/utility/my_constant.dart';
import 'package:nnotee/utility/my_style.dart';
import 'package:nnotee/utility/signout_process.dart';
//import 'package:nnotee/widget/store/product_store.dart';
//import 'package:nnotee/widget/customer/about_requirement_cs.dart';
//import 'package:nnotee/widget/customer/tracking_customer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileCustomer extends StatefulWidget {
  @override
  _ProfileCustomerState createState() => _ProfileCustomerState();
}

class _ProfileCustomerState extends State<ProfileCustomer> {
  CustomerModel customerModel;
  bool loading;

  @override
  void initState() {
    loading = false;
    readDataCustomer();
    super.initState();
  }

  void routeToRequirInfo() {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (context) => RequireCs(),
    );
    Navigator.push(context, materialPageRoute);
  }

  void routeToEstInfo() {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (context) => EstCustomer(),
    );
    Navigator.push(context, materialPageRoute);
  }

  void routeToProfileInfo() {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (context) => EditInfoCustomer(),
    );
    Navigator.push(context, materialPageRoute)
        .then((value) => readDataCustomer());
  }

  void routeToTrackingInfo() {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (context) => CsTracking(),
    );
    Navigator.push(context, materialPageRoute);
  }

  Future<Null> readDataCustomer() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.getString('idcus');

    String url =
        '${MyConstant().domain}/mobile/getCustomerWhereId.php?isAdd=true&id=$id';
    await Dio().get(url).then((value) {
      print('value = $value');
      var result = json.decode(value.data);
      for (var map in result) {
        setState(() {
          loading = true;
          customerModel = CustomerModel.fromJson(map);
        });
        print('name =${customerModel.name}');
      }
    });
  }

  Future<Null> tokenClear() async {
    String urlCustomerToken =
        '${MyConstant().domain}/mobile/editTokenCus.php?isAdd=true&token=&username=${customerModel.username}';
    print(urlCustomerToken);
    await Dio().get(urlCustomerToken);
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
                          'คุณ ${customerModel.name}',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        MyStyle().mySizebox(),
                        CircleAvatar(
                          radius: 30.0,
                          backgroundImage: NetworkImage('${customerModel.pic}'),
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
                        profileMenu(),
                        requireMenu(),
                        shopRateMenu(),
                        trackingMenu(),
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
                routeToEstInfo();
              },
              icon: Icon(
                Icons.list_alt,
                color: Colors.black87,
              ),
              label: Text(
                'ให้ร้านซ่อมเสนอราคา',
                style: TextStyle(color: Colors.black87),
              ))
        ],
      );

  shopRateMenu() => Row(
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
                'เสนอความต้องการให้ร้านซ่อม',
                style: TextStyle(color: Colors.black87),
              ))
        ],
      );

  trackingMenu() => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
          ),
          TextButton.icon(
              onPressed: () {
                routeToTrackingInfo();
              },
              icon: Icon(
                Icons.assistant_navigation,
                color: Colors.black87,
              ),
              label: Text(
                'รายละเอียดการติดตามการซ่อม',
                style: TextStyle(color: Colors.black87),
              ))
        ],
      );
  profileMenu() => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
          ),
          TextButton.icon(
              onPressed: () {
                routeToProfileInfo();
              },
              icon: Icon(
                Icons.account_circle_rounded,
                color: Colors.black87,
              ),
              label: Text(
                'แก้ไขโปรไฟล์',
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
