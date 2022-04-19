import 'package:flutter/material.dart';
import 'package:nnotee/model/require_est_model.dart';
import 'package:nnotee/widget/customer/about_requirement_cs.dart';
//import 'package:nnotee/widget/customer/about_tracking.dart';

class ShowRequire extends StatefulWidget {
  final RequireEstModel requireModel;
  ShowRequire({Key key, this.requireModel}) : super(key: key);

  @override
  _ShowRequireState createState() => _ShowRequireState();
}

class _ShowRequireState extends State<ShowRequire> {
  RequireEstModel requireModel;
  List<Widget> listWidgets = [];

  @override
  void initState() {
    super.initState();
    requireModel = widget.requireModel;
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
          title: Text('รายละเอียดร้านที่รับข้อเสนอ',
              style: TextStyle(color: Colors.black38)),
        ),
        body: AboutRequire(requireModel: requireModel));
  }
}
