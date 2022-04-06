import 'package:flutter/material.dart';
import 'package:nnotee/screen/customer/edit_info_customer.dart';
import 'package:nnotee/utility/my_style.dart';

class InformationCustomer extends StatefulWidget {
  @override
  _InformationCustomerState createState() => _InformationCustomerState();
}

class _InformationCustomerState extends State<InformationCustomer> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        MyStyle().titleCenter(context, 'ข้อมูล'),
        editButton()
      ],
    );
  }

  Row editButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 16.0, bottom: 16.0),
              child: FloatingActionButton(
                child: Icon(Icons.edit),
                onPressed: () => routeToAppInfo(),
              ),
            )
          ],
        ),
      ],
    );
  }

  void routeToAppInfo() {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (context) => EditInfoCustomer(),
    );
    Navigator.push(context, materialPageRoute);
  }
}
