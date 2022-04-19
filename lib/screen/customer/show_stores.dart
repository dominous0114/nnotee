import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nnotee/model/product.dart';
import 'package:nnotee/model/store_model.dart';
//import 'package:nnotee/screen/customer/report_cus.dart';
import 'package:nnotee/utility/my_constant.dart';
import 'package:nnotee/utility/normal_dialog.dart';
import 'package:nnotee/widget/customer/about_product.dart';
import 'package:nnotee/widget/customer/about_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowStores extends StatefulWidget {
  final StoreModel storeModel;
  ShowStores({Key key, this.storeModel}) : super(key: key);

  @override
  _ShowStoresState createState() => _ShowStoresState();
}

class _ShowStoresState extends State<ShowStores> {
  StoreModel storeModel;
  ProductModel productModel;
  List<Widget> listWidgets = [];
  int indexPage = 0;
  List<String> headerList = [
    'ร้านซ่อมนี้ไม่มีอยู่จริง',
    'ร้านซ่อมนี้ได้ปิดไปแล้ว',
    'อื่นๆ'
  ];
  String dropdownValue = 'ร้านซ่อมนี้ไม่มีอยู่จริง';
  String detail, customerId;
  String header;

  @override
  void initState() {
    super.initState();
    storeModel = widget.storeModel;
    listWidgets.add(AboutStore(
      storeModel: storeModel,
    ));
    listWidgets.add(AboutProduct(storeModel: storeModel));
  }

  BottomNavigationBarItem aboutStoreNav() {
    return BottomNavigationBarItem(
        icon: Icon(Icons.shop), label: ('รายละเอียดร้าน'));
  }

  BottomNavigationBarItem aboutProductNav() {
    return BottomNavigationBarItem(
        icon: Icon(Icons.widgets), label: ('รายละเอียดสินค้า'));
  }

  Future<Null> checkPreference() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String type = preferences.getString('type');
      if (type == 'customer') {
        showDialog(context: context, builder: (context) => dialogAdd());
      } else {
        normalDialog(context, 'กรุณาเข้าสู่ระบบ');
      }
    } catch (e) {}
  }

  Future<Null> addReportThread() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String idcus = preferences.getString('idcus');
    print('idCustomer = $idcus');
    setState(() {
      header = dropdownValue;
    });
    print(header);
    String url =
        '${MyConstant().domain}/mobile/addReport.php?isAdd=true&customerid=$idcus&header=$header&detail=$detail&&storeid=${storeModel.id}';
    try {
      print(url);
      Response response = await Dio().get(url);
      print('res = $response');
      if (response.toString() == 'true') {
        Fluttertoast.showToast(
            msg: "ส่งข้อมูลการรายงานแล้ว",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1);
      } else {
        normalDialog(context, 'ไม่สามารถส่งข้อมูลการรายงาน');
      }
    } catch (e) {
      print(e);
    }
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
          storeModel.name,
          style: TextStyle(color: Colors.black38),
        ),
        actions: [
          IconButton(
              color: Colors.black38,
              onPressed: () {
                checkPreference();
              },
              icon: Icon(Icons.warning_rounded))
        ],
      ),
      body: listWidgets.length == 0
          ? LinearProgressIndicator()
          : listWidgets[indexPage],
      bottomNavigationBar: showBottomNavigationBar(),
    );
  }

  BottomNavigationBar showBottomNavigationBar() => BottomNavigationBar(
        currentIndex: indexPage,
        onTap: (value) {
          setState(() {
            indexPage = value;
          });
        },
        items: <BottomNavigationBarItem>[
          aboutStoreNav(),
          aboutProductNav(),
        ],
      );

  Widget dialogAdd() => AlertDialog(
        title: Text(
          'แบบฟอร์มการรายงานร้านซ่อม',
          overflow: TextOverflow.visible,
        ),
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
                            child: Text(value, overflow: TextOverflow.visible),
                          );
                        }).toList(),
                      ),
                    ],
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
                            Navigator.pop(context);
                            addReportThread();
                            print(customerId);
                            print(header);
                            print(detail);
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
