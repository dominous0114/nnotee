import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:nnotee/model/require_est_model.dart';
import 'package:nnotee/screen/customer/estCustomer.dart';
import 'package:nnotee/screen/customer/show_est.dart';
import 'package:nnotee/utility/my_constant.dart';
import 'package:nnotee/utility/my_style.dart';
import 'package:nnotee/utility/normal_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CardEstCs extends StatefulWidget {
  @override
  _CardEstCsState createState() => _CardEstCsState();
}

class _CardEstCsState extends State<CardEstCs> {
  int index;
  List<RequireEstModel> estModels = [];
  List<Widget> shopCards = [];
  String customerId, estId;
  String orderId;
  var result;
  bool loading;

  @override
  void initState() {
    readEst();
    loading = false;
    super.initState();
  }

  void routeToEstInfo() {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (context) => EstCustomer(),
    );
    Navigator.push(context, materialPageRoute);
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
        routeToEstInfo();
      } else {
        normalDialog(context, 'ไม่สามารถลบได้');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<Null> readEst() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      customerId = preferences.getString('idcus');
      loading = true;
    });
    String url =
        '${MyConstant().domain}/mobile/estWhereCustomer.php?isAdd=true&customerId=$customerId';
    await Dio().get(url).then((value) {
      result = json.decode(value.data);
      print(result);
      index = 0;
      for (var map in result) {
        RequireEstModel model = RequireEstModel.fromJson(map);
        estModels.add(model);
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

  Widget createCard(RequireEstModel estModel, int index) {
    return Container(
      width: 300,
      child: GestureDetector(
        onTap: () {
          MaterialPageRoute route = MaterialPageRoute(
            builder: (context) => ShowEst(
              estModel: estModels[index],
            ),
          );
          Navigator.push(context, route);
        },
        child: Card(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'รหัสรายการ: ${estModel.id}',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            Text('หัวเรื่อง: ${estModel.header}'),
            Text('รายละเอียด: ${estModel.detail}'),
            Text('สถานะ: ${estModel.statusName}'),
            ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.red),
                onPressed: () {
                  setState(() {
                    estId = estModel.id;
                    deleteEstThread();
                    print(estId);
                  });
                },
                child: Text('ยกเลิก'))
          ],
        )),
      ),
    );
  }
}
