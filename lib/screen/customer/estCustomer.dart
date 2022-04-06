import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nnotee/utility/my_constant.dart';
import 'package:nnotee/utility/normal_dialog.dart';
import 'package:nnotee/widget/customer/card_est_cs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EstCustomer extends StatefulWidget {
  @override
  _EstCustomerState createState() => _EstCustomerState();
}

class _EstCustomerState extends State<EstCustomer> {
  List<String> headerList = ['เปลี่ยนยาง', 'เปลี่ยนอะไหล่'];
  String dropdownValue = 'เปลี่ยนยาง';
  String detail,customerId;
  String header;
  
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

  void routeToEstInfo() {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (context) => EstCustomer(),
    );
    Navigator.push(context, materialPageRoute);
  }


   Future<Null> addProductThread() async {
     setState(() {
      header = dropdownValue;
    });
    print(header);
    String url =
        '${MyConstant().domain}/mobile/addEst.php?isAdd=true&customerId=$customerId&typeId=2&header=$header&detail=$detail';
    try {
      Response response = await Dio().get(url);
      print('res = $response');
      if (response.toString() == 'true') {
        Navigator.pop(context);
        Navigator.pop(context);
        routeToEstInfo();
      } else {
        normalDialog(context, 'ไม่สามารถเพิ่มสินค้าได้');
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
          'รายการให้ร้านเสนอราคา',
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
      body: CardEstCs()
    );
  }

  Widget dialogAdd() => AlertDialog(
        title: Text('แบบฟอร์มให้ร้านเสนอราคา          '),
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
                            addProductThread();
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
