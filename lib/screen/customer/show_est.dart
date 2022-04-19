import 'package:flutter/material.dart';
import 'package:nnotee/model/require_est_model.dart';
import 'package:nnotee/widget/customer/about_est.dart';
//import 'package:nnotee/widget/customer/about_requirement_cs.dart';

class ShowEst extends StatefulWidget {
  final RequireEstModel estModel;
  ShowEst({Key key, this.estModel}) : super(key: key);

  @override
  _ShowEstState createState() => _ShowEstState();
}

class _ShowEstState extends State<ShowEst> {
  RequireEstModel estModel;
  List<Widget> listWidgets = [];

  @override
  void initState() {
    super.initState();
    estModel = widget.estModel;
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
          title: Text('รายละเอียดร้านที่เสนอราคา',
              style: TextStyle(color: Colors.black38)),
        ),
        body: AboutEst(estModel: estModel));
  }
}
