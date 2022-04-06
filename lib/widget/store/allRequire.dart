import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nnotee/model/allRequireEst.dart';
import 'package:nnotee/utility/banstore.dart';
import 'package:nnotee/utility/my_constant.dart';
import 'package:nnotee/utility/normal_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllRequire extends StatefulWidget {
  @override
  _AllRequireState createState() => _AllRequireState();
}

class _AllRequireState extends State<AllRequire> {
  int index;
  List<AllRequireEstModel> allEstModel = [];
  List<Widget> shopCards = [];
  String storeId, price, customerRequireId, header, detail;
  var result;
  bool loading;

  @override
  void initState() {
    BanStore().readdataBan(context);
    readRequire();
    loading = false;
    super.initState();
  }

  Future<Null> readRequire() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      storeId = preferences.getString('idst');
      loading = true;
    });
    String url =
        '${MyConstant().domain}/mobile/allRequireWhereStore.php?isAdd=true&storeId=$storeId';
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
        notificationToCustomer(customerRequireId);
        setState(() {
          loading = false;
          shopCards = [];
          allEstModel = [];
        });
        readRequire();
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
        String title = 'ร้านซ่อมได้รับข้อเสนอของคุณแล้ว';
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
                              'ยังไม่มีรายการ\nรับข้อเสนอ',
                              style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black38),
                            )
                          ],
                        ),
                      )));
  }

  Widget createCard(AllRequireEstModel allRequireModel, int index) {
    return Container(
      width: 300,
      child: GestureDetector(
        onTap: () {},
        child: Card(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'รหัสรายการ: R${allRequireModel.id}',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            Text('ชื่อลูกค้า: ${allRequireModel.customerName}'),
            Text('หัวเรื่อง: ${allRequireModel.header}'),
            Text('รายละเอียด: ${allRequireModel.detail}'),
            Text('ราคา: ประมาณ ~${allRequireModel.price} บาท'),
            ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.green),
                onPressed: () {
                  setState(() {
                    customerRequireId = allRequireModel.id;
                    price = allRequireModel.price;
                    print('customeRequireId: $customerRequireId');
                    print('storeId: $storeId');
                    print('price: $price');
                  });
                  addOfferThread();
                },
                child: Text('ตอบรับ'))
          ],
        )),
      ),
    );
  }
}
