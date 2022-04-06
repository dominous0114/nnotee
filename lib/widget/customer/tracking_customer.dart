import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:nnotee/Services/TrackServices.dart';
import 'package:nnotee/model/customer_model.dart';
import 'package:nnotee/model/store_order.dart';
import 'package:nnotee/screen/customer/review_screen.dart';
import 'package:nnotee/screen/customer/show_chatfromtrack.dart';
import 'package:nnotee/screen/store/add_order.dart';
import 'package:nnotee/screen/store/order_screen.dart';
import 'package:nnotee/screen/customer/show_tracking.dart';
import 'package:nnotee/utility/my_constant.dart';
import 'package:nnotee/utility/my_style.dart';
import 'package:nnotee/utility/normal_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class TrackingCustomer extends StatefulWidget {
  @override
  _TrackingCustomerState createState() => _TrackingCustomerState();
}

class _TrackingCustomerState extends State<TrackingCustomer> {
  int index;
  List<OrderModel> orderModels = [];
  List<Widget> shopCards = [];
  String storeId,
      customerId,
      score = '3',
      detail,
      user,
      orderId,
      storeName,
      storeLati,
      storeLongi;
  int statusId;
  bool loading;
  @override
  void initState() {
    readOrder();
    loading = false;
    super.initState();
  }

  void routeToReviewInfo() {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (context) => ReviewScreen(),
    );
    Navigator.push(context, materialPageRoute);
  }

  Future<Null> readOrder() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      customerId = preferences.getString('idcus');
      loading = true;
    });
    String url =
        '${MyConstant().domain}/mobile/trackingWhereCustomer.php?isAdd=true&customerId=$customerId';
    await Dio().get(url).then((value) {
      var result = json.decode(value.data);
      index = 0;
      for (var map in result) {
        OrderModel model = OrderModel.fromJson(map);
        orderModels.add(model);
        shopCards.add(createCard(model, index));
        index++;
        setState(() {});
      }
    });
  }

  Future<Null> addReviewThread() async {
    print(orderId);
    print(detail);
    print(score);
    String url =
        '${MyConstant().domain}/mobile/addReview.php?isAdd=true&orderId=$orderId&detail=$detail&score=$score';
    try {
      Response response = await Dio().get(url);
      print('res = $response');
      if (response.toString() == 'true') {
        Navigator.pop(context);
        normalDialog(context, 'เสร็จแล้ว');
      } else {
        normalDialog(context, 'ไม่สามารถอัพเดทสถานะ');
      }
      setState(() {
        score = '3';
        detail = null;
      });
    } catch (e) {
      print(e);
    }
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
        onTap: () {
          MaterialPageRoute route = MaterialPageRoute(
            builder: (context) => ShowTracking(
              orderModel: orderModels[index],
            ),
          );
          Navigator.push(context, route);
        },
        child: Card(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'ชื่อร้านซ่อม: ${orderModel.storeName}',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            Text('รายละเอียด: ${orderModel.detail}'),
            Text('ราคาทั้งหมด: ${orderModel.totalprice} บาท'),
            Text('รหัสออเดอร์: ${orderModel.ordersId}'),
            Text('สถานะ: ${orderModel.statusName}'),
            orderModel.statusName == 'เสร็จแล้ว'
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.green),
                    onPressed: () {
                      if (orderModel.numReview != '1') {
                        orderId = orderModel.ordersId;
                        storeName = orderModel.storeName;
                        print(orderId);
                        print(orderModel.ordersId);
                        print(orderModel.storeId);
                        print(orderModel.storeName);
                        print(orderModel.statusName);
                        print(orderModel.name);
                        orderId = orderModel.ordersId;
                        showDialog(
                            context: context,
                            builder: (context) => dialogAdd(orderModel));
                        setState(() {});
                      } else {
                        normalDialog(context, 'ท่านได้รีวิวรายการนี้ไปแล้ว');
                      }
                    },
                    child: Text('รีวิว'))
                : ElevatedButton(
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
                      showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return Container(
                              height: 250,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    title: Text('ร้าน ${orderModel.storeName}'),
                                    onTap: () {},
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.map),
                                    title: Text('ไปที่ร้าน'),
                                    onTap: () {
                                      setState(() {
                                        storeLati = orderModel.storelati;
                                        storeLongi = orderModel.storelongi;
                                      });
                                      openMap();
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.chat),
                                    title: Text('แชท'),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ShowChatFromTracking(
                                                  orderModel: orderModel,
                                                )),
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.phone),
                                    title: Text('โทร'),
                                    onTap: () {
                                      launch('tel://${orderModel.storeTel}');
                                    },
                                  ),
                                ],
                              ),
                            );
                          });
                    },
                    child: Text('ติดต่อร้าน'))
          ],
        )),
      ),
    );
  }

  void openMap() async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=$storeLati,$storeLongi';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget dialogAdd(OrderModel orderModel) => AlertDialog(
        title: Text('ร้าน ${orderModel.storeName}'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'กรุณาให้คะแนน',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  RatingBar.builder(
                    initialRating: 3,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        score = rating.toString();
                      });
                      print(rating);
                      print('score: $score');
                    },
                  ),
                  SizedBox(
                    width: 220,
                    child: TextFormField(
                      maxLines: 2,
                      onChanged: (value) => detail = value.trim(),
                      decoration: InputDecoration(
                        labelText: 'รายละเอียดเพิ่มเติม:',
                        hintText: "ใส่รายระเอียดเพิ่มเติม",
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 220,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: Colors.green),
                        onPressed: () {
                          if (detail == null) {
                            setState(() {
                              detail = '';
                              addReviewThread();
                            });
                          } else {
                            addReviewThread();
                          }
                        },
                        child: Text('รีวิว')),
                  )
                ],
              ),
            );
          },
        ),
      );
}
