import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nnotee/utility/my_constant.dart';
import 'package:nnotee/utility/normal_dialog.dart';
import 'package:nnotee/widget/customer/card_require_cs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequireCs extends StatefulWidget {
  @override
  _RequireCsState createState() => _RequireCsState();
}

class _RequireCsState extends State<RequireCs> {
  List<String> headerList = ['เปลี่ยนยาง', 'เปลี่ยนอะไหล่'];
  String dropdownValue = 'เปลี่ยนยาง';
  String header, price, detail, customerId;
  @override
  void initState() {
    getWhereCustomer();
    super.initState();
  }

  getWhereCustomer() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      customerId = preferences.getString('idcus');
    });
    print('customerId : $customerId');
  }

  void routeToRequireInfo() {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (context) => RequireCs(),
    );
    Navigator.push(context, materialPageRoute);
  }

  Future<Null> addRequireThread() async {
    setState(() {
      header = dropdownValue;
    });
    print(header);
    String url =
        '${MyConstant().domain}/mobile/addRequire.php?isAdd=true&customerId=$customerId&typeId=1&header=$header&detail=$detail&price=$price';
    try {
      Response response = await Dio().get(url);
      print('res = $response');
      if (response.toString() == 'true') {
        notificationToStore(customerId);
        Navigator.pop(context);
        Navigator.pop(context);
        routeToRequireInfo();
      } else {
        normalDialog(context, 'ไม่สามารถเพิ่มสินค้าได้');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<Null> notificationToStore(String customerId) async {
    String urlFindToken =
        '${MyConstant().domain}/mobile/getCustomerWhereId.php?isAdd=true&id=$customerId';
    await Dio().get(urlFindToken).then((value) {
      var result = json.decode(value.data);
      print('result = $result');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              color: Colors.black38,
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios_new_outlined,
              )),
          title: Text(
            'รายการเสนอความต้องการให้ร้านซ่อม',
            style: TextStyle(color: Colors.black38),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          foregroundColor: Colors.black,
          onPressed: () {
            showDialog(context: context, builder: (context) => dialogAdd());
          },
          child: Icon(Icons.add),
        ),
        body: CardRequireCs());
  }

  Widget dialogAdd() => AlertDialog(
        title: Text('แบบฟอร์มเสนอความต้องการ           '),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('หัวเรื่อง : '),
                      DropdownButton<String>(
                        value: dropdownValue,
                        onChanged: (String newValue) {
                          setState(() {
                            dropdownValue = newValue;
                          });
                        },
                        items: headerList
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) => price = value.trim(),
                    decoration: const InputDecoration(
                      hintText: 'ใส่ราคาที่ต้องการ',
                      labelText: 'ราคา/บาท:',
                    ),
                  ),
                  TextFormField(
                    maxLines: 2,
                    onChanged: (value) => detail = value.trim(),
                    decoration: InputDecoration(
                      labelText: 'รายละเอียดเพิ่มเติม:',
                      hintText: "ใส่รายระเอียดเพิ่มเติม",
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                          style:
                              ElevatedButton.styleFrom(primary: Colors.green),
                          onPressed: () {
                            addRequireThread();
                          },
                          child: Text('ตกลง')),
                      SizedBox(
                        width: 25,
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(primary: Colors.red),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('ยกเลิก'))
                    ],
                  )
                ],
              ),
            );
          },
        ),
      );
}
