import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:nnotee/model/chat_model.dart';
import 'package:nnotee/model/store_model.dart';
//import 'package:nnotee/screen/customer/show_chat.dart';
import 'package:nnotee/screen/customer/show_chatfromlist.dart';
//import 'package:nnotee/screen/store/resetpw_store.dart';
import 'package:nnotee/utility/my_constant.dart';
//import 'package:nnotee/utility/my_style.dart';
//import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StChat extends StatefulWidget {
  @override
  _StChatState createState() => _StChatState();
}

class _StChatState extends State<StChat> {
  var chats = [];
  StoreModel model;

  @override
  void initState() {
    readStoreFromDistance();
    super.initState();
  }

  Future<List<dynamic>> readDataChat(int value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.getString('idcus');
    var result;

    String url =
        '${MyConstant().domain}/mobile/getChat.php?isAdd=true&customer_id=$id';
    await Dio().get(url).then((value) {
      print('value = $value');
      result = json.decode(value.data);
      print('result =$result');
    });
    return result;
  }

  Future<LocationData> findLocationData() async {
    Location location = Location();
    try {
      return location.getLocation();
    } catch (e) {
      return null;
    }
  }

  Future<Null> readStoreFromDistance() async {
    LocationData locationData = await findLocationData();
    String url =
        '${MyConstant().domain}/mobile/getStore.php?isAdd=true&isType=distance&latitude=${locationData.latitude}&longitude=${locationData.longitude}';
    print('${locationData.latitude},${locationData.longitude}');
    await Dio().get(url).then((value) {
      print('valuestore = $value');
      var result = json.decode(value.data);
      for (var map in result) {
        model = StoreModel.fromJson(map);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'แชท',
            style: TextStyle(color: Colors.black38),
          ),
        ),
        body: StreamBuilder(
          stream: _stream(),
          builder: (context, snap) {
            print(snap.hasData);
            if (snap.hasData) {
              print(snap.data);
              var temp = snap.data as Future<List<dynamic>>;
              return FutureBuilder(
                future: temp,
                builder: (context, snap) {
                  List<dynamic> lst = snap.data;
                  if (lst != null) {
                    return Container(
                      child: ListView.builder(
                        itemCount: lst.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 30.0,
                              backgroundImage: NetworkImage(
                                  lst[index]['storePic'].toString()),
                              backgroundColor: Colors.transparent,
                            ),
                            title: Text(lst[index]['storeName'].toString()),
                            subtitle: Text(lst[index]['storeTel'].toString()),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ShowChatFromList(
                                            chatModel: ChatModel(
                                              lst[index]['id'].toString(),
                                              lst[index]['storeName']
                                                  .toString(),
                                              lst[index]['cusName'].toString(),
                                              lst[index]['customerPic']
                                                  .toString(),
                                              lst[index]['storePic'].toString(),
                                              lst[index]['store_id'].toString(),
                                              lst[index]['customer_id']
                                                  .toString(),
                                              lst[index]['store_username']
                                                  .toString(),
                                              lst[index]['customer_username']
                                                  .toString(),
                                              lst[index]['customer_toen']
                                                  .toString(),
                                              lst[index]['store_token']
                                                  .toString(),
                                              lst[index]['customerTel']
                                                  .toString(),
                                              lst[index]['storeTel'].toString(),
                                            ),
                                          )));
                              print(
                                  "*************************************************${lst[index]['store_username']}");
                            },
                          );
                        },
                      ),
                    );
                  } else {
                    return Center(
                      child: Column(
                        children: <Widget>[
                          Image.asset(
                            'images/hello.png',
                            scale: 1.5,
                          ),
                          Text(
                            'ยังไม่มีข้อความ',
                            style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w600,
                                color: Colors.black38),
                          )
                        ],
                      ),
                    );
                  }
                },
              );
            } else {
              return Container();
            }
          },
        ));
  }

  Stream<Future<List<dynamic>>> _stream() {
    Duration interval = Duration(seconds: 1);
    Stream<Future<List<dynamic>>> stream =
        Stream<Future<List<dynamic>>>.periodic(interval, readDataChat);
    return stream;
  }
}
