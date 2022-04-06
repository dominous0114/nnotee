import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nnotee/model/chat_model.dart';
import 'package:nnotee/model/store_model.dart';
import 'package:nnotee/model/strec_model.dart';
import 'package:nnotee/model/tracking.dart';
import 'package:nnotee/screen/store/resetpw_store.dart';
import 'package:nnotee/utility/banstore.dart';
import 'package:nnotee/utility/my_constant.dart';
import 'package:nnotee/utility/normal_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowChatFromrecStore extends StatefulWidget {
  StoreRecordModel storeRecordModel;
  ShowChatFromrecStore({Key key, this.storeRecordModel}) : super(key: key);

  @override
  _ShowChatFromrecStoreState createState() => _ShowChatFromrecStoreState();
}

class _ShowChatFromrecStoreState extends State<ShowChatFromrecStore> {
  var result;
  StoreRecordModel storeRecordModel;
  TrackModel checkModel;
  //ChatModel chatModel;
  List<ChatModel> chatList;
  int index;
  String idSt, usernameSt, content, pro;
  StoreModel storeModel;
  TextEditingController _ctrlMess = TextEditingController();
  @override
  void initState() {
    BanStore().readdataBan(context);
    storeRecordModel = widget.storeRecordModel;
    checkUser();
    super.initState();
  }

  Size screenSize() {
    return MediaQuery.of(context).size;
  }

  Future<Null> readDataStore() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.getString('idst');

    String url =
        '${MyConstant().domain}/mobile/getStoreWhereId.php?isAdd=true&id=$id';
    await Dio().get(url).then((value) {
      print('value = $value');
      var result = json.decode(value.data);
      for (var map in result) {
        setState(() {
          storeModel = StoreModel.fromJson(map);
        });
        print('name =====${storeModel.name}');
        print('pic =====${storeModel.pic}');
      }
    });
  }

  Future<Null> addChatThread() async {
    String url =
        '${MyConstant().domain}/mobile/addChat.php?isAdd=true&idCus=${storeRecordModel.id}&idStore=${storeRecordModel.storeId}';
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
        '${MyConstant().domain}/mobile/addChatDetail.php?isAdd=true&user_from=$usernameSt&user_to=${storeRecordModel.username}&content=$content&chatId=$pro';
    try {
      Response response = await Dio().get(url);
      print('res = $response');
      if (response.toString() == 'true') {
        sendNotificaionToCustomer(content);
        // print('คนส่ง : ${chatModel.storeName}');
        // print('คนรับ : ${chatModel.cusName}');
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

  // Future<Null> readDataCustomer() async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   String id = preferences.getString('idcus');

  //   String url =
  //       '${MyConstant().domain}/mobile/getCustomerWhereId.php?isAdd=true&id=$id';
  //   await Dio().get(url).then((value) {
  //     print('value = $value');
  //     var result = json.decode(value.data);
  //     for (var map in result) {
  //       setState(() {
  //         customerModel = CustomerModel.fromJson(map);
  //       });
  //       print('name =${customerModel.name}');
  //     }
  //   });
  // }

  Future<List<dynamic>> readDataChat(int value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    usernameSt = preferences.getString('usernamest');
    String url =
        '${MyConstant().domain}/mobile/getChatDetail_st.php?isAdd=true&userCus=${storeRecordModel.username}&userStore=$usernameSt';
    await Dio().get(url).then((value) {
      result = json.decode(value.data);
      print('^^^^^^^^^^^^^^^^^^^^^$result');
    });
    return result;
  }

  Future<Null> sendNotificaionToCustomer(String content) async {
    String urlSendToken =
        '${MyConstant().domain}/mobile/apiNotification.php?isAdd=true&token=${storeRecordModel.token}&title=${storeModel.name}&body=$content';
    await Dio().get(urlSendToken).then((value) => null);
    print('++++++++++++++++++++++++++++++++++++++++$urlSendToken');
  }

  Future<Null> checkUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      idSt = preferences.getString('idst');
      usernameSt = preferences.getString('usernamest');
      // print('userFrom = $usernameCus');
      // print('userTo = ${customerRecordModel.username}');
    });
    String url =
        '${MyConstant().domain}/mobile/CheckChatWhereId.php?isAdd=true&idCus=${storeRecordModel.id}&idStore=$idSt';
    print('###########################################$url');

    try {
      Response response = await Dio().get(url);
      print('res = $response');
      if (response.toString() == 'null') {
        addChatThread();
        readDataStore();
        modelChat(idSt);
      } else {
        readDataStore();
        modelChat(idSt);
      }
    } catch (e) {}
  }

  Future<Null> modelChat(String idSt) async {
    String url =
        '${MyConstant().domain}/mobile/CheckChatWhereId.php?isAdd=true&idCus=${storeRecordModel.id}&idStore=$idSt';
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
          'คุณ ${storeRecordModel.name}',
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
                            return username == usernameSt
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
                                                  '${storeModel.pic}'),
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
                                                  '${storeRecordModel.pic}'),
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
