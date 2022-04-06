import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nnotee/Services/productServices.dart';
import 'package:nnotee/model/product.dart';
import 'package:nnotee/utility/banstore.dart';
import 'package:nnotee/utility/my_constant.dart';
import 'package:nnotee/utility/my_style.dart';
import 'package:nnotee/utility/normal_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductStore extends StatefulWidget {
  @override
  _ProductStoreState createState() => _ProductStoreState();
}

class _ProductStoreState extends State<ProductStore> {
  String dropdownValue = 'Product';
  int value = 1, productLength;
  List<ProductModel> productList;
  bool loading, edit;
  String storeId, name, price, news, idpd, catalogName;
  ProductModel productModel;
  SharedPreferences preferences;

  @override
  void initState() {
    BanStore().readdataBan(context);
    loading = false;
    edit = false;
    productList = [];
    readDataProduct(productModel);
    super.initState();
  }

  readDataProduct(ProductModel productModel) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      storeId = preferences.getString('idst');
    });
    ProductServices.readDataProduct(storeId).then((productModel) {
      setState(() {
        loading = true;
        productList = productModel;
        productLength = productModel.length;
      });
      print('StoreId: $storeId');
      print('Product: ${productModel.length}');
    });
  }

  Future<Null> editProduct() async {
    print('$idpd,$name,$price');
    String url =
        '${MyConstant().domain}/mobile/editProduct.php?isAdd=true&id=$idpd&name=$name&price=$price';

    Response response = await Dio().get(url);
    if (response.toString() == 'true') {
      readDataProduct(productModel);
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg: "แก้ไขสำเร็จ",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1);
    } else {
      normalDialog(context, 'ไม่สามารถแก้ไขได้');
    }
  }

  setvalues(ProductModel productModel) {
    idpd = productModel.id;
    name = productModel.name;
    price = productModel.price;
    catalogName = productModel.catalogName;
  }

  Future<Null> deleteThread() async {
    String url =
        '${MyConstant().domain}/mobile/deleteProduct.php?isAdd=true&idpd="$idpd"';
    try {
      Response response = await Dio().get(url);
      print('res = $response');
      if (response.toString() == 'true') {
        readDataProduct(productModel);
        Navigator.pop(context);
        Fluttertoast.showToast(
            msg: "ลบสำเร็จ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1);
      } else {
        normalDialog(context, 'ไม่สามารถลบได้');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<Null> addProductThread() async {
    String url =
        '${MyConstant().domain}/mobile/addProduct.php?isAdd=true&catalogid=$value&storeid=$storeId&name=$name&price=$price';
    try {
      Response response = await Dio().get(url);
      print('res = $response');
      if (response.toString() == 'true') {
        readDataProduct(productModel);
        Navigator.pop(context);
        Fluttertoast.showToast(
            msg: "เพิ่มสำเร็จ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1);
      } else {
        normalDialog(context, 'ไม่สามารถเพิ่มสินค้าได้');
      }
    } catch (e) {
      print(e);
    }
  }

  onAddPressed() async {
    if (dropdownValue == 'Select' ||
        name == null ||
        name.isEmpty ||
        price == null ||
        price.isEmpty) {
      normalDialog(context, 'ตรวจสอบข้อมูลให้ถูกต้อง');
    } else {
      condition();
      addProductThread();
    }
  }

  onEditPressed() async {
    editProduct();
    clearValue();
  }

  clearValue() {
    name = null;
    price = null;
    edit = false;
    setState(() {});
  }

  condition() {
    if (news == 'Product') {
      value = 1;
    } else if (news == 'Service') {
      value = 2;
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
          'รายการสินค้า',
          style: TextStyle(color: Colors.black38),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
            child: loading != false
                ? Center(
                    child: Column(
                      children: <Widget>[
                        productLength != 0 ? dataTable() : noProduct(),
                      ],
                    ),
                  )
                : LinearProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.black,
        onPressed: () {
          clearValue();
          showDialog(context: context, builder: (context) => dialogAdd());
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget noProduct() => Column(
        children: <Widget>[
          Image.asset(
            'images/hello.png',
            scale: 1.5,
          ),
          Text(
            'ยังไม่มีรายการสินค้า',
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                color: Colors.black38),
          )
        ],
      );

  Widget dataTable() => SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
              columnSpacing: 20.0,
              columns: [
                DataColumn(label: Text('ชื่อ')),
                DataColumn(label: Text('ราคา')),
                DataColumn(label: Text('ชนิด')),
                DataColumn(label: Text('')),
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
                      editAction(productModel),
                      deleteAction(productModel),
                    ]),
                  )
                  .toList()),
        ),
      );
  DataCell editAction(ProductModel productModel) {
    return DataCell(IconButton(
        onPressed: () {
          setState(() {
            edit = true;
          });
          setvalues(productModel);
          showDialog(context: context, builder: (context) => dialogEdit());
        },
        icon: Icon(Icons.edit)));
  }

  DataCell deleteAction(ProductModel productModel) {
    return DataCell(IconButton(
        onPressed: () {
          setvalues(productModel);
          showDialog(
              context: context,
              builder: (context) => SimpleDialog(
                    title: Text('คุณต้องการลบใช่ไหม ?'),
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('ไม่ใช่')),
                          TextButton(
                              onPressed: () {
                                deleteThread();
                              },
                              child: Text('ใช่')),
                        ],
                      )
                    ],
                  ));
        },
        icon: Icon(Icons.delete)));
  }

  Widget dialogEdit() => AlertDialog(
        actions: [nameForm(), priceForm(), addButton()],
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Row(
              children: [
                Text('แก้ไขสินค้า',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                SizedBox(
                  width: 20.0,
                ),
                Text('ชนิด:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(
                  width: 10.0,
                ),
                Text('$catalogName')
              ],
            );
          },
        ),
      );

  Widget dialogAdd() => AlertDialog(
        actions: [nameForm(), priceForm(), addButton()],
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Row(
              children: [
                Text('เพิ่มสินค้า',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                SizedBox(
                  width: 20.0,
                ),
                DropdownButton<String>(
                  value: dropdownValue,
                  onChanged: (String newValue) {
                    setState(() {
                      dropdownValue = newValue;
                      news = newValue;
                    });
                    print('object= $news');
                  },
                  items: <String>['Product', 'Service']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            );
          },
        ),
      );

  Widget nameForm() => Container(
        padding: EdgeInsets.all(10),
        child: TextFormField(
          onChanged: (value) => name = value.trim(),
          initialValue: name,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.production_quantity_limits_outlined),
            hintText: 'ชื่อสินค้า/บริการ',
            labelText: 'ชื่อสินค้า/บริการ',
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
          ),
        ),
      );

  Widget priceForm() => Container(
        padding: EdgeInsets.all(10.0),
        child: TextFormField(
          keyboardType: TextInputType.number,
          onChanged: (value) => price = value.trim(),
          initialValue: price,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.price_change_outlined),
            hintText: 'ราคาสินค้า/บริการ',
            labelText: 'ราคาสินค้า/บริการ',
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
          ),
        ),
      );

  Widget addButton() => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.all(10.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.red),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'ยกเลิก',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.green),
              onPressed: () async {
                if (name == null ||
                    name.isEmpty ||
                    price == null ||
                    price.isEmpty) {
                  normalDialog(context, 'กรุณากรอกข้อมูลให้ครบถ้วน');
                } else {
                  edit == false ? onAddPressed() : onEditPressed();
                }
              },
              child: Text(
                edit == false ? 'เพิ่มสินค้า' : 'แก้ไขสินค้า',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      );
}
