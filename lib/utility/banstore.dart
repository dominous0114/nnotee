import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nnotee/model/store_model.dart';
import 'package:nnotee/utility/my_constant.dart';
import 'package:nnotee/utility/signout_process.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BanStore {
  Future<Null> readdataBan(BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.getString('idst');
    String username = preferences.getString('usernamest');
    StoreModel storeModel;
    String status;
    print(id);
    String url =
        '${MyConstant().domain}/mobile/getDataBan.php?isAdd=true&store_id=$id';
    await Dio().get(url).then((value) {
      print('url=$url');
      print('value = $value');
      var result = json.decode(value.data);
      for (var map in result) {
        storeModel = StoreModel.fromJson(map);
        status = storeModel.status;
      }
      if (status == '2') {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => alertBan(context, username));
      }
    });
  }

  Future<Null> tokenClear(String username) async {
    String urlCustomerToken =
        '${MyConstant().domain}/mobile/editTokenSt.php?isAdd=true&token=&username=$username';
    print('urltokenclear = $urlCustomerToken');
    await Dio().get(urlCustomerToken);
  }

  Widget alertBan(BuildContext context, String username) => SimpleDialog(
        title: Text('ร้านของท่านถูกแบนกรุณาออกจากระบบ'),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    signOutProcess(context);
                    tokenClear(username);
                  },
                  child: Text('ตกลง')),
            ],
          )
        ],
      );
  BanStore();
}
