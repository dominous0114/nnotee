import 'package:flutter/material.dart';
import 'package:nnotee/Services/productServices.dart';
import 'package:nnotee/model/product.dart';
import 'package:nnotee/model/store_model.dart';
import 'package:nnotee/utility/my_style.dart';

class AboutProduct extends StatefulWidget {
  final StoreModel storeModel;
  const AboutProduct({Key key, this.storeModel}) : super(key: key);

  @override
  _AboutProductState createState() => _AboutProductState();
}

class _AboutProductState extends State<AboutProduct> {
  StoreModel storeModel;
  int value = 1, productLength;
  List<ProductModel> productList;
  bool loading;
  String storeId, name, price, news, idpd;
  ProductModel productModel;

  @override
  void initState() {
    storeModel = widget.storeModel;
    loading = false;
    productList = [];
    readDataProduct(productModel);
    super.initState();
  }

  readDataProduct(ProductModel productModel) async {
    setState(() {
      storeId = storeModel.id;
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

  setvalues(ProductModel productModel) {
    idpd = productModel.id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
              child: Column(
            children: [
              loading == false
                  ? LinearProgressIndicator()
                  : productLength != 0
                      ? dataTable()
                      : Column(
                          children: [
                            Image.asset(
                              'images/hello.png',
                              scale: 1.5,
                            ),
                            Text(
                              'ยังไม่มีรายละเอียดสินค้า',
                              style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black38),
                            )
                          ],
                        ),
            ],
          )),
        ),
      ),
    );
  }

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
              ],
              rows: productList
                  .map(
                    (productModel) => DataRow(cells: [
                      DataCell(
                        Container(width: 85, child: Text(productModel.name)),
                      ),
                      DataCell(Text(productModel.price)),
                      DataCell(
                        Text(productModel.catalogName.toUpperCase()),
                      ),
                    ]),
                  )
                  .toList()),
        ),
      );
}
