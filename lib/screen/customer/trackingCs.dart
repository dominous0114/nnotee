
import 'package:flutter/material.dart';

import 'package:nnotee/model/customer_model.dart';

import 'package:nnotee/widget/customer/tracking_customer.dart';
import 'package:shared_preferences/shared_preferences.dart';


class CsTracking extends StatefulWidget {
  @override
  _CsTrackingState createState() => _CsTrackingState();
}

class _CsTrackingState extends State<CsTracking> {
  String storeId;
  String user;
  @override
  void initState() {
    super.initState();
  }

 
  Future<Null> routeToService(
      Widget myWidget, CustomerModel customerModel) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('idcus', customerModel.id);
    preferences.setString('usernamecus', customerModel.username);
    MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => myWidget,
    );
    Navigator.push(context, route);
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
          'การติดตามการซ่อม',
          style: TextStyle(color: Colors.black38),
        ),
      ),
      body: TrackingCustomer()
    );
  }


}