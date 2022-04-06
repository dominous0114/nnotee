import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nnotee/model/allRequireEst.dart';
import 'package:nnotee/utility/banstore.dart';
import 'package:nnotee/utility/my_constant.dart';
import 'package:nnotee/utility/my_style.dart';
import 'package:nnotee/utility/normal_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllEst extends StatefulWidget {
  @override
  _AllEstState createState() => _AllEstState();
}

class _AllEstState extends State<AllEst> {
  int index;
  List<AllRequireEstModel> allEstModel = [];
  List<Widget> shopCards = [];
  String storeId, price, customerRequireId, header, detail;
  var result;
  bool loading;

  @override
  void initState() {
    BanStore().readdataBan(context);
    readEst();
    loading = false;
    super.initState();
  }

  Future<Null> readEst() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      storeId = preferences.getString('idst');
      loading = true;
      print(storeId);
    });
    String url =
        '${MyConstant().domain}/mobile/allEstWhereStore.php?isAdd=true&storeId=$storeId';
    await Dio().get(url).then((value) {
      result = json.decode(value.data);
      index = 0;
      for (var map in result) {
        AllRequireEstModel model = AllRequireEstModel.fromJson(map);
        allEstModel.add(model);
        shopCards.add(createCard(model, index));
        index++;
        setState(() {});
      }
    });
  }

  Future<Null> addOfferThread() async {
    String url =
        '${MyConstant().domain}/mobile/addOffer.php?isAdd=true&customerRequireId=$customerRequireId&storeId=$storeId&price=$price';
    try {
      Response response = await Dio().get(url);
      print('res = $response');
      if (response.toString() == 'true') {
        Navigator.pop(context);
        notificationToCustomer(customerRequireId);
        setState(() {
          loading = false;
          shopCards = [];
          allEstModel = [];
        });
        readEst();
      } else {
        normalDialog(context, 'ไม่สามารถอัพเดทสถานะ');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<Null> notificationToCustomer(String customerRequireId) async {
    print(customerRequireId);
    String urlFindToken =
        '${MyConstant().domain}/mobile/getTokenCusOnRequire.php?isAdd=true&requireId=$customerRequireId';
    await Dio().get(urlFindToken).then((value) {
      var result = json.decode(value.data);
      print('result = $result');
      for (var json in result) {
        var token = json['token'];
        print(token);
        //String token = customerModel.token;
        //print('token = $token');
        String title = 'ร้านซ่อมได้ตอบรับข้อเสนอราคาของคุณแล้ว';
        String body = 'กรุณาตรวจสอบ';
        String urlSendToken =
            '${MyConstant().domain}/mobile/apiNotification.php?isAdd=true&token=$token&title=$title&body=$body';
        sendNotificaionToCus(urlSendToken);
        print(urlSendToken);
      }
    });
  }

  Future<Null> sendNotificaionToCus(String urlSendToken) async {
    await Dio().get(urlSendToken).then((value) => null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: loading == false
                ? LinearProgressIndicator()
                : shopCards.length != 0
                    ? Center(child: Column(children: shopCards))
                    : Center(
                        child: Column(
                          children: <Widget>[
                            Image.asset(
                              'images/hello.png',
                              scale: 1.5,
                            ),
                            Text(
                              'ยังไม่มีรายการ\nเสนอราคา',
                              style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black38),
                            )
                          ],
                        ),
                      )));
  }

  Widget createCard(AllRequireEstModel allEstModel, int index) {
    return Container(
      width: 300,
      child: GestureDetector(
        onTap: () {},
        child: Card(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'รหัสรายการ: E${allEstModel.id}',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            Text('ชื่อลูกค้า: ${allEstModel.customerName}'),
            Text('หัวเรื่อง: ${allEstModel.header}'),
            Text('รายละเอียด: ${allEstModel.detail}'),
            ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.red),
                onPressed: () {
                  print(allEstModel.id);
                  print(allEstModel.customerName);
                  print(allEstModel.header);
                  print(allEstModel.detail);
                  setState(() {
                    customerRequireId = allEstModel.id;
                    header = allEstModel.header;
                    detail = allEstModel.detail;
                  });
                  showDialog(
                      context: context, builder: (context) => dialogAdd());
                },
                child: Text('เสนอราคา'))
          ],
        )),
      ),
    );
  }

  Widget dialogAdd() => AlertDialog(
        title: Text('แบบฟอร์มให้ร้านเสนอราคา'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('รหัสสินค้า: $customerRequireId'),
                  Text('หัวเรื่อง: $header'),
                  Text('รายละเอียดสินค้า: $detail'),
                  TextFormField(
                    onChanged: (value) => price = value.trim(),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'ราคา:',
                      hintText: "ใส่ราคาโดยประมาณ",
                    ),
                  ),
                  MyStyle().mySizebox(),
                  SizedBox(
                    width: 230,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: Colors.green),
                        onPressed: () {
                          addOfferThread();
                          Fluttertoast.showToast(
                              msg: "เสนอราคาเรียบร้อยแล้ว",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1);
                        },
                        child: Text('ตกลง')),
                  )
                ],
              ),
            );
          },
        ),
      );
}
