import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nnotee/model/require_est_model.dart';
import 'package:nnotee/screen/customer/requireCustomer.dart';
import 'package:nnotee/screen/customer/show_require.dart';
import 'package:nnotee/utility/my_constant.dart';
import 'package:nnotee/utility/my_style.dart';
import 'package:nnotee/utility/normal_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CardRequireCs extends StatefulWidget {
  @override
  _CardRequireCsState createState() => _CardRequireCsState();
}

class _CardRequireCsState extends State<CardRequireCs> {
  int index;
  List<RequireEstModel> requireModels = [];
  List<Widget> shopCards = [];
  var result;
  String customerId, orderId, requireId;
  bool loading;

  @override
  void initState() {
    readRequire();
    loading = false;
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
        routeToEstInfo();
      } else {
        normalDialog(context, 'ไม่สามารถลบได้');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<Null> readRequire() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      customerId = preferences.getString('idcus');
      loading = true;
    });
    String url =
        '${MyConstant().domain}/mobile/requireWhereCustomer.php?isAdd=true&customerId=$customerId';
    await Dio().get(url).then((value) {
      result = json.decode(value.data);
      index = 0;
      for (var map in result) {
        RequireEstModel model = RequireEstModel.fromJson(map);
        requireModels.add(model);
        shopCards.add(createCard(model, index));
        index++;
        setState(() {});
      }
    });
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

  Widget createCard(RequireEstModel requireModel, int index) {
    return Container(
      width: 300,
      child: GestureDetector(
        onTap: () {
          MaterialPageRoute route = MaterialPageRoute(
            builder: (context) => ShowRequire(
              requireModel: requireModels[index],
            ),
          );
          Navigator.push(context, route);
        },
        child: Card(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'รหัสรายการ: ${requireModel.id}',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            Text('หัวเรื่อง: ${requireModel.header}'),
            Text('รายละเอียด: ${requireModel.detail}'),
            Text('ราคา: ${requireModel.price} บาท'),
            Text('สถานะ: ${requireModel.statusName}'),
            ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.red),
                onPressed: () {
                  setState(() {
                    requireId = requireModel.id;
                    deleteRequireThread();
                  });
                },
                child: Text('ยกเลิก'))
          ],
        )),
      ),
    );
  }
}
