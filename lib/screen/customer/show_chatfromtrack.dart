import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nnotee/model/chat_model.dart';
import 'package:nnotee/model/customer_model.dart';
import 'package:nnotee/model/store_order.dart';
import 'package:nnotee/model/tracking.dart';
import 'package:nnotee/utility/my_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowChatFromTracking extends StatefulWidget {
  final OrderModel orderModel;
  const ShowChatFromTracking({Key key, this.orderModel}) : super(key: key);

  @override
  _ShowChatFromTrackingState createState() => _ShowChatFromTrackingState();
}

var result;
int index;
String idCus, usernameCus, content, pro;
TextEditingController _ctrlMess = TextEditingController();
OrderModel orderModel;
TrackModel checkModel;
CustomerModel customerModel;
ChatModel chatModel;
List<ChatModel> chatList;

class _ShowChatFromTrackingState extends State<ShowChatFromTracking> {
  @override
  void initState() {
    orderModel = widget.orderModel;
    checkUser();
    super.initState();
  }

  Size screenSize() {
    return MediaQuery.of(context).size;
  }

  Future<Null> addChatThread() async {
    String url =
        '${MyConstant().domain}/mobile/addChat.php?isAdd=true&idCus=$idCus&idStore=${orderModel.storeId}';
    try {
      Response response = await Dio().get(url);
      print('res = $response');
      if (response.toString() == 'true') {
        print('เพิ่มสำเร็จ');
        checkUser();
      } else {
        print('เพิ่มไม่สำเร็จ');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<Null> addChatDetailThread() async {
    String url =
        '${MyConstant().domain}/mobile/addChatDetail.php?isAdd=true&user_from=$usernameCus&user_to=${orderModel.storeUsername}&content=$content&chatId=$pro';
    try {
      Response response = await Dio().get(url);
      print('res = $response');
      if (response.toString() == 'true') {
        sendNotificaionToStore(content, usernameCus);
        // print('คนรับ : ${customerRecordModel.username}');
        // print('คนส่ง : $usernameCus');
        print(content);
        print('เพิ่มสำเร็จ');
      } else {
        print('เพิ่มไม่สำเร็จ');
      }
      print(url);
    } catch (e) {
      print(e);
    }
  }

  Future<Null> readDataCustomer() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.getString('idcus');

    String url =
        '${MyConstant().domain}/mobile/getCustomerWhereId.php?isAdd=true&id=$id';
    await Dio().get(url).then((value) {
      print('value = $value');
      var result = json.decode(value.data);
      for (var map in result) {
        setState(() {
          customerModel = CustomerModel.fromJson(map);
        });
        print('name =${customerModel.name}');
      }
    });
  }

  Future<Null> sendNotificaionToStore(
      String content, String usernameCus) async {
    String urlSendToken =
        '${MyConstant().domain}/mobile/apiNotification.php?isAdd=true&token=${chatModel.storeToken}&title=$usernameCus&body=$content';
    await Dio().get(urlSendToken).then((value) => null);
    print('++++++++++++++++++++++++++++++++++++++++$urlSendToken');
  }

  Future<List<dynamic>> readDataChat(int value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    usernameCus = preferences.getString('usernamecus');
    String url =
        '${MyConstant().domain}/mobile/getChatDetail.php?isAdd=true&userCus=$usernameCus&userStore=${orderModel.storeUsername}';
    await Dio().get(url).then((value) {
      result = json.decode(value.data);
    });
    return result;
  }

  Future<Null> checkUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      idCus = preferences.getString('idcus');
      usernameCus = preferences.getString('usernamecus');
      // print('userFrom = $usernameCus');
      // print('userTo = ${customerRecordModel.username}');
    });
    String url =
        '${MyConstant().domain}/mobile/CheckChatWhereId.php?isAdd=true&idCus=$idCus&idStore=${orderModel.storeId}';

    try {
      Response response = await Dio().get(url);
      print('res = $response');
      if (response.toString() == 'null') {
        addChatThread();
        readDataCustomer();
        modelChat(idCus, usernameCus);
      } else {
        readDataCustomer();
        modelChat(idCus, usernameCus);
      }
    } catch (e) {}
  }

  Future<Null> modelChat(String idCus, String usernameCus) async {
    String url =
        '${MyConstant().domain}/mobile/CheckChatWhereId.php?isAdd=true&idCus=$idCus&idStore=${orderModel.storeId}';
    print('###########################################$url');

    try {
      await Dio().get(url).then((value) {
        print('value = $value');
        var result = json.decode(value.data);
        for (var map in result) {
          setState(() {
            checkModel = TrackModel.fromJson(map);
            pro = checkModel.id;
          });
          print('ChatId =${checkModel.id}');
        }
      });
    } catch (e) {}
  }

  Stream<Future<List<dynamic>>> _stream() {
    Duration interval = Duration(seconds: 1);
    Stream<Future<List<dynamic>>> stream =
        Stream<Future<List<dynamic>>>.periodic(interval, readDataChat);
    return stream;
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
          'ร้าน ${orderModel.storeName}',
          style: TextStyle(color: Colors.black38),
        ),
      ),
      body: StreamBuilder(
        initialData: null,
        stream: _stream(),
        builder: (context, snap) {
          if (snap.hasData) {
            var temp = snap.data as Future<List<dynamic>>;
            return Column(
              children: <Widget>[
                FutureBuilder(
                  future: temp,
                  builder: (context, snap) {
                    List<dynamic> lst = snap.data;
                    if (lst != null) {
                      return Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.all(20),
                          itemCount: lst.length,
                          itemBuilder: (context, index) {
                            var username = lst[index]['user_from'];
                            var mess = lst[index]['content'].toString();
                            var time = lst[index]['time'].toString();
                            return username == usernameCus
                                ? Column(
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.80,
                                          ),
                                          padding: EdgeInsets.all(10),
                                          margin: EdgeInsets.symmetric(
                                              vertical: 10),
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                spreadRadius: 2,
                                                blurRadius: 5,
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            mess,
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          Text(
                                            time,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black45,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  spreadRadius: 2,
                                                  blurRadius: 5,
                                                ),
                                              ],
                                            ),
                                            child: CircleAvatar(
                                              radius: 15,
                                              backgroundImage: NetworkImage(
                                                  '${customerModel.pic}'),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  )
                                : Column(
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.topLeft,
                                        child: Container(
                                          constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.80,
                                          ),
                                          padding: EdgeInsets.all(10),
                                          margin: EdgeInsets.symmetric(
                                              vertical: 10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                spreadRadius: 2,
                                                blurRadius: 5,
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            mess,
                                            style: TextStyle(
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  spreadRadius: 2,
                                                  blurRadius: 5,
                                                ),
                                              ],
                                            ),
                                            child: CircleAvatar(
                                              radius: 15,
                                              backgroundImage: NetworkImage(
                                                  '${orderModel.storePic}'),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            time,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black45,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  );
                          },
                        ),
                      );
                    } else {
                      return Spacer();
                    }
                  },
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  height: 70,
                  color: Colors.white,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _ctrlMess,
                          decoration: InputDecoration.collapsed(
                            hintText: 'กรอกข้อความตรงนี้',
                          ),
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                      IconButton(
                          icon: Icon(Icons.send),
                          iconSize: 25,
                          color: Theme.of(context).primaryColor,
                          onPressed: () async {
                            content = _ctrlMess.text.trim();
                            if (content.isNotEmpty) {
                              addChatDetailThread();
                              _ctrlMess.text = "";
                            } else {
                              print("empty");
                            }
                          }),
                    ],
                  ),
                )
              ],
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
