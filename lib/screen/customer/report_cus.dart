import 'package:flutter/material.dart';
import 'package:nnotee/model/store_model.dart';

class ReportFromCustomer extends StatefulWidget {
  final StoreModel storeModel;
  const ReportFromCustomer({Key key, this.storeModel}) : super(key: key);

  @override
  _ReportFromCustomerState createState() => _ReportFromCustomerState();
}

class _ReportFromCustomerState extends State<ReportFromCustomer> {
  StoreModel storeModel;
  @override
  void initState() {
    storeModel = widget.storeModel;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'รายงานร้านซ่อม ${storeModel.name}',
          style: TextStyle(color: Colors.black38),
        ),
        leading: IconButton(
            color: Colors.black38,
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new_outlined,
            )),
      ),
    );
  }
}
