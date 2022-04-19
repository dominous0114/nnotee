import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
//import 'package:nnotee/Services/productServices.dart';
import 'package:nnotee/model/customer_model.dart';
//import 'package:nnotee/model/product.dart';
//import 'package:nnotee/model/store_order.dart';
import 'package:nnotee/screen/store/add_order.dart';
import 'package:nnotee/utility/banstore.dart';
import 'package:nnotee/utility/my_constant.dart';
import 'package:nnotee/utility/my_style.dart';
import 'package:nnotee/utility/normal_dialog.dart';
import 'package:nnotee/widget/store/testWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderSceen extends StatefulWidget {
  @override
  _OrderSceenState createState() => _OrderSceenState();
}

class _OrderSceenState extends State<OrderSceen> {
  String storeId;
  String tel;
  @override
  void initState() {
    BanStore().readdataBan(context);
    super.initState();
  }

  Future<Null> routeToService(
      Widget myWidget, CustomerModel customerModel) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('idcus', customerModel.id);
    preferences.setString('usernamecus', customerModel.username);
    preferences.setString('namecus', customerModel.name);
    preferences.setString('telcus', customerModel.tel);
    preferences.setString('piccus', customerModel.pic);
    MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => myWidget,
    );
    Navigator.push(context, route);
  }

  Future<Null> checkAuthen() async {
    String urlCustomer =
        '${MyConstant().domain}/mobile/getCustomerWhereTel.php?isAdd=true&tel=$tel';
    try {
      Response response = await Dio().get(urlCustomer);
      print('res =$response');
      if (response == null) {
        MyStyle().showProgess();
      }
      var result = json.decode(response.data);
      print('result = $result');
      if (result == null) {
        normalDialog(context, 'ไม่มีชื่อผู้ใช้งานนี้');
      }
      for (var map in result) {
        CustomerModel customerModel = CustomerModel.fromJson(map);
        routeToService(OrderAdd(), customerModel);
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              color: Colors.black38,
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios_new_outlined,
              )),
          title: Text(
            'รายการออเดอร์',
            style: TextStyle(color: Colors.black38),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          foregroundColor: Colors.black,
          onPressed: () {
            setState(() {
              tel = null;
            });
            showDialog(context: context, builder: (context) => dialogAdd());
          },
          child: Icon(Icons.add),
        ),
        body: TestWidget());
  }

  Widget dialogAdd() => SimpleDialog(
        title: Text('กรอกเบอร์โทรศัพท์ของลูกค้า'),
        children: [userForm(), loginButton()],
      );

  Widget loginButton() => Container(
        padding: EdgeInsets.all(10),
        child: ElevatedButton(
          onPressed: () {
            if (tel == null || tel.isEmpty) {
              normalDialog(context, 'กรุณากรอกข้อมูลให้ครบ');
            } else {
              Navigator.pop(context);
              Navigator.pop(context);
              checkAuthen();
            }
          },
          child: Text(
            'ยืนยัน',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

  Widget userForm() => Container(
        padding: EdgeInsets.all(10),
        child: TextField(
          keyboardType: TextInputType.phone,
          onChanged: (value) => tel = value.trim(),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.phone),
            hintText: 'เบอร์โทรศัพท์',
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
          ),
        ),
      );
}
