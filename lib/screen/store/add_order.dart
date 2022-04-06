import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nnotee/Services/productServices.dart';
import 'package:nnotee/model/customer_model.dart';

import 'package:nnotee/model/product.dart';
import 'package:nnotee/screen/store/order_screen.dart';
import 'package:nnotee/utility/banstore.dart';
import 'package:nnotee/utility/my_constant.dart';
import 'package:nnotee/utility/normal_dialog.dart';

import 'package:shared_preferences/shared_preferences.dart';

class OrderAdd extends StatefulWidget {
  @override
  _OrderAddState createState() => _OrderAddState();
}

class _OrderAddState extends State<OrderAdd> {
  List<String> namelitems = [];
  List<String> pricelitems = [];
  List<int> totalPrice = [];
  final TextEditingController eCtrl = new TextEditingController();
  String user,
      usernameCus,
      idCus,
      idSt,
      storeId,
      detail,
      totalprice,
      tel,
      pic,
      name,
      nameProduct,
      priceProduct;
  ProductModel productModel;
  int total;
  List<ProductModel> productList;
  bool loading;
  @override
  void initState() {
    BanStore().readdataBan(context);
    readDataProduct(productModel);
    loading = false;
    super.initState();
  }

  sumPrice() {
    total = 0;
    for (var string in pricelitems) {
      total = total + int.parse(string.trim());
    }
    return Text('คิดเป็นเงิน: $total บาท');
  }

  removeItem(int index) {
    namelitems.removeAt(index);
    pricelitems.removeAt(index);
  }

  void routeToOrder() {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (context) => OrderSceen(),
    );
    Navigator.push(context, materialPageRoute);
  }

  Future<Null> addProductThread() async {
    String url =
        '${MyConstant().domain}/mobile/addOrder.php?isAdd=true&detail=$namelitems&customerid=$idCus&storeid=$storeId&total=$total';
    try {
      Response response = await Dio().get(url);
      print('res = $response');
      if (response.toString() == 'true') {
        notificationToCustomer(idCus);
        Navigator.pop(context);
      } else {
        normalDialog(context, 'ไม่สามารถเพิ่มสินค้าได้');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<Null> notificationToCustomer(String idCus) async {
    String urlFindToken =
        '${MyConstant().domain}/mobile/getCustomerWhereId.php?isAdd=true&id=$idCus';
    await Dio().get(urlFindToken).then((value) {
      var result = json.decode(value.data);
      print('result = $result');
      for (var json in result) {
        CustomerModel customerModel = CustomerModel.fromJson(json);
        String token = customerModel.token;
        print('token = $token');
        String title = 'คุณมีการออเดอร์จากร้านซ่อม';
        String body = 'กรุณาตรวจสอบ';
        String urlSendToken =
            '${MyConstant().domain}/mobile/apiNotification.php?isAdd=true&token=$token&title=$title&body=$body';
        sendNotificaionToCus(urlSendToken);
      }
    });
  }

  Future<Null> sendNotificaionToCus(String urlSendToken) async {
    await Dio().get(urlSendToken).then((value) => null);
  }

  readDataProduct(ProductModel productModel) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      storeId = preferences.getString('idst');
      idCus = preferences.getString('idcus');
      usernameCus = preferences.getString('usernamecus');
      name = preferences.getString('namecus');
      tel = preferences.getString('telcus');
      pic = preferences.getString('piccus');
    });
    ProductServices.readDataProduct(storeId).then((productModel) {
      setState(() {
        loading = true;
        productList = productModel;
      });
      print('StoreId: $storeId');
      print('Product: ${productModel.length}');
      print('$idCus');
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
          'เพิ่มออเดอร์',
          style: TextStyle(color: Colors.black38),
        ),
        actions: [
          IconButton(
              color: Colors.black38,
              onPressed: () {
                showDialog(context: context, builder: (context) => dialogAdd());
              },
              icon: Icon(Icons.add_shopping_cart))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.black,
        onPressed: () {
          showDialog(context: context, builder: (context) => dialogAnother());
        },
        child: Icon(Icons.add),
      ),
      body: loading == false
          ? LinearProgressIndicator()
          : SingleChildScrollView(
              child: Container(
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'รายการออเดอร์',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      CircleAvatar(
                        radius: 30.0,
                        backgroundImage: NetworkImage('$pic'),
                        backgroundColor: Colors.transparent,
                      ),
                      Text('ชื่อลูกค้า : $name'),
                      Text('เบอร์โทรของลูกค้า : $tel'),
                      Text(
                        'จำนวนรายการ : ${namelitems.length}',
                        textAlign: TextAlign.start,
                      ),
                      sumPrice(),
                      SizedBox(height: 50),
                      Container(
                        height: 300,
                        child: Expanded(
                          child: ListView.builder(
                              itemCount: namelitems.length,
                              itemBuilder: (BuildContext ctxt, int index) {
                                return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Column(
                                        children: [
                                          Text('ชื่อรายการ'),
                                          Text(namelitems[index]),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 50,
                                        height: 80,
                                      ),
                                      Column(
                                        children: [
                                          Text('ราคา'),
                                          Text(pricelitems[index]),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          IconButton(
                                              onPressed: () {
                                                removeItem(index);
                                                setState(() {});
                                              },
                                              icon: Icon(Icons.delete)),
                                        ],
                                      ),
                                    ]);
                              }),
                        ),
                      ),
                      SizedBox(height: 20),
                      namelitems.length > 0
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) => SimpleDialog(
                                                title: Text(
                                                    'คุณต้องการเพิ่มออเดอร์ใช่ไหม?'),
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child:
                                                              Text('ยกเลิก')),
                                                      TextButton(
                                                          onPressed: () {
                                                            addProductThread();
                                                            Navigator.pop(
                                                                context);
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "เพิ่มออร์เดอร์เรียบร้อยแล้ว",
                                                                toastLength: Toast
                                                                    .LENGTH_SHORT,
                                                                gravity:
                                                                    ToastGravity
                                                                        .BOTTOM,
                                                                timeInSecForIosWeb:
                                                                    1);
                                                          },
                                                          child: Text('ตกลง'))
                                                    ],
                                                  )
                                                ],
                                              ));
                                    },
                                    child: Text('ยืนยัน')),
                                SizedBox(
                                  width: 20,
                                ),
                                ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        namelitems = [];
                                        pricelitems = [];
                                      });
                                    },
                                    child: Text('ยกเลิก')),
                              ],
                            )
                          : Text('')
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget dialogAnother() => SimpleDialog(
        title: Text('สินค้า/บริการ อื่นๆ'),
        children: [nameForm(), priceForm(), loginButton()],
      );

  Widget loginButton() => Container(
        padding: EdgeInsets.all(10),
        child: ElevatedButton(
          onPressed: () {
            if (name == null ||
                name.isEmpty ||
                priceProduct == null ||
                priceProduct.isEmpty) {
              normalDialog(context, 'กรุณากรอกข้อมูลให้ครบถ้วน');
            } else {
              namelitems.add(nameProduct);
              pricelitems.add(priceProduct);
              Navigator.pop(context);
              readDataProduct(productModel);
            }
          },
          child: Text(
            'ยืนยัน',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

  Widget nameForm() => Container(
        padding: EdgeInsets.all(10),
        child: TextField(
          onChanged: (value) => nameProduct = value.trim(),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.production_quantity_limits_outlined),
            hintText: 'ชื่อสินค้า/บริการ',
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
          ),
        ),
      );
  Widget priceForm() => Container(
        padding: EdgeInsets.all(10),
        child: TextField(
          onChanged: (value) => priceProduct = value.trim(),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.price_change_outlined),
            hintText: 'ราคาสินค้า/บริการ',
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
          ),
        ),
      );

  Widget dialogAdd() => SimpleDialog(
        title: Text('ตารางสินค้าและบริการ'),
        children: [dataTable()],
      );

  Widget dataTable() => SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
              columnSpacing: 38.0,
              columns: [
                DataColumn(label: Text('ชื่อ')),
                DataColumn(label: Text('ราคา')),
                DataColumn(label: Text('ชนิด')),
                DataColumn(label: Text('')),
              ],
              rows: productList
                  .map(
                    (productModel) => DataRow(cells: [
                      DataCell(
                        Container(width: 85, child: Text(productModel.name)),
                      ),
                      DataCell(
                        Text(productModel.price),
                      ),
                      DataCell(
                        Text(productModel.catalogName.toUpperCase()),
                      ),
                      DataCell(ElevatedButton(
                          onPressed: () {
                            namelitems.add(productModel.name);
                            pricelitems.add(productModel.price);
                            eCtrl.clear();
                            setState(() {});
                          },
                          child: Text('เลือก')))
                    ]),
                  )
                  .toList()),
        ),
      );
}
