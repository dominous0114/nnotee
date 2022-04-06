import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:nnotee/Services/requireServices.dart';
import 'package:nnotee/model/cusrec_model.dart';
import 'package:nnotee/model/customer_model.dart';
import 'package:nnotee/model/require_est_model.dart';
import 'package:nnotee/model/tracking.dart';
import 'package:nnotee/screen/customer/requireCustomer.dart';
import 'package:nnotee/screen/customer/show_chatfromrecord.dart';
import 'package:nnotee/screen/customer/showchat_fromrequire.dart';
import 'package:nnotee/utility/my_constant.dart';
import 'package:nnotee/utility/normal_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutRequire extends StatefulWidget {
  final RequireEstModel requireModel;
  const AboutRequire({Key key, this.requireModel}) : super(key: key);

  @override
  _AboutRequireState createState() => _AboutRequireState();
}

class _AboutRequireState extends State<AboutRequire> {
  RequireEstModel requireModel;
  TrackModel trackModel;
  String distance = '1589999';
  int index;
  List<RequireEstModel> requireList = [];
  bool loading;
  double lati, longi;
  String requireId, latitude, longitude, storeLati, storeLongi;
  Location newlocation = Location();
  CustomerModel customerModel;
  CustomerRecordModel customerRecordModel;
  @override
  void initState() {
    requireModel = widget.requireModel;
    requireId = requireModel.id;
    readDataRequire(requireModel);
    super.initState();
  }

  void routeToEstInfo() {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (context) => RequireCs(),
    );
    Navigator.push(context, materialPageRoute);
  }

  Future<Null> deleteRequireThread() async {
    String url =
        '${MyConstant().domain}/mobile/deleteEst.php?isAdd=true&estId=$requireId';
    try {
      Response response = await Dio().get(url);
      print('res = $response');
      if (response.toString() == 'true') {
        normalDialog(context, 'ลบข้อเสนอแล้ว');
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
        routeToEstInfo();
      } else {
        normalDialog(context, 'ไม่สามารถลบได้');
      }
    } catch (e) {
      print(e);
    }
  }

  readDataRequire(requireModel) async {
    LocationData locationData = await findLocationData();
    setState(() {
      lati = locationData.latitude;
      longi = locationData.longitude;
      latitude = lati.toString();
      longitude = longi.toString();
    });
    RequireServices.readDataRequire(requireId, latitude, longitude)
        .then((requireModel) {
      setState(() {
        requireList = requireModel;
      });
      print('List: ${requireModel.length}');
      print('$latitude,$longitude');
    });
  }

  Future<LocationData> findLocationData() async {
    Location location = Location();
    try {
      return location.getLocation();
    } catch (e) {
      return null;
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
                            'รหัสรายการ: ${requireModel.id}',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          Text('หัวเรื่อง: ${requireModel.header}'),
                          Text('รายละเอียด: ${requireModel.detail}'),
                          Text('ราคา: ${requireModel.price} บาท'),
                          SizedBox(
                            height: 50,
                          ),
                          Text(
                            'รายชื่อร้านซ่อมที่รับข้อเสนอ',
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
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.green),
                                onPressed: () {
                                  deleteRequireThread();
                                },
                                child: Text('เสร็จสิ้น')),
                          ),
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
              columnSpacing: 20.0,
              columns: [
                DataColumn(label: Text('ชื่อร้าน')),
                DataColumn(label: Text('ระยะทาง')),
                DataColumn(label: Text('')),
              ],
              rows: requireList
                  .map(
                    (requireModel) => DataRow(cells: [
                      DataCell(
                        Text(requireModel.storeName),
                      ),
                      DataCell(Text('${requireModel.distance} กิโลเมตร')),
                      DataCell(ElevatedButton(
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
                                              'ร้าน ${requireModel.storeName}'),
                                          onTap: () {},
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.map),
                                          title: Text('ไปที่ร้าน'),
                                          onTap: () {
                                            setState(() {
                                              storeLati =
                                                  requireModel.storeLati;
                                              storeLongi =
                                                  requireModel.storeLongi;
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
                                                      ShowChatFromreq(
                                                        requireModel:
                                                            requireModel,
                                                      )),
                                            );
                                          },
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.phone),
                                          title: Text('โทร'),
                                          onTap: () {
                                            launch(
                                                'tel://${requireModel.storeTel}');
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                });
                          },
                          child: Text('ติดต่อร้าน'))),
                    ]),
                  )
                  .toList()),
        ),
      );
}
