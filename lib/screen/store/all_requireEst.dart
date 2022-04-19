import 'package:flutter/material.dart';
//import 'package:nnotee/screen/store/profile_store.dart';
import 'package:nnotee/utility/banstore.dart';
import 'package:nnotee/widget/store/allEst.dart';
import 'package:nnotee/widget/store/allRequire.dart';

class AllRequireEsSceen extends StatefulWidget {
  @override
  _AllRequireEsSceenState createState() => _AllRequireEsSceenState();
}

class _AllRequireEsSceenState extends State<AllRequireEsSceen> {
  int pageIndex = 0;
  List<Widget> pageList = <Widget>[
    AllEst(),
    AllRequire(),
  ];
  @override
  void initState() {
    BanStore().readdataBan(context);
    super.initState();
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
          'รายการความต้องการของลูกค้า',
          style: TextStyle(color: Colors.black38),
        ),
      ),
      body: pageList[pageIndex],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: pageIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (value) {
            setState(() {
              pageIndex = value;
            });
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.checklist), label: "เสนอราคา"),
            BottomNavigationBarItem(
                icon: Icon(Icons.checklist), label: "รับข้อเสนอ"),
          ]),
    );
  }
}
