import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nnotee/model/customer_model.dart';
import 'package:nnotee/model/strec_model.dart';
//import 'package:nnotee/screen/customer/show_chatfromrecord.dart';
import 'package:nnotee/screen/store/add_order.dart';
//import 'package:nnotee/screen/store/resetpw_store.dart';
import 'package:nnotee/screen/store/showchatfromrec_st.dart';
import 'package:nnotee/utility/my_constant.dart';
import 'package:nnotee/utility/my_style.dart';
import 'package:nnotee/utility/normal_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreCol extends StatefulWidget {
  const StoreCol({Key key}) : super(key: key);

  @override
  _StoreColState createState() => _StoreColState();
}

class _StoreColState extends State<StoreCol> {
  List<Widget> shopCards = [];
  List<StoreRecordModel> strecmodel = [];
  List<StoreRecordModel> strecList = [];
  String tel;
  CustomerModel customerModel;

  void initState() {
    readStoreRecord();

    strecmodel = [];
    shopCards = [];
    strecList = [];

    super.initState();
  }

  Future<Null> readStoreRecord() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.getString('idst');
    print(id);
    String url =
        '${MyConstant().domain}/mobile/getRecordSt.php?isAdd=true&store_id=$id';
    await Dio().get(url).then((value) {
      print('url=$url');
      print('value = $value');
      var result = json.decode(value.data);
      int index = 0;
      for (var map in result) {
        StoreRecordModel model = StoreRecordModel.fromJson(map);
        String name = model.name;
        if (name.isNotEmpty) {
          print('*******************${model.name}');
          if (mounted)
            setState(() {
              strecmodel.add(model);
              shopCards.add(createCard(model, index));
              print(shopCards);
              print('$model, $index,');
              index++;
            });
        }
      }
    });
  }

  Future<Null> checkRecordThread(CustomerModel customerModel) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.getString('idst');
    String url =
        '${MyConstant().domain}/mobile/checkRecordSt.php?isAdd=true&store_id=$id&customer_id=${customerModel.id}';
    try {
      Response response = await Dio().get(url);
      print('res = $response');
      if (response.toString() == 'null') {
        setState(() {
          addRecordThread(customerModel);
        });
      } else {
        Fluttertoast.showToast(
            msg: "ผู้ใช้ถูกเพิ่มไปแล้ว",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<Null> addRecordThread(CustomerModel customerModel) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.getString('idst');
    String url =
        '${MyConstant().domain}/mobile/addRecordSt.php?isAdd=true&store_id=$id&customer_id=${customerModel.id}';
    try {
      Response response = await Dio().get(url);
      print('res = $response');
      if (response.toString() == 'true') {
        setState(() {
          strecmodel = [];
          shopCards = [];
          strecList = [];
        });
        readStoreRecord();
        Fluttertoast.showToast(
            msg: "เพิ่มที่บันทึกไว้เรียบร้อย",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1);
      } else {
        normalDialog(context, 'ไม่สามารถเพิ่มสินค้าได้');
      }
    } catch (e) {
      print(e);
    }
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

  Widget createCard(StoreRecordModel storeRecordModel, int index) {
    return Stack(
      children: [
        Container(
          width: 500.0,
          child: GestureDetector(
            onTap: () {
              _onEditPressed(storeRecordModel);
            },
            onLongPress: () {},
            child: Card(
              child: Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 30.0,
                          backgroundImage:
                              NetworkImage('${storeRecordModel.pic}'),
                          backgroundColor: Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(
                      'ชื่อ : ${storeRecordModel.name}\nเบอร์โทร : ${storeRecordModel.tel}\nE-mail : ${storeRecordModel.email}',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onEditPressed(StoreRecordModel storeRecordModel) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: 280,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: Text(
                    '${storeRecordModel.name}',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
                  ),
                ),
                ListTile(
                    leading: Icon(Icons.add_outlined),
                    title: Text('เพิ่มออเดอร์'),
                    onTap: () {
                      setState(() {
                        tel = storeRecordModel.tel;
                      });
                      checkOrder();
                    }),
                ListTile(
                  leading: Icon(Icons.chat),
                  title: Text('แชท'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ShowChatFromrecStore(
                                storeRecordModel: storeRecordModel,
                              )),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.phone),
                  title: Text('โทร'),
                  onTap: () {
                    launch('tel://${storeRecordModel.tel}');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('ลบ'),
                  onTap: () {
                    delRecordstThread(storeRecordModel);
                  },
                )
              ],
            ),
          );
        });
  }

  Future<Null> delRecordstThread(StoreRecordModel storeRecordModel) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.getString('idst');
    String url =
        '${MyConstant().domain}/mobile/delRecordSt.php?isAdd=true&store_id=$id&customer_id=${storeRecordModel.id}';
    try {
      Response response = await Dio().get(url);
      setState(() {
        strecmodel = [];
        shopCards = [];
        strecList = [];
        readStoreRecord();
      });
      Fluttertoast.showToast(
          msg: "ลบที่บันทึกไว้เรียบร้อย",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1);
      print('res = $response');
    } catch (e) {
      print(e);
    }
  }

  Future<Null> checkOrder() async {
    String urlCustomer =
        '${MyConstant().domain}/mobile/getCustomerWhereTel.php?isAdd=true&tel=$tel';
    print(urlCustomer);
    try {
      Response response = await Dio().get(urlCustomer);
      print('res =$response');
      if (response == null) {
        MyStyle().showProgess();
      }
      var result = json.decode(response.data);
      print('result = $result');
      if (result == null) {
        normalDialog(context, 'ไม่มีเบอร์โทรนี้ในระบบ');
      }
      for (var map in result) {
        customerModel = CustomerModel.fromJson(map);
        routeToService(OrderAdd(), customerModel);
      }
    } catch (e) {}
  }

  Future<Null> checkAuthen() async {
    String urlCustomer =
        '${MyConstant().domain}/mobile/getCustomerWhereTel.php?isAdd=true&tel=$tel';
    print(urlCustomer);
    try {
      Response response = await Dio().get(urlCustomer);
      print('res =$response');
      if (response == null) {
        MyStyle().showProgess();
      }
      var result = json.decode(response.data);
      print('result = $result');
      if (result == null) {
        normalDialog(context, 'ไม่มีเบอร์โทรนี้ในระบบ');
      }
      for (var map in result) {
        customerModel = CustomerModel.fromJson(map);
        checkRecordThread(customerModel);
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'ที่บักทึกไว้',
            style: TextStyle(color: Colors.black38),
          ),
          actions: [
            IconButton(
                color: Colors.black38,
                onPressed: () {
                  setState(() {
                    tel = null;
                  });
                  showDialog(
                      context: context, builder: (context) => dialogAdd());
                },
                icon: Icon(Icons.bookmark_add_outlined))
          ],
        ),
        body: shopCards.length != 0
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(children: [
                  SizedBox(
                    height: 20,
                  ),
                  Column(
                    children: shopCards,
                  )
                ]))
            : SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Image.asset(
                        'images/hello.png',
                        scale: 1.5,
                      ),
                      Text(
                        'ยังไม่มีรายการ\nที่บันทึกไว้',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            color: Colors.black38),
                      )
                    ],
                  ),
                ),
              ));
  }

  Widget dialogAdd() => SimpleDialog(
        title: Text('กรอกเบอร์โทรศัพท์ของลูกค้า'),
        children: [telForm(), addButton()],
      );

  Widget addButton() => Container(
        padding: EdgeInsets.all(10),
        child: ElevatedButton(
          onPressed: () {
            if (tel == null || tel.isEmpty) {
              normalDialog(context, 'กรุณากรอกข้อมูลให้ครบ');
            } else {
              checkAuthen();
            }
          },
          child: Text(
            'ยืนยัน',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

  Widget telForm() => Container(
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
