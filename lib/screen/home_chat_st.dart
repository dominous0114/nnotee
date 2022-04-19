import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:nnotee/model/chat_model.dart';
//import 'package:nnotee/screen/customer/show_chat.dart';
import 'package:nnotee/screen/store/show_chat_st.dart';
import 'package:nnotee/utility/banstore.dart';
import 'package:nnotee/utility/my_constant.dart';
//import 'package:nnotee/utility/my_style.dart';
//import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CusChat extends StatefulWidget {
  const CusChat({Key key}) : super(key: key);

  @override
  _CusChatState createState() => _CusChatState();
}

class _CusChatState extends State<CusChat> {
  var chats = [];
  @override
  void initState() {
    BanStore().readdataBan(context);
    super.initState();
  }

  Future<List<dynamic>> readDataChat(int value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.getString('idst');
    print('id=$id');
    var result;

    String url =
        '${MyConstant().domain}/mobile/getChat_st.php?isAdd=true&store_id=$id';
    await Dio().get(url).then((value) {
      print('value = $value');
      result = json.decode(value.data);
      print('result =$result');
      //for (var map in result) {
      // setState(() {
      //   Chat chat = Chat.fromJson(map);
      //   print(chat);
      //   chats.add(chat);
      // });
      //print('name =${storeModel.name}');
      //}
    });
    return result;
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
                                  lst[index]['customerPic'].toString()),
                              backgroundColor: Colors.transparent,
                            ),
                            title: Text(lst[index]['customerName'].toString()),
                            subtitle:
                                Text(lst[index]['customerTel'].toString()),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ShowChatStore(
                                            chatModel: ChatModel(
                                              lst[index]['id'].toString(),
                                              lst[index]['storeName']
                                                  .toString(),
                                              lst[index]['customerName']
                                                  .toString(),
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
                                              lst[index]['customer_token']
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
                              print(
                                  "*************************************************${lst[index]['customerName']}");
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
                            'ยังไม่มีรายข้อความ',
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
