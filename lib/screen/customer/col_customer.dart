import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nnotee/model/cusrec_model.dart';
import 'package:nnotee/screen/customer/show_chatfromrecord.dart';
import 'package:nnotee/screen/signin.dart';
import 'package:nnotee/utility/my_constant.dart';
import 'package:nnotee/utility/my_style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class CusCol extends StatefulWidget {
  @override
  _CusColState createState() => _CusColState();
}

List<CustomerRecordModel> cusrecmodel = [];
List<Widget> shopCards = [];
List<CustomerRecordModel> cusrecList = [];

class _CusColState extends State<CusCol> {
  void initState() {
    readCustomerRecord();

    cusrecmodel = [];
    shopCards = [];
    cusrecList = [];

    super.initState();
  }

  Future<Null> readCustomerRecord() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.getString('idcus');
    String url =
        '${MyConstant().domain}/mobile/getRocordCus.php?isAdd=true&customer_id=$id';
    await Dio().get(url).then((value) {
      print('value = $value');
      var result = json.decode(value.data);
      int index = 0;
      for (var map in result) {
        CustomerRecordModel model = CustomerRecordModel.fromJson(map);
        String name = model.name;
        if (name.isNotEmpty) {
          print('*******************${model.name}');
          if (mounted)
            setState(() {
              cusrecmodel.add(model);
              shopCards.add(createCard(model, index));
              print(shopCards);
              print('$model, $index,');
              index++;
            });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'ที่บักทึกไว้',
            style: TextStyle(color: Colors.black38),
          ),
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
            : Center(
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
              ));
  }

  Widget createCard(CustomerRecordModel customerRecordModel, int index) {
    return Stack(
      children: [
        Container(
          width: 500.0,
          child: GestureDetector(
            onTap: () {
              _onEditPressed(customerRecordModel);
            },
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
                              NetworkImage('${customerRecordModel.pic}'),
                          backgroundColor: Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(
                      'ชื่อ : ${customerRecordModel.name}\nเบอร์โทร : ${customerRecordModel.tel}\nE-mail : ${customerRecordModel.email}',
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

  void _onEditPressed(CustomerRecordModel customerRecordModel) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: Text(
                    '${customerRecordModel.name}',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.chat),
                  title: Text('แชท'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ShowChatFromRecord(
                                customerRecordModel: customerRecordModel,
                              )),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.phone),
                  title: Text('โทร'),
                  onTap: () {
                    launch('tel://${customerRecordModel.tel}');
                  },
                )
              ],
            ),
          );
        });
  }
}
