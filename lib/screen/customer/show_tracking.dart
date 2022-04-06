import 'package:flutter/material.dart';
import 'package:nnotee/model/store_order.dart';
import 'package:nnotee/widget/customer/about_tracking.dart';

class ShowTracking extends StatefulWidget {
  final OrderModel orderModel;
  ShowTracking({Key key, this.orderModel}) : super(key: key);

  @override
  _ShowTrackingState createState() => _ShowTrackingState();
}

class _ShowTrackingState extends State<ShowTracking> {
  OrderModel orderModel;
  List<Widget> listWidgets = [];

  @override
  void initState() {
    super.initState();
    orderModel = widget.orderModel;
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
        title: Text('รายละเอียดการติดตามสถานะ',
          style: TextStyle(color: Colors.black38)),
      ),
      body: AboutTracking(orderModel: orderModel)
    );
  }


}
