import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nnotee/Services/TrackServices.dart';
import 'package:nnotee/model/customer_model.dart';
import 'package:nnotee/model/store_order.dart';
import 'package:nnotee/screen/store/add_order.dart';
import 'package:nnotee/screen/store/order_screen.dart';
import 'package:nnotee/utility/banstore.dart';
import 'package:nnotee/utility/my_constant.dart';
import 'package:nnotee/utility/my_style.dart';
import 'package:nnotee/utility/normal_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class TestWidget extends StatefulWidget {
  @override
  _TestWidgetState createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> {
  int index;
  List<OrderModel> orderModel = [];
  List<Widget> shopCards = [];
  String storeId;
  String user;
  String orderId;
  int statusId;
  bool loading;
  @override
  void initState() {
    BanStore().readdataBan(context);
    readOrder();
    loading = false;
    super.initState();
  }

  Future<Null> readOrder() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      orderModel = [];
      shopCards = [];
      storeId = preferences.getString('idst');
      loading = true;
    });
    String url =
        '${MyConstant().domain}/mobile/orderWhereStore.php?isAdd=true&storeId=$storeId';
    await Dio().get(url).then((value) {
      var result = json.decode(value.data);
      index = 0;
      for (var map in result) {
        OrderModel model = OrderModel.fromJson(map);
        orderModel.add(model);
        shopCards.add(createCard(model, index));
        index++;
        setState(() {});
      }
    });
  }

  void routeToOrder() {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (context) => OrderSceen(),
    );
    Navigator.push(context, materialPageRoute);
  }

  Future<Null> routeToService(
      Widget myWidget, CustomerModel customerModel) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('idcus', customerModel.id);
    preferences.setString('usernamecus', customerModel.username);
    MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => myWidget,
    );
    Navigator.push(context, route);
  }

  // getOrder() async {
  //   OrderServices.getOrder().then((productModel) {
  //     setState(() {
  //       loading = true;
  //       productList = productModel;
  //     });
  //     print('StoreId: $storeId');
  //     print('Product: ${productModel.length}');
  //   });
  // }

  Future<Null> addTrackingThread(OrderModel orderModel) async {
    String url =
        '${MyConstant().domain}/mobile/addTracking.php?isAdd=true&orderId=${orderModel.ordersId}&statusId=$statusId';
    try {
      Response response = await Dio().get(url);
      print('res = $response');
      if (response.toString() == 'true') {
        readOrder();
        notificationToCustomer(orderModel);
      } else {
        normalDialog(context, 'ไม่สามารถอัพเดทสถานะ');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<Null> notificationToCustomer(OrderModel orderModel) async {
    print(orderModel.id);
    String urlFindToken =
        '${MyConstant().domain}/mobile/getTokenCusOnOrders.php?isAdd=true&orderId=${orderModel.ordersId}';
    await Dio().get(urlFindToken).then((value) {
      var result = json.decode(value.data);
      print('result = $result');
      for (var json in result) {
        var token = json['token'];
        print(token);
        //String token = customerModel.token;
        //print('token = $token');
        String title = 'สถานะการซ่อมของคุณมีความคืบหน้า';
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
                              'ยังไม่มีรายการ',
                              style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black38),
                            )
                          ],
                        ),
                      )));
  }

  Widget createCard(OrderModel orderModel, int index) {
    return Container(
      width: 300,
      child: GestureDetector(
        onTap: () {},
        child: Card(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'ออเดอร์ที่: ${orderModel.id}',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            Text('ราคาทั้งหมด: ${orderModel.totalprice} บาท'),
            Text('รหัสออเดอร์: ${orderModel.ordersId}'),
            Text('ชื่อลูกค้า: ${orderModel.name}'),
            Text('สถานะ: ${orderModel.statusName}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        orderModel.statusName == 'ยังไม่เริ่ม'
                            ? statusId = 2
                            : statusId = 3;
                        print(orderModel.id);
                        print(orderModel.ordersId);
                        print(orderModel.storeId);
                        print(orderModel.statusName);
                        print(orderModel.name);
                      });
                      showDialog(
                          context: context,
                          builder: (context) => SimpleDialog(
                                title: Text('คุณต้องการอัพเดทสถานะใช่ไหม?'),
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('ยกเลิก')),
                                      TextButton(
                                          onPressed: () {
                                            addTrackingThread(orderModel);
                                            Navigator.pop(context);
                                          },
                                          child: Text('ตกลง'))
                                    ],
                                  )
                                ],
                              ));
                    },
                    child: Text('อัพเดทสถานะ')),
                SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.green),
                    onPressed: () {
                      launch('tel://${orderModel.telCus}');
                    },
                    child: Text('โทร')),
              ],
            )
          ],
        )),
      ),
    );
  }
}
