//import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
//import 'package:location/location.dart';
import 'package:nnotee/Services/TrackServices.dart';
//import 'package:nnotee/Services/productServices.dart';
import 'package:nnotee/model/product.dart';
import 'package:nnotee/model/store_order.dart';
import 'package:nnotee/model/tracking.dart';
import 'package:nnotee/screen/customer/show_chatfromtrack.dart';
import 'package:nnotee/utility/my_constant.dart';

import 'package:nnotee/utility/my_style.dart';
import 'package:nnotee/utility/normal_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutTracking extends StatefulWidget {
  final OrderModel orderModel;
  const AboutTracking({Key key, this.orderModel}) : super(key: key);

  @override
  _AboutTrackingState createState() => _AboutTrackingState();
}

class _AboutTrackingState extends State<AboutTracking> {
  String orderId, score = '3', detail, storeLati, storeLongi;
  OrderModel orderModel;
  ProductModel productModel;
  TrackModel trackModel;
  int index;
  List<TrackModel> trackList = [];
  bool loading;
  @override
  void initState() {
    super.initState();
    loading = false;
    orderModel = widget.orderModel;
    orderId = orderModel.ordersId;
    readDataTrack(trackModel);
  }

  readDataTrack(TrackModel trackModel) async {
    TrackServices.readDataTrack(orderId).then((trackModel) {
      setState(() {
        loading = true;
        trackList = trackModel;
      });
      print('List: ${trackModel.length}');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Center(
                child: loading == false
                    ? LinearProgressIndicator()
                    : Column(
                        children: [
                          SizedBox(
                            height: 50,
                          ),
                          Text(
                            'ชื่อร้านซ่อม: ${orderModel.storeName}',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          Text('รายละเอียด: ${orderModel.detail}'),
                          Text('ราคาทั้งหมด: ${orderModel.totalprice} บาท'),
                          Text('รหัสออเดอร์: ${orderModel.ordersId}'),
                          Text('สถานะ: ${orderModel.statusName}'),
                          SizedBox(
                            height: 50,
                          ),
                          Text(
                            'ประวัติการติดตามสถานะ',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w800),
                          ),
                          dataTable(),
                          SizedBox(
                            height: 50,
                          ),
                          SizedBox(
                            width: 300,
                            child: ElevatedButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return Container(
                                          height: 250,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ListTile(
                                                title: Text(
                                                    'ร้าน ${orderModel.storeName}'),
                                                onTap: () {},
                                              ),
                                              ListTile(
                                                leading: Icon(Icons.map),
                                                title: Text('ไปที่ร้าน'),
                                                onTap: () {
                                                  setState(() {
                                                    storeLati =
                                                        orderModel.storelati;
                                                    storeLongi =
                                                        orderModel.storelongi;
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
                                                              orderModel:
                                                                  orderModel,
                                                            )),
                                                  );
                                                },
                                              ),
                                              ListTile(
                                                leading: Icon(Icons.phone),
                                                title: Text('โทร'),
                                                onTap: () {
                                                  launch(
                                                      'tel://${orderModel.storeTel}');
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      });
                                },
                                child: Text('ติดต่อร้าน')),
                          ),
                          orderModel.statusName == 'เสร็จแล้ว'
                              ? SizedBox(
                                  width: 300,
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          primary: Colors.green),
                                      onPressed: () {
                                        orderId = orderModel.ordersId;
                                        showDialog(
                                            context: context,
                                            builder: (context) =>
                                                dialogAdd(orderModel));
                                        setState(() {});
                                      },
                                      child: Text('รีวิว')),
                                )
                              : Container()
                        ],
                      ))));
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

  Widget dataTable() => SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
              columnSpacing: 38.0,
              columns: [
                DataColumn(label: Text('สถานะ')),
                DataColumn(label: Text('วันที่')),
              ],
              rows: trackList
                  .map(
                    (trackModel) => DataRow(cells: [
                      DataCell(
                        Text(trackModel.trackingName),
                      ),
                      DataCell(
                        Text(trackModel.date),
                      ),
                    ]),
                  )
                  .toList()),
        ),
      );
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

  Widget showNoData(BuildContext context) =>
      MyStyle().titleCenter(context, 'ข้อมูล');
}
