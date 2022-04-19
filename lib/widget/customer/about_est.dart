import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:nnotee/Services/requireServices.dart';
import 'package:nnotee/model/cusrec_model.dart';
import 'package:nnotee/model/require_est_model.dart';
import 'package:nnotee/model/tracking.dart';
import 'package:nnotee/screen/customer/estCustomer.dart';
//import 'package:nnotee/screen/customer/show_chatfromrecord.dart';
import 'package:nnotee/screen/customer/showchat_fromrequire.dart';
import 'package:nnotee/utility/my_constant.dart';
import 'package:nnotee/utility/normal_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutEst extends StatefulWidget {
  final RequireEstModel estModel;
  const AboutEst({Key key, this.estModel}) : super(key: key);

  @override
  _AboutEstState createState() => _AboutEstState();
}

class _AboutEstState extends State<AboutEst> {
  RequireEstModel estModel;
  TrackModel trackModel;
  int index;
  List<RequireEstModel> estList = [];
  bool loading;
  double lati, longi;
  String storeLati, storeLongi;
  String requireId, latitude, longitude, estId;
  Location newlocation = Location();
  CustomerRecordModel customerRecordModel;
  @override
  void initState() {
    estModel = widget.estModel;
    requireId = estModel.id;
    readDataEst(estModel);
    super.initState();
  }

  void routeToEstInfo() {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (context) => EstCustomer(),
    );
    Navigator.push(context, materialPageRoute);
  }

  Future<Null> readCustomerRecord() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.getString('idcus');
    String url =
        '${MyConstant().domain}/mobile/getRocordCus.php?isAdd=true&customer_id=$id';
    await Dio().get(url).then((value) {
      print('value = $value');
      var result = json.decode(value.data);
      for (var map in result) {
        setState(() {
          customerRecordModel = CustomerRecordModel.fromJson(map);
        });

        String name = customerRecordModel.name;
        if (name.isNotEmpty) {
          print('*******************${customerRecordModel.name}');
        }
      }
    });
  }

  Future<Null> deleteEstThread() async {
    String url =
        '${MyConstant().domain}/mobile/deleteEst.php?isAdd=true&estId=$estId';
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

  readDataEst(estModel) async {
    LocationData locationData = await findLocationData();
    setState(() {
      lati = locationData.latitude;
      longi = locationData.longitude;
      latitude = lati.toString();
      longitude = longi.toString();
    });
    RequireServices.readDataEst(requireId, latitude, longitude)
        .then((estModel) {
      setState(() {
        estList = estModel;
      });
      print('List: ${estModel.length}');
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
                            'รหัสรายการ: ${estModel.id}',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          Text('หัวเรื่อง: ${estModel.header}'),
                          Text('รายละเอียด: ${estModel.detail}'),
                          SizedBox(
                            height: 50,
                          ),
                          Text(
                            'รายชื่อร้านซ่อมที่เสนอราคา',
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
                                  setState(() {
                                    estId = estModel.id;
                                    deleteEstThread();
                                  });
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
                DataColumn(label: Text('ราคา/ประมาณ')),
                DataColumn(label: Text('ระยะทาง')),
                DataColumn(label: Text('')),
              ],
              rows: estList
                  .map(
                    (estModel) => DataRow(cells: [
                      DataCell(
                        Text(estModel.storeName),
                      ),
                      DataCell(
                        Text('${estModel.price} บาท'),
                      ),
                      DataCell(Text('${estModel.distance} กิโลเมตร')),
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
                                              'ร้าน ${estModel.storeName}'),
                                          onTap: () {},
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.map),
                                          title: Text('ไปที่ร้าน'),
                                          onTap: () {
                                            setState(() {
                                              storeLati = estModel.storeLati;
                                              storeLongi = estModel.storeLongi;
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
                                                        requireModel: estModel,
                                                      )),
                                            );
                                          },
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.phone),
                                          title: Text('โทร'),
                                          onTap: () {
                                            launch(
                                                'tel://${estModel.storeTel}');
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                });
                          },
                          child: Text('ติดต่อร้าน'))),
                      // DataCell(
                      //  IconButton(onPressed: (){launch('tel://${estModel.storeTel}');}, icon: Icon(Icons.phone))
                      // ),
                    ]),
                  )
                  .toList()),
        ),
      );
}
